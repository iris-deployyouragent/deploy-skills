# QuickBooks Online

## Authentication

Uses OAuth 2.0 with Intuit.

### Required Credentials
```env
QUICKBOOKS_CLIENT_ID=your-client-id
QUICKBOOKS_CLIENT_SECRET=your-client-secret
QUICKBOOKS_REFRESH_TOKEN=your-refresh-token
QUICKBOOKS_REALM_ID=your-company-id
```

### Setup Steps
1. Create app at [developer.intuit.com](https://developer.intuit.com)
2. Set redirect URI
3. Select scopes: `com.intuit.quickbooks.accounting`
4. Complete OAuth flow
5. Get Realm ID (company ID) from auth response

## API Endpoints

Base URL: `https://quickbooks.api.intuit.com/v3/company/{realmId}`

Headers:
```
Authorization: Bearer {access_token}
Accept: application/json
Content-Type: application/json
```

### List Invoices
```
GET /query?query=SELECT * FROM Invoice WHERE Balance > '0' ORDERBY DueDate
```

Query language supports:
- `SELECT * FROM Invoice`
- `WHERE Balance > '0'` - unpaid
- `WHERE DueDate < '2026-02-20'` - overdue
- `ORDERBY`, `STARTPOSITION`, `MAXRESULTS`

### Get Invoice
```
GET /invoice/{invoiceId}
```

### Create Invoice
```
POST /invoice
{
  "CustomerRef": {
    "value": "customer-id"
  },
  "Line": [
    {
      "Amount": 1500,
      "DetailType": "SalesItemLineDetail",
      "SalesItemLineDetail": {
        "ItemRef": { "value": "item-id" },
        "Qty": 10,
        "UnitPrice": 150
      },
      "Description": "Consulting Services"
    }
  ],
  "DueDate": "2026-03-20"
}
```

### Update Invoice
```
POST /invoice?operation=update
{
  "Id": "invoice-id",
  "SyncToken": "0",
  "sparse": true,
  "DueDate": "2026-03-25"
}
```

Note: Must include current `SyncToken` for updates.

### Send Invoice
```
POST /invoice/{invoiceId}/send?sendTo=customer@email.com
```

### Record Payment
```
POST /payment
{
  "CustomerRef": { "value": "customer-id" },
  "TotalAmt": 1500,
  "Line": [
    {
      "Amount": 1500,
      "LinkedTxn": [
        {
          "TxnId": "invoice-id",
          "TxnType": "Invoice"
        }
      ]
    }
  ]
}
```

### Void Invoice
```
POST /invoice?operation=void
{
  "Id": "invoice-id",
  "SyncToken": "current-sync-token"
}
```

## Customers

### List Customers
```
GET /query?query=SELECT * FROM Customer WHERE Active = true
```

### Create Customer
```
POST /customer
{
  "DisplayName": "Acme Corporation",
  "PrimaryEmailAddr": { "Address": "billing@acme.com" }
}
```

## Reports

### Aged Receivables
```
GET /reports/AgedReceivables?date_macro=Today
```

### Profit and Loss
```
GET /reports/ProfitAndLoss?start_date=2026-01-01&end_date=2026-02-20
```

## Sandbox vs Production

- Sandbox: `https://sandbox-quickbooks.api.intuit.com`
- Production: `https://quickbooks.api.intuit.com`

Use sandbox for testing.

## Rate Limits

- 500 requests per minute per realm
- 10 concurrent requests
- Throttle with 429 response

## Common Issues

1. **SyncToken mismatch**: Always fetch latest before update
2. **Stale object**: Refetch and retry with new SyncToken
3. **Item not found**: Create item first, or use SalesItemLineDetail with manual amounts
4. **Minor version**: Add `?minorversion=65` for latest API features
