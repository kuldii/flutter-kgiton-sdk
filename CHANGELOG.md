# Changelog

All notable changes to the KGiTON SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-12-07

### Added - Cart API Enhancement
- **NEW**: `forceNew` parameter in `AddCartRequest` for multiple entries support
  - When `forceNew: true`, always creates new cart entry (ideal for scale app)
  - When `forceNew: false` or `null`, updates existing entry if found (default behavior)
- **NEW**: Enhanced documentation for `addItemToCart()` with use cases and examples
- **NEW**: Cart API example in `example/lib/main.dart` demonstrating both use cases

### Use Cases
- **Scale App**: Use `forceNew: true` to create separate entries for each weighing, allowing users to see history of multiple weighings for the same item
- **E-commerce App**: Use `forceNew: false` or omit parameter to update quantity of existing cart item

### Example
```dart
// Scale app - multiple weighings
await cartService.addItemToCart(AddCartRequest(
  licenseKey: 'ABC123',
  itemId: 'orange-uuid',
  quantity: 0.5,
  forceNew: true, // Creates new entry
));

// E-commerce app - update quantity
await cartService.addItemToCart(AddCartRequest(
  licenseKey: 'ABC123',
  itemId: 'apple-uuid',
  quantity: 2.0,
  // forceNew not specified, updates existing
));
```

### Changed
- Updated `AddCartRequest.toJson()` to include `force_new` parameter when provided
- Enhanced `KgitonCartService.addItemToCart()` documentation with detailed behavior explanation

## [1.1.0] - 2025-12-06

### Breaking Changes - Simplified Delete API
- **BREAKING**: `deleteItem()` now performs permanent delete (previously soft delete)
- **REMOVED**: `deleteItemPermanent()` method (merged into `deleteItem()`)
- **REMOVED**: Soft delete functionality (backend still supports it but SDK simplified)

### Why This Change?
The backend uses soft delete system (`is_active = false`), but there's no restore functionality available. Having two delete methods was confusing and unnecessary. Now `deleteItem()` directly calls the permanent delete endpoint for cleaner API.

### Migration Guide
```dart
// Before (v1.0.0)
await apiService.owner.deleteItemPermanent(itemId); // Hard delete

// After (v1.1.0)
await apiService.owner.deleteItem(itemId); // Always permanent delete
```

### Changed
- `deleteItem()` now calls `/items/:id/permanent` endpoint
- Simplified documentation - no more soft delete vs permanent delete confusion
- Updated README examples to reflect permanent delete only

## [1.0.0] - 2025-12-06

### Initial Release - Complete SDK with BLE & API Integration

### Added - Permanent Delete Support
- **NEW**: `deleteItemPermanent()` method for hard delete (remove from database)
- **NEW**: Enhanced `deleteItem()` documentation (soft delete - set is_active = false)
- **NEW**: `deletePermanentItem()` endpoint constant
- **NEW**: Enhanced DELETE request logging for debugging
- **NEW**: Complete examples for soft delete vs permanent delete in README
- **NEW**: Delete operations section in API README with best practices

### Changed
- `deleteItem()` now returns `bool` instead of `void` for better response handling
- Updated documentation to clarify soft delete behavior
- Enhanced error messages for delete operations

### Added - BLE Scan Optimization (Built-in from v1.0.0)
- **NEW**: `autoStopOnFound` parameter in `scanForDevices()` untuk auto-stop scan setelah menemukan device
- **NEW**: Auto-stop scan saat user melakukan connect ke device
- **NEW**: Proper scan subscription cleanup untuk mencegah memory leak
- **NEW**: Battery efficient scanning (70-85% lebih hemat dengan auto-stop)
- **NEW**: Settings toggle di example app untuk auto-stop scan

### Added - Complete API Integration
- **NEW**: Complete REST API client for KGiTON backend
- **NEW**: Authentication service (login, register, logout)
- **NEW**: License management service (Super Admin)
- **NEW**: Owner operations service (items, licenses)
- **NEW**: Transaction management service
- **NEW**: Admin settings service (processing fees)
- **NEW**: `KgitonApiService` - Main API service integrator
- **NEW**: `KgitonApiClient` - HTTP client with automatic token management
- **NEW**: 7 comprehensive model files for all API responses
- **NEW**: Custom exception types for API errors (401, 403, 404, 409, 429, etc.)
- **NEW**: Automatic token storage and retrieval using SharedPreferences
- **NEW**: Complete API integration documentation
- **NEW**: Full working example with API integration
- **NEW**: `API_IMPLEMENTATION_SUMMARY.md` - Quick reference guide

### Added - Models
- `ApiResponse<T>` - Generic API response wrapper
- `AuthData`, `User`, `UserProfile` - Authentication models
- `License`, `LicenseListData`, `BulkLicenseData` - License models
- `Item`, `ItemListData` - Item/product models
- `Transaction`, `TransactionDetail`, `TransactionListData` - Transaction models
- `SystemSetting`, `CartProcessingFeeData` - Admin settings models

### Added - Services
- `KgitonAuthService` - Login, register, logout, get current user
- `KgitonLicenseService` - Create, list, upload/download CSV licenses
- `KgitonOwnerService` - Manage licenses, CRUD items
- `KgitonTransactionService` - List transactions, get details, summary
- `KgitonAdminSettingsService` - Get/update system settings

### Added - BLE Features & Android 10+ Support
- ✅ Automatic JWT token management
- ✅ Token persistence in local storage
- ✅ Comprehensive error handling with specific exception types
- ✅ Support for pagination in list endpoints
- ✅ Flexible API response parsing (supports both array and object formats)
- ✅ Handle both `{items: [...], count: 1}` and `[...]` response formats
- ✅ Date range filtering for transactions
- ✅ CSV upload/download for license management
- ✅ Multi-branch support via multiple licenses per owner
- ✅ Type-safe API with full type inference
- ✅ **Robust BLE permission handling untuk Android 10+**
- ✅ **`PermissionHelper` class dengan version-specific logic**
- ✅ **Automatic location service checking untuk Android 10-11**
- ✅ **Native layer permission checks di Kotlin BleManager**
- ✅ **Clear error messages: PERMISSION_DENIED, LOCATION_DISABLED**

### Dependencies
- Added: `http: ^1.2.0` - HTTP client for API calls
- Added: `permission_handler: ^11.3.1` - Permission handling untuk BLE

### Documentation
- Added comprehensive API integration guide
- Added complete usage examples for all endpoints
- Added error handling best practices
- Updated README with API features

### Platform Support
- Android (minSdkVersion 21)
- iOS (iOS 12.0+)

### Dependencies
- kgiton_ble_sdk: Custom BLE implementation
- http: ^1.2.0 - HTTP client for API calls
- permission_handler: ^11.3.1 - BLE permission handling
- logger: ^2.5.0 - Debugging support
- shared_preferences: ^2.3.4 - Local storage
- meta: ^1.15.0

---

## [Unreleased]

### Planned Features
- Auto-reconnect capability
- Connection retry dengan backoff strategy
- Weight data filtering dan smoothing
- Calibration API
- Multiple device simultaneous connection
- Firmware version check
- OTA firmware update support
- Battery level monitoring
- Signal strength monitoring
- Data caching untuk offline mode
- Custom buzzer patterns
