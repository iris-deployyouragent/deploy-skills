# Google Calendar

## Authentication

Uses same OAuth credentials as Gmail (Google Cloud).

### Required Credentials
```env
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
GOOGLE_REFRESH_TOKEN=your-refresh-token
```

Add scope: `https://www.googleapis.com/auth/calendar`

## API Endpoints

Base URL: `https://www.googleapis.com/calendar/v3`

### List Calendars
```
GET /users/me/calendarList
```

### List Events
```
GET /calendars/{calendarId}/events
  ?timeMin={ISO-datetime}
  &timeMax={ISO-datetime}
  &singleEvents=true
  &orderBy=startTime
```

Use `primary` as calendarId for main calendar.

### Get Event
```
GET /calendars/{calendarId}/events/{eventId}
```

### Create Event
```
POST /calendars/{calendarId}/events
{
  "summary": "Meeting Title",
  "description": "Meeting description",
  "location": "Conference Room A",
  "start": {
    "dateTime": "2026-02-21T10:00:00",
    "timeZone": "Australia/Adelaide"
  },
  "end": {
    "dateTime": "2026-02-21T11:00:00",
    "timeZone": "Australia/Adelaide"
  },
  "attendees": [
    { "email": "attendee@example.com" }
  ],
  "reminders": {
    "useDefault": false,
    "overrides": [
      { "method": "popup", "minutes": 15 }
    ]
  },
  "conferenceData": {
    "createRequest": {
      "requestId": "unique-id",
      "conferenceSolutionKey": { "type": "hangoutsMeet" }
    }
  }
}
```

Add `?conferenceDataVersion=1` for Google Meet link.

### Update Event
```
PUT /calendars/{calendarId}/events/{eventId}
```

### Delete Event
```
DELETE /calendars/{calendarId}/events/{eventId}
```

### Free/Busy Query
```
POST /freeBusy/query
{
  "timeMin": "2026-02-21T00:00:00Z",
  "timeMax": "2026-02-21T23:59:59Z",
  "items": [
    { "id": "primary" },
    { "id": "colleague@company.com" }
  ]
}
```

## Recurring Events

Create with `recurrence` field:
```json
{
  "recurrence": [
    "RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR"
  ]
}
```

Common patterns:
- `FREQ=DAILY` - every day
- `FREQ=WEEKLY;BYDAY=TU,TH` - Tuesdays and Thursdays
- `FREQ=MONTHLY;BYMONTHDAY=1` - first of each month
- `FREQ=YEARLY` - annually

## Rate Limits

- 1,000,000 queries per day
- 500 requests per 100 seconds per user
- Implement exponential backoff on 403/429

## Common Issues

1. **All-day events**: Use `date` instead of `dateTime`
2. **Timezone issues**: Always specify timeZone
3. **Attendee not notified**: Add `sendUpdates: 'all'` to request
