# 🚀 Henry's Setup Guide

Hey Henry! This guide covers everything you need to deploy and monitor agents for clients.

---

## Two Repos You Need

| Repo | Purpose |
|------|---------|
| [deploy-skills](https://github.com/iris-deployyouragent/deploy-skills) | Skill templates + installer for client agents |
| [iris-mission-control](https://github.com/iris-deployyouragent/iris-mission-control) | Dashboard to monitor all deployed agents |

---

## Part 1: Skills (Installing Agent Capabilities)

### One-Time Setup

```bash
# Clone the skills repo
git clone https://github.com/iris-deployyouragent/deploy-skills.git
cd deploy-skills
```

### For Each New Client

1. **Run the installer:**
   ```bash
   ./installer/deploy-install.sh
   ```

2. **Follow the prompts:**
   - Enter client name
   - Enter their agent workspace path
   - Select which skills they need:
     - 📧 Email (Gmail / Outlook / IMAP)
     - 📅 Calendar (Google / Outlook)
     - 💬 Customer Service (Zendesk / Freshdesk / Email)
     - 💰 Invoicing (Xero / QuickBooks / Generic)
     - 📊 CRM (HubSpot / Salesforce / Deploy CRM)
     - 📦 Inventory (Shopify / WooCommerce / Generic)
     - 📁 Documents (Google Drive / OneDrive / Dropbox)

3. **What happens:**
   - Skills get copied to their workspace
   - `.env.template` is generated with required credentials
   - Installation is logged to `~/.deploy/clients/`

4. **Get credentials from client:**
   - Send them the `.env.template` 
   - They fill in their API keys / passwords
   - Rename to `.env`

5. **Restart their agent:**
   ```bash
   clawdbot gateway restart
   ```

### Available Skills

| Skill | What It Does |
|-------|--------------|
| email-management | Read inbox, send emails, organize |
| calendar | Schedule meetings, check availability |
| customer-service | Handle support tickets |
| invoicing | Create invoices, track payments |
| crm | Manage leads, deals, contacts |
| inventory | Track stock levels |
| document-management | Organize files, share docs |

---

## Part 2: Mission Control (Monitoring Agents)

### Option A: One Dashboard Per Client

For each client:

1. **Create Supabase project:**
   - Go to [supabase.com](https://supabase.com)
   - Create new project
   - Save the URL + anon key + service role key

2. **Set up database:**
   - Go to SQL Editor in Supabase
   - Copy contents of `database-setup.sql` from the mission-control repo
   - Run it

3. **Deploy dashboard:**
   ```bash
   git clone https://github.com/iris-deployyouragent/iris-mission-control.git
   cd iris-mission-control
   npm install
   
   # Create .env.local with their Supabase credentials
   cp .env.example .env.local
   # Edit .env.local with their values
   
   # Deploy
   npx vercel --prod
   ```

4. **Set up agent scripts:**
   - Copy `scripts/` folder to their agent workspace
   - Create `scripts/.env` with their Supabase credentials
   - Add heartbeat checks to their HEARTBEAT.md

### Option B: Shared Dashboard (Multi-Agent)

Use ONE Supabase project for all clients:
- Each agent gets a unique `AGENT_NAME`
- Filter by agent in the dashboard
- Saves on Supabase projects

---

## Quick Reference

### Client Installation Checklist

- [ ] Run skill installer
- [ ] Get credentials from client
- [ ] Set up their .env
- [ ] Deploy Mission Control (or add to shared)
- [ ] Test all skills work
- [ ] Show client the dashboard

### File Locations

```
Client workspace:
├── skills/           # Installed skills
├── scripts/          # Mission Control scripts
├── .env              # Credentials
└── HEARTBEAT.md      # Agent check-in config

Your machine:
├── ~/.deploy/clients/  # Installation logs
└── deploy-skills/      # This repo
```

### Useful Commands

```bash
# Check agent status
clawdbot status

# Restart agent
clawdbot gateway restart

# View agent logs
clawdbot gateway logs

# Test a skill
# (just ask the agent to do something from that skill)
```

---

## Troubleshooting

**Agent not picking up skills?**
→ Restart: `clawdbot gateway restart`

**Skill not working?**
→ Check `.env` has all required credentials
→ Check the skill's SKILL.md for setup instructions

**Dashboard not showing data?**
→ Verify Supabase credentials in `.env.local`
→ Check database tables exist (run SQL again if needed)

**Need help?**
→ Ask in the team chat, we got you 👊

---

## Updates

When we update skills or the dashboard:

```bash
# Update skills repo
cd deploy-skills && git pull

# Update mission-control
cd iris-mission-control && git pull && npm install && npx vercel --prod
```

---

Welcome to the team! 🎉

— Iris
