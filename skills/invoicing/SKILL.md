---
name: invoicing
description: Manage invoicing and payments with Xero, QuickBooks, or generic templates. Create invoices, track payments, send reminders, reconcile accounts, and generate financial reports. Use for any billing task including creating invoices, checking unpaid invoices, sending payment reminders, or reconciling payments.
---

# Invoicing & Payments

Handle invoicing, payment tracking, and basic financial operations.

## Capabilities

- **Invoices**: Create, send, update, void invoices
- **Payments**: Record payments, track outstanding amounts
- **Reminders**: Automated payment reminders for overdue invoices
- **Contacts**: Manage customer/vendor billing information
- **Reports**: Outstanding invoices, cash flow, aging reports

## Quick Reference

### List Unpaid Invoices
```bash
node scripts/[provider].js invoices --status unpaid
```

### Create Invoice
```bash
node scripts/[provider].js create-invoice \
  --customer "Acme Corp" \
  --items '[{"description": "Consulting", "quantity": 10, "rate": 150}]' \
  --due-days 30
```

### Record Payment
```bash
node scripts/[provider].js record-payment \
  --invoice INV-001 \
  --amount 1500 \
  --method bank_transfer
```

### Send Reminder
```bash
node scripts/[provider].js send-reminder --invoice INV-001
```

## Provider-Specific Details

- **Xero**: See [references/xero.md](references/xero.md)
- **QuickBooks**: See [references/quickbooks.md](references/quickbooks.md)
- **Generic**: See [references/generic.md](references/generic.md)

## Workflows

### Create & Send Invoice
1. Verify customer exists (create if not)
2. Build line items with descriptions, quantities, rates
3. Set payment terms and due date
4. Add any notes or payment instructions
5. Create invoice in system
6. Send to customer via email

### Payment Follow-up
1. Check for invoices past due
2. Categorize by days overdue:
   - 1-7 days: Gentle reminder
   - 8-14 days: Firm reminder
   - 15-30 days: Urgent notice
   - 30+ days: Final notice / escalation
3. Send appropriate reminder
4. Log follow-up action

### Monthly Reconciliation
1. Pull all invoices for period
2. Match against received payments
3. Identify discrepancies
4. Update invoice statuses
5. Generate aging report
6. Flag bad debt candidates

### Cash Flow Check
1. Sum outstanding receivables
2. Group by expected payment date
3. Compare against upcoming expenses
4. Alert if potential shortfall

## Invoice Best Practices

### Required Fields
- Unique invoice number
- Date issued
- Due date
- Customer name and contact
- Line items with clear descriptions
- Total amount and currency
- Payment instructions

### Payment Terms
Common options:
- **Net 7/14/30** - Due in X days
- **Due on Receipt** - Immediate payment
- **2/10 Net 30** - 2% discount if paid in 10 days
- **50% Upfront** - Deposit required

### Professional Invoice Tips
- Include your logo and branding
- Clearly state payment methods accepted
- Add late payment fees if applicable
- Include PO number if customer requires
- Keep itemization clear and detailed

## Best Practices

- Always confirm invoice details before sending
- Never share customer financial data inappropriately
- Maintain audit trail of all changes
- Follow up on overdue invoices promptly
- Keep payment terms consistent per customer
