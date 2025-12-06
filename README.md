<div align="center">
  <img src="logo/kgiton-logo.png" alt="KGiTON Logo" width="400"/>
  
  # KGiTON Flutter Package SDK

  [![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey.svg)](https://github.com/kuldii/flutter-kgiton-sdk)
</div>

Official Flutter SDK for integrating with KGiTON BLE scale devices.

> **⚠️ PROPRIETARY SOFTWARE**: This SDK is commercial software owned by PT KGiTON. Use requires explicit authorization. See [AUTHORIZATION.md](AUTHORIZATION.md) for licensing information.

## Features Overview

- ✅ **Auto-Stop Scan**: Scan otomatis berhenti setelah menemukan device (hemat battery!)
- ✅ **Smart Connect**: Scan otomatis stop saat connect ke device
- ✅ **Optimized Performance**: Battery efficient dengan intelligent scan management
- ✅ **Memory Safe**: Proper cleanup untuk mencegah memory leak
- ✅ **Complete API**: REST API integration untuk backend KGiTON

## 📖 Documentation

### Core Documentation (New Structure!)

- 📘 [Getting Started](docs_integrations/GETTING_STARTED.md) - Complete setup guide
- 🔵 [BLE Integration](docs_integrations/BLE_INTEGRATION.md) - Scale device integration
- 🌐 [API Integration](docs_integrations/API_INTEGRATION.md) - Backend API guide
- ⚠️ [Troubleshooting](docs_integrations/TROUBLESHOOTING.md) - Common issues & solutions
- 📱 [Android 10-11 Guide](docs_integrations/ANDROID_10_TROUBLESHOOTING.md) - Android specific

### Additional Resources

- 📗 [Authorization Guide](AUTHORIZATION.md) - How to obtain license
- 🛡️ [Security Policy](SECURITY.md) - Security and vulnerability reporting
- 📔 [Changelog](CHANGELOG.md) - Version history and updates
- 🔧 [Example App](example/) - Complete working example with UI

## Features

### BLE Scale Integration
- ✅ Cross-platform (iOS + Android)
- ✅ BLE device scanning with RSSI
- ✅ Real-time weight data streaming (~10 Hz)
- ✅ License-based authentication
- ✅ Buzzer control (BEEP, BUZZ, LONG, OFF)
- ✅ Connection state management
- ✅ Type-safe API with comprehensive error handling
- ✅ Built on kgiton_ble_sdk (proprietary)

### API Integration
- ✅ Complete REST API client
- ✅ Authentication (login, register, logout)
- ✅ License management (Super Admin)
- ✅ Owner operations (items, licenses)
- ✅ Transaction management
- ✅ Admin settings (processing fees)
- ✅ Automatic token management
- ✅ Local storage for configuration
- ✅ Comprehensive error handling

## Quick Start

### ⚠️ Authorization Required

**This SDK requires explicit authorization from PT KGiTON.**

📋 **[Read Authorization Guide](AUTHORIZATION.md)** for licensing information.

To obtain a license:
1. Email: support@kgiton.com
2. Subject: "KGiTON SDK License Request"
3. Include: Company name, use case, contact information

### Installation (For Authorized Users)

Contact PT KGiTON for access credentials, then add to your `pubspec.yaml`:

```yaml
dependencies:
  kgiton_sdk:
    git:
      url: https://github.com/kuldii/flutter-kgiton-sdk.git
      # Use provided access token if private repository
```

### Platform Configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<!-- CRITICAL: Include ALL these permissions for Android 10+ support -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
    android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- REQUIRED for Android 10-11 BLE scanning -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

> 🚨 **Android 10 users**: BLE scanning tidak akan bekerja tanpa `ACCESS_FINE_LOCATION` dan Location Service aktif. 
> Baca [ANDROID_10_BLE_TROUBLESHOOTING.md](docs_integrations/ANDROID_10_BLE_TROUBLESHOOTING.md) untuk panduan lengkap.

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Need Bluetooth to connect to scale</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Need location to discover Bluetooth devices</string>
```

> 📖 **Untuk panduan lengkap Android 10**, lihat [ANDROID_10_BLE_TROUBLESHOOTING.md](docs_integrations/ANDROID_10_BLE_TROUBLESHOOTING.md)

### Basic Usage - BLE Scale

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// 1. Request permissions (SDK built-in helper)
final granted = await PermissionHelper.requestBLEPermissions();
if (!granted) {
  final errorMsg = await PermissionHelper.getPermissionErrorMessage();
  print(errorMsg); // Shows specific error for Android 10, etc.
  return;
}

// 2. Initialize SDK
final sdk = KGiTONScaleService();

// Listen to devices
sdk.devicesStream.listen((devices) {
  print('Found ${devices.length} devices');
});

// Listen to weight data
sdk.weightStream.listen((weight) {
  print('Weight: ${weight.displayWeight}');
});

// Listen to connection state
sdk.connectionStateStream.listen((state) {
  print('State: ${state.name}');
});

// Scan for devices (with auto-stop for better performance!)
await sdk.scanForDevices(
  timeout: Duration(seconds: 15),
  autoStopOnFound: true, // 🔥 Hemat battery & memory!
);

// Connect to device with license key
// Scan will automatically stop when connecting!
await sdk.connectWithLicenseKey(
  deviceId: selectedDevice.id,
  licenseKey: 'YOUR-LICENSE-KEY-HERE',
);

// Control buzzer
await sdk.triggerBuzzer('BEEP');

// Disconnect
await sdk.disconnect();
```

### Additional Resources

- 📚 [Example App](example/) - Complete working example with Material Design 3 UI
- 🌐 [API Integration Guide](docs_integrations/18-api-integration-guide.md) - Complete API documentation
- 📋 [STRUCTURE.md](STRUCTURE.md) - Detailed project structure
- 🔐 [AUTHORIZATION.md](AUTHORIZATION.md) - Licensing information
- 🛡️ [SECURITY.md](SECURITY.md) - Security policy

### API Quick Example

```dart
// Initialize API service
final apiService = KgitonApiService(
  baseUrl: 'https://api.kgiton.com',
);

// Login
final authData = await apiService.auth.login(
  email: 'owner@example.com',
  password: 'password123',
);

// List items
final itemsData = await apiService.owner.listAllItems();
print('Items: ${itemsData.items.length}');

// Create item
final item = await apiService.owner.createItem(
  licenseKey: 'LICENSE-KEY',
  name: 'Apple',
  unit: 'kg',
  price: 15000,
);

// Soft delete (set is_active = false)
await apiService.owner.deleteItem(item.id);

// Permanent delete (remove from database)
await apiService.owner.deleteItemPermanent(item.id);
```

## API Overview

### BLE Scale Service: `KGiTONScaleService`

**Streams:**
- `devicesStream` - Discovered devices
- `weightStream` - Real-time weight data
- `connectionStateStream` - Connection state changes

**Methods:**
- `startScan()` - Start scanning for devices
- `stopScan()` - Stop scanning
- `connect()` - Connect to device
- `disconnect()` - Disconnect from device
- `triggerBuzzer()` - Control buzzer

**Properties:**
- `connectionState` - Current connection state
- `isConnected` - Connection status
- `isAuthenticated` - Authentication status
- `connectedDevice` - Current device
- `availableDevices` - List of discovered devices

### API Service: `KgitonApiService`

**Services:**
- `auth` - Authentication (login, register, logout)
- `license` - License management (Super Admin)
- `owner` - Owner operations (items, licenses)
- `transaction` - Transaction management
- `adminSettings` - Admin settings management

**Key Features:**
- Automatic token management
- Local storage persistence
- Comprehensive error handling
- Type-safe models

See [API Integration Guide](docs_integrations/18-api-integration-guide.md) for complete API documentation.

## Running the Example

```bash
cd example
flutter pub get
flutter run
```

## Architecture

This SDK uses:
- **BLE Library**: kgiton_ble_sdk (internal, proprietary)
- **Platform**: iOS + Android
- **Language**: Pure Dart
- **Pattern**: Stream-based reactive API
- **Size**: ~52KB source code

See inline documentation in source code for complete API details.

## Support

For authorized users:
- 🐛 [Report Issues](https://github.com/kuldii/flutter-kgiton-sdk/issues)
- 📧 Technical Support: support@kgiton.com
- 🔒 Security Issues: support@kgiton.com
- 🌐 Website: https://kgiton.com

## License

**PROPRIETARY SOFTWARE - ALL RIGHTS RESERVED**

This software is the proprietary property of PT KGiTON and is protected by copyright law.

### Usage Restrictions

- ❌ **NOT Open Source** - Source code is confidential
- ❌ **NOT Free to Use** - Requires explicit authorization from PT KGiTON
- ❌ **NO Redistribution** - Cannot be shared or distributed
- ❌ **NO Modifications** - Cannot be altered or reverse-engineered
- ✅ **Commercial License Available** - Contact PT KGiTON for licensing

### License Summary

Copyright (c) 2025 PT KGiTON. All Rights Reserved.

This SDK may only be used by individuals or organizations explicitly authorized 
by PT KGiTON. Unauthorized use, reproduction, or distribution is strictly 
prohibited and may result in legal action.

See [LICENSE](LICENSE) file for complete terms and conditions.

### How to Obtain a License

📋 **Read [AUTHORIZATION.md](AUTHORIZATION.md)** for complete licensing information.

**Contact Information**:
- 📧 Email: support@kgiton.com
- 🌐 Website: https://kgiton.com
- 🔒 Security: support@kgiton.com

---

**SDK Version:** 1.0.0  
**API Base URL:** `https://dev-api.kgiton.com`  
**API Version:** `/api/v1`  
**Platform:** iOS + Android  
**Flutter:** ≥3.0.0  

© 2025 PT KGiTON. All rights reserved.
