# Generic Inventory Tracking

For businesses without e-commerce platforms — manual or spreadsheet-based inventory.

## Overview

Uses:
- **Spreadsheet** (Google Sheets or Excel) for data
- **Automated alerts** via email/Slack for low stock
- **Simple scripts** for common operations

## Spreadsheet Structure

### Products Sheet

| SKU | Name | Category | Cost | Price | Reorder Point | Supplier |
|-----|------|----------|------|-------|---------------|----------|
| WGT-001 | Widget Basic | Widgets | $10 | $25 | 20 | Acme Supply |
| WGT-PRO | Widget Pro | Widgets | $15 | $35 | 15 | Acme Supply |

### Stock Sheet

| SKU | Location | Quantity | Last Updated | Updated By |
|-----|----------|----------|--------------|------------|
| WGT-001 | Warehouse A | 45 | 2026-02-20 | Iris |
| WGT-001 | Store | 12 | 2026-02-20 | Iris |
| WGT-PRO | Warehouse A | 8 | 2026-02-19 | Manual |

### Movements Sheet (Audit Trail)

| Date | SKU | Type | Quantity | From | To | Reason | By |
|------|-----|------|----------|------|-----|--------|-----|
| 2026-02-20 | WGT-001 | Transfer | 10 | Warehouse A | Store | Restock | Iris |
| 2026-02-19 | WGT-PRO | Received | 50 | Supplier | Warehouse A | PO-123 | Manual |
| 2026-02-18 | WGT-001 | Adjustment | -3 | Warehouse A | - | Damaged | Manual |

### Purchase Orders Sheet

| PO # | Date | Supplier | Status | Expected | Total |
|------|------|----------|--------|----------|-------|
| PO-123 | 2026-02-15 | Acme Supply | Received | 2026-02-19 | $750 |
| PO-124 | 2026-02-20 | Beta Parts | Ordered | 2026-02-27 | $500 |

## Google Sheets Integration

### Using Google Sheets API
```env
GOOGLE_SHEETS_ID=your-spreadsheet-id
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret
GOOGLE_REFRESH_TOKEN=your-refresh-token
```

### Read Stock Levels
```javascript
const { google } = require('googleapis');

const sheets = google.sheets({ version: 'v4', auth });

const response = await sheets.spreadsheets.values.get({
  spreadsheetId: SHEETS_ID,
  range: 'Stock!A:E'
});

const rows = response.data.values;
```

### Update Stock
```javascript
await sheets.spreadsheets.values.update({
  spreadsheetId: SHEETS_ID,
  range: 'Stock!C2', // Quantity cell
  valueInputOption: 'RAW',
  requestBody: {
    values: [[newQuantity]]
  }
});
```

### Append Movement Log
```javascript
await sheets.spreadsheets.values.append({
  spreadsheetId: SHEETS_ID,
  range: 'Movements!A:H',
  valueInputOption: 'RAW',
  requestBody: {
    values: [[
      new Date().toISOString(),
      sku,
      type,
      quantity,
      fromLocation,
      toLocation,
      reason,
      updatedBy
    ]]
  }
});
```

## Low Stock Alert Script

```javascript
async function checkLowStock() {
  // Get products with reorder points
  const products = await getSheet('Products!A:G');
  const stock = await getSheet('Stock!A:C');
  
  // Build stock totals by SKU
  const stockBySku = {};
  for (const row of stock) {
    const [sku, location, qty] = row;
    stockBySku[sku] = (stockBySku[sku] || 0) + parseInt(qty);
  }
  
  // Check against reorder points
  const lowStock = [];
  for (const product of products) {
    const [sku, name, category, cost, price, reorderPoint] = product;
    const currentStock = stockBySku[sku] || 0;
    
    if (currentStock <= parseInt(reorderPoint)) {
      lowStock.push({
        sku,
        name,
        current: currentStock,
        reorderPoint: parseInt(reorderPoint)
      });
    }
  }
  
  if (lowStock.length > 0) {
    await sendAlert(lowStock);
  }
}
```

## Simple File-Based Tracking

If no spreadsheet, use JSON files:

### inventory.json
```json
{
  "products": {
    "WGT-001": {
      "name": "Widget Basic",
      "cost": 10,
      "price": 25,
      "reorderPoint": 20,
      "supplier": "Acme Supply"
    }
  },
  "stock": {
    "WGT-001": {
      "Warehouse A": 45,
      "Store": 12
    }
  },
  "lastUpdated": "2026-02-20T10:00:00Z"
}
```

### Operations
```javascript
const fs = require('fs');

function loadInventory() {
  return JSON.parse(fs.readFileSync('inventory.json'));
}

function saveInventory(data) {
  data.lastUpdated = new Date().toISOString();
  fs.writeFileSync('inventory.json', JSON.stringify(data, null, 2));
}

function updateStock(sku, location, quantity, reason) {
  const inv = loadInventory();
  const oldQty = inv.stock[sku]?.[location] || 0;
  
  if (!inv.stock[sku]) inv.stock[sku] = {};
  inv.stock[sku][location] = quantity;
  
  // Log movement
  const movement = {
    date: new Date().toISOString(),
    sku,
    change: quantity - oldQty,
    reason
  };
  
  saveInventory(inv);
  appendMovement(movement);
}
```

## When to Upgrade

Consider Shopify/WooCommerce when:
- Selling online (e-commerce needed)
- Inventory > 100 SKUs
- Multiple sales channels
- Need barcode scanning
- Complex variant management
- Integration with accounting

For offline-only retail, consider:
- Square for Retail
- Lightspeed
- Vend
