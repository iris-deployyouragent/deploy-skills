#!/usr/bin/env bash
# Quick Google Calendar operations using gcalcli (if installed)
# Or direct API calls for basic ops
# Usage: ./gcal-quick.sh <command>

set -e

CMD="${1:-today}"

# Check for gcalcli first
if command -v gcalcli &> /dev/null; then
  case "$CMD" in
    today)
      gcalcli agenda --nocolor "today" "tomorrow"
      ;;
    week)
      gcalcli calw --monday
      ;;
    add)
      shift
      gcalcli add "$@"
      ;;
    quick)
      shift
      gcalcli quick "$@"
      ;;
    *)
      echo "Commands: today, week, add, quick"
      ;;
  esac
else
  echo "gcalcli not found. Install with: pip install gcalcli"
  echo ""
  echo "Manual API test (requires GOOGLE_CALENDAR_TOKEN):"
  if [ -n "$GOOGLE_CALENDAR_TOKEN" ]; then
    curl -s -H "Authorization: Bearer $GOOGLE_CALENDAR_TOKEN" \
      "https://www.googleapis.com/calendar/v3/calendars/primary/events?maxResults=5&orderBy=startTime&singleEvents=true&timeMin=$(date -u +%Y-%m-%dT%H:%M:%SZ)" | \
      python3 -c "import sys,json; events=json.load(sys.stdin).get('items',[]); [print(f\"{e.get('start',{}).get('dateTime','')[:16]} - {e.get('summary','')}\") for e in events]"
  else
    echo "GOOGLE_CALENDAR_TOKEN not set"
  fi
fi
