# Getting Started with KGiTON SDK

## Prerequisites

- Flutter SDK 3.10 or higher
- Dart 3.0 or higher
- Android Studio / Xcode for platform development
- Valid KGiTON license key (contact: support@kgiton.com)

### Platform Requirements

**Android:**
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 33 or higher
- BLE support required

**iOS:**
- Minimum: iOS 12.0
- Xcode 14 or higher
- BLE support required

---

## Installation

### 1. Add Dependency

Add to your `pubspec.yaml`:

```yaml
dependencies:
  kgiton_sdk:
    git:
      url: https://github.com/kuldii/flutter-kgiton-sdk.git
      ref: main
  
  # Required dependencies
  permission_handler: ^11.3.1
  uuid: ^4.5.1
```

### 2. Install Packages

```bash
flutter pub get
```

---

## Platform Setup

### Android Configuration

#### 1. Update `android/app/build.gradle`

```gradle
android {
    compileSdk 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

#### 2. Add Permissions in `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Bluetooth Permissions -->
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    
    <!-- Android 12+ BLE Permissions -->
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"
        android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    
    <!-- Location Permissions (Required for Android 10-11) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <uses-feature android:name="android.hardware.bluetooth_le" android:required="true" />
    
    <application>
        <!-- Your app config -->
    </application>
</manifest>
```

> ⚠️ **Android 10-11 Important**: BLE scanning requires `ACCESS_FINE_LOCATION` and Location Services enabled. See [ANDROID_10_TROUBLESHOOTING.md](ANDROID_10_TROUBLESHOOTING.md) for details.

### iOS Configuration

Update `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>We need Bluetooth to connect to your scale device</string>

<key>NSBluetoothPeripheralUsageDescription</key>
<string>We need Bluetooth to connect to your scale device</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Location is required to discover Bluetooth devices</string>
```

Update `ios/Podfile` (minimum iOS 12.0):

```ruby
platform :ios, '12.0'
```

---

## Permissions Setup

### Request Permissions at Runtime

The SDK provides a built-in helper for requesting all required permissions:

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

Future<void> setupPermissions() async {
  // Request all required BLE permissions
  final granted = await PermissionHelper.requestBLEPermissions();
  
  if (!granted) {
    // Get specific error message for user
    final errorMsg = await PermissionHelper.getPermissionErrorMessage();
    print('Permission denied: $errorMsg');
    
    // Optionally open app settings
    // await openAppSettings();
    return;
  }
  
  print('✅ All permissions granted');
}
```

### Permission Helper Methods

```dart
// Check if all permissions are granted
final allGranted = await PermissionHelper.checkBLEPermissions();

// Get detailed error message
final errorMsg = await PermissionHelper.getPermissionErrorMessage();

// Check specific permission
final locationGranted = await Permission.locationWhenInUse.isGranted;
```

---

## API Configuration

### Initialize API Service

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// Option 1: Use default production URL
final apiService = KgitonApiService();

// Option 2: Use custom URL
final apiService = KgitonApiService(
  baseUrl: 'https://your-custom-api.com',
);

// Load saved configuration (tokens, etc.)
await apiService.loadConfiguration();
```

### Check Authentication

```dart
if (apiService.isAuthenticated()) {
  print('User is logged in');
  final user = await apiService.auth.getCurrentUser();
  print('Welcome ${user.name}');
} else {
  print('User needs to login');
}
```

---

## First Integration Test

### Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

class ScaleTestScreen extends StatefulWidget {
  @override
  State<ScaleTestScreen> createState() => _ScaleTestScreenState();
}

class _ScaleTestScreenState extends State<ScaleTestScreen> {
  final sdk = KGiTONScaleService();
  List<ScaleDevice> devices = [];
  String status = 'Ready';
  
  @override
  void initState() {
    super.initState();
    _setupListeners();
  }
  
  void _setupListeners() {
    // Listen to devices
    sdk.devicesStream.listen((newDevices) {
      setState(() => devices = newDevices);
    });
    
    // Listen to connection state
    sdk.connectionStateStream.listen((state) {
      setState(() => status = state.name);
    });
    
    // Listen to weight data
    sdk.weightStream.listen((weight) {
      print('Weight: ${weight.displayWeight} kg');
    });
  }
  
  Future<void> _requestPermissions() async {
    final granted = await PermissionHelper.requestBLEPermissions();
    if (!granted) {
      final error = await PermissionHelper.getPermissionErrorMessage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }
  
  Future<void> _scanDevices() async {
    setState(() => status = 'Scanning...');
    await sdk.scanForDevices(timeout: Duration(seconds: 10));
    setState(() => status = 'Scan complete');
  }
  
  Future<void> _connect(ScaleDevice device) async {
    try {
      await sdk.connectWithLicenseKey(
        deviceId: device.id,
        licenseKey: 'YOUR-LICENSE-KEY',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection failed: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('KGiTON Scale Test')),
      body: Column(
        children: [
          // Status
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Status: $status', style: TextStyle(fontSize: 18)),
          ),
          
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _requestPermissions,
                child: Text('Request Permissions'),
              ),
              ElevatedButton(
                onPressed: _scanDevices,
                child: Text('Scan Devices'),
              ),
            ],
          ),
          
          // Device List
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text('RSSI: ${device.rssi} dBm'),
                  trailing: ElevatedButton(
                    onPressed: () => _connect(device),
                    child: Text('Connect'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    sdk.disconnect();
    super.dispose();
  }
}
```

---

## Next Steps

After getting your first integration working:

1. **BLE Integration** - Read [BLE_INTEGRATION.md](BLE_INTEGRATION.md) for complete BLE features
2. **API Integration** - Read [API_INTEGRATION.md](API_INTEGRATION.md) for backend operations
3. **Cart System** - Read [CART_GUIDE.md](CART_GUIDE.md) for shopping cart implementation
4. **Troubleshooting** - See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) if you encounter issues

---

## Common Issues

### "Permission denied" on Android 10-11

**Solution**: Enable Location Services on device + grant Location permission.
See [ANDROID_10_TROUBLESHOOTING.md](ANDROID_10_TROUBLESHOOTING.md)

### "No devices found" when scanning

**Possible causes:**
1. Permissions not granted
2. Bluetooth disabled on device
3. Location Services disabled (Android 10-11)
4. Scale device not powered on
5. Scale device already connected to another device

### "License key invalid"

**Solution**: Contact support@kgiton.com to verify your license key.

---

## Getting Help

- 📧 Email: support@kgiton.com
- 📚 Full Documentation: [README.md](README.md)
- 🔐 License Info: [../AUTHORIZATION.md](../AUTHORIZATION.md)
- 🛡️ Security: [../SECURITY.md](../SECURITY.md)
