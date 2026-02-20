#!/usr/bin/env python3
"""
Zendesk CLI for ticket management.
Usage: python zendesk-cli.py <command> [options]

Commands:
  test - Test API connection
  tickets [--status open|pending|solved] [--limit N]
  ticket <id> - Get ticket details
  reply <id> --message "text" - Add reply
"""

import argparse
import base64
import json
import os
import sys
import urllib.request
import urllib.error

SUBDOMAIN = os.environ.get("ZENDESK_SUBDOMAIN", "")
EMAIL = os.environ.get("ZENDESK_EMAIL", "")
API_TOKEN = os.environ.get("ZENDESK_API_TOKEN", "")

BASE_URL = f"https://{SUBDOMAIN}.zendesk.com/api/v2"


def api_request(method: str, endpoint: str, data: dict = None) -> dict:
    """Make authenticated API request to Zendesk."""
    url = f"{BASE_URL}/{endpoint}"
    
    # Basic auth: email/token:api_token
    auth_str = f"{EMAIL}/token:{API_TOKEN}"
    auth_bytes = base64.b64encode(auth_str.encode()).decode()
    
    headers = {
        "Authorization": f"Basic {auth_bytes}",
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


def test_connection():
    """Test API connection."""
    try:
        result = api_request("GET", "users/me.json")
        user = result.get("user", {})
        print("✅ Zendesk API connection successful")
        print(f"   User: {user.get('name', 'Unknown')}")
        print(f"   Role: {user.get('role', 'Unknown')}")
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        sys.exit(1)


def list_tickets(status: str = None, limit: int = 10):
    """List tickets."""
    query = f"tickets.json?per_page={limit}"
    if status:
        query = f"search.json?query=type:ticket status:{status}&per_page={limit}"
    
    result = api_request("GET", query)
    tickets = result.get("tickets", result.get("results", []))
    
    for t in tickets:
        status_icon = {"open": "🔴", "pending": "🟡", "solved": "🟢"}.get(t.get("status"), "⚪")
        print(f"[{t['id']}] {status_icon} {t.get('subject', 'No subject')[:50]}")


def get_ticket(ticket_id: int):
    """Get ticket details."""
    result = api_request("GET", f"tickets/{ticket_id}.json")
    t = result.get("ticket", {})
    
    print(f"Ticket #{t['id']}: {t.get('subject', 'No subject')}")
    print(f"Status: {t.get('status')} | Priority: {t.get('priority', 'normal')}")
    print(f"Created: {t.get('created_at', '')[:10]}")
    print(f"\nDescription:\n{t.get('description', 'No description')[:500]}")


def reply_ticket(ticket_id: int, message: str):
    """Add public reply to ticket."""
    data = {
        "ticket": {
            "comment": {
                "body": message,
                "public": True
            }
        }
    }
    api_request("PUT", f"tickets/{ticket_id}.json", data)
    print(f"✅ Reply added to ticket #{ticket_id}")


def main():
    if not all([SUBDOMAIN, EMAIL, API_TOKEN]):
        print("❌ Required environment variables not set:", file=sys.stderr)
        print("   ZENDESK_SUBDOMAIN, ZENDESK_EMAIL, ZENDESK_API_TOKEN")
        sys.exit(1)
    
    parser = argparse.ArgumentParser(description="Zendesk Ticket CLI")
    subparsers = parser.add_subparsers(dest="command")
    
    subparsers.add_parser("test")
    
    tickets_parser = subparsers.add_parser("tickets")
    tickets_parser.add_argument("--status", choices=["open", "pending", "solved"])
    tickets_parser.add_argument("--limit", type=int, default=10)
    
    ticket_parser = subparsers.add_parser("ticket")
    ticket_parser.add_argument("id", type=int)
    
    reply_parser = subparsers.add_parser("reply")
    reply_parser.add_argument("id", type=int)
    reply_parser.add_argument("--message", required=True)
    
    args = parser.parse_args()
    
    if args.command == "test":
        test_connection()
    elif args.command == "tickets":
        list_tickets(args.status, args.limit)
    elif args.command == "ticket":
        get_ticket(args.id)
    elif args.command == "reply":
        reply_ticket(args.id, args.message)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
