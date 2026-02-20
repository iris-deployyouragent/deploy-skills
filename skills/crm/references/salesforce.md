# Salesforce

## Authentication

Uses OAuth 2.0 with JWT or Web Server flow.

### Required Credentials
```env
SALESFORCE_CLIENT_ID=your-connected-app-client-id
SALESFORCE_CLIENT_SECRET=your-client-secret
SALESFORCE_REFRESH_TOKEN=your-refresh-token
SALESFORCE_INSTANCE_URL=https://yourorg.salesforce.com
```

### Setup Steps
1. Create Connected App in Setup → App Manager
2. Enable OAuth settings
3. Add scopes: `api`, `refresh_token`, `offline_access`
4. Complete OAuth flow to get refresh token
5. Note your instance URL

## API Endpoints

Base URL: `{instance_url}/services/data/v59.0`

### SOQL Queries
```
GET /query?q={SOQL_QUERY}
```

Example queries:
```sql
-- Recent leads
SELECT Id, Name, Email, Company, Status 
FROM Lead 
WHERE CreatedDate = LAST_N_DAYS:7

-- Open opportunities
SELECT Id, Name, Amount, StageName, CloseDate 
FROM Opportunity 
WHERE IsClosed = false

-- Contacts at company
SELECT Id, Name, Email, Phone 
FROM Contact 
WHERE Account.Name = 'Acme Corp'
```

### Leads

#### Create Lead
```
POST /sobjects/Lead
{
  "FirstName": "John",
  "LastName": "Smith",
  "Email": "john@company.com",
  "Company": "Acme Corp",
  "Status": "New"
}
```

#### Update Lead
```
PATCH /sobjects/Lead/{leadId}
{
  "Status": "Working"
}
```

#### Convert Lead
```
POST /sobjects/Lead/{leadId}/convert
```

### Opportunities

#### Create Opportunity
```
POST /sobjects/Opportunity
{
  "Name": "Acme Corp - Enterprise Deal",
  "Amount": 50000,
  "StageName": "Prospecting",
  "CloseDate": "2026-03-31",
  "AccountId": "account-id"
}
```

#### Update Stage
```
PATCH /sobjects/Opportunity/{oppId}
{
  "StageName": "Closed Won"
}
```

### Contacts

#### Create Contact
```
POST /sobjects/Contact
{
  "FirstName": "John",
  "LastName": "Smith",
  "Email": "john@company.com",
  "AccountId": "account-id"
}
```

### Accounts

#### Create Account
```
POST /sobjects/Account
{
  "Name": "Acme Corporation",
  "Industry": "Technology",
  "Website": "https://acme.com"
}
```

### Tasks

#### Create Task
```
POST /sobjects/Task
{
  "Subject": "Follow up call",
  "WhoId": "contact-id",
  "WhatId": "opportunity-id",
  "ActivityDate": "2026-02-25",
  "Status": "Not Started",
  "Priority": "High"
}
```

### Activities (Log Call/Email)

#### Log Call
```
POST /sobjects/Task
{
  "Subject": "Call - Discussed proposal",
  "Description": "Notes from the call...",
  "WhoId": "contact-id",
  "WhatId": "opportunity-id",
  "TaskSubtype": "Call",
  "Status": "Completed",
  "ActivityDate": "2026-02-20"
}
```

## Standard Opportunity Stages

- Prospecting
- Qualification
- Needs Analysis
- Value Proposition
- Id. Decision Makers
- Perception Analysis
- Proposal/Price Quote
- Negotiation/Review
- Closed Won
- Closed Lost

## Rate Limits

- Varies by org edition
- Check with: `GET /limits`
- Daily API requests: 15,000 - 1,000,000+ (by edition)
- Concurrent requests: 25

## Common Issues

1. **INVALID_SESSION_ID**: Refresh access token
2. **REQUIRED_FIELD_MISSING**: Check required fields for object
3. **DUPLICATE_VALUE**: Record with this value exists
4. **API not enabled**: Contact Salesforce admin
