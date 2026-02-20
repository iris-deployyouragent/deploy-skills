# Outlook Calendar

## Authentication

Uses same Microsoft Graph credentials as Outlook email.

### Required Credentials
```env
MICROSOFT_CLIENT_ID=your-azure-app-id
MICROSOFT_CLIENT_SECRET=your-client-secret
MICROSOFT_REFRESH_TOKEN=your-refresh-token
```

Add permission: `Calendars.ReadWrite`

## API Endpoints

Base URL: `https://graph.microsoft.com/v1.0`

### List Calendars
```
GET /me/calendars
```

### List Events
```
GET /me/events
  ?$filter=start/dateTime ge '2026-02-21T00:00:00' and end/dateTime le '2026-02-21T23:59:59'
  &$orderby=start/dateTime
  &$top=50
```

Or by calendar view (expands recurring):
```
GET /me/calendarView
  ?startDateTime=2026-02-21T00:00:00
  &endDateTime=2026-02-22T00:00:00
```

### Get Event
```
GET /me/events/{eventId}
```

### Create Event
```
POST /me/events
{
  "subject": "Meeting Title",
  "body": {
    "contentType": "HTML",
    "content": "Meeting description"
  },
  "start": {
    "dateTime": "2026-02-21T10:00:00",
    "timeZone": "Australia/Adelaide"
  },
  "end": {
    "dateTime": "2026-02-21T11:00:00",
    "timeZone": "Australia/Adelaide"
  },
  "location": {
    "displayName": "Conference Room A"
  },
  "attendees": [
    {
      "emailAddress": {
        "address": "attendee@example.com",
        "name": "Attendee Name"
      },
      "type": "required"
    }
  ],
  "isOnlineMeeting": true,
  "onlineMeetingProvider": "teamsForBusiness"
}
```

### Update Event
```
PATCH /me/events/{eventId}
```

### Delete Event
```
DELETE /me/events/{eventId}
```

### Find Meeting Times
```
POST /me/findMeetingTimes
{
  "attendees": [
    {
      "emailAddress": { "address": "colleague@company.com" },
      "type": "required"
    }
  ],
  "timeConstraint": {
    "timeslots": [
      {
        "start": { "dateTime": "2026-02-21T09:00:00", "timeZone": "Australia/Adelaide" },
        "end": { "dateTime": "2026-02-21T17:00:00", "timeZone": "Australia/Adelaide" }
      }
    ]
  },
  "meetingDuration": "PT1H"
}
```

## Recurring Events

Use `recurrence` object:
```json
{
  "recurrence": {
    "pattern": {
      "type": "weekly",
      "interval": 1,
      "daysOfWeek": ["monday", "wednesday", "friday"]
    },
    "range": {
      "type": "endDate",
      "startDate": "2026-02-21",
      "endDate": "2026-12-31"
    }
  }
}
```

Pattern types: `daily`, `weekly`, `absoluteMonthly`, `relativeMonthly`, `absoluteYearly`, `relativeYearly`

## Teams Integration

Set `isOnlineMeeting: true` to auto-create Teams link.

The response includes:
```json
{
  "onlineMeeting": {
    "joinUrl": "https://teams.microsoft.com/l/meetup-join/..."
  }
}
```

## Rate Limits

- 10,000 requests per 10 minutes per app
- Calendar-specific: 4 concurrent requests per mailbox
- Use `Retry-After` header for backoff

## Common Issues

1. **All-day events**: Set `isAllDay: true`, use date only (no time)
2. **Timezone confusion**: Always specify timeZone in start/end
3. **Attendee not notified**: Check `responseRequested` and `allowNewTimeProposals`
4. **Room booking**: Use `locations` array with `locationEmailAddress` for room resources
