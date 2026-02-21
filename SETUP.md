# Deploy Skills - Complete Setup Guide

This guide covers everything needed to install and configure skills for a Deploy client.

## Overview

Deploy Skills is a modular library of AI agent capabilities. Each skill adds specific functionality (email, calendar, CRM, etc.) with variants for different platforms (Gmail vs Outlook, etc.).

---

## Prerequisites

- [Clawdbot](https://github.com/clawdbot/clawdbot) installed and running
- Client workspace set up (typically `~/clawd/`)
- Access to client's service accounts (API keys, OAuth, etc.)

---

## Quick Install (Recommended)

```bash
# Clone the skills repo
git clone https://github.com/iris-deployyouragent/deploy-skills.git
cd deploy-skills

# Run interactive installer
./installer/deploy-install.sh
```

The installer will:
1. Ask for client name and workspace path
2. Show available skills
3. Let you select which skills to install
4. Ask which variant for each skill (e.g., Gmail or Outlook)
5. Copy skills to client workspace
6. Generate `.env.template` with required credentials
7. Log the installation for tracking

---

## Manual Installation

If you prefer manual setup:

### Step 1: Copy the Skill

```bash
# Example: Install email-management skill
cp -r skills/email-management /path/to/client/skills/
```

### Step 2: Keep Only Needed Variant

Each skill has multiple variants (references). Remove the ones not needed:

```bash
# If client uses Gmail, remove other variants
cd /path/to/client/skills/email-management/references/
rm outlook.md imap.md
# Keep only gmail.md
```

### Step 3: Configure Credentials

Add required credentials to client's `.env`:

```env
# Gmail credentials
GMAIL_CLIENT_ID=your-client-id
GMAIL_CLIENT_SECRET=your-client-secret
GMAIL_REFRESH_TOKEN=your-refresh-token
```

### Step 4: Update AGENTS.md

Add skill reference to client's `AGENTS.md`:

```markdown
## Skills
- email-management (Gmail variant)
```

---

## Available Skills

| Skill | Description | Variants |
|-------|-------------|----------|
| **email-management** | Read, send, organize emails | gmail, outlook, imap |
| **calendar** | Schedule meetings, manage events | google, outlook |
| **customer-service** | Handle support tickets | zendesk, freshdesk, email |
| **invoicing** | Create invoices, track payments | xero, quickbooks, generic |
| **crm** | Manage leads and deals | hubspot, salesforce, deploy-crm |
| **inventory** | Track stock levels | shopify, woocommerce, generic |
| **document-management** | Organize and share files | google-drive, onedrive, dropbox |

---

## Skill Structure

Each skill follows this structure:

```
skill-name/
├── SKILL.md              # Main skill definition (agent reads this)
├── references/           # Platform-specific implementations
│   ├── variant1.md       # e.g., gmail.md
│   ├── variant2.md       # e.g., outlook.md
│   └── variant3.md       # e.g., imap.md
└── examples/             # (optional) Example usage
```

### SKILL.md Format

```markdown
---
name: skill-name
version: 1.0.0
description: What this skill does
credentials:
  - ENV_VAR_NAME: Description of what this is
variants:
  - variant1
  - variant2
---

# Skill Name

Instructions for the AI agent on how to use this skill...
```

---

## Credential Requirements

### Email Management

**Gmail:**
```env
GMAIL_CLIENT_ID=           # Google Cloud Console → APIs → Credentials
GMAIL_CLIENT_SECRET=       # Same location as above
GMAIL_REFRESH_TOKEN=       # From OAuth flow
GMAIL_USER_EMAIL=          # User's email address
```

**Outlook:**
```env
OUTLOOK_CLIENT_ID=         # Azure Portal → App registrations
OUTLOOK_CLIENT_SECRET=     # Same location
OUTLOOK_REFRESH_TOKEN=     # From OAuth flow
OUTLOOK_USER_EMAIL=        # User's email address
```

### Calendar

**Google Calendar:**
```env
GOOGLE_CALENDAR_CLIENT_ID=
GOOGLE_CALENDAR_CLIENT_SECRET=
GOOGLE_CALENDAR_REFRESH_TOKEN=
GOOGLE_CALENDAR_ID=        # Usually 'primary'
```

**Outlook Calendar:**
```env
OUTLOOK_CLIENT_ID=         # Same as email if using same app
OUTLOOK_CLIENT_SECRET=
OUTLOOK_REFRESH_TOKEN=
```

### CRM

**HubSpot:**
```env
HUBSPOT_API_KEY=           # Settings → Integrations → API key
# OR
HUBSPOT_ACCESS_TOKEN=      # Private app access token
```

**Salesforce:**
```env
SALESFORCE_CLIENT_ID=
SALESFORCE_CLIENT_SECRET=
SALESFORCE_REFRESH_TOKEN=
SALESFORCE_INSTANCE_URL=   # e.g., https://yourcompany.salesforce.com
```

### Invoicing

**Xero:**
```env
XERO_CLIENT_ID=
XERO_CLIENT_SECRET=
XERO_REFRESH_TOKEN=
XERO_TENANT_ID=
```

**QuickBooks:**
```env
QUICKBOOKS_CLIENT_ID=
QUICKBOOKS_CLIENT_SECRET=
QUICKBOOKS_REFRESH_TOKEN=
QUICKBOOKS_REALM_ID=       # Company ID
```

### Document Management

**Google Drive:**
```env
GOOGLE_DRIVE_CLIENT_ID=
GOOGLE_DRIVE_CLIENT_SECRET=
GOOGLE_DRIVE_REFRESH_TOKEN=
GOOGLE_DRIVE_FOLDER_ID=    # Root folder for agent access
```

**Dropbox:**
```env
DROPBOX_ACCESS_TOKEN=      # App Console → Generate token
DROPBOX_ROOT_PATH=         # e.g., /AgentFiles
```

---

## OAuth Setup Guides

### Google (Gmail, Calendar, Drive)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable required APIs:
   - Gmail API
   - Google Calendar API
   - Google Drive API
4. Go to **Credentials** → **Create Credentials** → **OAuth client ID**
5. Configure OAuth consent screen (External, add scopes)
6. Create Desktop app credentials
7. Download JSON, note Client ID and Secret
8. Use OAuth Playground or a script to get refresh token

### Microsoft (Outlook, OneDrive)

1. Go to [Azure Portal](https://portal.azure.com/)
2. Navigate to **Azure Active Directory** → **App registrations**
3. New registration (Accounts in any org + personal)
4. Add redirect URI: `http://localhost:3000/callback`
5. Go to **Certificates & secrets** → New client secret
6. Go to **API permissions** → Add:
   - Microsoft Graph: Mail.ReadWrite, Calendars.ReadWrite, Files.ReadWrite
7. Use MSAL or similar to get refresh token

### HubSpot

1. Go to [HubSpot Developers](https://developers.hubspot.com/)
2. Create app or use private app
3. For private apps: Settings → Integrations → Private Apps → Create
4. Add scopes: contacts, deals, tickets, etc.
5. Copy access token

### Xero

1. Go to [Xero Developer](https://developer.xero.com/)
2. Create new app (Web app type)
3. Add redirect URI
4. Note Client ID and Secret
5. Use OAuth2 flow to get tokens

---

## Client Installation Tracking

All installations are logged to `~/.deploy/clients/`:

```json
{
  "client": "Acme Corp",
  "installed": "2026-02-20T14:00:00+10:30",
  "workspace": "/home/acme/clawd",
  "skills": {
    "email-management": { "variant": "gmail", "version": "1.0.0" },
    "calendar": { "variant": "google", "version": "1.0.0" }
  },
  "credentials_template": ".env.template generated"
}
```

Use this to:
- Track what each client has installed
- Know which clients need updates when skills change
- Audit installations

---

## Updating Skills

### Update a Single Client

```bash
# Re-run installer for specific client
./installer/deploy-install.sh --client "Acme Corp"
```

### Update All Clients

```bash
# List all clients
ls ~/.deploy/clients/

# For each, re-run installer or manually copy updated skill
```

### Version Tracking

Check `registry/versions.json` for current skill versions:

```json
{
  "email-management": "1.0.0",
  "calendar": "1.0.0",
  "crm": "1.0.0"
}
```

---

## Creating New Skills

### Step 1: Create Skill Directory

```bash
mkdir -p skills/new-skill/references
```

### Step 2: Create SKILL.md

```markdown
---
name: new-skill
version: 1.0.0
description: What this skill does
credentials:
  - API_KEY: Description
variants:
  - variant1
  - variant2
---

# New Skill

Instructions for the AI agent...
```

### Step 3: Create Variant References

```bash
# skills/new-skill/references/variant1.md
# Platform-specific instructions and API details
```

### Step 4: Register the Skill

Update `registry/skills.json`:

```json
{
  "new-skill": {
    "name": "New Skill",
    "description": "What it does",
    "variants": ["variant1", "variant2"],
    "credentials": {
      "variant1": ["API_KEY"],
      "variant2": ["CLIENT_ID", "CLIENT_SECRET"]
    }
  }
}
```

### Step 5: Update Installer

Add skill to installer menu in `installer/deploy-install.sh`.

---

## Troubleshooting

### "Skill not found"
- Check skill is in correct path: `skills/skill-name/SKILL.md`
- Verify SKILL.md has correct frontmatter

### "Authentication failed"
- Verify credentials in `.env` are correct
- Check token hasn't expired (refresh if needed)
- Ensure correct scopes/permissions

### "API rate limited"
- Implement backoff in agent instructions
- Consider caching frequent requests
- Check provider's rate limits

### "Wrong variant installed"
- Check `references/` folder only has one variant
- Re-run installer and select correct variant

---

## Support

- **Deploy Docs:** https://deployyouragent.com/docs
- **Clawdbot Docs:** https://docs.clawd.bot
- **Discord:** https://discord.com/invite/clawd

---

## License

MIT - Use freely for Deploy client installations.

---

**Deploy Your Agent** - deployyouragent.com 🚀
