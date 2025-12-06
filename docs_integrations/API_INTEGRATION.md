# API Integration Guide

Complete guide for integrating with KGiTON backend API.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Authentication](#authentication)
3. [License Management](#license-management)
4. [Item Management](#item-management)
5. [Cart Operations](#cart-operations)
6. [Transactions](#transactions)
7. [Error Handling](#error-handling)
8. [Complete Workflows](#complete-workflows)

---

## Quick Start

### Initialize API Service

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// Use default production URL
final api = KgitonApiService();

// Or use custom URL
final api = KgitonApiService(
  baseUrl: 'https://your-api.com',
);

// Load saved configuration (tokens, base URL)
await api.loadConfiguration();
```

### Configuration

**Default Configuration:**
- Base URL: `https://dev-api.kgiton.com`
- API Version: `/api/v1`
- Full endpoint: `https://dev-api.kgiton.com/api/v1/*`

The SDK automatically:
- ✅ Manages JWT tokens
- ✅ Stores tokens locally (SharedPreferences)
- ✅ Includes auth header in requests
- ✅ Handles token expiration

---

## Authentication

### Register Owner

```dart
try {
  final auth = await api.auth.registerOwner(
    email: 'owner@example.com',
    password: 'SecurePass123',
    licenseKey: 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX',
    entityType: 'individual', // or 'company'
    name: 'John Doe',
    phone: '+628123456789',    // Optional
    address: '123 Main St',     // Optional
  );
  
  print('✅ Registered: ${auth.user.name}');
  print('Token: ${auth.accessToken}');
  
} on ApiException catch (e) {
  if (e.statusCode == 409) {
    print('❌ Email already registered');
  } else if (e.statusCode == 404) {
    print('❌ Invalid license key');
  } else {
    print('❌ Registration failed: ${e.message}');
  }
}
```

### Login

```dart
try {
  final auth = await api.auth.login(
    email: 'owner@example.com',
    password: 'SecurePass123',
  );
  
  print('✅ Logged in: ${auth.user.name}');
  // Token automatically stored
  
} on UnauthorizedException {
  print('❌ Invalid email or password');
} on ApiException catch (e) {
  print('❌ Login failed: ${e.message}');
}
```

### Get Current User

```dart
if (api.isAuthenticated()) {
  try {
    final user = await api.auth.getCurrentUser();
    
    print('Name: ${user.name}');
    print('Email: ${user.email}');
    print('Role: ${user.role}');
    print('Entity: ${user.entityType}');
    
  } catch (e) {
    print('Failed to get user: $e');
  }
} else {
  print('Not logged in');
}
```

### Logout

```dart
await api.auth.logout();
print('Logged out');
```

---

## License Management

### Super Admin: Create Licenses

```dart
// Create single license
final license = await api.license.createLicense();
print('License: ${license.licenseKey}');

// Bulk create
final bulk = await api.license.bulkCreateLicenses(count: 100);
print('Created ${bulk.count} licenses');
print('Keys: ${bulk.licenseKeys.join(", ")}');
```

### Super Admin: List All Licenses

```dart
final data = await api.license.listLicenses(
  status: 'unused',  // 'all', 'used', 'unused'
  page: 1,
  limit: 50,
);

print('Total: ${data.pagination.total}');
for (var license in data.licenses) {
  print('${license.licenseKey} - ${license.status}');
}
```

### Super Admin: Upload/Download CSV

```dart
// Upload licenses from CSV
await api.license.uploadLicensesFromCsv('/path/to/licenses.csv');

// Download licenses as CSV
await api.license.downloadLicensesCsv(
  savePath: '/path/to/save/licenses.csv',
  status: 'unused',
);
```

### Owner: List Own Licenses

```dart
final licenses = await api.owner.listOwnLicenses();

for (var license in licenses) {
  print('License: ${license.licenseKey}');
  print('Status: ${license.status}');
  print('Assigned: ${license.assignedAt}');
}
```

### Owner: Assign Additional License

```dart
try {
  await api.owner.assignAdditionalLicense('XXXXX-XXXXX-XXXXX-XXXXX-XXXXX');
  print('✅ License assigned successfully');
  
} on NotFoundException {
  print('❌ License not found or already used');
} on ApiException catch (e) {
  print('❌ Assignment failed: ${e.message}');
}
```

---

## Item Management

### Create Item

```dart
final item = await api.owner.createItem(
  licenseKey: 'YOUR-LICENSE-KEY',
  name: 'Mangga Harum Manis',
  unit: 'kg',
  price: 25000,
);

print('Item ID: ${item.id}');
print('Name: ${item.name}');
```

### List Items

```dart
final data = await api.owner.listItems(
  'YOUR-LICENSE-KEY',
  page: 1,
  limit: 20,
);

print('Total items: ${data.pagination.total}');
for (var item in data.items) {
  print('${item.name} - Rp ${item.price}/${item.unit}');
}
```

### Get Item Detail

```dart
final item = await api.owner.getItemDetail('item-id-here');
print('${item.name}: Rp ${item.price}/${item.unit}');
```

### Update Item

```dart
await api.owner.updateItem(
  itemId: 'item-id-here',
  name: 'Mangga Super',
  price: 30000,
  unit: 'kg',
);
print('✅ Item updated');
```

### Delete Item

```dart
await api.owner.deleteItem('item-id-here');
print('✅ Item deleted');
```

---

## Cart Operations

**See [CART_GUIDE.md](CART_GUIDE.md) for complete cart documentation.**

### Quick Cart Flow

```dart
import 'package:uuid/uuid.dart';

// 1. Create cart ID
final cartId = Uuid().v4();
final licenseKey = 'YOUR-LICENSE-KEY';

// 2. Add items (UPSERT: adds quantity if exists)
await api.cart.addToCart(
  cartId: cartId,
  licenseKey: licenseKey,
  itemId: 'item-id',
  quantity: 2.5,
);

// 3. View cart
final cart = await api.cart.viewCart(
  cartId: cartId,
  licenseKey: licenseKey,
);

print('Items: ${cart.summary.totalItems}');
print('Total: Rp ${cart.summary.grandTotal}');

// 4. Update item quantity (sets to specific value)
await api.cart.updateCartItem(
  cartItemId: cart.items[0].id,
  quantity: 3.0,  // Sets to 3.0 (not add 3.0)
);

// 5. Remove item
await api.cart.removeCartItem(cart.items[0].id);

// 6. Process cart (checkout) - auto-clears by default
final result = await api.cart.processCart(
  cartId: cartId,
  licenseKey: licenseKey,
  paymentMethod: 'qris',      // Optional
  notes: 'Mobile order',      // Optional
  // autoClear: true (default) - Cart auto-cleared!
);

print('✅ Transaction: ${result.transactionId}');
print('✅ Cart cleared automatically');

// Generate new cart ID for next session
cartId = Uuid().v4();
```

### Cart Methods Summary

| Method | Description | UPSERT? |
|--------|-------------|---------|
| `addToCart()` | Add item to cart | ✅ Adds quantity if exists |
| `viewCart()` | Get cart details | - |
| `updateCartItem()` | Set specific quantity | ❌ Sets value (not add) |
| `removeCartItem()` | Remove single item | - |
| `clearCart()` | Clear cart by cart ID | - |
| `clearCartByLicense()` | Clear all carts for license | - |
| `processCart()` | Checkout (auto-clears) | - |

---

## Transactions

### List Transactions

```dart
final data = await api.transaction.listTransactions(
  licenseKey: 'YOUR-LICENSE-KEY',
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime.now(),
  page: 1,
  limit: 20,
);

print('Total: ${data.pagination.total}');
for (var tx in data.transactions) {
  print('${tx.transactionId}: Rp ${tx.grandTotal}');
  print('Items: ${tx.itemCount}');
  print('Date: ${tx.createdAt}');
}
```

### Get Transaction Detail

```dart
final detail = await api.transaction.getTransactionDetail('transaction-id');

print('Transaction: ${detail.transaction.transactionId}');
print('Items: ${detail.items.length}');

for (var item in detail.items) {
  print('- ${item.itemName}: ${item.quantity} ${item.unit} @ Rp ${item.price}');
}

print('Subtotal: Rp ${detail.summary.subtotal}');
print('Processing Fee: Rp ${detail.summary.processingFee}');
print('Grand Total: Rp ${detail.summary.grandTotal}');
```

### Get Transaction Summary

```dart
final summary = await api.transaction.getTransactionSummary(
  licenseKey: 'YOUR-LICENSE-KEY',
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime.now(),
);

print('Total Transactions: ${summary.totalTransactions}');
print('Total Items Sold: ${summary.totalItemsSold}');
print('Total Revenue: Rp ${summary.totalRevenue}');
print('Avg per Transaction: Rp ${summary.avgTransactionValue}');
```

---

## Error Handling

### Exception Types

```dart
try {
  await api.auth.login(email: 'test@test.com', password: 'wrong');
  
} on UnauthorizedException catch (e) {
  // 401: Invalid credentials
  print('Login failed: ${e.message}');
  
} on ForbiddenException catch (e) {
  // 403: No permission
  print('Access denied: ${e.message}');
  
} on NotFoundException catch (e) {
  // 404: Resource not found
  print('Not found: ${e.message}');
  
} on ConflictException catch (e) {
  // 409: Resource conflict (e.g., email already exists)
  print('Conflict: ${e.message}');
  
} on RateLimitException catch (e) {
  // 429: Too many requests
  print('Rate limited. Try again in ${e.retryAfter} seconds');
  
} on ApiException catch (e) {
  // Generic API error
  print('Error ${e.statusCode}: ${e.message}');
  
} catch (e) {
  // Network or other errors
  print('Unexpected error: $e');
}
```

### Common Status Codes

| Code | Exception | Description |
|------|-----------|-------------|
| 400 | `ApiException` | Bad request / validation error |
| 401 | `UnauthorizedException` | Not authenticated / invalid credentials |
| 403 | `ForbiddenException` | No permission for this resource |
| 404 | `NotFoundException` | Resource not found |
| 409 | `ConflictException` | Resource conflict (duplicate) |
| 422 | `ApiException` | Validation failed |
| 429 | `RateLimitException` | Too many requests |
| 500 | `ApiException` | Server error |

---

## Complete Workflows

### Workflow 1: Owner Registration & Setup

```dart
Future<void> setupNewOwner() async {
  try {
    // 1. Register
    await api.auth.registerOwner(
      email: 'owner@example.com',
      password: 'password',
      licenseKey: 'LICENSE-KEY',
      entityType: 'individual',
      name: 'John Doe',
    );
    
    // 2. Login (if needed)
    await api.auth.login(
      email: 'owner@example.com',
      password: 'password',
    );
    
    // 3. List licenses
    final licenses = await api.owner.listOwnLicenses();
    final primaryLicense = licenses.first.licenseKey;
    
    // 4. Create items
    await api.owner.createItem(
      licenseKey: primaryLicense,
      name: 'Mangga',
      unit: 'kg',
      price: 25000,
    );
    
    await api.owner.createItem(
      licenseKey: primaryLicense,
      name: 'Apel',
      unit: 'kg',
      price: 30000,
    );
    
    print('✅ Owner setup complete');
    
  } catch (e) {
    print('❌ Setup failed: $e');
  }
}
```

### Workflow 2: Complete Shopping Flow

```dart
Future<void> completeShoppingFlow() async {
  try {
    // 1. Login
    await api.auth.login(
      email: 'owner@example.com',
      password: 'password',
    );
    
    final licenseKey = 'YOUR-LICENSE-KEY';
    
    // 2. Get items
    final itemsData = await api.owner.listItems(licenseKey);
    final items = itemsData.items;
    
    // 3. Create cart
    final cartId = Uuid().v4();
    
    // 4. Customer weighs items and adds to cart
    for (var item in items.take(3)) {
      final weight = 2.5; // From scale
      
      await api.cart.addToCart(
        cartId: cartId,
        licenseKey: licenseKey,
        itemId: item.id,
        quantity: weight,
      );
      
      print('Added ${item.name}: $weight kg');
    }
    
    // 5. View cart
    final cart = await api.cart.viewCart(
      cartId: cartId,
      licenseKey: licenseKey,
    );
    
    print('\n📦 Cart Summary:');
    print('Items: ${cart.summary.totalItems}');
    print('Total: Rp ${cart.summary.grandTotal}');
    
    // 6. Checkout
    final result = await api.cart.processCart(
      cartId: cartId,
      licenseKey: licenseKey,
      paymentMethod: 'qris',
      notes: 'Mobile checkout',
    );
    
    print('\n✅ Transaction completed!');
    print('ID: ${result.transactionId}');
    print('Total: Rp ${result.total}');
    print('Items: ${result.itemCount}');
    
  } catch (e) {
    print('❌ Shopping flow failed: $e');
  }
}
```

### Workflow 3: Daily Sales Report

```dart
Future<void> generateDailySalesReport() async {
  try {
    final licenseKey = 'YOUR-LICENSE-KEY';
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    // Get transaction summary
    final summary = await api.transaction.getTransactionSummary(
      licenseKey: licenseKey,
      startDate: startOfDay,
      endDate: endOfDay,
    );
    
    // Get transaction list
    final data = await api.transaction.listTransactions(
      licenseKey: licenseKey,
      startDate: startOfDay,
      endDate: endOfDay,
      limit: 100,
    );
    
    print('📊 Daily Sales Report');
    print('Date: ${startOfDay.toString().split(' ')[0]}');
    print('');
    print('Total Transactions: ${summary.totalTransactions}');
    print('Total Items Sold: ${summary.totalItemsSold}');
    print('Total Revenue: Rp ${summary.totalRevenue}');
    print('Average Transaction: Rp ${summary.avgTransactionValue}');
    print('');
    print('Recent Transactions:');
    
    for (var tx in data.transactions.take(5)) {
      print('- ${tx.transactionId}: Rp ${tx.grandTotal} (${tx.itemCount} items)');
    }
    
  } catch (e) {
    print('❌ Report failed: $e');
  }
}
```

---

## Configuration Management

### Save Custom Base URL

```dart
// Set custom URL
final api = KgitonApiService(
  baseUrl: 'https://production-api.kgiton.com',
);

// Save to local storage
await api.saveConfiguration();

// Later, load configuration
await api.loadConfiguration();
// baseUrl will be restored
```

### Check Authentication Status

```dart
if (api.isAuthenticated()) {
  print('✅ User is logged in');
  
  final user = await api.auth.getCurrentUser();
  print('User: ${user.name}');
} else {
  print('❌ Not logged in');
  // Navigate to login screen
}
```

---

## Best Practices

### 1. Always Handle Errors

```dart
try {
  await api.cart.processCart(...);
} on ApiException catch (e) {
  // Show error to user
  showErrorDialog('Checkout failed: ${e.message}');
} catch (e) {
  // Network or unexpected errors
  showErrorDialog('An error occurred. Please try again.');
}
```

### 2. Check Authentication Before API Calls

```dart
Future<void> loadItems() async {
  if (!api.isAuthenticated()) {
    // Navigate to login
    return;
  }
  
  try {
    final items = await api.owner.listItems(licenseKey);
    // ...
  } catch (e) {
    // Handle error
  }
}
```

### 3. Use Pagination for Large Lists

```dart
Future<List<Item>> loadAllItems(String licenseKey) async {
  List<Item> allItems = [];
  int page = 1;
  const limit = 50;
  
  while (true) {
    final data = await api.owner.listItems(
      licenseKey,
      page: page,
      limit: limit,
    );
    
    allItems.addAll(data.items);
    
    if (allItems.length >= data.pagination.total) {
      break;
    }
    
    page++;
  }
  
  return allItems;
}
```

### 4. Implement Retry Logic

```dart
Future<T> retryOperation<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
}) async {
  int attempts = 0;
  
  while (attempts < maxRetries) {
    try {
      return await operation();
    } catch (e) {
      attempts++;
      
      if (attempts >= maxRetries) {
        rethrow;
      }
      
      // Wait before retry
      await Future.delayed(Duration(seconds: 2 * attempts));
    }
  }
  
  throw Exception('Max retries exceeded');
}

// Usage
final items = await retryOperation(
  () => api.owner.listItems(licenseKey),
);
```

---

## Next Steps

- **Cart System**: Complete cart implementation guide - [CART_GUIDE.md](CART_GUIDE.md)
- **BLE Integration**: Connect to scale devices - [BLE_INTEGRATION.md](BLE_INTEGRATION.md)
- **Troubleshooting**: Common issues - [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
