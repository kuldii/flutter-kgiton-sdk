# Changelog

All notable changes to the KGiTON SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
