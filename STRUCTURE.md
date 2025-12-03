# KGiTON SDK - Project Structure

Clean and organized structure for production-ready SDK.

```
kgiton_sdk/
├── .gitignore                      # Git ignore rules
├── AUTHORIZATION.md                # Commercial license guide
├── CHANGELOG.md                    # Version history
├── LICENSE                         # Proprietary license agreement
├── README.md                       # Main documentation
├── SECURITY.md                     # Security policy
├── pubspec.yaml                    # Package configuration
│
├── lib/
│   ├── kgiton_sdk.dart            # Public API exports
│   └── src/
│       ├── kgiton_scale_service.dart    # Core service implementation
│       │
│       ├── constants/
│       │   └── ble_constants.dart       # BLE configuration constants
│       │
│       ├── exceptions/
│       │   └── kgiton_exceptions.dart   # Custom exception classes
│       │
│       └── models/
│           ├── control_response.dart        # Control command response
│           ├── scale_connection_state.dart  # Connection state enum
│           ├── scale_device.dart            # Device model
│           └── weight_data.dart             # Weight data model
│
└── example/
    ├── README.md                   # Example documentation
    ├── pubspec.yaml               # Example dependencies
    └── lib/
        └── main.dart              # Example application
```

## File Descriptions

### Root Level

- **`.gitignore`** - Comprehensive ignore rules for Flutter/Dart projects
- **`AUTHORIZATION.md`** - How to obtain commercial license
- **`CHANGELOG.md`** - Version history and changes
- **`LICENSE`** - Proprietary software license agreement
- **`README.md`** - Complete SDK documentation with examples
- **`SECURITY.md`** - Security vulnerability reporting policy
- **`pubspec.yaml`** - Package metadata and dependencies

### lib/

#### Public API
- **`kgiton_sdk.dart`** - Main entry point, exports all public APIs

#### Core (src/)
- **`kgiton_scale_service.dart`** - Main service class for BLE scale operations

#### Constants (src/constants/)
- **`ble_constants.dart`** - BLE UUIDs, timeouts, and configuration

#### Exceptions (src/exceptions/)
- **`kgiton_exceptions.dart`** - Custom exception hierarchy
  - `KGiTONException` (base)
  - `BLEConnectionException`
  - `AuthenticationException`
  - `DeviceNotFoundException`
  - `TimeoutException`
  - `LicenseKeyException`

#### Models (src/models/)
- **`control_response.dart`** - Response from control commands
- **`scale_connection_state.dart`** - Connection state enumeration
- **`scale_device.dart`** - BLE device model with license key
- **`weight_data.dart`** - Weight measurement data model

### example/

Contains example Flutter application demonstrating SDK usage.

## Clean Structure Benefits

✅ **Organized**: Clear separation of concerns  
✅ **Maintainable**: Easy to navigate and update  
✅ **Professional**: Production-ready structure  
✅ **Scalable**: Easy to add new features  
✅ **Minimal**: No unnecessary files or logs  

## What Was Removed

- ❌ Build artifacts (`.dart_tool/`, `pubspec.lock`)
- ❌ Temporary documentation (`AUDIT_REPORT.md`, etc.)
- ❌ Development logs and notes
- ❌ Cache files (`.flutter-plugins-dependencies`)

## What's Protected by .gitignore

- Flutter/Dart artifacts (`.dart_tool/`, `.packages`, `.pub/`, `.metadata`)
- Build files (`build/`, `pubspec.lock`)
- Flutter plugins (`.flutter-plugins*`)
- IDE configurations (`.idea/`, `.vscode/`, `*.iml`)
- Platform builds (`/android/`, `/ios/`, `/example/android/`, `/example/ios/`)
- Generated files (`*.g.dart`, `*.freezed.dart`, `*.mocks.dart`)
- Coverage reports (`coverage/`, `*.lcov`)
- Logs (`*.log`)
- Local development (`.env`, `.env.local`)
- Internal documentation (`AUDIT_REPORT.md`, `*_INTERNAL.md`)

---

**Structure Version**: 1.1.0  
**Last Updated**: December 3, 2025  
**Status**: ✅ Production Ready

© 2025 PT KGiTON - All Rights Reserved
