# WooCommerce

## Authentication

Uses REST API with consumer key/secret.

### Required Credentials
```env
WOOCOMMERCE_URL=https://yourstore.com
WOOCOMMERCE_KEY=ck_xxxxx
WOOCOMMERCE_SECRET=cs_xxxxx
```

### Setup Steps
1. WooCommerce → Settings → Advanced → REST API
2. Add key → Read/Write permissions
3. Copy Consumer Key and Secret

## API Endpoints

Base URL: `{store_url}/wp-json/wc/v3`

Authentication: Basic auth with key:secret or OAuth 1.0a

### Products

#### List Products
```
GET /products?per_page=50&status=publish
```

Filter by stock:
```
GET /products?stock_status=outofstock
GET /products?stock_status=lowstock
```

#### Get Product
```
GET /products/{id}
```

#### Create Product
```
POST /products
{
  "name": "Widget Pro",
  "type": "simple",
  "regular_price": "29.99",
  "description": "Product description",
  "sku": "WGT-PRO-001",
  "manage_stock": true,
  "stock_quantity": 100,
  "stock_status": "instock",
  "categories": [
    { "id": 15 }
  ]
}
```

#### Update Product
```
PUT /products/{id}
{
  "stock_quantity": 75
}
```

### Stock Management

#### Update Stock
```
PUT /products/{id}
{
  "stock_quantity": 50,
  "manage_stock": true
}
```

#### Batch Update
```
POST /products/batch
{
  "update": [
    { "id": 123, "stock_quantity": 50 },
    { "id": 456, "stock_quantity": 30 }
  ]
}
```

### Product Variations

For variable products:

#### List Variations
```
GET /products/{product_id}/variations
```

#### Update Variation Stock
```
PUT /products/{product_id}/variations/{variation_id}
{
  "stock_quantity": 25
}
```

### Reports

#### Stock Report
```
GET /reports/stock?status=lowstock
GET /reports/stock?status=outofstock
```

### Categories
```
GET /products/categories
POST /products/categories
```

## Stock Statuses

- `instock` - In stock
- `outofstock` - Out of stock
- `onbackorder` - Available for backorder

## Low Stock Threshold

Set in WooCommerce settings or per-product:
```json
{
  "low_stock_amount": 5
}
```

## Useful Queries

### Low Stock Products
```
GET /products?stock_status=lowstock&per_page=100
```

### Out of Stock
```
GET /products?stock_status=outofstock
```

### By Category
```
GET /products?category=15
```

### By SKU
```
GET /products?sku=WGT-PRO-001
```

## Webhooks

Create webhooks for stock changes:
```
POST /webhooks
{
  "name": "Low stock alert",
  "topic": "product.updated",
  "delivery_url": "https://your-endpoint.com/webhook"
}
```

Topics:
- `product.created`
- `product.updated`
- `product.deleted`
- `order.created` (affects stock)

## Rate Limits

Default: No hard limit, but be reasonable:
- Batch operations where possible
- Limit to ~25 requests/second
- Some hosts impose limits

## Common Issues

1. **Stock not updating**: Check `manage_stock: true`
2. **Variation stock**: Parent and variation both need `manage_stock`
3. **Authentication failed**: Verify key/secret, check HTTPS
4. **Permalink issues**: Ensure pretty permalinks enabled
