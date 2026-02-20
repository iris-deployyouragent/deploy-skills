---
name: inventory
description: Manage inventory with Shopify, WooCommerce, or generic tracking. Track stock levels, set reorder alerts, manage products, coordinate with suppliers. Use for any inventory task including checking stock, updating quantities, creating products, setting low-stock alerts, or generating inventory reports.
---

# Inventory Management

Track products, stock levels, and inventory operations.

## Capabilities

- **Products**: Create, update, organize products and variants
- **Stock**: Track quantities, locations, movements
- **Alerts**: Low stock warnings, reorder notifications
- **Orders**: Connect inventory to order fulfillment
- **Reports**: Stock valuation, movement history, turnover

## Quick Reference

### Check Stock Levels
```bash
node scripts/[provider].js stock --low-stock
```

### Update Quantity
```bash
node scripts/[provider].js update-stock \
  --sku "PROD-001" \
  --quantity 50 \
  --reason "Restocked from supplier"
```

### Create Product
```bash
node scripts/[provider].js create-product \
  --name "Widget Pro" \
  --sku "WGT-PRO-001" \
  --price 29.99 \
  --quantity 100
```

### Generate Report
```bash
node scripts/[provider].js report --type low-stock
```

## Provider-Specific Details

- **Shopify**: See [references/shopify.md](references/shopify.md)
- **WooCommerce**: See [references/woocommerce.md](references/woocommerce.md)
- **Generic**: See [references/generic.md](references/generic.md)

## Workflows

### Daily Stock Check
1. Query products below reorder point
2. Check incoming shipments
3. Review pending orders affecting stock
4. Generate low-stock report
5. Alert on critical items (< 1 week supply)

### Reorder Process
1. Identify products at reorder point
2. Calculate order quantity (based on lead time + safety stock)
3. Check supplier availability
4. Create purchase order
5. Update expected arrival date
6. Monitor until received

### Receive Shipment
1. Get shipment details (items, quantities)
2. Verify against purchase order
3. Update stock quantities
4. Note any discrepancies
5. Update product costs if changed
6. Close purchase order

### Inventory Audit
1. Pull current system quantities
2. Compare against physical count
3. Identify discrepancies
4. Investigate variances
5. Adjust quantities with notes
6. Document for accounting

## Stock Management Concepts

### Reorder Point
When to reorder:
```
Reorder Point = (Daily Sales × Lead Time) + Safety Stock
```

### Safety Stock
Buffer for variability:
```
Safety Stock = Daily Sales × Safety Days
```

### Economic Order Quantity
Optimal order size:
```
EOQ = √((2 × Annual Demand × Order Cost) / Holding Cost)
```

### Stock Statuses
- **In Stock**: Available for sale
- **Low Stock**: Below reorder point
- **Out of Stock**: Zero available
- **On Order**: Ordered from supplier
- **Reserved**: Allocated to orders

## Best Practices

- Set realistic reorder points based on lead times
- Include safety stock for popular items
- Track inventory movements with reasons
- Regular cycle counts vs annual full audit
- Separate display/warehouse stock if needed
- Monitor slow-moving inventory for markdowns
