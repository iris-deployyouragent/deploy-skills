---
name: document-management
description: Manage documents with Google Drive, OneDrive, or Dropbox. Upload, organize, search, share files. Use for finding documents, uploading files, sharing, creating folders, or organizing file structures.
homepage: https://developers.google.com/drive
metadata: {"clawdbot":{"emoji":"📁","requires":{"env":["GOOGLE_DRIVE_TOKEN","ONEDRIVE_TOKEN"]},"primaryEnv":"GOOGLE_DRIVE_TOKEN"}}
---

# Document Management

Organize, search, and share files across cloud storage.

## Capabilities

- **Browse**: Navigate folders, list files, check storage
- **Upload/Download**: Move files to/from cloud storage
- **Organize**: Create folders, move files, rename, delete
- **Search**: Find files by name, content, type, date
- **Share**: Set permissions, create links, manage access
- **Sync**: Keep local and cloud in sync

## Quick Reference

### List Files
```bash
node scripts/[provider].js list --folder "Documents"
```

### Search
```bash
node scripts/[provider].js search --query "quarterly report"
```

### Upload File
```bash
node scripts/[provider].js upload \
  --file "./report.pdf" \
  --folder "Reports/2026"
```

### Share File
```bash
node scripts/[provider].js share \
  --file "report.pdf" \
  --email "colleague@company.com" \
  --role editor
```

## Provider-Specific Details

- **Google Drive**: See [references/google-drive.md](references/google-drive.md)
- **OneDrive**: See [references/onedrive.md](references/onedrive.md)
- **Dropbox**: See [references/dropbox.md](references/dropbox.md)

## Workflows

### Find a Document
1. Ask user for details (name, type, approximate date)
2. Search using available criteria
3. If multiple results, present options
4. Confirm the correct file
5. Perform requested action (open, share, download)

### Organize Files
1. Review current folder structure
2. Identify files needing organization
3. Create appropriate folders if needed
4. Move files to correct locations
5. Rename for consistency if needed
6. Confirm changes with user

### Share Securely
1. Identify file to share
2. Determine appropriate access level:
   - View only (most cases)
   - Comment (for review)
   - Edit (for collaboration)
3. Set expiration if sensitive
4. Share and notify recipient
5. Log sharing action

### Backup Important Files
1. Identify critical files
2. Check existing backup status
3. Copy to backup location/folder
4. Verify copy success
5. Document backup location

## File Organization Best Practices

### Folder Structure
```
📁 Company/
├── 📁 Clients/
│   ├── 📁 Acme Corp/
│   │   ├── 📁 Contracts/
│   │   ├── 📁 Invoices/
│   │   └── 📁 Projects/
│   └── 📁 Beta Inc/
├── 📁 Finance/
│   ├── 📁 2025/
│   └── 📁 2026/
├── 📁 HR/
├── 📁 Marketing/
└── 📁 Operations/
```

### Naming Conventions
- Use dates in ISO format: `2026-02-20`
- Include version: `Contract_v2.pdf`
- Be descriptive: `Acme_ServiceAgreement_2026-02-20_v1.pdf`
- Avoid special characters: `/ \ : * ? " < > |`

### Permission Levels
| Level | Can View | Can Comment | Can Edit | Can Share |
|-------|----------|-------------|----------|-----------|
| Viewer | ✓ | | | |
| Commenter | ✓ | ✓ | | |
| Editor | ✓ | ✓ | ✓ | |
| Owner | ✓ | ✓ | ✓ | ✓ |

## Best Practices

- Confirm before deleting (trash first, delete later)
- Check sharing permissions before adding new shares
- Use descriptive file names
- Maintain consistent folder structure
- Regular cleanup of old/unused files
- Respect existing organization systems
