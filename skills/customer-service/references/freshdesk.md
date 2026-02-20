# Freshdesk

## Authentication

Uses API key with Basic auth.

### Required Credentials
```env
FRESHDESK_DOMAIN=yourcompany.freshdesk.com
FRESHDESK_API_KEY=your-api-key
```

Get key: Profile → API Key (or Admin → Profile Settings)

### Auth Header
```
Authorization: Basic base64({api_key}:X)
```

Note: Password is literally "X".

## API Endpoints

Base URL: `https://{domain}/api/v2`

### List Tickets
```
GET /tickets
  ?filter=new_and_my_open
  &order_by=created_at
  &order_type=desc
```

Filter values:
- `new_and_my_open` - new + assigned to me
- `watching` - tickets I'm watching
- `spam` - spam tickets
- `deleted` - deleted tickets

Custom filter:
```
GET /search/tickets?query="status:2 AND priority:4"
```

Query operators:
- `status:2` - open (2=open, 3=pending, 4=resolved, 5=closed)
- `priority:4` - urgent (1=low, 2=medium, 3=high, 4=urgent)
- `agent_id:123` - assigned to agent
- `created_at:>'2026-02-01'` - created after

### Get Ticket
```
GET /tickets/{id}?include=conversations
```

### Create Ticket
```
POST /tickets
{
  "subject": "Issue subject",
  "description": "Issue description",
  "email": "customer@email.com",
  "priority": 2,
  "status": 2,
  "source": 1,
  "tags": ["tag1", "tag2"]
}
```

Source values: 1=email, 2=portal, 3=phone, 7=chat

### Update Ticket
```
PUT /tickets/{id}
{
  "status": 4,
  "priority": 3
}
```

### Reply to Ticket
```
POST /tickets/{id}/reply
{
  "body": "Response to customer"
}
```

### Add Note (Internal)
```
POST /tickets/{id}/notes
{
  "body": "Internal note content",
  "private": true
}
```

## Ticket Properties

### Status
- 2 = Open
- 3 = Pending
- 4 = Resolved
- 5 = Closed

### Priority
- 1 = Low
- 2 = Medium
- 3 = High
- 4 = Urgent

## Useful Endpoints

### Contacts
```
GET /contacts?email=customer@email.com
POST /contacts
```

### Canned Responses
```
GET /canned_responses?folder_id={id}
```

### Groups (Teams)
```
GET /groups
```

### Agents
```
GET /agents
```

## Rate Limits

- Varies by plan (Sprout: 50/min, Blossom: 200/min, etc.)
- Check `X-RateLimit-Remaining` header
- 429 response when exceeded

## Common Issues

1. **Domain format**: Use full domain (company.freshdesk.com)
2. **API version**: Always use /api/v2
3. **Field types**: Custom fields need `custom_fields` object
4. **Attachments**: Use multipart/form-data with `attachments[]`
