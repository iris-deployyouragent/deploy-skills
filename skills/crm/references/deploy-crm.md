# Deploy CRM Module

Our own lightweight CRM built on Supabase.

## Authentication

Uses Supabase credentials.

### Required Credentials
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-or-service-key
CRM_AGENT_ID=client-identifier
```

## Overview

Simple, agent-friendly CRM with:
- Contacts (leads and customers)
- Pipeline stages
- Interactions (calls, emails, meetings)
- Tasks with due dates

Perfect for small businesses without enterprise CRM needs.

## CLI Commands

Location: `~/clawd/projects/crm-module/`

```bash
# Initialize default stages (once)
node src/cli.js init

# Contacts
node src/cli.js contacts list
node src/cli.js contacts create "Acme Corp" --email john@acme.com
node src/cli.js contacts search "acme"
node src/cli.js contacts move <id> <stage_id>

# Interactions
node src/cli.js interactions add <contact_id> call "Discussed pricing"
node src/cli.js interactions list --contact <id>

# Tasks
node src/cli.js tasks add "Follow up" --contact 1 --due 2026-02-25
node src/cli.js tasks list --overdue
node src/cli.js tasks complete <id>

# Stats
node src/cli.js stats all
```

## Database Schema

### contacts
```sql
CREATE TABLE contacts (
  id SERIAL PRIMARY KEY,
  agent_id TEXT NOT NULL,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  company TEXT,
  stage_id INTEGER REFERENCES stages(id),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### stages
```sql
CREATE TABLE stages (
  id SERIAL PRIMARY KEY,
  agent_id TEXT NOT NULL,
  name TEXT NOT NULL,
  position INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

Default stages:
1. New Lead
2. Contacted
3. Qualified
4. Proposal
5. Negotiation
6. Won
7. Lost

### interactions
```sql
CREATE TABLE interactions (
  id SERIAL PRIMARY KEY,
  agent_id TEXT NOT NULL,
  contact_id INTEGER REFERENCES contacts(id),
  type TEXT NOT NULL, -- 'call', 'email', 'meeting', 'note'
  notes TEXT,
  logged_by TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### tasks
```sql
CREATE TABLE tasks (
  id SERIAL PRIMARY KEY,
  agent_id TEXT NOT NULL,
  contact_id INTEGER REFERENCES contacts(id),
  description TEXT NOT NULL,
  due_date DATE,
  completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## API Usage (Direct Supabase)

```javascript
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
);

const agentId = process.env.CRM_AGENT_ID || 'default';

// List contacts in a stage
const { data: contacts } = await supabase
  .from('contacts')
  .select('*, stages(name)')
  .eq('agent_id', agentId)
  .eq('stage_id', stageId);

// Create contact
const { data: contact } = await supabase
  .from('contacts')
  .insert({
    agent_id: agentId,
    name: 'John Smith',
    email: 'john@acme.com',
    company: 'Acme Corp',
    stage_id: 1
  })
  .select()
  .single();

// Log interaction
await supabase
  .from('interactions')
  .insert({
    agent_id: agentId,
    contact_id: contactId,
    type: 'call',
    notes: 'Discussed pricing',
    logged_by: 'iris'
  });

// Create follow-up task
await supabase
  .from('tasks')
  .insert({
    agent_id: agentId,
    contact_id: contactId,
    description: 'Send proposal',
    due_date: '2026-02-25'
  });

// Get overdue tasks
const { data: overdue } = await supabase
  .from('tasks')
  .select('*, contacts(name)')
  .eq('agent_id', agentId)
  .eq('completed', false)
  .lt('due_date', new Date().toISOString().split('T')[0]);
```

## Multi-Tenancy

The `agent_id` field enables multi-tenant usage:
- Each client installation uses a unique agent_id
- Data is isolated per agent_id
- Same Supabase instance can serve multiple clients

```env
# Client A
CRM_AGENT_ID=acme-corp

# Client B
CRM_AGENT_ID=beta-inc
```

## Advantages

- **Simple**: No complex setup or learning curve
- **Cheap**: Supabase free tier handles most use cases
- **Flexible**: Easy to customize schema for client needs
- **Agent-Friendly**: CLI designed for AI agent use
- **Owned**: Client owns their data (their Supabase)

## When to Upgrade

Consider HubSpot/Salesforce when:
- Need advanced automation (workflows, sequences)
- Marketing integration required
- Team collaboration features needed
- Advanced reporting/forecasting required
- Integration with many third-party tools
