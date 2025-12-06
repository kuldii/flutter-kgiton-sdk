# API Configuration Guide

## Overview

KGiTON SDK menggunakan sistem konfigurasi API yang robust dengan versioning untuk memudahkan maintenance dan update di masa depan.

## 🔧 Cara Mengubah Konfigurasi

### 📍 Lokasi File Konfigurasi
```
lib/src/api/api_constants.dart
```

### 🎯 Konfigurasi Saat Ini
- **Base URL**: `https://dev-api.kgiton.com`
- **API Version**: `/api/v1`
- **Contoh URL Lengkap**: `https://dev-api.kgiton.com/api/v1/auth/login`

### Cara Mengubah Base URL (baris 13)
```dart
class KgitonApiConfig {
  /// 🔧 CHANGE THIS: Update this URL when API endpoint changes
  static const String defaultBaseUrl = 'https://dev-api.kgiton.com';
}
```

**Contoh perubahan:**
- Development: `'https://dev-api.kgiton.com'` ✅ (saat ini)
- Production: `'https://api.kgiton.com'`
- Staging: `'https://staging-api.kgiton.com'`
- Local: `'http://localhost:3000'`

### Cara Mengubah API Version (baris 17)
```dart
  /// 🔧 CHANGE THIS: Update version prefix if API versioning changes
  static const String apiVersion = '/api/v1';
```

## API Constants

### 1. KgitonApiConfig

Kelas konfigurasi utama untuk API client:

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// Default configuration (uses dev-api.kgiton.com)
final api = KgitonApiService();

// Custom base URL
final api = KgitonApiService(baseUrl: 'https://your-api.com');
```

**Properties:**
- `defaultBaseUrl`: URL default API (`https://dev-api.kgiton.com`)
- `apiVersion`: Prefix versioning API (`/api/v1`)
- `requestTimeout`: Timeout untuk semua request (30 detik)
- `tokenStorageKey`: Key untuk menyimpan token di SharedPreferences

### 2. KgitonApiEndpoints

Kelas yang berisi semua endpoint paths. Endpoint sudah termasuk versioning prefix.

**Authentication Endpoints:**
```dart
KgitonApiEndpoints.registerOwner    // POST /v1/auth/register-owner
KgitonApiEndpoints.login            // POST /v1/auth/login
KgitonApiEndpoints.getCurrentUser   // GET /v1/auth/me
KgitonApiEndpoints.logout           // POST /v1/auth/logout
```

**License Management Endpoints (Super Admin):**
```dart
KgitonApiEndpoints.createLicense                    // POST /v1/licenses
KgitonApiEndpoints.bulkCreateLicenses              // POST /v1/licenses/bulk
KgitonApiEndpoints.listLicenses                    // GET /v1/licenses
KgitonApiEndpoints.getLicenseById(id)              // GET /v1/licenses/:id
KgitonApiEndpoints.updateLicense(id)               // PUT /v1/licenses/:id
KgitonApiEndpoints.deleteLicense(id)               // DELETE /v1/licenses/:id
KgitonApiEndpoints.uploadLicensesFromCsv           // POST /v1/licenses/upload-csv
KgitonApiEndpoints.downloadLicensesAsCsv           // GET /v1/licenses/download-csv
```

**Owner Operations Endpoints:**
```dart
KgitonApiEndpoints.listOwnerLicenses               // GET /v1/owner/licenses
KgitonApiEndpoints.assignAdditionalLicense         // POST /v1/owner/licenses/assign
```

**Items/Products Endpoints:**
```dart
KgitonApiEndpoints.createItem                      // POST /v1/items
KgitonApiEndpoints.listItems                       // GET /v1/items
KgitonApiEndpoints.getItemById(id)                 // GET /v1/items/:id
KgitonApiEndpoints.updateItem(id)                  // PUT /v1/items/:id
KgitonApiEndpoints.deleteItem(id)                  // DELETE /v1/items/:id
```

**Cart Endpoints:**
```dart
KgitonApiEndpoints.addToCart                       // POST /v1/cart/add
KgitonApiEndpoints.viewCart                        // GET /v1/cart
KgitonApiEndpoints.updateCartItem(cartItemId)      // PATCH /v1/cart/items/:id
KgitonApiEndpoints.removeFromCart(cartItemId)      // DELETE /v1/cart/items/:id
KgitonApiEndpoints.clearCart                       // DELETE /v1/cart/clear
KgitonApiEndpoints.processCart                     // POST /v1/cart/process
```

**Transaction Endpoints:**
```dart
KgitonApiEndpoints.listTransactions                // GET /v1/transactions
KgitonApiEndpoints.getTransactionById(id)          // GET /v1/transactions/:id
KgitonApiEndpoints.getTransactionStats             // GET /v1/transactions/stats
KgitonApiEndpoints.cancelTransaction(id)           // POST /v1/transactions/:id/cancel
KgitonApiEndpoints.paymentCallback                 // POST /v1/transactions/callback
```

**Admin Settings Endpoints (Super Admin):**
```dart
KgitonApiEndpoints.getAllSettings                  // GET /v1/admin/settings
KgitonApiEndpoints.getCartProcessingFee            // GET /v1/admin/settings/cart-processing-fee
KgitonApiEndpoints.updateCartProcessingFee         // PUT /v1/admin/settings/cart-processing-fee
```

### 3. Status Constants

**License Status:**
```dart
LicenseStatus.available   // 'available'
LicenseStatus.assigned    // 'assigned'
LicenseStatus.expired     // 'expired'
LicenseStatus.revoked     // 'revoked'
```

**Transaction Status:**
```dart
TransactionStatus.pending    // 'pending'
TransactionStatus.paid       // 'paid'
TransactionStatus.cancelled  // 'cancelled'
TransactionStatus.expired    // 'expired'
TransactionStatus.refunded   // 'refunded'
```

**Entity Type:**
```dart
EntityType.individual    // 'individual'
EntityType.company       // 'company'
```

**User Role:**
```dart
UserRole.owner          // 'owner'
UserRole.superAdmin     // 'super_admin'
```

### 4. Query Parameters

```dart
QueryParams.page         // 'page'
QueryParams.limit        // 'limit'
QueryParams.status       // 'status'
QueryParams.startDate    // 'start_date'
QueryParams.endDate      // 'end_date'
QueryParams.search       // 'search'
QueryParams.sortBy       // 'sort_by'
QueryParams.sortOrder    // 'sort_order'
```

### 5. Pagination Defaults

```dart
PaginationDefaults.defaultPage   // 1
PaginationDefaults.defaultLimit  // 10
PaginationDefaults.maxLimit      // 100
```

### 6. HTTP Status Codes

```dart
HttpStatusCode.ok                    // 200
HttpStatusCode.created               // 201
HttpStatusCode.noContent             // 204
HttpStatusCode.badRequest            // 400
HttpStatusCode.unauthorized          // 401
HttpStatusCode.forbidden             // 403
HttpStatusCode.notFound              // 404
HttpStatusCode.conflict              // 409
HttpStatusCode.tooManyRequests       // 429
HttpStatusCode.internalServerError   // 500
```

## Usage Examples

### Custom Configuration

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

void main() {
  // Production (default)
  final apiProd = KgitonApiService();
  
  // Staging
  final apiStaging = KgitonApiService(
    baseUrl: 'https://staging-api.kgiton.com',
  );
  
  // Development
  final apiDev = KgitonApiService(
    baseUrl: 'http://localhost:3000',
  );
}
```

### Using Status Constants

```dart
// Filter licenses by status
final licenses = await api.licenseService.listLicenses(
  status: LicenseStatus.available,
  page: PaginationDefaults.defaultPage,
  limit: 20,
);

// Filter transactions by status
final transactions = await api.transactionService.listTransactions(
  status: TransactionStatus.paid,
  page: 1,
  limit: PaginationDefaults.defaultLimit,
);
```

### Using Endpoint Constants Directly

```dart
// Jika Anda perlu menggunakan endpoint langsung
final endpoint = KgitonApiEndpoints.getItemById('item-uuid');
print(endpoint); // Output: /items/item-uuid

// Full URL akan menjadi: https://api.kgiton.com/v1/items/item-uuid
```

## Versioning

SDK ini menggunakan API versioning dengan prefix `/v1/`. Semua endpoint otomatis mendapat prefix ini melalui `KgitonApiClient._buildUrl()`.

**Format URL:**
```
{baseUrl}{apiVersion}{endpoint}

Contoh:
https://api.kgiton.com/v1/auth/login
https://api.kgiton.com/v1/items
https://api.kgiton.com/v1/cart/add
```

## Migration dari Versi 2.0.0

Jika Anda menggunakan versi 2.0.0, tidak ada breaking changes. Semua API tetap sama, hanya internal implementasi yang berubah menggunakan constants.

### Sebelum (2.0.0):
```dart
final api = KgitonApiService(baseUrl: 'https://api.kgiton.com');
```

### Sesudah (2.1.0):
```dart
// Cara 1: Gunakan default
final api = KgitonApiService();

// Cara 2: Custom URL tetap sama
final api = KgitonApiService(baseUrl: 'https://custom-api.com');
```

## Best Practices

1. **Gunakan Constants**: Selalu gunakan constants dari `KgitonApiEndpoints`, `LicenseStatus`, dll. untuk menghindari typo
2. **Environment-based Configuration**: Gunakan environment variables untuk base URL
3. **Timeout Handling**: Handle timeout exceptions dengan proper error messages
4. **Status Validation**: Gunakan status constants untuk validasi

## Troubleshooting

### Base URL berubah
```dart
// Ganti base URL setelah initialization
api.client.setBaseUrl('https://new-api.com');
await api.client.saveConfiguration();
```

### Custom Timeout
Timeout dikonfigurasi di `KgitonApiConfig.requestTimeout`. Untuk mengubahnya, perlu modify source code atau buat custom client.

### Versioning Changes
Jika API mengupdate ke v2, Anda hanya perlu update `KgitonApiConfig.apiVersion` dari `/v1` ke `/v2`.

## Related Documentation

- [API Integration Guide](./18-api-integration-guide.md)
- [API Quick Reference](../API_QUICK_REFERENCE.md)
- [API Implementation Summary](../API_IMPLEMENTATION_SUMMARY.md)
