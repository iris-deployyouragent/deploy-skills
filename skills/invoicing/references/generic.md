# Generic Invoicing (No System)

For businesses without dedicated accounting software.

## Overview

This variant uses:
- **PDF generation** for professional invoices
- **Spreadsheet tracking** for payment status
- **Email** for sending invoices and reminders

## Invoice Template

### HTML Template Structure

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; max-width: 800px; margin: auto; }
    .header { display: flex; justify-content: space-between; }
    .invoice-title { font-size: 2em; color: #333; }
    .invoice-details { background: #f5f5f5; padding: 1em; margin: 1em 0; }
    table { width: 100%; border-collapse: collapse; margin: 1em 0; }
    th, td { padding: 0.75em; text-align: left; border-bottom: 1px solid #ddd; }
    th { background: #333; color: white; }
    .total { font-size: 1.2em; font-weight: bold; text-align: right; }
    .footer { margin-top: 2em; font-size: 0.9em; color: #666; }
  </style>
</head>
<body>
  <div class="header">
    <div>
      <div class="invoice-title">INVOICE</div>
      <div>{{company_name}}</div>
      <div>{{company_address}}</div>
      <div>{{company_email}}</div>
    </div>
    <div style="text-align: right;">
      <div><strong>Invoice #:</strong> {{invoice_number}}</div>
      <div><strong>Date:</strong> {{date}}</div>
      <div><strong>Due Date:</strong> {{due_date}}</div>
    </div>
  </div>

  <div class="invoice-details">
    <strong>Bill To:</strong><br>
    {{customer_name}}<br>
    {{customer_address}}<br>
    {{customer_email}}
  </div>

  <table>
    <thead>
      <tr>
        <th>Description</th>
        <th>Qty</th>
        <th>Rate</th>
        <th>Amount</th>
      </tr>
    </thead>
    <tbody>
      {{#items}}
      <tr>
        <td>{{description}}</td>
        <td>{{quantity}}</td>
        <td>${{rate}}</td>
        <td>${{amount}}</td>
      </tr>
      {{/items}}
    </tbody>
  </table>

  <div class="total">
    Subtotal: ${{subtotal}}<br>
    Tax ({{tax_rate}}%): ${{tax}}<br>
    <strong>Total: ${{total}}</strong>
  </div>

  <div class="footer">
    <strong>Payment Terms:</strong> {{payment_terms}}<br>
    <strong>Payment Methods:</strong><br>
    Bank Transfer: {{bank_details}}<br>
    Or pay online: {{payment_link}}
  </div>
</body>
</html>
```

### Generate PDF

```bash
# Using wkhtmltopdf
wkhtmltopdf invoice.html invoice.pdf

# Using puppeteer (Node.js)
node scripts/generate-pdf.js --template invoice.html --output INV-001.pdf
```

## Invoice Numbering

Use sequential format:
- `INV-001`, `INV-002`, ... (simple)
- `INV-2026-001` (year prefix)
- `INV-20260220-001` (date prefix)

Track in spreadsheet or simple JSON:
```json
{
  "lastInvoiceNumber": 42,
  "prefix": "INV-2026-"
}
```

## Tracking Spreadsheet

### Structure

| Invoice # | Date | Customer | Amount | Due Date | Status | Paid Date | Notes |
|-----------|------|----------|--------|----------|--------|-----------|-------|
| INV-001 | 2026-02-01 | Acme Corp | $1,500 | 2026-03-01 | Paid | 2026-02-15 | |
| INV-002 | 2026-02-10 | Beta Inc | $3,000 | 2026-03-10 | Overdue | | Sent reminder |

### Status Values
- `Draft` - Not yet sent
- `Sent` - Sent to customer
- `Paid` - Payment received
- `Overdue` - Past due date
- `Void` - Cancelled

## Email Templates

### Send Invoice
```
Subject: Invoice {{invoice_number}} from {{company_name}}

Hi {{customer_name}},

Please find attached invoice {{invoice_number}} for ${{total}}.

Due date: {{due_date}}
Payment terms: {{payment_terms}}

Payment methods:
- Bank transfer: {{bank_details}}
- Online: {{payment_link}}

Thank you for your business!

Best regards,
{{company_name}}
```

### Payment Reminder
```
Subject: Reminder: Invoice {{invoice_number}} is due {{due_date}}

Hi {{customer_name}},

This is a friendly reminder that invoice {{invoice_number}} for ${{total}} is due on {{due_date}}.

If you've already sent payment, please disregard this message.

Payment methods:
- Bank transfer: {{bank_details}}
- Online: {{payment_link}}

Questions? Just reply to this email.

Best regards,
{{company_name}}
```

### Overdue Notice
```
Subject: OVERDUE: Invoice {{invoice_number}} - Payment Required

Hi {{customer_name}},

Invoice {{invoice_number}} for ${{total}} was due on {{due_date}} and is now {{days_overdue}} days overdue.

Please arrange payment at your earliest convenience to avoid any late fees.

Amount due: ${{total}}

Payment methods:
- Bank transfer: {{bank_details}}
- Online: {{payment_link}}

If you're experiencing difficulties, please contact us to discuss payment arrangements.

Best regards,
{{company_name}}
```

## When to Upgrade

Consider Xero/QuickBooks when:
- Processing 20+ invoices per month
- Need automated payment matching
- Require financial reporting
- Multiple team members need access
- Audit trail is critical

Both offer free trials and affordable starter plans.
