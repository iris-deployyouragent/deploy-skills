# Email Assistant Skill

AI-powered email management for Clawdbot. Monitors inbox, categorizes messages, drafts replies, and sends with approval.

## Features

- **Inbox Monitoring** — Check for new emails on schedule
- **Smart Categorization** — Urgent, Client, Admin, Spam
- **Draft Replies** — AI-generated responses for approval
- **Approval Flow** — Review & send via Telegram/Discord
- **Follow-up Tracking** — Remind if no reply received
- **Template Library** — Common responses ready to go

## Setup

### 1. Gmail Configuration

**Option A: OAuth (Recommended)**
```bash
# Run the OAuth setup script
node scripts/setup-oauth.js
```

**Option B: App Password (Simpler)**
1. Enable 2FA on your Google account
2. Go to: https://myaccount.google.com/apppasswords
3. Generate app password for "Mail"
4. Add to config:
```json
{
  "email": "your@gmail.com",
  "appPassword": "xxxx xxxx xxxx xxxx"
}
```

### 2. Configuration

Edit `config/settings.json`:
```json
{
  "checkInterval": 15,
  "categories": {
    "urgent": ["urgent", "asap", "deadline", "important"],
    "client": ["inquiry", "quote", "booking", "interested"],
    "admin": ["receipt", "invoice", "notification", "automated"]
  },
  "autoArchive": ["newsletter", "promo", "unsubscribe"],
  "notifyChannel": "telegram"
}
```

### 3. Add to Clawdbot

In your Clawdbot config, add:
```yaml
skills:
  - name: email-assistant
    path: ./projects/deploy-skills/email-assistant
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `check email` | Manual inbox check |
| `draft reply to [sender]` | Create reply draft |
| `send draft [id]` | Approve and send |
| `email summary` | Today's email overview |
| `follow up on [subject]` | Set follow-up reminder |

### Automated Flows

**Inbox Check (every 15 min):**
1. Fetch unread emails
2. Categorize each message
3. Urgent → immediate notification
4. Client → draft reply, notify for approval
5. Admin → log, no notification
6. Spam → archive silently

**Reply Approval:**
```
📧 New client inquiry from john@acme.com

Subject: Quote request for AI setup

Draft reply:
"Hi John, Thanks for reaching out! I'd be happy to 
discuss our AI setup services..."

[✅ Send] [✏️ Edit] [🗑️ Discard]
```

## Scripts

| Script | Purpose |
|--------|---------|
| `check-inbox.js` | Fetch and categorize new emails |
| `draft-reply.js` | Generate AI reply drafts |
| `send-email.js` | Send approved emails |
| `setup-oauth.js` | OAuth configuration wizard |

## Templates

Pre-built response templates in `templates/`:
- `inquiry-response.md` — New lead reply
- `meeting-confirm.md` — Meeting confirmation
- `follow-up.md` — No-reply follow-up
- `out-of-office.md` — Auto-reply template

## Environment Variables

```bash
GMAIL_EMAIL=your@gmail.com
GMAIL_APP_PASSWORD=xxxx
# Or for OAuth:
GMAIL_CLIENT_ID=xxx
GMAIL_CLIENT_SECRET=xxx
GMAIL_REFRESH_TOKEN=xxx
```

## Integration with Deploy

This skill is part of the Deploy Your Agent business automation suite.
Pairs well with: calendar-assistant, crm-module, customer-service

---

*Built by Iris for Deploy Your Agent*
