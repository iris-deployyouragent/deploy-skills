---
name: customer-service
description: Handle customer support via Zendesk, Freshdesk, or email. Manage tickets, respond to inquiries, escalate issues, track satisfaction. Use for support tasks, ticket management, answering customer questions, or drafting responses.
homepage: https://developer.zendesk.com
metadata: {"clawdbot":{"emoji":"🎧","requires":{"env":["ZENDESK_API_KEY","FRESHDESK_API_KEY"]},"primaryEnv":"ZENDESK_API_KEY"}}
---

# Customer Service

Handle customer support operations and ticket management.

## Capabilities

- **Tickets**: Create, update, assign, resolve, escalate
- **Responses**: Draft replies, use templates, personalize answers
- **Search**: Find tickets by customer, status, topic, date
- **Analytics**: Track response times, satisfaction scores, volume
- **Knowledge**: Reference FAQs, documentation, past solutions

## Quick Reference

### List Open Tickets
```bash
node scripts/[provider].js tickets --status open --limit 20
```

### Get Ticket Details
```bash
node scripts/[provider].js ticket --id 12345
```

### Reply to Ticket
```bash
node scripts/[provider].js reply --id 12345 --message "Response content"
```

### Create Ticket
```bash
node scripts/[provider].js create \
  --subject "Issue description" \
  --customer "customer@email.com" \
  --priority normal
```

## Provider-Specific Details

- **Zendesk**: See [references/zendesk.md](references/zendesk.md)
- **Freshdesk**: See [references/freshdesk.md](references/freshdesk.md)
- **Email-Only**: See [references/email.md](references/email.md)

## Workflows

### Ticket Triage
1. Fetch new/unassigned tickets
2. Categorize by type (technical, billing, general)
3. Assess priority (urgent, high, normal, low)
4. Assign or auto-respond based on category

### Response Drafting
1. Read full ticket history
2. Identify core issue
3. Check knowledge base for existing solution
4. Draft personalized response
5. Include next steps or resolution
6. Ask for confirmation before sending

### Escalation
1. Identify escalation triggers:
   - Customer explicitly requests
   - Issue beyond agent capability
   - VIP customer
   - Legal/compliance concern
2. Add internal note with context
3. Assign to appropriate team/person
4. Notify customer of escalation

### Daily Review
1. Check SLA breaches (tickets nearing deadline)
2. Follow up on pending customer responses
3. Review resolved tickets for proper closure
4. Flag patterns (recurring issues, angry customers)

## Response Guidelines

### Tone
- Professional but friendly
- Empathetic to frustration
- Solution-focused
- Clear and concise

### Structure
1. Acknowledge the issue
2. Apologize if appropriate
3. Explain the solution/next steps
4. Offer additional help
5. Thank them

### Templates to Adapt
- **Acknowledgment**: "Thanks for reaching out. I understand you're experiencing..."
- **Resolution**: "Great news! I've resolved this by..."
- **Need Info**: "To help you further, could you provide..."
- **Escalation**: "I've escalated this to our specialist team who will..."

## Best Practices

- Never share customer data across tickets
- Always verify customer identity for sensitive requests
- Document all actions in ticket notes
- Set realistic expectations on resolution time
- Follow up on resolved tickets after 24-48 hours
