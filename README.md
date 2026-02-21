# Deploy Skills

Modular skill library for Deploy Your Agent installations.

> **📘 Full Setup Guide:** See [SETUP.md](./SETUP.md) for complete installation and credential setup instructions.

## Quick Start

```bash
# Run the installer
./installer/deploy-install.sh
```

The installer walks you through selecting skills and variants for each client, then:
- Copies the right skills to their workspace
- Generates `.env.template` with required credentials
- Logs the installation for tracking

## Skills Included

| Skill | Variants | Description |
|-------|----------|-------------|
| **email-management** | gmail, outlook, imap | Read, send, organize emails |
| **calendar** | google, outlook | Schedule meetings, manage events |
| **customer-service** | zendesk, freshdesk, email | Handle support tickets |
| **invoicing** | xero, quickbooks, generic | Create invoices, track payments |
| **crm** | hubspot, salesforce, deploy-crm | Manage leads and deals |
| **inventory** | shopify, woocommerce, generic | Track stock levels |
| **document-management** | google-drive, onedrive, dropbox | Organize and share files |

## Structure

```
deploy-skills/
├── installer/
│   └── deploy-install.sh    # Interactive installer
├── registry/
│   ├── skills.json          # Skill definitions & credentials
│   └── versions.json        # Version tracking
└── skills/
    ├── email-management/
    │   ├── SKILL.md
    │   └── references/
    │       ├── gmail.md
    │       ├── outlook.md
    │       └── imap.md
    ├── calendar/
    ├── customer-service/
    ├── invoicing/
    ├── crm/
    ├── inventory/
    └── document-management/
```

## Manual Installation

If you prefer manual setup:

1. Copy the skill folder to client's `skills/` directory
2. Copy only the needed variant reference file
3. Add required credentials to their `.env`

Example:
```bash
# Install Gmail email management
cp -r skills/email-management /path/to/client/skills/
# Keep only gmail.md reference if they use Gmail
```

## Client Tracking

Installations are logged to `~/.deploy/clients/`:

```json
{
  "client": "Acme Corp",
  "installed": "2026-02-20T14:00:00+10:30",
  "workspace": "/home/acme/clawd",
  "skills": {
    "email-management": { "variant": "gmail", "version": "1.0.0" },
    "calendar": { "variant": "google", "version": "1.0.0" }
  }
}
```

## Updating Skills

To update a skill for all clients:

1. Update the skill in this repo
2. For each client in `~/.deploy/clients/`:
   - Re-run installer, or
   - Manually copy updated files

Future: Auto-update from GitHub (Phase 2).

## Adding New Skills

1. Create folder in `skills/`
2. Add `SKILL.md` with frontmatter
3. Add variant references in `references/`
4. Update `registry/skills.json`
5. Update installer to include new skill

## Credentials Reference

See `registry/skills.json` for full credential requirements per variant.

---

**Deploy Your Agent** - deployyouragent.com
