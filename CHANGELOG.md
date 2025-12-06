# Changelog

All notable changes to the KGiTON SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-06

### Initial Release - Complete SDK with BLE & API Integration

### Added - Complete API Integration
- **NEW**: Complete REST API client for KGiTON backend
- **NEW**: Authentication service (login, register, logout)
- **NEW**: License management service (Super Admin)
- **NEW**: Owner operations service (items, licenses)
- **NEW**: Cart management service (add, update, clear, process)
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
- `CartItem`, `CartData`, `ProcessCartData` - Shopping cart models
- `Transaction`, `TransactionDetail`, `TransactionListData` - Transaction models
- `SystemSetting`, `CartProcessingFeeData` - Admin settings models

### Added - Services
- `KgitonAuthService` - Login, register, logout, get current user
- `KgitonLicenseService` - Create, list, upload/download CSV licenses
- `KgitonOwnerService` - Manage licenses, CRUD items
- `KgitonCartService` - Add to cart, update, clear by cart ID or license key, process cart
  - `clearCart()` - Clear cart by cart ID
  - `clearCartByLicense()` - Clear all carts for a specific license (recommended after checkout)
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
- ✅ Cart processing with automatic fee calculation
- ✅ Type-safe API with full type inference
- ✅ **Robust BLE permission handling untuk Android 10+**
- ✅ **`PermissionHelper` class dengan version-specific logic**
- ✅ **Automatic location service checking untuk Android 10-11**
- ✅ **Native layer permission checks di Kotlin BleManager**
- ✅ **Clear error messages: PERMISSION_DENIED, LOCATION_DISABLED**

### Dependencies
- Added: `http: ^1.2.0` - HTTP client for API calls
- Added: `permission_handler: ^11.3.1` - Permission handling untuk BLE
- Required: `uuid: ^4.0.0` - For generating cart IDs (in consumer app)

### Documentation
- Added comprehensive API integration guide
- Added complete usage examples for all endpoints
- Added error handling best practices
- Updated README with API features

## [1.1.0] - 2025-12-02

### Changed
- **BREAKING**: Replaced `flutter_blue_plus` with `kgiton_ble_sdk`
- Updated to use custom MIT-licensed BLE implementation for commercial freedom
- Removed external BLE dependency - now uses in-house `kgiton_ble_sdk`

### Internal
- Refactored `KGiTONScaleService` to use `KgitonBleSdk` API
- Updated `ScaleDevice` model to be independent of third-party BLE library
- All BLE characteristics now referenced by string IDs instead of objects
- Improved BLE abstraction for better maintainability

### Dependencies
- Added: kgiton_ble_sdk (path dependency)
- Removed: flutter_blue_plus

## [1.0.0] - 2025-12-02

### Added
- Initial release of KGiTON SDK untuk Flutter
- BLE connection management dengan ESP32
- Connect/Disconnect dengan license key authentication
- Realtime weight data streaming
- Buzzer control dengan berbagai perintah (BUZZ, BEEP, LONG, OFF)
- Device scanning dengan filter berdasarkan nama
- Connection state monitoring
- Comprehensive error handling dengan custom exceptions
- Logger integration untuk debugging
- Models: ScaleDevice, WeightData, ControlResponse, ScaleConnectionState
- Stream-based architecture untuk reactive updates
- Support untuk multiple devices selection
- Auto-timeout untuk scanning dan connection
- BLE characteristic management (TX, Control, Buzzer)
- Complete documentation dan examples
- MIT License

### Features
- ✅ Autentikasi dengan license key
- ✅ Streaming data berat realtime (format: kg dengan 3 desimal)
- ✅ Kontrol buzzer jarak jauh
- ✅ Multi-device scanning
- ✅ Connection state tracking
- ✅ Error handling yang robust
- ✅ Logging support

### Platform Support
- Android (minSdkVersion 21)
- iOS (iOS 12.0+)

### Dependencies
- flutter_blue_plus: ^2.0.2
- logger: ^2.5.0
- meta: ^1.15.0

---

## [Unreleased]

### Planned Features
- Auto-reconnect capability
- Connection retry dengan backoff strategy
- Weight data filtering dan smoothing
- Calibration API
- Multiple device simultaneous connection
- Device pairing management
- Firmware version check
- OTA firmware update support
- Battery level monitoring
- Signal strength monitoring
- Data caching untuk offline mode
- Custom buzzer patterns
