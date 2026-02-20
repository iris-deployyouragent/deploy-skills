---
name: calendar
description: Manage calendar events across Google Calendar or Outlook Calendar. Schedule meetings, check availability, set reminders, find free slots, and manage recurring events. Use for any scheduling task including booking meetings, checking what's on today, finding available times, or setting up reminders.
---

# Calendar Management

Handle all calendar operations for the connected account.

## Capabilities

- **View**: Today's schedule, upcoming events, specific date ranges
- **Create**: New events with attendees, location, reminders
- **Modify**: Reschedule, update details, cancel events
- **Availability**: Find free slots, check conflicts, suggest meeting times
- **Reminders**: Set and manage event reminders

## Quick Reference

### Today's Schedule
```bash
# Google Calendar
node scripts/gcal.js today

# Outlook Calendar
node scripts/outlook-cal.js today
```

### Create Event
```bash
node scripts/[provider].js create \
  --title "Meeting with Client" \
  --start "2026-02-21T10:00:00" \
  --end "2026-02-21T11:00:00" \
  --attendees "client@company.com"
```

### Find Free Time
```bash
node scripts/[provider].js free-slots \
  --date "2026-02-21" \
  --duration 60
```

## Provider-Specific Details

- **Google Calendar**: See [references/google.md](references/google.md)
- **Outlook Calendar**: See [references/outlook.md](references/outlook.md)

## Workflows

### Daily Briefing
1. Fetch today's events
2. Include tomorrow's early events
3. Highlight conflicts or tight transitions
4. Note preparation needed for meetings

### Schedule a Meeting
1. Check user's availability
2. If attendees specified, check their availability (if accessible)
3. Suggest optimal times
4. Create event with all details
5. Send invitations

### Reschedule
1. Find the existing event
2. Check new time availability
3. Update event
4. Notify attendees of change

### Find Meeting Time
1. Get user's free slots for date range
2. Filter by preferred hours (e.g., business hours)
3. Consider buffer time between meetings
4. Suggest top 3 options

## Best Practices

- Always confirm before creating/modifying events
- Include timezone in all time references
- Add buffer time between back-to-back meetings
- Set appropriate reminders (15min for calls, 1hr for in-person)
- Include video link for remote meetings
- Check for conflicts before scheduling
