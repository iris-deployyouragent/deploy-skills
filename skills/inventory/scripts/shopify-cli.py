#!/usr/bin/env python3
"""
Shopify Inventory CLI.
Usage: python shopify-cli.py <command> [options]

Commands:
  test - Test API connection
  products [--limit N] - List products
  inventory [--low-stock] - Check inventory levels
  update <variant_id> --quantity N - Update stock
"""

import argparse
import json
import os
import sys
import urllib.request
import urllib.error

SHOP_NAME = os.environ.get("SHOPIFY_SHOP_NAME", "")
ACCESS_TOKEN = os.environ.get("SHOPIFY_ACCESS_TOKEN", "")
API_VERSION = "2024-01"

BASE_URL = f"https://{SHOP_NAME}.myshopify.com/admin/api/{API_VERSION}"


def api_request(method: str, endpoint: str, data: dict = None) -> dict:
    """Make authenticated API request to Shopify."""
    url = f"{BASE_URL}/{endpoint}"
    headers = {
        "X-Shopify-Access-Token": ACCESS_TOKEN,
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
        result = api_request("GET", "shop.json")
        shop = result.get("shop", {})
        print("✅ Shopify API connection successful")
        print(f"   Shop: {shop.get('name', 'Unknown')}")
        print(f"   Domain: {shop.get('domain', 'Unknown')}")
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        sys.exit(1)


def list_products(limit: int = 10):
    """List products."""
    result = api_request("GET", f"products.json?limit={limit}")
    products = result.get("products", [])
    
    print(f"Found {len(products)} products:\n")
    for p in products:
        variants = len(p.get("variants", []))
        status = p.get("status", "unknown")
        print(f"[{p['id']}] {p.get('title', 'Untitled')} ({variants} variants) - {status}")


def check_inventory(low_stock: bool = False):
    """Check inventory levels."""
    # Get inventory levels
    result = api_request("GET", "inventory_levels.json?limit=50")
    levels = result.get("inventory_levels", [])
    
    # Get products for context
    products_result = api_request("GET", "products.json?limit=50")
    products = products_result.get("products", [])
    
    # Build variant map
    variant_map = {}
    for p in products:
        for v in p.get("variants", []):
            variant_map[v.get("inventory_item_id")] = {
                "product": p.get("title"),
                "variant": v.get("title"),
                "sku": v.get("sku", "N/A"),
            }
    
    print("Inventory Levels:\n")
    for level in levels:
        item_id = level.get("inventory_item_id")
        qty = level.get("available", 0)
        
        if low_stock and qty > 10:
            continue
            
        info = variant_map.get(item_id, {})
        status = "🔴 LOW" if qty < 5 else "🟡" if qty < 20 else "🟢"
        
        product = info.get("product", "Unknown")
        sku = info.get("sku", "N/A")
        print(f"{status} [{sku}] {product}: {qty} available")


def update_inventory(variant_id: int, quantity: int):
    """Update inventory quantity (set adjustment)."""
    # First get the inventory item id from variant
    result = api_request("GET", f"variants/{variant_id}.json")
    variant = result.get("variant", {})
    inventory_item_id = variant.get("inventory_item_id")
    
    if not inventory_item_id:
        print("❌ Could not find inventory item for variant")
        sys.exit(1)
    
    # Get location
    locations = api_request("GET", "locations.json")
    location_id = locations.get("locations", [{}])[0].get("id")
    
    # Set inventory level
    data = {
        "location_id": location_id,
        "inventory_item_id": inventory_item_id,
        "available": quantity
    }
    api_request("POST", "inventory_levels/set.json", data)
    print(f"✅ Updated variant {variant_id} to {quantity} units")


def main():
    if not all([SHOP_NAME, ACCESS_TOKEN]):
        print("❌ Required environment variables not set:", file=sys.stderr)
        print("   SHOPIFY_SHOP_NAME, SHOPIFY_ACCESS_TOKEN")
        sys.exit(1)
    
    parser = argparse.ArgumentParser(description="Shopify Inventory CLI")
    subparsers = parser.add_subparsers(dest="command")
    
    subparsers.add_parser("test")
    
    products_parser = subparsers.add_parser("products")
    products_parser.add_argument("--limit", type=int, default=10)
    
    inv_parser = subparsers.add_parser("inventory")
    inv_parser.add_argument("--low-stock", action="store_true")
    
    update_parser = subparsers.add_parser("update")
    update_parser.add_argument("variant_id", type=int)
    update_parser.add_argument("--quantity", type=int, required=True)
    
    args = parser.parse_args()
    
    if args.command == "test":
        test_connection()
    elif args.command == "products":
        list_products(args.limit)
    elif args.command == "inventory":
        check_inventory(args.low_stock)
    elif args.command == "update":
        update_inventory(args.variant_id, args.quantity)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
