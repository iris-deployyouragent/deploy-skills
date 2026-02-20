#!/usr/bin/env python3
"""
Google Drive CLI for file operations.
Usage: python gdrive-cli.py <command> [options]

Commands:
  test - Test API connection
  list [--folder ID] [--limit N] - List files
  search --query "name contains 'report'" - Search files
  info <file_id> - Get file details
"""

import argparse
import json
import os
import sys
import urllib.request
import urllib.error
import urllib.parse

ACCESS_TOKEN = os.environ.get("GOOGLE_DRIVE_TOKEN", "")
BASE_URL = "https://www.googleapis.com/drive/v3"


def api_request(endpoint: str, params: dict = None) -> dict:
    """Make authenticated API request to Google Drive."""
    url = f"{BASE_URL}/{endpoint}"
    if params:
        url += "?" + urllib.parse.urlencode(params)
    
    headers = {
        "Authorization": f"Bearer {ACCESS_TOKEN}",
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
        result = api_request("about", {"fields": "user"})
        user = result.get("user", {})
        print("✅ Google Drive API connection successful")
        print(f"   User: {user.get('displayName', 'Unknown')}")
        print(f"   Email: {user.get('emailAddress', 'Unknown')}")
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        sys.exit(1)


def list_files(folder_id: str = None, limit: int = 10):
    """List files."""
    params = {
        "pageSize": limit,
        "fields": "files(id,name,mimeType,modifiedTime,size)",
        "orderBy": "modifiedTime desc",
    }
    
    if folder_id:
        params["q"] = f"'{folder_id}' in parents"
    
    result = api_request("files", params)
    files = result.get("files", [])
    
    print(f"Found {len(files)} files:\n")
    for f in files:
        mime = f.get("mimeType", "")
        icon = "📁" if "folder" in mime else "📄"
        size = f.get("size", "")
        size_str = f" ({int(size)//1024}KB)" if size else ""
        modified = f.get("modifiedTime", "")[:10]
        print(f"{icon} [{f['id'][:8]}] {f.get('name', 'Untitled')}{size_str} - {modified}")


def search_files(query: str):
    """Search files."""
    params = {
        "q": query,
        "pageSize": 20,
        "fields": "files(id,name,mimeType,modifiedTime)",
    }
    
    result = api_request("files", params)
    files = result.get("files", [])
    
    print(f"Search results for: {query}\n")
    for f in files:
        mime = f.get("mimeType", "")
        icon = "📁" if "folder" in mime else "📄"
        print(f"{icon} [{f['id'][:8]}] {f.get('name', 'Untitled')}")


def get_file_info(file_id: str):
    """Get file details."""
    params = {
        "fields": "id,name,mimeType,modifiedTime,size,owners,webViewLink,permissions"
    }
    result = api_request(f"files/{file_id}", params)
    
    print(f"File: {result.get('name', 'Unknown')}")
    print(f"ID: {result.get('id')}")
    print(f"Type: {result.get('mimeType')}")
    print(f"Modified: {result.get('modifiedTime', '')[:19]}")
    
    size = result.get("size")
    if size:
        print(f"Size: {int(size)//1024} KB")
    
    owners = result.get("owners", [])
    if owners:
        print(f"Owner: {owners[0].get('displayName', 'Unknown')}")
    
    link = result.get("webViewLink")
    if link:
        print(f"Link: {link}")


def main():
    if not ACCESS_TOKEN:
        print("❌ GOOGLE_DRIVE_TOKEN environment variable not set", file=sys.stderr)
        sys.exit(1)
    
    parser = argparse.ArgumentParser(description="Google Drive CLI")
    subparsers = parser.add_subparsers(dest="command")
    
    subparsers.add_parser("test")
    
    list_parser = subparsers.add_parser("list")
    list_parser.add_argument("--folder", help="Folder ID")
    list_parser.add_argument("--limit", type=int, default=10)
    
    search_parser = subparsers.add_parser("search")
    search_parser.add_argument("--query", required=True)
    
    info_parser = subparsers.add_parser("info")
    info_parser.add_argument("file_id")
    
    args = parser.parse_args()
    
    if args.command == "test":
        test_connection()
    elif args.command == "list":
        list_files(args.folder, args.limit)
    elif args.command == "search":
        search_files(args.query)
    elif args.command == "info":
        get_file_info(args.file_id)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
