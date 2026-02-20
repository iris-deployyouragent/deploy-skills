# Deploy Skills Improvements Report

Investigation of Clawdbot's built-in skills (`/usr/local/lib/node_modules/clawdbot/skills/`) to identify best practices and improvements for our deploy-skills repo.

## What Clawdbot Does Well

### 1. YAML Frontmatter Metadata Structure
Clawdbot skills use rich metadata in frontmatter:
```yaml
---
name: skill-name
description: Comprehensive description with trigger phrases
homepage: https://docs.example.com
metadata: {"clawdbot":{"emoji":"🔐","requires":{"bins":["op"],"env":["API_KEY"]},"primaryEnv":"API_KEY","install":[...]}}
---
```

**Key features we're missing:**
- `homepage` - Link to official docs
- `metadata.clawdbot.emoji` - Visual identifier
- `metadata.clawdbot.requires` - Explicit dependencies (bins, env vars)
- `metadata.clawdbot.primaryEnv` - Main API key variable
- `metadata.clawdbot.install` - Auto-install instructions

### 2. Concise, Action-Oriented SKILL.md
Clawdbot skills are remarkably concise. They assume the AI is smart and only include:
- What's non-obvious
- Specific commands that work
- Critical guardrails
- References to detailed docs (not duplicated)

**Example: Weather skill is only 48 lines** - Just working curl commands, no fluff.

### 3. Reference Files for Deep Documentation
Instead of bloating SKILL.md, detailed docs go in `references/`:
- `references/configuration.md` - Setup details
- `references/api-docs.md` - API specifics
- Keeps SKILL.md lean (<500 lines ideally)

### 4. Scripts Directory for Executable Tools
Clawdbot skills include actual working scripts:
- `scripts/gen.py` - Actual Python scripts
- `scripts/validate.py` - Validation tools
- Not just placeholder "node scripts/[provider].js"

### 5. Progressive Disclosure Pattern
Three-level loading:
1. **Metadata** (always loaded) - Name + description for triggering
2. **SKILL.md body** (on trigger) - Core instructions
3. **References** (on demand) - Deep details

---

## Specific Improvements by Skill

### email-management

**Current Issues:**
- Placeholder scripts `node scripts/[provider].js` don't exist
- No scripts/ directory
- Missing `homepage` and metadata
- References are good but could include more working examples

**Improvements:**
```yaml
---
name: email-management
description: Manage emails across Gmail, Outlook, or IMAP providers. Read inbox, compose/send emails, organize with labels/folders, search messages, draft responses. Use when user asks to check email, send messages, find emails, or organize inbox.
homepage: https://developers.google.com/gmail/api
metadata: {"clawdbot":{"emoji":"📧","requires":{"env":["GMAIL_CREDENTIALS","OUTLOOK_TOKEN"]}}}
---
```

**Add scripts/:**
- `scripts/gmail-auth.py` - OAuth flow helper
- `scripts/imap-test.sh` - Connection test script

### crm

**Current Issues:**
- Same placeholder script pattern
- No actual executable code
- Good workflows but verbose

**Improvements:**
```yaml
---
name: crm
description: Manage customer relationships with HubSpot, Salesforce, or Deploy CRM. Track leads, manage deals, log interactions, check pipeline. Use for sales tasks, lead management, deal tracking, or pipeline review.
homepage: https://developers.hubspot.com/docs/api/overview
metadata: {"clawdbot":{"emoji":"🤝","requires":{"env":["HUBSPOT_API_KEY","SALESFORCE_TOKEN"]}}}
---
```

**Add scripts/:**
- `scripts/hubspot-cli.py` - Actual CLI wrapper

### calendar

**Current Issues:**
- Missing metadata
- Placeholder scripts

**Improvements:**
```yaml
---
name: calendar
description: Manage calendar events across Google Calendar or Outlook. Schedule meetings, check availability, set reminders, find free slots. Use when user needs to check schedule, book meetings, or find available times.
homepage: https://developers.google.com/calendar
metadata: {"clawdbot":{"emoji":"📅","requires":{"env":["GOOGLE_CALENDAR_TOKEN"]}}}
---
```

### invoicing

**Current Issues:**
- Very verbose SKILL.md (could trim 30%)
- No actual scripts

**Improvements:**
```yaml
---
name: invoicing
description: Manage invoicing with Xero, QuickBooks, or generic templates. Create invoices, track payments, send reminders. Use for billing, creating invoices, checking unpaid invoices, or payment follow-ups.
homepage: https://developer.xero.com/documentation
metadata: {"clawdbot":{"emoji":"💰","requires":{"env":["XERO_API_KEY","QUICKBOOKS_TOKEN"]}}}
---
```

### customer-service

**Improvements:**
```yaml
---
name: customer-service
description: Handle customer support via Zendesk, Freshdesk, or email. Manage tickets, respond to inquiries, escalate issues. Use for support tasks, ticket management, or drafting customer responses.
homepage: https://developer.zendesk.com
metadata: {"clawdbot":{"emoji":"🎧","requires":{"env":["ZENDESK_API_KEY"]}}}
---
```

### inventory

**Improvements:**
```yaml
---
name: inventory
description: Manage inventory with Shopify, WooCommerce, or generic tracking. Track stock, set reorder alerts, manage products. Use for stock checks, updating quantities, low-stock alerts, or inventory reports.
homepage: https://shopify.dev/docs/api
metadata: {"clawdbot":{"emoji":"📦","requires":{"env":["SHOPIFY_ACCESS_TOKEN"]}}}
---
```

### document-management

**Improvements:**
```yaml
---
name: document-management
description: Manage documents with Google Drive, OneDrive, or Dropbox. Upload, organize, search, share files. Use for finding documents, uploading files, sharing, or organizing file structures.
homepage: https://developers.google.com/drive
metadata: {"clawdbot":{"emoji":"📁","requires":{"env":["GOOGLE_DRIVE_TOKEN"]}}}
---
```

---

## General Improvements to Implement

### 1. Add Metadata to All Skills ✅
Add `homepage` and `metadata` fields with:
- Emoji for visual identification
- Required environment variables
- Primary API key reference

### 2. Add scripts/ Directory with Real Code
Start with simple utility scripts:
- Connection testers
- Auth flow helpers
- Sample API calls

### 3. Trim SKILL.md Verbosity
Follow Clawdbot's principle: "Only add context Codex doesn't already have."
- Remove obvious explanations
- Keep workflows actionable
- Move detailed API docs to references/

### 4. Improve Reference File Quality
Clawdbot's references include:
- Working configuration examples (copy-paste ready)
- Common issues and solutions
- Rate limit info
- Authentication flows

Our references have good structure but need:
- More copy-paste ready examples
- Troubleshooting sections
- Actual endpoint details

### 5. Add install Metadata for Auto-Setup
```yaml
metadata: {"clawdbot":{"install":[{"id":"brew","kind":"brew","formula":"tool-name","bins":["tool"],"label":"Install Tool (brew)"}]}}
```

---

## Implementation Priority

1. **High**: Add metadata to all SKILL.md files ✅
2. **High**: Create at least one real script per skill
3. **Medium**: Trim verbose sections in SKILL.md
4. **Medium**: Enhance references with troubleshooting
5. **Low**: Add install instructions for tools

---

## Reference Skills to Study

Best Clawdbot skills to reference:
- `1password/` - Perfect metadata, references, guardrails
- `himalaya/` - Great reference organization
- `github/` - Concise, practical examples
- `weather/` - Minimal but complete
- `sag/` - Good env var handling
- `discord/` - Comprehensive action catalog

---

*Generated: 2026-02-20*
*Source: Clawdbot skills analysis*
