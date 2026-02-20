# Google Drive

## Authentication

Uses OAuth 2.0 (same as Gmail/Calendar).

### Required Credentials
```env
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
GOOGLE_REFRESH_TOKEN=your-refresh-token
```

Add scope: `https://www.googleapis.com/auth/drive`

## API Endpoints

Base URL: `https://www.googleapis.com/drive/v3`

### List Files

```
GET /files
  ?q='{folder_id}' in parents
  &pageSize=100
  &fields=files(id,name,mimeType,size,modifiedTime)
```

Query operators:
- `'root' in parents` - root folder
- `'{folder_id}' in parents` - specific folder
- `name contains 'report'` - name search
- `mimeType='application/pdf'` - file type
- `modifiedTime > '2026-01-01'` - modified after
- `trashed=false` - exclude trash

### Search Files
```
GET /files?q=fullText contains 'quarterly report'
```

### Get File Metadata
```
GET /files/{fileId}?fields=id,name,mimeType,size,parents,permissions
```

### Download File
```
GET /files/{fileId}?alt=media
```

For Google Docs (export):
```
GET /files/{fileId}/export?mimeType=application/pdf
```

### Upload File

Simple upload (< 5MB):
```
POST /upload/drive/v3/files?uploadType=media
Content-Type: application/pdf

{binary content}
```

With metadata:
```
POST /upload/drive/v3/files?uploadType=multipart
Content-Type: multipart/related; boundary=foo

--foo
Content-Type: application/json

{"name": "report.pdf", "parents": ["folder_id"]}
--foo
Content-Type: application/pdf

{binary content}
--foo--
```

### Create Folder
```
POST /files
{
  "name": "New Folder",
  "mimeType": "application/vnd.google-apps.folder",
  "parents": ["parent_folder_id"]
}
```

### Move File
```
PATCH /files/{fileId}?addParents={newFolder}&removeParents={oldFolder}
```

### Rename File
```
PATCH /files/{fileId}
{
  "name": "new_name.pdf"
}
```

### Delete File (to Trash)
```
PATCH /files/{fileId}
{
  "trashed": true
}
```

Permanent delete:
```
DELETE /files/{fileId}
```

### Share File
```
POST /files/{fileId}/permissions
{
  "role": "reader",
  "type": "user",
  "emailAddress": "user@email.com"
}
```

Roles: `reader`, `commenter`, `writer`, `owner`
Types: `user`, `group`, `domain`, `anyone`

### Create Shareable Link
```
POST /files/{fileId}/permissions
{
  "role": "reader",
  "type": "anyone"
}
```

Get the link:
```
GET /files/{fileId}?fields=webViewLink
```

### List Permissions
```
GET /files/{fileId}/permissions
```

### Remove Permission
```
DELETE /files/{fileId}/permissions/{permissionId}
```

## MIME Types

| Type | MIME Type |
|------|-----------|
| Folder | application/vnd.google-apps.folder |
| Google Doc | application/vnd.google-apps.document |
| Google Sheet | application/vnd.google-apps.spreadsheet |
| Google Slides | application/vnd.google-apps.presentation |
| PDF | application/pdf |

## Rate Limits

- 1,000 queries per 100 seconds per user
- 1,000,000 queries per day
- Check `X-RateLimit-*` headers

## Common Issues

1. **File not found**: Check folder ID, permissions
2. **Quota exceeded**: Implement backoff
3. **Can't download Google Docs**: Use export endpoint
4. **Permission denied**: Need write scope for modifications
