# HubSpot CRM

## Authentication

Uses API key or OAuth.

### Required Credentials
```env
HUBSPOT_API_KEY=your-api-key
```

Or for OAuth:
```env
HUBSPOT_CLIENT_ID=your-client-id
HUBSPOT_CLIENT_SECRET=your-client-secret
HUBSPOT_REFRESH_TOKEN=your-refresh-token
```

Get API key: Settings → Integrations → API key

## API Endpoints

Base URL: `https://api.hubapi.com`

### Contacts

#### List Contacts
```
GET /crm/v3/objects/contacts
  ?limit=100
  &properties=email,firstname,lastname,company
```

#### Search Contacts
```
POST /crm/v3/objects/contacts/search
{
  "filterGroups": [{
    "filters": [{
      "propertyName": "email",
      "operator": "EQ",
      "value": "john@company.com"
    }]
  }],
  "properties": ["email", "firstname", "lastname"]
}
```

#### Create Contact
```
POST /crm/v3/objects/contacts
{
  "properties": {
    "email": "john@company.com",
    "firstname": "John",
    "lastname": "Smith",
    "company": "Acme Corp",
    "phone": "+1234567890"
  }
}
```

#### Update Contact
```
PATCH /crm/v3/objects/contacts/{contactId}
{
  "properties": {
    "lifecyclestage": "customer"
  }
}
```

### Deals

#### List Deals
```
GET /crm/v3/objects/deals
  ?properties=dealname,amount,dealstage,closedate
```

#### Create Deal
```
POST /crm/v3/objects/deals
{
  "properties": {
    "dealname": "Acme Corp - Enterprise",
    "amount": "50000",
    "dealstage": "qualifiedtobuy",
    "closedate": "2026-03-31",
    "pipeline": "default"
  }
}
```

#### Update Deal Stage
```
PATCH /crm/v3/objects/deals/{dealId}
{
  "properties": {
    "dealstage": "closedwon"
  }
}
```

#### Associate Deal with Contact
```
PUT /crm/v3/objects/deals/{dealId}/associations/contacts/{contactId}/deal_to_contact
```

### Activities

#### Create Note
```
POST /crm/v3/objects/notes
{
  "properties": {
    "hs_note_body": "Called to discuss proposal. Very interested.",
    "hs_timestamp": "2026-02-20T10:00:00Z"
  }
}
```

Then associate with contact:
```
PUT /crm/v3/objects/notes/{noteId}/associations/contacts/{contactId}/note_to_contact
```

#### Create Task
```
POST /crm/v3/objects/tasks
{
  "properties": {
    "hs_task_body": "Follow up on proposal",
    "hs_task_subject": "Call John at Acme",
    "hs_task_status": "NOT_STARTED",
    "hs_task_priority": "HIGH",
    "hs_timestamp": "2026-02-25T10:00:00Z"
  }
}
```

#### Log Call
```
POST /crm/v3/objects/calls
{
  "properties": {
    "hs_call_body": "Discussed pricing options",
    "hs_call_direction": "OUTBOUND",
    "hs_call_duration": "900000",
    "hs_call_status": "COMPLETED",
    "hs_timestamp": "2026-02-20T10:00:00Z"
  }
}
```

### Pipeline

#### Get Pipeline Stages
```
GET /crm/v3/pipelines/deals
```

## Default Deal Stages

- `appointmentscheduled`
- `qualifiedtobuy`
- `presentationscheduled`
- `decisionmakerboughtin`
- `contractsent`
- `closedwon`
- `closedlost`

## Rate Limits

- 100 requests per 10 seconds (private apps)
- 150,000 requests per day
- Check `X-HubSpot-RateLimit-*` headers

## Common Issues

1. **Property doesn't exist**: Check property internal name (not label)
2. **Association failed**: Verify both objects exist first
3. **403 Forbidden**: API key needs correct scopes
