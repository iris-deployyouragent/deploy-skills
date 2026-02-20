# Outlook / Microsoft 365

## Authentication

Uses OAuth 2.0 with Microsoft Graph API.

### Required Credentials
```env
MICROSOFT_CLIENT_ID=your-azure-app-id
MICROSOFT_CLIENT_SECRET=your-client-secret
MICROSOFT_REFRESH_TOKEN=your-refresh-token
MICROSOFT_TENANT_ID=common  # or specific tenant
```

### Setup Steps
1. Register app in [Azure Portal](https://portal.azure.com) → App registrations
2. Add Microsoft Graph API permissions:
   - `Mail.Read`, `Mail.ReadWrite`, `Mail.Send`
3. Create client secret
4. Run auth flow to get refresh token
5. Add credentials to agent's .env

## API Endpoints

Base URL: `https://graph.microsoft.com/v1.0`

### List Messages
```
GET /me/messages?$top={limit}&$filter={filter}&$orderby=receivedDateTime desc
```

Filter examples:
- `isRead eq false` - unread only
- `from/emailAddress/address eq 'sender@email.com'` - from sender
- `receivedDateTime ge 2026-01-01` - after date
- `hasAttachments eq true` - with attachments

OData query parameters:
- `$select` - choose fields
- `$top` - limit results
- `$skip` - pagination
- `$filter` - filter criteria
- `$search` - full-text search

### Get Message
```
GET /me/messages/{id}
```

### Send Email
```
POST /me/sendMail
Content-Type: application/json

{
  "message": {
    "subject": "Subject",
    "body": {
      "contentType": "HTML",
      "content": "<p>Body content</p>"
    },
    "toRecipients": [
      { "emailAddress": { "address": "recipient@email.com" } }
    ]
  }
}
```

### Move to Folder
```
POST /me/messages/{id}/move
{
  "destinationId": "folder-id"
}
```

### Mark as Read
```
PATCH /me/messages/{id}
{
  "isRead": true
}
```

## Outlook-Specific Features

### Folders (vs Labels)
Outlook uses folders. Each email is in exactly one folder.

Default folders:
- `inbox`, `drafts`, `sentitems`, `deleteditems`, `junkemail`
- `archive`

Get folders:
```
GET /me/mailFolders
```

### Categories
For tagging (like Gmail labels):
```
PATCH /me/messages/{id}
{
  "categories": ["Important", "Project X"]
}
```

### Focused Inbox
Messages are classified as `focused` or `other`:
```
GET /me/messages?$filter=inferenceClassification eq 'focused'
```

### Conversations
Group by `conversationId`:
```
GET /me/messages?$filter=conversationId eq '{id}'
```

## Rate Limits

- 10,000 requests per 10 minutes per app
- 4 concurrent requests per mailbox
- Implement retry with `Retry-After` header

## Common Issues

1. **Token expired**: Use refresh_token to get new access_token
2. **Consent required**: Admin consent may be needed for org accounts
3. **Throttled**: Check `Retry-After` header, implement backoff
