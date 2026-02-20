#!/usr/bin/env bash
# Test email provider connectivity
# Usage: ./test-connection.sh [gmail|outlook|imap]

set -e

PROVIDER="${1:-gmail}"

case "$PROVIDER" in
  gmail)
    echo "Testing Gmail API connection..."
    if [ -z "$GMAIL_CLIENT_ID" ]; then
      echo "❌ GMAIL_CLIENT_ID not set"
      exit 1
    fi
    # Test OAuth endpoint
    curl -s -o /dev/null -w "%{http_code}" "https://accounts.google.com/.well-known/openid-configuration" | grep -q "200" && \
      echo "✅ Gmail OAuth endpoint reachable" || echo "❌ Gmail OAuth endpoint unreachable"
    ;;
    
  outlook)
    echo "Testing Outlook API connection..."
    if [ -z "$OUTLOOK_CLIENT_ID" ]; then
      echo "❌ OUTLOOK_CLIENT_ID not set"
      exit 1
    fi
    curl -s -o /dev/null -w "%{http_code}" "https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration" | grep -q "200" && \
      echo "✅ Microsoft OAuth endpoint reachable" || echo "❌ Microsoft OAuth endpoint unreachable"
    ;;
    
  imap)
    echo "Testing IMAP connection..."
    if [ -z "$IMAP_HOST" ]; then
      echo "❌ IMAP_HOST not set"
      exit 1
    fi
    nc -z -w5 "$IMAP_HOST" "${IMAP_PORT:-993}" && \
      echo "✅ IMAP server reachable at $IMAP_HOST:${IMAP_PORT:-993}" || \
      echo "❌ Cannot connect to $IMAP_HOST:${IMAP_PORT:-993}"
    ;;
    
  *)
    echo "Usage: $0 [gmail|outlook|imap]"
    exit 1
    ;;
esac

echo "Done."
