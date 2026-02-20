# OneDrive / SharePoint

## Authentication

Uses Microsoft Graph API (same as Outlook).

### Required Credentials
```env
MICROSOFT_CLIENT_ID=your-azure-app-id
MICROSOFT_CLIENT_SECRET=your-client-secret
MICROSOFT_REFRESH_TOKEN=your-refresh-token
```

Add permission: `Files.ReadWrite.All`

## API Endpoints

Base URL: `https://graph.microsoft.com/v1.0`

### List Files

Root folder:
```
GET /me/drive/root/children
```

Specific folder:
```
GET /me/drive/items/{item-id}/children
```

By path:
```
GET /me/drive/root:/Documents:/children
```

### Search Files
```
GET /me/drive/root/search(q='quarterly report')
```

### Get File Metadata
```
GET /me/drive/items/{item-id}
```

By path:
```
GET /me/drive/root:/Documents/report.pdf
```

### Download File
```
GET /me/drive/items/{item-id}/content
```

Response is redirect to download URL.

### Upload File

Small files (< 4MB):
```
PUT /me/drive/root:/Documents/report.pdf:/content
Content-Type: application/pdf

{binary content}
```

Large files (upload session):
```
POST /me/drive/root:/Documents/large.zip:/createUploadSession
{
  "item": {
    "name": "large.zip"
  }
}
```

### Create Folder
```
POST /me/drive/root/children
{
  "name": "New Folder",
  "folder": {},
  "@microsoft.graph.conflictBehavior": "rename"
}
```

### Move File
```
PATCH /me/drive/items/{item-id}
{
  "parentReference": {
    "id": "new-parent-folder-id"
  }
}
```

### Rename File
```
PATCH /me/drive/items/{item-id}
{
  "name": "new_name.pdf"
}
```

### Delete File
```
DELETE /me/drive/items/{item-id}
```

(Goes to recycle bin)

### Share File

Create sharing link:
```
POST /me/drive/items/{item-id}/createLink
{
  "type": "view",
  "scope": "anonymous"
}
```

Types: `view`, `edit`, `embed`
Scopes: `anonymous`, `organization`

Share with specific person:
```
POST /me/drive/items/{item-id}/invite
{
  "recipients": [
    { "email": "user@email.com" }
  ],
  "roles": ["read"],
  "sendInvitation": true
}
```

### List Permissions
```
GET /me/drive/items/{item-id}/permissions
```

### Remove Permission
```
DELETE /me/drive/items/{item-id}/permissions/{perm-id}
```

## SharePoint (Team Sites)

Access SharePoint document libraries:
```
GET /sites/{site-id}/drive/root/children
```

Find site:
```
GET /sites?search=contoso
```

## Special Folders

```
GET /me/drive/special/documents
GET /me/drive/special/photos
GET /me/drive/special/music
```

## Sync Status

Check if file is synced:
```json
{
  "file": {
    "hashes": {
      "sha1Hash": "...",
      "quickXorHash": "..."
    }
  }
}
```

## Rate Limits

- 10,000 requests per 10 minutes
- Throttling returns 429 with `Retry-After`

## Common Issues

1. **Item not found**: Check path encoding, case sensitivity
2. **Conflict**: File with same name exists - use conflictBehavior
3. **Large upload fails**: Use upload session for > 4MB
4. **SharePoint access**: May need Sites.ReadWrite.All permission
