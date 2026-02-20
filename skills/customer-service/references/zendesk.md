# Zendesk

## Authentication

Uses API token with email.

### Required Credentials
```env
ZENDESK_SUBDOMAIN=yourcompany
ZENDESK_EMAIL=agent@company.com
ZENDESK_API_TOKEN=your-api-token
```

Get token: Admin → Channels → API → Add API token

### Auth Header
```
Authorization: Basic base64({email}/token:{api_token})
```

## API Endpoints

Base URL: `https://{subdomain}.zendesk.com/api/v2`

### List Tickets
```
GET /tickets.json?sort_by=created_at&sort_order=desc
```

With filters:
```
GET /search.json?query=status:open type:ticket
```

Search query syntax:
- `status:open` - open tickets
- `status:pending` - awaiting customer
- `assignee:me` - assigned to current user
- `requester:customer@email.com` - from specific customer
- `created>2026-02-01` - created after date
- `priority:urgent` - priority level

### Get Ticket
```
GET /tickets/{id}.json
```

With comments:
```
GET /tickets/{id}/comments.json
```

### Create Ticket
```
POST /tickets.json
{
  "ticket": {
    "subject": "Issue subject",
    "description": "Initial message",
    "requester": {
      "email": "customer@email.com",
      "name": "Customer Name"
    },
    "priority": "normal",
    "tags": ["tag1", "tag2"]
  }
}
```

### Update Ticket
```
PUT /tickets/{id}.json
{
  "ticket": {
    "status": "solved",
    "comment": {
      "body": "Response to customer",
      "public": true
    },
    "assignee_id": 123456
  }
}
```

### Add Comment (Reply)
```
PUT /tickets/{id}.json
{
  "ticket": {
    "comment": {
      "body": "Response content",
      "public": true,
      "author_id": 123456
    }
  }
}
```

Set `public: false` for internal notes.

## Ticket Statuses

- `new` - Not yet assigned
- `open` - Assigned, being worked on
- `pending` - Waiting for customer response
- `hold` - On hold (internal)
- `solved` - Resolution provided
- `closed` - Finalized (cannot reopen)

## Useful Endpoints

### Users
```
GET /users/search.json?query=email:customer@email.com
```

### Macros (Canned Responses)
```
GET /macros.json
POST /tickets/{id}/macros/{macro_id}/apply.json
```

### Views (Saved Searches)
```
GET /views.json
GET /views/{id}/tickets.json
```

## Rate Limits

- 700 requests per minute (Team/Professional)
- 200 requests per minute (Essential)
- Check `X-Rate-Limit-Remaining` header

## Common Issues

1. **401 Unauthorized**: Check email format ({email}/token) and token validity
2. **Ticket not updating**: May need to include `safe_update` param
3. **Missing fields**: Some fields require specific plan levels
