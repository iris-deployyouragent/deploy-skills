# Dropbox

## Authentication

Uses OAuth 2.0 access token.

### Required Credentials
```env
DROPBOX_ACCESS_TOKEN=your-access-token
```

For long-lived access (recommended):
```env
DROPBOX_APP_KEY=your-app-key
DROPBOX_APP_SECRET=your-app-secret
DROPBOX_REFRESH_TOKEN=your-refresh-token
```

### Setup Steps
1. Create app at [dropbox.com/developers](https://www.dropbox.com/developers)
2. Choose access type (App folder or Full Dropbox)
3. Generate access token or complete OAuth flow
4. For refresh tokens, enable offline access

## API Endpoints

### Files

Base URL: `https://api.dropboxapi.com/2`
Content URL: `https://content.dropboxapi.com/2`

#### List Files
```
POST /files/list_folder
{
  "path": "/Documents",
  "recursive": false,
  "include_deleted": false
}
```

For root:
```json
{ "path": "" }
```

Continue pagination:
```
POST /files/list_folder/continue
{
  "cursor": "cursor_from_previous_call"
}
```

#### Search Files
```
POST /files/search_v2
{
  "query": "quarterly report",
  "options": {
    "path": "/Documents",
    "file_extensions": ["pdf", "docx"]
  }
}
```

#### Get Metadata
```
POST /files/get_metadata
{
  "path": "/Documents/report.pdf"
}
```

#### Download File
```
POST https://content.dropboxapi.com/2/files/download
Dropbox-API-Arg: {"path": "/Documents/report.pdf"}
```

Response body is file content.

#### Upload File

Small files (< 150MB):
```
POST https://content.dropboxapi.com/2/files/upload
Dropbox-API-Arg: {"path": "/Documents/report.pdf", "mode": "add"}
Content-Type: application/octet-stream

{binary content}
```

Modes: `add`, `overwrite`, `update`

Large files (upload session):
```
POST https://content.dropboxapi.com/2/files/upload_session/start
```

#### Create Folder
```
POST /files/create_folder_v2
{
  "path": "/Documents/New Folder",
  "autorename": true
}
```

#### Move File
```
POST /files/move_v2
{
  "from_path": "/Documents/old.pdf",
  "to_path": "/Archive/old.pdf"
}
```

#### Copy File
```
POST /files/copy_v2
{
  "from_path": "/Documents/original.pdf",
  "to_path": "/Backup/original.pdf"
}
```

#### Delete File
```
POST /files/delete_v2
{
  "path": "/Documents/old.pdf"
}
```

(Goes to trash for 30 days)

### Sharing

#### Create Shared Link
```
POST /sharing/create_shared_link_with_settings
{
  "path": "/Documents/report.pdf",
  "settings": {
    "requested_visibility": "public",
    "audience": "public",
    "access": "viewer"
  }
}
```

#### List Shared Links
```
POST /sharing/list_shared_links
{
  "path": "/Documents/report.pdf"
}
```

#### Share Folder with User
```
POST /sharing/add_folder_member
{
  "shared_folder_id": "folder_id",
  "members": [
    {
      "member": {
        ".tag": "email",
        "email": "user@email.com"
      },
      "access_level": "editor"
    }
  ]
}
```

Access levels: `viewer`, `editor`, `owner`

#### List Folder Members
```
POST /sharing/list_folder_members
{
  "shared_folder_id": "folder_id"
}
```

#### Remove Sharing
```
POST /sharing/revoke_shared_link
{
  "url": "https://www.dropbox.com/s/..."
}
```

## Paper Documents

List Paper docs:
```
POST /paper/docs/list
{
  "filter_by": "docs_accessed",
  "sort_by": "modified"
}
```

## Rate Limits

- 1000 calls per minute per user
- Certain endpoints have stricter limits
- 429 response with `Retry-After` header

## Error Handling

Dropbox errors include `.tag` for error type:
```json
{
  "error": {
    ".tag": "path",
    "path": {
      ".tag": "not_found"
    }
  }
}
```

Common tags: `path/not_found`, `path/conflict`, `insufficient_space`

## Common Issues

1. **Path format**: Must start with `/` or be empty for root
2. **Case sensitivity**: Dropbox is case-insensitive but case-preserving
3. **App folder**: If using App folder, paths are relative to app folder
4. **Token expiration**: Use refresh tokens for long-lived access
