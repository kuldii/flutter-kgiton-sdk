# KGiTON SDK - API Quick Reference Card

## 🚀 Initialization

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// Using default (https://dev-api.kgiton.com)
final api = KgitonApiService();
await api.loadConfiguration(); // Load saved tokens

// Or with custom URL
final api = KgitonApiService(baseUrl: 'https://custom-api.com');
```

**Current Configuration:**
- Base URL: `https://dev-api.kgiton.com`
- API Version: `/api/v1`
- Full URL: `https://dev-api.kgiton.com/api/v1/*`

---

## 🔐 Authentication

```dart
// Register
await api.auth.registerOwner(
  email: 'owner@example.com',
  password: 'pass123',
  licenseKey: 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX',
  entityType: 'individual', // or 'company'
  name: 'John Doe',
);

// Login
await api.auth.login(email: 'email', password: 'pass');

// Get current user
final user = await api.auth.getCurrentUser();

// Logout
await api.auth.logout();

// Check auth
if (api.isAuthenticated()) { /* ... */ }
```

---

## 📜 License Management (Super Admin)

```dart
// Create single
final license = await api.license.createLicense();

// Bulk create
final bulk = await api.license.bulkCreateLicenses(count: 100);

// List
final licenses = await api.license.listLicenses(
  status: 'unused', // 'all', 'used', 'unused'
  page: 1,
  limit: 50,
);

// Get detail
final detail = await api.license.getLicenseDetail(licenseId);

// Upload CSV
await api.license.uploadLicensesFromCsv('/path/to/file.csv');
```

---

## 👤 Owner Operations

```dart
// List own licenses
final licenses = await api.owner.listOwnLicenses();

// Assign additional license
await api.owner.assignAdditionalLicense('LICENSE-KEY');

// Create item
final item = await api.owner.createItem(
  licenseKey: 'KEY',
  name: 'Mangga',
  unit: 'kg',
  price: 25000,
);

// List items
final items = await api.owner.listItems('LICENSE-KEY');

// Get item
final item = await api.owner.getItemDetail(itemId);

// Update item
await api.owner.updateItem(
  itemId: itemId,
  name: 'New Name',
  price: 30000,
);

// Delete item
await api.owner.deleteItem(itemId);
```

---

## 🛒 Cart Management

```dart
import 'package:uuid/uuid.dart';

final cartId = Uuid().v4(); // Generate cart ID

// Add to cart
await api.cart.addToCart(
  cartId: cartId,
  licenseKey: 'KEY',
  itemId: 'item-id',
  quantity: 5.0,
  notes: 'Optional notes',
);

// View cart
final cart = await api.cart.viewCart(cartId: cartId);
print('Total: ${cart.summary.subtotal}');

// Update item
await api.cart.updateCartItem(
  cartItemId: cartItemId,
  quantity: 10.0,
);

// Remove item
await api.cart.removeCartItem(cartItemId);

// Clear cart by cart ID
await api.cart.clearCart(cartId);

// Clear cart by license (recommended after checkout)
await api.cart.clearCartByLicense(licenseKey: 'KEY');

// Process cart + checkout (best practice)
try {
  final result = await api.cart.processCart(
    cartId: cartId,
    licenseKey: 'KEY',
  );
  print('Transaction: ${result.transactionId}');
  
  // Clear cart after successful checkout (recommended)
  await api.cart.clearCartByLicense(licenseKey: 'KEY');
} catch (e) {
  // Don't clear on error - user can retry
}
```

---

## 💰 Transactions

```dart
// List transactions
final txList = await api.transaction.listTransactions(
  licenseKey: 'KEY',
  page: 1,
  limit: 20,
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime.now(),
);

// Get detail
final detail = await api.transaction.getTransactionDetail(txId);
print('Total: ${detail.transaction.total}');
for (var item in detail.items) {
  print('${item.itemName}: ${item.quantity}');
}

// Get summary
final summary = await api.transaction.getTransactionSummary(
  licenseKey: 'KEY',
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime.now(),
);
```

---

## ⚙️ Admin Settings (Super Admin)

```dart
// Get all settings
final settings = await api.adminSettings.getAllSettings();

// Get processing fee
final fee = await api.adminSettings.getCartProcessingFee();
print('Fee: ${fee.cartProcessingFee}');

// Update processing fee
await api.adminSettings.updateCartProcessingFee(1500);
```

---

## 🔧 Configuration

```dart
// Set base URL
api.setBaseUrl('https://api.kgiton.com');

// Set tokens
api.setTokens(
  accessToken: 'token',
  refreshToken: 'refresh',
);

// Save to storage
await api.saveConfiguration();

// Load from storage
await api.loadConfiguration();

// Clear storage
await api.clearConfiguration();

// Get tokens
final accessToken = api.auth.getAccessToken();
final refreshToken = api.auth.getRefreshToken();
```

---

## ⚠️ Error Handling

```dart
try {
  await api.auth.login(email: email, password: password);
} on KgitonValidationException catch (e) {
  print('Validation: ${e.message}');
} on KgitonAuthenticationException catch (e) {
  print('Auth failed: ${e.message}');
} on KgitonAuthorizationException catch (e) {
  print('No permission: ${e.message}');
} on KgitonNotFoundException catch (e) {
  print('Not found: ${e.message}');
} on KgitonConflictException catch (e) {
  print('Conflict: ${e.message}');
} on KgitonRateLimitException catch (e) {
  print('Rate limit: ${e.message}');
} on KgitonApiException catch (e) {
  print('API error: ${e.message}');
}
```

---

## 🎯 Common Patterns

### Login Flow
```dart
if (!api.isAuthenticated()) {
  await api.auth.login(email: email, password: password);
  await api.saveConfiguration();
}
```

### Complete Transaction Flow
```dart
// 1. Get items
final items = await api.owner.listItems('KEY');

// 2. Create cart
final cartId = Uuid().v4();

// 3. Add items
for (var item in items.items) {
  await api.cart.addToCart(
    cartId: cartId,
    licenseKey: 'KEY',
    itemId: item.id,
    quantity: 2.0,
  );
}

// 4. Process
final result = await api.cart.processCart(
  cartId: cartId,
  licenseKey: 'KEY',
);

print('Done! TX: ${result.transactionId}');
```

### Pagination Pattern
```dart
int page = 1;
const limit = 50;
bool hasMore = true;

while (hasMore) {
  final data = await api.license.listLicenses(
    status: 'all',
    page: page,
    limit: limit,
  );
  
  // Process data.licenses
  
  hasMore = page < data.pagination.totalPages;
  page++;
}
```

---

## 📱 UI Integration

### With Provider
```dart
class ApiProvider extends ChangeNotifier {
  final KgitonApiService api;
  bool _isLoading = false;
  String? _error;
  
  ApiProvider(this.api);
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await api.auth.login(email: email, password: password);
      await api.saveConfiguration();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### With FutureBuilder
```dart
FutureBuilder<ItemListData>(
  future: api.owner.listItems('KEY'),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }
    return ListView.builder(
      itemCount: snapshot.data!.items.length,
      itemBuilder: (context, index) {
        final item = snapshot.data!.items[index];
        return ListTile(
          title: Text(item.name),
          subtitle: Text('Rp ${item.price}'),
        );
      },
    );
  },
)
```

---

## 🔗 Quick Links

- [Complete Guide](docs_integrations/18-api-integration-guide.md)
- [API Reference](../../docs_api/API_REFERENCE.md)
- [Example App](example/lib/api_example.dart)
- [Module README](lib/src/api/README.md)

---

**Version**: 2.0.0 | **Updated**: Dec 6, 2025
