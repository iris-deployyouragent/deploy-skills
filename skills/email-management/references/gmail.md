# Gmail / Google Workspace

## Authentication

Uses OAuth 2.0 with Google Cloud credentials.

### Required Credentials
```env
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
GOOGLE_REFRESH_TOKEN=your-refresh-token
```

### Setup Steps
1. Create project in [Google Cloud Console](https://console.cloud.google.com)
2. Enable Gmail API
3. Create OAuth 2.0 credentials (Desktop app type)
4. Run auth flow to get refresh token
5. Add credentials to agent's .env

## API Endpoints

Base URL: `https://gmail.googleapis.com/gmail/v1`

### List Messages
```
GET /users/me/messages?q={query}&maxResults={limit}
```

Query examples:
- `is:unread` - unread only
- `from:sender@email.com` - from specific sender
- `after:2026/01/01` - after date
- `has:attachment` - with attachments
- `subject:invoice` - subject contains

### Get Message
```
GET /users/me/messages/{id}?format=full
```

### Send Message
```
POST /users/me/messages/send
Content-Type: application/json

{
  "raw": "base64-encoded-email"
}
```

### Modify Labels
```
POST /users/me/messages/{id}/modify
{
  "addLabelIds": ["STARRED"],
  "removeLabelIds": ["UNREAD"]
}
```

## Gmail-Specific Features

### Labels (vs Folders)
Gmail uses labels, not folders. Emails can have multiple labels.

System labels:
- `INBOX`, `SENT`, `DRAFTS`, `TRASH`, `SPAM`
- `STARRED`, `IMPORTANT`, `UNREAD`
- `CATEGORY_PERSONAL`, `CATEGORY_SOCIAL`, `CATEGORY_PROMOTIONS`, `CATEGORY_UPDATES`, `CATEGORY_FORUMS`

### Threads
Gmail groups emails into threads. Use `threadId` to get full conversation.

```
GET /users/me/threads/{threadId}
```

### Batch Operations
For bulk operations, use batch endpoint:
```
POST /batch/gmail/v1
```

## Rate Limits

- 250 quota units per user per second
- Sending: 100 emails/day (free), 2000/day (Workspace)
- Read operations: ~5 quota units each

## Common Issues

1. **Token expired**: Refresh using refresh_token
2. **Quota exceeded**: Implement exponential backoff
3. **Permission denied**: Check OAuth scopes include gmail.modify
