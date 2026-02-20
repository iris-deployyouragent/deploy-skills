# Xero

## Authentication

Uses OAuth 2.0.

### Required Credentials
```env
XERO_CLIENT_ID=your-client-id
XERO_CLIENT_SECRET=your-client-secret
XERO_REFRESH_TOKEN=your-refresh-token
XERO_TENANT_ID=your-tenant-id
```

### Setup Steps
1. Create app at [developer.xero.com](https://developer.xero.com)
2. Set redirect URI
3. Add scopes: `accounting.transactions`, `accounting.contacts`
4. Complete OAuth flow to get refresh token
5. Get tenant ID from `/connections` endpoint

## API Endpoints

Base URL: `https://api.xero.com/api.xro/2.0`

Headers required:
```
Authorization: Bearer {access_token}
Xero-Tenant-Id: {tenant_id}
```

### List Invoices
```
GET /Invoices
  ?where=Status=="AUTHORISED"
  &order=DueDate
```

Status values: `DRAFT`, `SUBMITTED`, `AUTHORISED`, `PAID`, `VOIDED`

Filter examples:
- `Status=="AUTHORISED"` - approved, unpaid
- `AmountDue>0` - has outstanding amount
- `DueDate<DateTime(2026,02,20)` - overdue

### Get Invoice
```
GET /Invoices/{InvoiceID}
```

### Create Invoice
```
POST /Invoices
{
  "Type": "ACCREC",
  "Contact": {
    "ContactID": "contact-guid"
  },
  "Date": "2026-02-20",
  "DueDate": "2026-03-20",
  "LineItems": [
    {
      "Description": "Consulting Services",
      "Quantity": 10,
      "UnitAmount": 150,
      "AccountCode": "200"
    }
  ],
  "Reference": "PO-12345",
  "Status": "AUTHORISED"
}
```

Type: `ACCREC` (receivable/sales), `ACCPAY` (payable/bills)

### Update Invoice
```
POST /Invoices/{InvoiceID}
{
  "InvoiceID": "invoice-guid",
  "Status": "AUTHORISED"
}
```

### Send Invoice
```
POST /Invoices/{InvoiceID}/Email
```

### Record Payment
```
PUT /Payments
{
  "Invoice": { "InvoiceID": "invoice-guid" },
  "Account": { "Code": "090" },
  "Date": "2026-02-20",
  "Amount": 1500
}
```

### Void Invoice
```
POST /Invoices/{InvoiceID}
{
  "InvoiceID": "invoice-guid",
  "Status": "VOIDED"
}
```

## Contacts (Customers)

### List Contacts
```
GET /Contacts?where=IsCustomer==true
```

### Create Contact
```
POST /Contacts
{
  "Name": "Acme Corporation",
  "EmailAddress": "billing@acme.com",
  "IsCustomer": true
}
```

## Reports

### Aged Receivables
```
GET /Reports/AgedReceivablesByContact
```

### Profit and Loss
```
GET /Reports/ProfitAndLoss?fromDate=2026-01-01&toDate=2026-02-20
```

## Rate Limits

- 5,000 calls per day per tenant
- 60 calls per minute
- Minute limit applies per connection

Use `X-Rate-Limit-Problem` header to detect issues.

## Common Issues

1. **Token expired**: Refresh tokens every 30 minutes
2. **Tenant not found**: Verify Xero-Tenant-Id header
3. **Invoice validation**: Check AccountCode exists, Contact valid
