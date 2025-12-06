# KGiTON API Integration Guide

Panduan lengkap untuk mengintegrasikan KGiTON API dengan Flutter SDK.

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Authentication](#authentication)
- [License Management](#license-management)
- [Owner Operations](#owner-operations)
- [Cart Management](#cart-management)
- [Transaction Management](#transaction-management)
- [Admin Settings](#admin-settings)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)

---

## Installation

Pastikan SDK sudah terinstall dengan mengikuti [installation guide](./03-installation.md).

SDK ini sudah include dependency `http` untuk komunikasi API.

---

## Quick Start

### 1. Initialize API Service

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// Initialize dengan base URL
final apiService = KgitonApiService(
  baseUrl: 'http://localhost:3000',
);

// Atau load dari saved configuration
await apiService.loadConfiguration();
```

### 2. Login

```dart
try {
  final authData = await apiService.auth.login(
    email: 'owner@example.com',
    password: 'password123',
  );
  
  print('Login berhasil!');
  print('User: ${authData.user.email}');
  print('Role: ${authData.profile.role}');
  
  // Token akan otomatis disimpan
} on KgitonAuthenticationException catch (e) {
  print('Login gagal: ${e.message}');
} on KgitonApiException catch (e) {
  print('Error: ${e.message}');
}
```

### 3. Gunakan API

```dart
// List items
final items = await apiService.owner.listItems('LICENSE-KEY');

// Add to cart
final cartItem = await apiService.cart.addToCart(
  cartId: Uuid().v4(),
  licenseKey: 'LICENSE-KEY',
  itemId: items.items.first.id,
  quantity: 5.0,
);

// Process cart
final result = await apiService.cart.processCart(
  cartId: cartId,
  licenseKey: 'LICENSE-KEY',
);
```

---

## Configuration

### Set Base URL

```dart
// Saat inisialisasi
final apiService = KgitonApiService(
  baseUrl: 'https://api.kgiton.com',
);

// Atau ubah setelah inisialisasi
apiService.setBaseUrl('https://api.kgiton.com');
```

### Token Management

```dart
// Set tokens manually
apiService.setTokens(
  accessToken: 'your-access-token',
  refreshToken: 'your-refresh-token',
);

// Clear tokens
apiService.clearTokens();

// Check authentication status
bool isAuth = apiService.isAuthenticated();
```

### Save & Load Configuration

```dart
// Save configuration ke local storage
await apiService.saveConfiguration();

// Load configuration dari local storage
await apiService.loadConfiguration();

// Clear saved configuration
await apiService.clearConfiguration();
```

---

## Authentication

### Register Owner

```dart
try {
  final authData = await apiService.auth.registerOwner(
    email: 'newowner@example.com',
    password: 'securePassword123',
    licenseKey: 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX',
    entityType: 'individual', // or 'company'
    name: 'John Doe',
  );
  
  print('Registrasi berhasil!');
  print('User ID: ${authData.user.id}');
  
} on KgitonValidationException catch (e) {
  print('Validasi error: ${e.message}');
} on KgitonConflictException catch (e) {
  print('Email sudah terdaftar: ${e.message}');
}
```

### Login

```dart
final authData = await apiService.auth.login(
  email: 'owner@example.com',
  password: 'password123',
);

print('Token: ${authData.accessToken}');
```

### Get Current User

```dart
final currentUser = await apiService.auth.getCurrentUser();

print('Email: ${currentUser.user.email}');
print('Role: ${currentUser.profile.role}');
print('Name: ${currentUser.profile.name}');
```

### Logout

```dart
await apiService.auth.logout();
print('Logged out successfully');
```

### Check Authentication

```dart
if (apiService.auth.isAuthenticated()) {
  print('User is authenticated');
} else {
  print('User is not authenticated');
}
```

---

## License Management

**Note**: Semua operasi license management hanya untuk Super Admin.

### Create Single License

```dart
try {
  final license = await apiService.license.createLicense();
  print('License created: ${license.licenseKey}');
  
  // Atau dengan custom key
  final customLicense = await apiService.license.createLicense(
    licenseKey: 'CUSTOM-XXXXX-XXXXX-XXXXX-XXXXX',
  );
  
} on KgitonAuthorizationException catch (e) {
  print('Tidak ada akses: ${e.message}');
}
```

### Bulk Create Licenses

```dart
final result = await apiService.license.bulkCreateLicenses(count: 100);

print('Created: ${result.count} licenses');
print('Failed: ${result.failed} licenses');

for (var license in result.licenses) {
  print('License: ${license.licenseKey}');
}
```

### List Licenses

```dart
final licenseData = await apiService.license.listLicenses(
  status: 'unused', // 'all', 'used', or 'unused'
  page: 1,
  limit: 50,
);

print('Total: ${licenseData.pagination.total}');

for (var license in licenseData.licenses) {
  print('${license.licenseKey} - Used: ${license.isUsed}');
}
```

### Get License Detail

```dart
final license = await apiService.license.getLicenseDetail(licenseId);

print('Key: ${license.licenseKey}');
print('Used: ${license.isUsed}');
print('Assigned To: ${license.assignedTo}');
```

### Upload Licenses from CSV

```dart
try {
  final response = await apiService.license.uploadLicensesFromCsv(
    '/path/to/licenses.csv',
  );
  
  print('Upload result: ${response.message}');
  
} on KgitonValidationException catch (e) {
  print('CSV format invalid: ${e.message}');
}
```

---

## Owner Operations

### List Own Licenses

```dart
final ownerLicenses = await apiService.owner.listOwnLicenses();

print('Total licenses: ${ownerLicenses.count}');

for (var license in ownerLicenses.licenses) {
  print('License: ${license.licenseKey}');
}
```

### Assign Additional License

```dart
try {
  final license = await apiService.owner.assignAdditionalLicense(
    'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX',
  );
  
  print('License assigned: ${license.licenseKey}');
  
} on KgitonConflictException catch (e) {
  print('License sudah digunakan: ${e.message}');
}
```

### Create Item

```dart
final item = await apiService.owner.createItem(
  licenseKey: 'LICENSE-KEY',
  name: 'Mangga Harum Manis',
  unit: 'kg',
  price: 25000,
);

print('Item created: ${item.name} - Rp ${item.price}/${item.unit}');
```

### List Items

```dart
final itemData = await apiService.owner.listItems('LICENSE-KEY');

print('Total items: ${itemData.count}');

for (var item in itemData.items) {
  print('${item.name} - Rp ${item.price}/${item.unit}');
}
```

### Get Item Detail

```dart
final item = await apiService.owner.getItemDetail(itemId);

print('Name: ${item.name}');
print('Price: Rp ${item.price}');
print('Unit: ${item.unit}');
```

### Update Item

```dart
final updatedItem = await apiService.owner.updateItem(
  itemId: itemId,
  name: 'Mangga Harum Manis Premium',
  price: 30000,
);

print('Item updated: ${updatedItem.name}');
```

### Delete Item

```dart
await apiService.owner.deleteItem(itemId);
print('Item deleted successfully');
```

---

## Cart Management

### Generate Cart ID

```dart
import 'package:uuid/uuid.dart';

final uuid = Uuid();
final cartId = uuid.v4(); // Generate UUID v4
```

### Add Item to Cart

```dart
final cartItem = await apiService.cart.addToCart(
  cartId: cartId,
  licenseKey: 'LICENSE-KEY',
  itemId: 'item-uuid',
  quantity: 5.5,
  notes: 'Extra large size',
);

print('Added: ${cartItem.item.name}');
print('Quantity: ${cartItem.quantity}');
print('Total: Rp ${cartItem.totalPrice}');
```

### View Cart

```dart
final cartData = await apiService.cart.viewCart(
  cartId: cartId,
  licenseKey: 'LICENSE-KEY', // optional
);

print('Cart Summary:');
print('Total Items: ${cartData.summary.totalItems}');
print('Total Quantity: ${cartData.summary.totalQuantity}');
print('Subtotal: Rp ${cartData.summary.subtotal}');

print('\nItems:');
for (var item in cartData.items) {
  print('- ${item.item.name}: ${item.quantity} ${item.item.unit}');
  print('  Price: Rp ${item.totalPrice}');
}
```

### Update Cart Item

```dart
final updatedItem = await apiService.cart.updateCartItem(
  cartItemId: cartItemId,
  quantity: 10.0,
  notes: 'Updated notes',
);

print('Updated quantity: ${updatedItem.quantity}');
```

### Remove Cart Item

```dart
await apiService.cart.removeCartItem(cartItemId);
print('Item removed from cart');
```

### Clear Cart

```dart
await apiService.cart.clearCart(cartId);
print('Cart cleared');
```

### Process Cart & Checkout

💡 **Best Practice**: Clear cart after successful checkout using `clearCartByLicense()`.

```dart
try {
  // 1. Process cart (create transaction)
  final result = await apiService.cart.processCart(
    cartId: cartId,
    licenseKey: 'LICENSE-KEY',
  );

  print('Transaction created: ${result.transactionId}');
  print('Subtotal: Rp ${result.subtotal}');
  print('Processing Fee: Rp ${result.processingFee}');
  print('Total: Rp ${result.total}');
  print('Items: ${result.itemCount}');

  // 2. Clear cart after successful checkout (recommended)
  await apiService.cart.clearCartByLicense(
    licenseKey: 'LICENSE-KEY',
  );
  
  print('Cart cleared successfully');

  // 3. Update local state
  // Clear local cart items, reset UI, etc.

} catch (e) {
  print('Checkout failed: $e');
  // Don't clear cart on error - user can retry
}
```

### Clear Cart by License Key

Clear all cart items for a specific license. This is the recommended approach after checkout.

```dart
await apiService.cart.clearCartByLicense(
  licenseKey: 'LICENSE-KEY',
);
print('All carts for license cleared');
```

---

## Transaction Management

### List Transactions

```dart
final transactionData = await apiService.transaction.listTransactions(
  licenseKey: 'LICENSE-KEY',
  page: 1,
  limit: 20,
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime.now(),
);

print('Total: ${transactionData.pagination.total}');

for (var tx in transactionData.transactions) {
  print('ID: ${tx.id}');
  print('Total: Rp ${tx.total}');
  print('Date: ${tx.createdAt}');
}
```

### Get Transaction Detail

```dart
final txDetail = await apiService.transaction.getTransactionDetail(
  transactionId,
);

print('Transaction Info:');
print('Total: Rp ${txDetail.transaction.total}');
print('Subtotal: Rp ${txDetail.transaction.subtotal}');
print('Processing Fee: Rp ${txDetail.transaction.processingFee}');

print('\nItems:');
for (var item in txDetail.items) {
  print('- ${item.itemName}: ${item.quantity} ${item.unit}');
  print('  Price: Rp ${item.totalPrice}');
}
```

### Get Transaction Summary

```dart
final summary = await apiService.transaction.getTransactionSummary(
  licenseKey: 'LICENSE-KEY',
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime.now(),
);

print('Summary: $summary');
```

---

## Admin Settings

**Note**: Operasi ini hanya untuk Super Admin.

### Get All Settings

```dart
final settings = await apiService.adminSettings.getAllSettings();

for (var setting in settings.settings) {
  print('${setting.settingKey}: ${setting.settingValue}');
  print('Description: ${setting.description}');
}
```

### Get Cart Processing Fee

```dart
final feeData = await apiService.adminSettings.getCartProcessingFee();

print('Current processing fee: Rp ${feeData.cartProcessingFee}');
```

### Update Cart Processing Fee

```dart
final result = await apiService.adminSettings.updateCartProcessingFee(1500);

print('Fee updated to: Rp ${result.setting.settingValue}');
print('Updated by: ${result.setting.updatedBy}');
```

---

## Error Handling

### Exception Types

SDK menyediakan berbagai tipe exception:

```dart
try {
  // API call
  await apiService.auth.login(email: email, password: password);
  
} on KgitonValidationException catch (e) {
  // 400 - Validation errors
  print('Validation error: ${e.message}');
  print('Details: ${e.details}');
  
} on KgitonAuthenticationException catch (e) {
  // 401 - Authentication failed
  print('Authentication error: ${e.message}');
  
} on KgitonAuthorizationException catch (e) {
  // 403 - Permission denied
  print('Authorization error: ${e.message}');
  
} on KgitonNotFoundException catch (e) {
  // 404 - Resource not found
  print('Not found: ${e.message}');
  
} on KgitonConflictException catch (e) {
  // 409 - Conflict (e.g., duplicate)
  print('Conflict: ${e.message}');
  
} on KgitonRateLimitException catch (e) {
  // 429 - Too many requests
  print('Rate limit exceeded: ${e.message}');
  
} on KgitonApiException catch (e) {
  // Generic API error
  print('API error: ${e.message}');
  print('Status code: ${e.statusCode}');
  
} catch (e) {
  // Other errors
  print('Unexpected error: $e');
}
```

### Centralized Error Handler

```dart
Future<T?> handleApiCall<T>(Future<T> Function() apiCall) async {
  try {
    return await apiCall();
  } on KgitonAuthenticationException {
    // Redirect to login
    Navigator.pushNamed(context, '/login');
    return null;
  } on KgitonApiException catch (e) {
    // Show error dialog
    showErrorDialog(context, e.message);
    return null;
  } catch (e) {
    showErrorDialog(context, 'Unexpected error occurred');
    return null;
  }
}

// Usage
final items = await handleApiCall(() => 
  apiService.owner.listItems('LICENSE-KEY')
);
```

---

## Best Practices

### 1. Dependency Injection

```dart
class ApiProvider {
  static final KgitonApiService _instance = KgitonApiService(
    baseUrl: 'https://api.kgiton.com',
  );
  
  static KgitonApiService get instance => _instance;
}

// Usage
final items = await ApiProvider.instance.owner.listItems('KEY');
```

### 2. Save Configuration

```dart
// After login
await apiService.auth.login(email: email, password: password);
await apiService.saveConfiguration(); // Save tokens

// On app start
await apiService.loadConfiguration(); // Load saved tokens
```

### 3. Check Authentication Before API Calls

```dart
Future<void> fetchData() async {
  if (!apiService.isAuthenticated()) {
    // Redirect to login
    Navigator.pushNamed(context, '/login');
    return;
  }
  
  // Proceed with API call
  final data = await apiService.owner.listItems('KEY');
}
```

### 4. Use UUID for Cart ID

```dart
import 'package:uuid/uuid.dart';

class CartManager {
  final _uuid = Uuid();
  String? _currentCartId;
  
  String getOrCreateCartId() {
    _currentCartId ??= _uuid.v4();
    return _currentCartId!;
  }
  
  void clearCartId() {
    _currentCartId = null;
  }
}
```

### 5. Implement Retry Logic

```dart
Future<T> retryApiCall<T>(
  Future<T> Function() apiCall, {
  int maxRetries = 3,
  Duration delay = const Duration(seconds: 2),
}) async {
  int attempts = 0;
  
  while (attempts < maxRetries) {
    try {
      return await apiCall();
    } on KgitonApiException catch (e) {
      attempts++;
      if (attempts >= maxRetries) rethrow;
      
      await Future.delayed(delay);
    }
  }
  
  throw Exception('Max retries exceeded');
}
```

### 6. Loading States

```dart
class DataController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Item>? _items;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Item>? get items => _items;
  
  Future<void> loadItems(String licenseKey) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final data = await apiService.owner.listItems(licenseKey);
      _items = data.items;
    } on KgitonApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:uuid/uuid.dart';

class ApiExample extends StatefulWidget {
  @override
  _ApiExampleState createState() => _ApiExampleState();
}

class _ApiExampleState extends State<ApiExample> {
  late KgitonApiService apiService;
  final uuid = Uuid();
  String? cartId;
  
  @override
  void initState() {
    super.initState();
    _initializeApi();
  }
  
  Future<void> _initializeApi() async {
    apiService = KgitonApiService(
      baseUrl: 'http://localhost:3000',
    );
    
    // Load saved configuration
    await apiService.loadConfiguration();
    
    // Check if authenticated
    if (!apiService.isAuthenticated()) {
      await _login();
    }
  }
  
  Future<void> _login() async {
    try {
      await apiService.auth.login(
        email: 'owner@example.com',
        password: 'password123',
      );
      
      await apiService.saveConfiguration();
      print('Login successful');
    } catch (e) {
      print('Login failed: $e');
    }
  }
  
  Future<void> _createAndProcessOrder() async {
    try {
      // 1. Get items
      final itemData = await apiService.owner.listItems('LICENSE-KEY');
      
      if (itemData.items.isEmpty) {
        print('No items available');
        return;
      }
      
      // 2. Create cart
      cartId = uuid.v4();
      
      // 3. Add items to cart
      for (var item in itemData.items.take(3)) {
        await apiService.cart.addToCart(
          cartId: cartId!,
          licenseKey: 'LICENSE-KEY',
          itemId: item.id,
          quantity: 2.0,
        );
      }
      
      // 4. View cart
      final cart = await apiService.cart.viewCart(cartId: cartId!);
      print('Cart total: Rp ${cart.summary.subtotal}');
      
      // 5. Process cart
      final result = await apiService.cart.processCart(
        cartId: cartId!,
        licenseKey: 'LICENSE-KEY',
      );
      
      print('Transaction created: ${result.transactionId}');
      print('Total: Rp ${result.total}');
      
      // 6. Reset cart
      cartId = null;
      
    } on KgitonApiException catch (e) {
      print('Error: ${e.message}');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('KGiTON API Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: _createAndProcessOrder,
          child: Text('Create Order'),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    apiService.dispose();
    super.dispose();
  }
}
```

---

## Additional Resources

- [API Reference Documentation](../../docs_api/API_REFERENCE.md)
- [Authentication Guide](../../docs_api/AUTHENTICATION.md)
- [Cart API Documentation](../../docs_api/CART_API.md)
- [Error Handling Guide](../../docs_api/ERROR_HANDLING.md)

---

**Need Help?**

Jika ada pertanyaan atau masalah, silakan buka issue di repository atau hubungi tim support.
