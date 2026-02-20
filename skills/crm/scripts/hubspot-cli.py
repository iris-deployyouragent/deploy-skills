#!/usr/bin/env python3
"""
HubSpot CLI wrapper for common CRM operations.
Usage: python hubspot-cli.py <command> [options]

Commands:
  contacts list [--limit N]
  contacts search --query "email:john@example.com"
  contacts create --email EMAIL --firstname NAME --company COMPANY
  deals list [--limit N]
  deals create --name NAME --amount AMOUNT --stage STAGE
  test - Test API connection
"""

import argparse
import json
import os
import sys
import urllib.request
import urllib.error

API_KEY = os.environ.get("HUBSPOT_API_KEY")
BASE_URL = "https://api.hubapi.com"


def api_request(method: str, endpoint: str, data: dict = None) -> dict:
    """Make authenticated API request to HubSpot."""
    url = f"{BASE_URL}{endpoint}"
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json",
    }
    
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode())
    except urllib.error.HTTPError as e:
        error_body = e.read().decode() if e.fp else ""
        print(f"API Error {e.code}: {error_body}", file=sys.stderr)
        sys.exit(1)


def list_contacts(limit: int = 10):
    """List recent contacts."""
    result = api_request("GET", f"/crm/v3/objects/contacts?limit={limit}&properties=email,firstname,lastname,company")
    for contact in result.get("results", []):
        props = contact.get("properties", {})
        print(f"[{contact['id']}] {props.get('firstname', '')} {props.get('lastname', '')} <{props.get('email', 'no email')}> - {props.get('company', 'N/A')}")


def search_contacts(query: str):
    """Search contacts."""
    # Parse simple query like "email:john@example.com"
    filters = []
    for part in query.split():
        if ":" in part:
            key, value = part.split(":", 1)
            filters.append({"propertyName": key, "operator": "CONTAINS_TOKEN", "value": value})
    
    data = {
        "filterGroups": [{"filters": filters}] if filters else [],
        "properties": ["email", "firstname", "lastname", "company"]
    }
    result = api_request("POST", "/crm/v3/objects/contacts/search", data)
    for contact in result.get("results", []):
        props = contact.get("properties", {})
        print(f"[{contact['id']}] {props.get('firstname', '')} {props.get('lastname', '')} <{props.get('email', '')}>")


def create_contact(email: str, firstname: str = "", company: str = ""):
    """Create a new contact."""
    data = {
        "properties": {
            "email": email,
            "firstname": firstname,
            "company": company,
        }
    }
    result = api_request("POST", "/crm/v3/objects/contacts", data)
    print(f"✅ Created contact: {result['id']}")


def list_deals(limit: int = 10):
    """List recent deals."""
    result = api_request("GET", f"/crm/v3/objects/deals?limit={limit}&properties=dealname,amount,dealstage,closedate")
    for deal in result.get("results", []):
        props = deal.get("properties", {})
        amount = props.get("amount", "0")
        print(f"[{deal['id']}] {props.get('dealname', 'Untitled')} - ${amount} - {props.get('dealstage', 'unknown')}")


def create_deal(name: str, amount: str, stage: str = "appointmentscheduled"):
    """Create a new deal."""
    data = {
        "properties": {
            "dealname": name,
            "amount": amount,
            "dealstage": stage,
        }
    }
    result = api_request("POST", "/crm/v3/objects/deals", data)
    print(f"✅ Created deal: {result['id']}")


def test_connection():
    """Test API connection."""
    try:
        result = api_request("GET", "/crm/v3/objects/contacts?limit=1")
        print("✅ HubSpot API connection successful")
        print(f"   Found {result.get('total', 0)} total contacts")
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        sys.exit(1)


def main():
    if not API_KEY:
        print("❌ HUBSPOT_API_KEY environment variable not set", file=sys.stderr)
        sys.exit(1)
    
    parser = argparse.ArgumentParser(description="HubSpot CRM CLI")
    subparsers = parser.add_subparsers(dest="command")
    
    # Contacts
    contacts_parser = subparsers.add_parser("contacts")
    contacts_sub = contacts_parser.add_subparsers(dest="action")
    
    list_parser = contacts_sub.add_parser("list")
    list_parser.add_argument("--limit", type=int, default=10)
    
    search_parser = contacts_sub.add_parser("search")
    search_parser.add_argument("--query", required=True)
    
    create_parser = contacts_sub.add_parser("create")
    create_parser.add_argument("--email", required=True)
    create_parser.add_argument("--firstname", default="")
    create_parser.add_argument("--company", default="")
    
    # Deals
    deals_parser = subparsers.add_parser("deals")
    deals_sub = deals_parser.add_subparsers(dest="action")
    
    deals_list = deals_sub.add_parser("list")
    deals_list.add_argument("--limit", type=int, default=10)
    
    deals_create = deals_sub.add_parser("create")
    deals_create.add_argument("--name", required=True)
    deals_create.add_argument("--amount", required=True)
    deals_create.add_argument("--stage", default="appointmentscheduled")
    
    # Test
    subparsers.add_parser("test")
    
    args = parser.parse_args()
    
    if args.command == "test":
        test_connection()
    elif args.command == "contacts":
        if args.action == "list":
            list_contacts(args.limit)
        elif args.action == "search":
            search_contacts(args.query)
        elif args.action == "create":
            create_contact(args.email, args.firstname, args.company)
    elif args.command == "deals":
        if args.action == "list":
            list_deals(args.limit)
        elif args.action == "create":
            create_deal(args.name, args.amount, args.stage)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
