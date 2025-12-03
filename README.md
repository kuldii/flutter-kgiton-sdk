<div align="center">
  <img src="logo/kgiton-logo.png" alt="KGiTON Logo" width="400"/>
  
  # KGiTON Flutter Package SDK

  [![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey.svg)](https://github.com/kuldii/flutter-kgiton-sdk)
</div>

Official Flutter SDK for integrating with KGiTON BLE scale devices.

> **⚠️ PROPRIETARY SOFTWARE**: This SDK is commercial software owned by PT KGiTON. Use requires explicit authorization. See [AUTHORIZATION.md](AUTHORIZATION.md) for licensing information.

## 📖 Documentation

**Complete documentation available at:** [`/flutter/docs/`](../docs/)

### Quick Links

- 📘 [Overview & Comparison](../docs/01-overview.md) - SDK selection guide
- 📗 [Installation Guide](../docs/02-installation.md) - Platform setup
- 📙 [Flutter SDK Guide](../docs/03-flutter-sdk-guide.md) - Usage guide
- 📕 [API Reference](../docs/04-flutter-sdk-api.md) - Complete API docs
- 📔 [Complete Index](../docs/COMPLETE_DOCUMENTATION_INDEX.md) - Quick reference
- 🔧 [Integration Guide](../docs/integration-guides/FLUTTER-PACKAGE-SDK-INTEGRATION.md) - Step-by-step integration

## Features

- ✅ Cross-platform (iOS + Android)
- ✅ BLE device scanning with RSSI
- ✅ Real-time weight data streaming (~10 Hz)
- ✅ License-based authentication
- ✅ Buzzer control (BEEP, BUZZ, LONG, OFF)
- ✅ Connection state management
- ✅ Type-safe API with comprehensive error handling
- ✅ Built on kgiton_ble_sdk (MIT licensed)

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
      path: flutter/kgiton_sdk
      # Use provided access token if private repository
  permission_handler: ^11.4.0
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

### Basic Usage

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
await sdk.startScan(timeout: Duration(seconds: 15));

// Connect to device
await sdk.connect(
  device: selectedDevice,
  licenseKey: 'YOUR-LICENSE-KEY-HERE',
);

// Control buzzer
await sdk.triggerBuzzer('BEEP');

// Disconnect
await sdk.disconnect();
```

### Complete Integration

For complete step-by-step integration with full UI examples, see:
- **[Flutter Package SDK Integration Guide](../docs/integration-guides/FLUTTER-PACKAGE-SDK-INTEGRATION.md)**

Includes:
- Complete platform configuration
- Permission handling service
- Full screen implementations (Scan, Connection, Weight Display)
- Error handling patterns
- Testing and troubleshooting

## Example App

See the [example](example/) directory for a complete working example with Material Design 3 UI.

To run:
```bash
cd example
flutter pub get
flutter run
```

## Architecture

This SDK uses:
- **BLE Library**: flutter_blue_plus
- **Platform**: iOS + Android
- **Language**: Pure Dart
- **Pattern**: Stream-based reactive API

For Android-only apps with better performance, see [Native SDK](../kgiton_sdk_native/).

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
- `isScanning` - Scan status
- `isConnected` - Connection status
- `connectedDevice` - Current device

See [API Reference](../docs/04-flutter-sdk-api.md) for complete details.

## Support

- 📚 [Full Documentation](../docs/)
- 📖 [Integration Guide](../docs/integration-guides/FLUTTER-PACKAGE-SDK-INTEGRATION.md)
- 🐛 [Report Issues](https://github.com/kuldii/flutter-kgiton-sdk/issues)
- 📧 Email: support@kgiton.com

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
- 🔒 Security: security@kgiton.com

---

**SDK Version:** 1.1.0  
**Platform:** iOS + Android  
**Flutter:** ≥3.3.0  
© 2025 PT KGiTON. All rights reserved.
