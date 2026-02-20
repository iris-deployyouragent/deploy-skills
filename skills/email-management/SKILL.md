---
name: email-management
description: Manage emails across Gmail, Outlook, or IMAP providers. Read inbox, compose/send emails, organize with labels/folders, search messages, draft responses, and handle attachments. Use for any email-related task including checking unread messages, sending replies, organizing inbox, or drafting professional correspondence.
---

# Email Management

Handle all email operations for the connected account.

## Capabilities

- **Read**: Fetch inbox, unread messages, specific emails, search by sender/subject/date
- **Compose**: Draft and send emails with formatting and attachments
- **Organize**: Label/folder management, archive, mark read/unread, delete
- **Search**: Find emails by any criteria (sender, subject, date range, content)
- **Reply**: Generate contextual responses, handle threads

## Quick Reference

### Check Unread
```bash
# Gmail
node scripts/gmail.js unread --limit 10

# Outlook  
node scripts/outlook.js unread --limit 10

# IMAP
node scripts/imap.js unread --limit 10
```

### Send Email
```bash
# All variants
node scripts/[provider].js send \
  --to "recipient@example.com" \
  --subject "Subject line" \
  --body "Email body content"
```

### Search
```bash
node scripts/[provider].js search --query "from:boss@company.com after:2026-01-01"
```

## Provider-Specific Details

Load the appropriate reference based on client's email provider:

- **Gmail / Google Workspace**: See [references/gmail.md](references/gmail.md)
- **Outlook / Microsoft 365**: See [references/outlook.md](references/outlook.md)
- **Generic IMAP/SMTP**: See [references/imap.md](references/imap.md)

## Workflows

### Daily Inbox Review
1. Fetch unread messages
2. Categorize by priority (urgent, action needed, FYI)
3. Summarize for user
4. Draft responses for high-priority items

### Email Drafting
1. Understand context/request
2. Match tone to recipient relationship
3. Keep concise but complete
4. Include clear call-to-action if needed
5. Proofread before sending

### Organizing
1. Apply labels/folders based on content
2. Archive processed emails
3. Flag items needing follow-up
4. Unsubscribe from unwanted newsletters (with permission)

## Best Practices

- Always confirm before sending emails on user's behalf
- Summarize long email threads instead of dumping raw content
- Respect user's communication style
- Never share email content outside authorized contexts
- Check for attachments when email mentions "attached"
