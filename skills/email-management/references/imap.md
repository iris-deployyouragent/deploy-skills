# Generic IMAP/SMTP

For email providers without dedicated APIs (custom domains, legacy systems).

## Authentication

Direct server credentials.

### Required Credentials
```env
IMAP_HOST=imap.provider.com
IMAP_PORT=993
IMAP_USER=user@domain.com
IMAP_PASSWORD=app-specific-password

SMTP_HOST=smtp.provider.com
SMTP_PORT=587
SMTP_USER=user@domain.com
SMTP_PASSWORD=app-specific-password
```

### Common Provider Settings

| Provider | IMAP Host | IMAP Port | SMTP Host | SMTP Port |
|----------|-----------|-----------|-----------|-----------|
| Gmail | imap.gmail.com | 993 | smtp.gmail.com | 587 |
| Outlook | outlook.office365.com | 993 | smtp.office365.com | 587 |
| Yahoo | imap.mail.yahoo.com | 993 | smtp.mail.yahoo.com | 587 |
| Zoho | imap.zoho.com | 993 | smtp.zoho.com | 587 |
| FastMail | imap.fastmail.com | 993 | smtp.fastmail.com | 587 |

## IMAP Operations

### Connect
```javascript
const Imap = require('imap');
const imap = new Imap({
  user: process.env.IMAP_USER,
  password: process.env.IMAP_PASSWORD,
  host: process.env.IMAP_HOST,
  port: process.env.IMAP_PORT,
  tls: true
});
```

### List Mailboxes
```javascript
imap.getBoxes((err, boxes) => {
  console.log(boxes); // INBOX, Sent, Drafts, etc.
});
```

### Fetch Unread
```javascript
imap.openBox('INBOX', false, () => {
  imap.search(['UNSEEN'], (err, uids) => {
    const fetch = imap.fetch(uids, { bodies: '' });
    // Process messages
  });
});
```

### Search
```javascript
// IMAP search criteria
imap.search([
  ['FROM', 'sender@email.com'],
  ['SINCE', 'Jan 1, 2026'],
  'UNSEEN'
], callback);
```

### Mark as Read
```javascript
imap.addFlags(uid, ['\\Seen'], callback);
```

### Move to Folder
```javascript
imap.move(uid, 'Archive', callback);
```

## SMTP Operations

### Send Email
```javascript
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: false, // true for 465
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASSWORD
  }
});

await transporter.sendMail({
  from: 'user@domain.com',
  to: 'recipient@email.com',
  subject: 'Subject',
  text: 'Plain text body',
  html: '<p>HTML body</p>'
});
```

### With Attachments
```javascript
await transporter.sendMail({
  // ...
  attachments: [
    { filename: 'doc.pdf', path: '/path/to/doc.pdf' }
  ]
});
```

## Limitations vs API

| Feature | API (Gmail/Outlook) | IMAP/SMTP |
|---------|---------------------|-----------|
| Speed | Fast | Slower |
| Labels/Categories | Full support | Limited |
| Search | Powerful | Basic |
| Threading | Native | Manual |
| Webhooks | Available | Not available |
| Rate limits | Documented | Varies |

## Best Practices

1. Use app-specific passwords (not main password)
2. Enable 2FA on the email account
3. Cache connections (don't reconnect per operation)
4. Handle connection drops gracefully
5. Respect server rate limits

## Common Issues

1. **Auth failed**: Check app-specific password, not regular password
2. **Connection timeout**: Verify host/port, check firewall
3. **TLS error**: Some servers need `tls: { rejectUnauthorized: false }`
4. **Encoding issues**: Decode quoted-printable and base64 content
