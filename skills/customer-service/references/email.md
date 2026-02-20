# Email-Only Customer Service

For businesses without a ticketing system — support handled via email.

## Setup

Uses the Email Management skill as the backend. No additional credentials needed beyond email access.

### Configuration
```env
SUPPORT_EMAIL=support@company.com
SUPPORT_FOLDER=Support  # Email folder/label for support messages
```

## Workflow

### Ticket = Email Thread

Without a ticketing system, each email thread is a "ticket":
- **Ticket ID** = Email thread ID / conversation ID
- **Status** = Manual tracking (use labels/folders)
- **Priority** = Manual assessment

### Suggested Folder Structure

```
📧 Support/
  ├── 📁 New/          (unread, needs response)
  ├── 📁 In Progress/  (being worked on)
  ├── 📁 Waiting/      (waiting for customer)
  ├── 📁 Resolved/     (completed)
  └── 📁 Escalated/    (needs attention)
```

## Operations

### Check New Tickets
```javascript
// Gmail
const newTickets = await gmail.search('label:Support/New is:unread');

// Outlook
const newTickets = await outlook.messages({
  filter: "parentFolderId eq 'support-new-folder-id' and isRead eq false"
});
```

### Process a Ticket
1. Read the email thread
2. Move from "New" to "In Progress"
3. Draft response
4. After sending, move to "Waiting" or "Resolved"

### Track Status with Labels/Folders

| Action | Gmail | Outlook |
|--------|-------|---------|
| New ticket | Label: Support/New | Folder: Support/New |
| In progress | Move to Support/InProgress | Move to Support/InProgress |
| Waiting | Move to Support/Waiting | Move to Support/Waiting |
| Resolved | Move to Support/Resolved | Move to Support/Resolved |

## Response Templates

### Acknowledgment
```
Subject: Re: {original subject}

Hi {name},

Thank you for contacting us. We've received your message and will get back to you within [X hours/days].

Your reference: {thread-id}

Best regards,
{company} Support
```

### Resolution
```
Subject: Re: {original subject}

Hi {name},

Great news! We've resolved your issue.

[Explanation of solution]

Is there anything else we can help with?

Best regards,
{company} Support
```

### Need More Info
```
Subject: Re: {original subject}

Hi {name},

Thank you for reaching out. To help you better, could you please provide:

- [Specific information needed]
- [Screenshots if applicable]

We'll get back to you as soon as we have this information.

Best regards,
{company} Support
```

## Tracking (Without a System)

### Option 1: Spreadsheet
Maintain a simple tracking sheet:
| Date | Customer | Subject | Status | Assigned | Notes |
|------|----------|---------|--------|----------|-------|

### Option 2: Labels/Tags
Use email labels to track:
- `support/priority-high`
- `support/category-billing`
- `support/status-waiting`

### Option 3: Notes in Email
Forward tickets to yourself with status notes, or use email notes feature (Outlook).

## Limitations

| Feature | Ticketing System | Email-Only |
|---------|------------------|------------|
| Ticket ID | Automatic | Thread ID |
| Assignment | Built-in | Manual |
| SLA tracking | Automatic | Manual |
| Analytics | Dashboard | Manual counting |
| Collision detection | Yes | No |
| Customer portal | Yes | No |

## When to Upgrade

Consider a ticketing system when:
- Volume exceeds 20+ tickets/day
- Multiple agents need to collaborate
- SLA tracking becomes critical
- Customer self-service is needed
- Reporting/analytics are required

Recommended: Start with Freshdesk Free (up to 10 agents) or Zendesk Suite Team.
