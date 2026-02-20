---
name: crm
description: Manage customer relationships with HubSpot, Salesforce, or Deploy CRM. Track leads, manage deals, log interactions, automate follow-ups, and analyze sales pipeline. Use for any sales task including adding leads, updating deal stages, logging calls/meetings, checking pipeline status, or planning follow-ups.
---

# CRM & Sales

Manage customer relationships, sales pipeline, and deal tracking.

## Capabilities

- **Contacts/Leads**: Create, update, search, segment
- **Deals/Opportunities**: Track through pipeline stages
- **Interactions**: Log calls, emails, meetings, notes
- **Tasks**: Create follow-up reminders, track completion
- **Pipeline**: View stages, forecast, identify bottlenecks
- **Reports**: Win rates, conversion metrics, activity summaries

## Quick Reference

### List Leads
```bash
node scripts/[provider].js leads --status new --limit 20
```

### Create Lead
```bash
node scripts/[provider].js create-lead \
  --name "John Smith" \
  --email "john@company.com" \
  --company "Acme Corp" \
  --source "website"
```

### Update Deal Stage
```bash
node scripts/[provider].js move-deal \
  --deal-id 123 \
  --stage "proposal"
```

### Log Interaction
```bash
node scripts/[provider].js log-activity \
  --contact 123 \
  --type call \
  --notes "Discussed pricing, sending proposal"
```

## Provider-Specific Details

- **HubSpot**: See [references/hubspot.md](references/hubspot.md)
- **Salesforce**: See [references/salesforce.md](references/salesforce.md)
- **Deploy CRM**: See [references/deploy-crm.md](references/deploy-crm.md)

## Workflows

### Lead Processing
1. New lead comes in
2. Enrich with available data (company info, LinkedIn)
3. Score based on criteria (company size, industry, engagement)
4. Assign to appropriate sales rep
5. Create initial follow-up task

### Deal Progression
1. Qualify lead (budget, authority, need, timeline)
2. Move through stages:
   - Prospecting → Qualified → Proposal → Negotiation → Closed
3. Update probability at each stage
4. Log all interactions
5. Set next action after each touchpoint

### Follow-up Management
1. Check tasks due today
2. Review overdue follow-ups
3. Prioritize by deal value and stage
4. Execute outreach
5. Log activity and schedule next step

### Pipeline Review
1. Pull all active deals
2. Group by stage
3. Calculate weighted pipeline value
4. Identify stalled deals (no activity in X days)
5. Flag at-risk opportunities
6. Generate summary for review

## Sales Best Practices

### Lead Qualification (BANT)
- **Budget**: Can they afford it?
- **Authority**: Are you talking to decision maker?
- **Need**: Is there a real problem to solve?
- **Timeline**: When do they need a solution?

### Follow-up Timing
- Hot lead: Same day
- Warm lead: Within 24 hours
- After demo: Within 2 hours
- After proposal: 2-3 days
- No response: 3-5-7 day sequence

### Interaction Logging
Always capture:
- Date and time
- Type (call, email, meeting)
- Participants
- Key discussion points
- Agreed next steps
- Follow-up date

## Best Practices

- Update CRM immediately after every interaction
- Never guess — confirm data with the contact
- Keep notes concise but complete
- Set specific follow-up dates, not vague reminders
- Review pipeline weekly for stale deals
