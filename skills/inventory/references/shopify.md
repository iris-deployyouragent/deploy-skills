# Shopify

## Authentication

Uses Admin API access token.

### Required Credentials
```env
SHOPIFY_STORE_URL=your-store.myshopify.com
SHOPIFY_ACCESS_TOKEN=shpat_xxxxx
```

### Setup Steps
1. Shopify Admin → Settings → Apps → Develop apps
2. Create new app
3. Configure Admin API scopes:
   - `read_products`, `write_products`
   - `read_inventory`, `write_inventory`
4. Install app to get access token

## API Endpoints

Base URL: `https://{store}.myshopify.com/admin/api/2024-01`

### Products

#### List Products
```
GET /products.json?limit=50&status=active
```

With inventory:
```
GET /products.json?fields=id,title,variants
```

#### Get Product
```
GET /products/{product_id}.json
```

#### Create Product
```
POST /products.json
{
  "product": {
    "title": "Widget Pro",
    "body_html": "<p>Product description</p>",
    "vendor": "Your Company",
    "product_type": "Widgets",
    "tags": "widget, pro, featured",
    "variants": [
      {
        "sku": "WGT-PRO-001",
        "price": "29.99",
        "inventory_management": "shopify",
        "inventory_quantity": 100
      }
    ]
  }
}
```

#### Update Product
```
PUT /products/{product_id}.json
{
  "product": {
    "id": 123456,
    "title": "Updated Title"
  }
}
```

### Inventory

#### Get Inventory Levels
```
GET /inventory_levels.json?inventory_item_ids=123,456,789
```

#### Adjust Inventory
```
POST /inventory_levels/adjust.json
{
  "location_id": 12345,
  "inventory_item_id": 67890,
  "available_adjustment": 10
}
```

Use negative number to decrease.

#### Set Inventory
```
POST /inventory_levels/set.json
{
  "location_id": 12345,
  "inventory_item_id": 67890,
  "available": 50
}
```

### Locations

#### List Locations
```
GET /locations.json
```

### Inventory Items

#### Get Inventory Item
```
GET /inventory_items/{inventory_item_id}.json
```

#### Update Cost
```
PUT /inventory_items/{inventory_item_id}.json
{
  "inventory_item": {
    "cost": "15.00"
  }
}
```

## Useful Queries

### Low Stock Products (GraphQL)
```graphql
{
  products(first: 50, query: "inventory_total:<10") {
    edges {
      node {
        id
        title
        totalInventory
        variants(first: 10) {
          edges {
            node {
              sku
              inventoryQuantity
            }
          }
        }
      }
    }
  }
}
```

### Products by Collection
```
GET /collections/{collection_id}/products.json
```

## Multi-Location Inventory

Shopify supports multiple locations:
1. Get locations: `GET /locations.json`
2. Check inventory per location
3. Transfer between locations (manual or via Shopify Flow)

## Rate Limits

- REST: 2 requests/second (burst of 40)
- GraphQL: 50 points/second (1000 point bucket)
- Check `X-Shopify-Shop-Api-Call-Limit` header

## Common Issues

1. **Inventory not tracking**: Ensure `inventory_management: "shopify"` on variant
2. **Location required**: Most inventory calls need location_id
3. **Variant vs Product**: Inventory is on variants, not products
