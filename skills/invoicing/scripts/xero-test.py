#!/usr/bin/env python3
"""
Xero API connection test and basic operations.
Usage: python xero-test.py <command>

Commands:
  test - Test API connection
  invoices - List recent invoices
  contacts - List contacts
"""

import json
import os
import sys
import urllib.request
import urllib.error

ACCESS_TOKEN = os.environ.get("XERO_ACCESS_TOKEN")
TENANT_ID = os.environ.get("XERO_TENANT_ID")
BASE_URL = "https://api.xero.com/api.xro/2.0"


def api_request(endpoint: str) -> dict:
    """Make authenticated API request to Xero."""
    url = f"{BASE_URL}/{endpoint}"
    headers = {
        "Authorization": f"Bearer {ACCESS_TOKEN}",
        "Xero-tenant-id": TENANT_ID,
        "Accept": "application/json",
    }
    
    req = urllib.request.Request(url, headers=headers)
    
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
        result = api_request("Organisation")
        org = result.get("Organisations", [{}])[0]
        print("✅ Xero API connection successful")
        print(f"   Organisation: {org.get('Name', 'Unknown')}")
        print(f"   Country: {org.get('CountryCode', 'Unknown')}")
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        sys.exit(1)


def list_invoices():
    """List recent invoices."""
    result = api_request("Invoices?page=1")
    invoices = result.get("Invoices", [])
    
    print(f"Found {len(invoices)} invoices:\n")
    for inv in invoices[:10]:
        status = inv.get("Status", "Unknown")
        total = inv.get("Total", 0)
        contact = inv.get("Contact", {}).get("Name", "Unknown")
        print(f"[{inv.get('InvoiceNumber', 'N/A')}] {contact} - ${total:.2f} ({status})")


def list_contacts():
    """List contacts."""
    result = api_request("Contacts?page=1")
    contacts = result.get("Contacts", [])
    
    print(f"Found {len(contacts)} contacts:\n")
    for c in contacts[:10]:
        email = c.get("EmailAddress", "no email")
        print(f"[{c.get('ContactID', '')[:8]}] {c.get('Name', 'Unknown')} <{email}>")


def main():
    if not ACCESS_TOKEN:
        print("❌ XERO_ACCESS_TOKEN environment variable not set", file=sys.stderr)
        print("   Get token from Xero OAuth flow or API app")
        sys.exit(1)
    
    if not TENANT_ID:
        print("❌ XERO_TENANT_ID environment variable not set", file=sys.stderr)
        sys.exit(1)
    
    cmd = sys.argv[1] if len(sys.argv) > 1 else "test"
    
    if cmd == "test":
        test_connection()
    elif cmd == "invoices":
        list_invoices()
    elif cmd == "contacts":
        list_contacts()
    else:
        print(__doc__)


if __name__ == "__main__":
    main()
