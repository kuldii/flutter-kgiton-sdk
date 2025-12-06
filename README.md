<div align="center">
  <img src="logo/kgiton-logo.png" alt="KGiTON Logo" width="400"/>
  
  # KGiTON Flutter Package SDK

  [![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey.svg)](https://github.com/kuldii/flutter-kgiton-sdk)
</div>

Official Flutter SDK for integrating with KGiTON BLE scale devices.

> **⚠️ PROPRIETARY SOFTWARE**: This SDK is commercial software owned by PT KGiTON. Use requires explicit authorization. See [AUTHORIZATION.md](AUTHORIZATION.md) for licensing information.

## 📖 Documentation

### Quick Links

- 📘 [Authorization Guide](AUTHORIZATION.md) - How to obtain license
- 📗 [Security Policy](SECURITY.md) - Security and vulnerability reporting
- 📔 [Changelog](CHANGELOG.md) - Version history
- 📚 [Complete Documentation](docs_integrations/) - Full integration guide
- 🔧 [Example App](example/) - Complete working example

### API Documentation
- 🚀 [API Integration Guide](docs_integrations/18-api-integration-guide.md) - Complete API guide
- ⚙️ [API Configuration](docs_integrations/19-api-configuration-guide.md) - How to configure endpoints
- 📋 [API Quick Reference](docs_integrations/20-api-quick-reference.md) - Quick cheat sheet

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
- ✅ Cart management (add, update, clear, process)
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
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Need Bluetooth to connect to scale</string>
```

### Basic Usage - BLE Scale

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

// Request permissions
await Permission.bluetoothScan.request();
await Permission.bluetoothConnect.request();
await Permission.location.request();

// Initialize SDK
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

// Scan for devices
await sdk.scanForDevices(timeout: Duration(seconds: 15));

// Connect to device with license key
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
final items = await apiService.owner.listItems('LICENSE-KEY');

// Add to cart
final cartId = Uuid().v4();
await apiService.cart.addToCart(
  cartId: cartId,
  licenseKey: 'LICENSE-KEY',
  itemId: items.items.first.id,
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
- `cart` - Cart management (add, update, clear, process)
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

## API Overview

### Main Class: `KGiTONScaleService`

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
