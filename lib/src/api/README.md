# KGiTON SDK - API Module

Complete REST API client for KGiTON backend integration.

## 📦 Module Structure

```
lib/src/api/
├── kgiton_api_client.dart        # HTTP client with token management
├── kgiton_api_service.dart       # Main API service integrator
├── exceptions/
│   └── api_exceptions.dart       # Custom API exceptions
├── models/
│   ├── api_response.dart         # Generic response wrapper
│   ├── auth_models.dart          # Authentication models
│   ├── license_models.dart       # License management models
│   ├── item_models.dart          # Item/product models
│   ├── cart_models.dart          # Shopping cart models
│   ├── transaction_models.dart   # Transaction models
│   ├── admin_models.dart         # Admin settings models
│   └── models.dart               # Barrel export
└── services/
    ├── auth_service.dart         # Authentication service
    ├── license_service.dart      # License management (Super Admin)
    ├── owner_service.dart        # Owner operations
    ├── cart_service.dart         # Cart management
    ├── transaction_service.dart  # Transaction operations
    ├── admin_settings_service.dart # System settings
    └── services.dart             # Barrel export
```

## 🎯 Features

### Core Features
- ✅ HTTP client with automatic token management
- ✅ JWT token persistence via SharedPreferences
- ✅ Automatic token injection in headers
- ✅ Comprehensive error handling
- ✅ Type-safe models with JSON serialization
- ✅ Pagination support
- ✅ Query parameter handling

### Services Available

#### 1. Authentication Service
- Register owner with license key
- Login (owner/super admin)
- Get current user
- Logout with token cleanup

#### 2. License Service (Super Admin)
- Create single license
- Bulk create licenses (up to 1000)
- List licenses with filters (all/used/unused)
- Get license detail
- Upload licenses from CSV
- Download licenses as CSV

#### 3. Owner Service
- List own licenses
- Assign additional license (multi-branch)
- Create items
- List items by license
- Get item detail
- Update item
- Delete item

#### 4. Cart Service
- Add item to cart
- View cart with summary
- Update cart item quantity
- Remove cart item
- Clear entire cart
- Process cart to create transaction

#### 5. Transaction Service
- List transactions with pagination
- Filter by date range
- Get transaction detail with items
- Get transaction summary

#### 6. Admin Settings Service
- Get all system settings
- Get cart processing fee
- Update cart processing fee

## 🚀 Quick Start

### Installation

The API module is included in the main SDK. Just import:

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';
```

### Basic Usage

```dart
// Initialize
final apiService = KgitonApiService(
  baseUrl: 'https://api.kgiton.com',
);

// Load saved configuration
await apiService.loadConfiguration();

// Login
if (!apiService.isAuthenticated()) {
  await apiService.auth.login(
    email: 'owner@example.com',
    password: 'password123',
  );
  await apiService.saveConfiguration();
}

// Use services
final items = await apiService.owner.listItems('LICENSE-KEY');
final licenses = await apiService.owner.listOwnLicenses();
```

## 📚 Documentation

- **[Complete API Integration Guide](../../docs_integrations/18-api-integration-guide.md)** - Full documentation with examples
- **[API Reference](../../../../docs_api/API_REFERENCE.md)** - Backend API documentation
- **[Example App](../../example/lib/api_example.dart)** - Complete working example

## 🔧 Configuration

### Base URL Configuration

```dart
// Development
final devApi = KgitonApiService(baseUrl: 'http://localhost:3000');

// Production
final prodApi = KgitonApiService(baseUrl: 'https://api.kgiton.com');

// Change at runtime
apiService.setBaseUrl('https://staging.kgiton.com');
```

### Token Management

```dart
// Manual token management
apiService.setTokens(
  accessToken: 'your-access-token',
  refreshToken: 'your-refresh-token',
);

// Save to storage
await apiService.saveConfiguration();

// Load from storage
await apiService.loadConfiguration();

// Clear tokens
await apiService.clearConfiguration();

// Check authentication
bool isAuth = apiService.isAuthenticated();
```

## 🔐 Error Handling

### Exception Types

```dart
try {
  await apiService.auth.login(email: email, password: password);
} on KgitonValidationException catch (e) {
  // 400 - Validation error
  print('Validation: ${e.message}');
} on KgitonAuthenticationException catch (e) {
  // 401 - Authentication failed
  print('Auth failed: ${e.message}');
} on KgitonAuthorizationException catch (e) {
  // 403 - Permission denied
  print('No permission: ${e.message}');
} on KgitonNotFoundException catch (e) {
  // 404 - Resource not found
  print('Not found: ${e.message}');
} on KgitonConflictException catch (e) {
  // 409 - Conflict (duplicate)
  print('Conflict: ${e.message}');
} on KgitonRateLimitException catch (e) {
  // 429 - Too many requests
  print('Rate limit: ${e.message}');
} on KgitonApiException catch (e) {
  // Generic API error
  print('API error [${e.statusCode}]: ${e.message}');
}
```

## 📋 Models

### Authentication Models
- `User` - User account info
- `UserProfile` - User profile with role
- `AuthData` - Complete auth response
- `CurrentUserData` - Current user info

### License Models
- `License` - License information
- `LicenseListData` - Paginated license list
- `BulkLicenseData` - Bulk create result
- `OwnerLicensesData` - Owner's licenses

### Item Models
- `Item` - Product/item info
- `ItemListData` - Item list with count

### Cart Models
- `CartItem` - Item in cart
- `CartData` - Cart with items and summary
- `CartSummary` - Cart totals
- `ProcessCartData` - Transaction result

### Transaction Models
- `Transaction` - Transaction header
- `TransactionDetail` - Full transaction with items
- `TransactionDetailItem` - Line item
- `TransactionListData` - Paginated transaction list

### Admin Models
- `SystemSetting` - System setting
- `SystemSettingsData` - All settings
- `CartProcessingFeeData` - Processing fee value

## 🎨 Usage Examples

### Complete Workflow Example

```dart
// 1. Initialize and login
final api = KgitonApiService(baseUrl: 'http://localhost:3000');
await api.auth.login(
  email: 'owner@example.com',
  password: 'password123',
);

// 2. Get items
final itemData = await api.owner.listItems('LICENSE-KEY');

// 3. Create cart
final cartId = Uuid().v4();
for (var item in itemData.items) {
  await api.cart.addToCart(
    cartId: cartId,
    licenseKey: 'LICENSE-KEY',
    itemId: item.id,
    quantity: 2.0,
  );
}

// 4. View cart
final cart = await api.cart.viewCart(cartId: cartId);
print('Total: Rp ${cart.summary.subtotal}');

// 5. Process to transaction
final result = await api.cart.processCart(
  cartId: cartId,
  licenseKey: 'LICENSE-KEY',
);
print('Transaction ID: ${result.transactionId}');

// 6. View transactions
final txList = await api.transaction.listTransactions(
  licenseKey: 'LICENSE-KEY',
  page: 1,
  limit: 10,
);
```

### Super Admin Operations

```dart
// Create licenses
final license = await api.license.createLicense();
print('Created: ${license.licenseKey}');

// Bulk create
final bulk = await api.license.bulkCreateLicenses(count: 100);
print('Created ${bulk.count} licenses');

// List licenses
final licenses = await api.license.listLicenses(
  status: 'unused',
  page: 1,
  limit: 50,
);

// Update processing fee
await api.adminSettings.updateCartProcessingFee(1500);
```

## ⚙️ Advanced Configuration

### Custom HTTP Client

```dart
import 'package:http/http.dart' as http;

final customClient = http.Client();
final apiClient = KgitonApiClient(
  baseUrl: 'https://api.kgiton.com',
  httpClient: customClient,
);

final apiService = KgitonApiService.withClient(apiClient);
```

### Timeout Configuration

```dart
// Implement timeout in your HTTP client
final client = http.Client();
// Configure timeout settings as needed
```

## 🧪 Testing

### Unit Testing

```dart
import 'package:mockito/mockito.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

class MockApiClient extends Mock implements KgitonApiClient {}

void main() {
  test('Login success', () async {
    final mockClient = MockApiClient();
    final authService = KgitonAuthService(mockClient);
    
    // Setup mock response
    when(mockClient.post(any, body: anyNamed('body')))
      .thenAnswer((_) async => /* mock response */);
    
    // Test
    final result = await authService.login(
      email: 'test@example.com',
      password: 'password',
    );
    
    expect(result.user.email, 'test@example.com');
  });
}
```

## 🔒 Security Best Practices

1. **Never hardcode credentials**
   ```dart
   // ❌ Bad
   await api.auth.login(email: 'admin@example.com', password: 'pass123');
   
   // ✅ Good
   await api.auth.login(email: emailController.text, password: pwdController.text);
   ```

2. **Store tokens securely**
   - SDK uses SharedPreferences (secure on iOS, less secure on Android)
   - Consider using `flutter_secure_storage` for production

3. **Handle token expiration**
   ```dart
   try {
     await api.owner.listItems('KEY');
   } on KgitonAuthenticationException {
     // Token expired, redirect to login
     await api.auth.logout();
     Navigator.pushNamed(context, '/login');
   }
   ```

4. **Use HTTPS in production**
   ```dart
   final api = KgitonApiService(
     baseUrl: 'https://api.kgiton.com', // Always use HTTPS
   );
   ```

## 📊 Performance Tips

1. **Cache data when possible**
2. **Use pagination for large lists**
3. **Implement proper loading states**
4. **Handle errors gracefully**
5. **Dispose services when done**

```dart
@override
void dispose() {
  apiService.dispose(); // Clean up HTTP client
  super.dispose();
}
```

## 🐛 Troubleshooting

### Common Issues

**Issue**: 401 Unauthorized
```dart
// Solution: Check if logged in
if (!apiService.isAuthenticated()) {
  await apiService.auth.login(...);
}
```

**Issue**: Network errors
```dart
// Solution: Wrap in try-catch
try {
  await apiService.owner.listItems('KEY');
} catch (e) {
  print('Network error: $e');
  // Show retry button
}
```

**Issue**: Token not persisting
```dart
// Solution: Call saveConfiguration after login
await apiService.auth.login(...);
await apiService.saveConfiguration(); // Don't forget this!
```

## 📞 Support

- **Documentation**: See [API Integration Guide](../../docs_integrations/18-api-integration-guide.md)
- **Examples**: Check [example app](../../example/)
- **Issues**: Report at repository

## 📄 License

Proprietary - PT KGiTON. All rights reserved.

---

**Version**: 2.0.0  
**Last Updated**: December 6, 2025
