# 5. Permissions Setup

Learn how to properly handle Bluetooth and location permissions required by the KGiTON SDK.

---

## 🔐 Understanding Permissions

The KGiTON SDK requires several permissions to function:

### Required Permissions

| Permission | Platform | Purpose | When Requested |
|------------|----------|---------|----------------|
| Bluetooth Scan | Android 12+ | Scan for BLE devices | Before scanning |
| Bluetooth Connect | Android 12+ | Connect to devices | Before connecting |
| Location | Android <12, iOS | BLE device discovery | Before scanning |
| Bluetooth | iOS | Access Bluetooth | Automatic |

### Permission Flow

```
App Start
    ↓
Check Permissions
    ↓
Request if Not Granted
    ↓
Handle User Response
    ↓
Proceed or Show Rationale
```

---

## 📦 Add permission_handler Package

The recommended way to handle permissions is using the `permission_handler` package.

### Step 1: Add Dependency

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  kgiton_sdk:
    git: ...
  permission_handler: ^11.4.0  # Or latest version
```

### Step 2: Install

```bash
flutter pub get
```

---

## 📱 Android Permission Implementation

### Complete Permission Handler

Create `lib/utils/permissions_helper.dart`:

```dart
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  /// Request all required permissions for BLE
  static Future<bool> requestBLEPermissions() async {
    if (Platform.isAndroid) {
      return await _requestAndroidBLEPermissions();
    } else if (Platform.isIOS) {
      return await _requestIOSBLEPermissions();
    }
    return false;
  }

  /// Android-specific permission request
  static Future<bool> _requestAndroidBLEPermissions() async {
    // Android 12+ (API 31+)
    if (await _getAndroidVersion() >= 31) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      return statuses[Permission.bluetoothScan]!.isGranted &&
             statuses[Permission.bluetoothConnect]!.isGranted;
    } 
    // Android < 12
    else {
      final statuses = await [
        Permission.bluetooth,
        Permission.location,
      ].request();

      // Check if location service is enabled
      if (!await Permission.location.serviceStatus.isEnabled) {
        return false;
      }

      return statuses[Permission.bluetooth]!.isGranted &&
             statuses[Permission.location]!.isGranted;
    }
  }

  /// iOS-specific permission request
  static Future<bool> _requestIOSBLEPermissions() async {
    final status = await Permission.bluetooth.request();
    return status.isGranted;
  }

  /// Check if all BLE permissions are granted
  static Future<bool> checkBLEPermissions() async {
    if (Platform.isAndroid) {
      if (await _getAndroidVersion() >= 31) {
        return await Permission.bluetoothScan.isGranted &&
               await Permission.bluetoothConnect.isGranted;
      } else {
        return await Permission.bluetooth.isGranted &&
               await Permission.location.isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.bluetooth.isGranted;
    }
    return false;
  }

  /// Get Android SDK version
  static Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;
    
    // This is a simplified version
    // You might need to use a platform channel for exact version
    return 31; // Assume Android 12+ for this example
  }

  /// Show permission rationale dialog
  static Future<bool> showPermissionRationale(context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'This app needs Bluetooth and Location permissions to scan and connect to your KGiTON scale device.\n\n'
          'Without these permissions, the app cannot function properly.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Grant Permissions'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
```

### Usage in Your App

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'utils/permissions_helper.dart';

class ScalePage extends StatefulWidget {
  const ScalePage({super.key});

  @override
  State<ScalePage> createState() => _ScalePageState();
}

class _ScalePageState extends State<ScalePage> {
  final _sdk = KGiTONScaleService();
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    // Check if permissions already granted
    final granted = await PermissionsHelper.checkBLEPermissions();
    
    if (granted) {
      setState(() => _permissionsGranted = true);
      return;
    }

    // Show rationale
    if (mounted) {
      final shouldRequest = await PermissionsHelper.showPermissionRationale(context);
      
      if (!shouldRequest) return;
    }

    // Request permissions
    final result = await PermissionsHelper.requestBLEPermissions();
    
    setState(() => _permissionsGranted = result);

    if (!result && mounted) {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Denied'),
        content: const Text(
          'Bluetooth and Location permissions are required to use this app.\n\n'
          'Please grant permissions in Settings.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              PermissionsHelper.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _startScan() async {
    if (!_permissionsGranted) {
      await _checkAndRequestPermissions();
      return;
    }

    // Proceed with scan
    await _sdk.scanForDevices(timeout: const Duration(seconds: 15));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KGiTON Scale')),
      body: _permissionsGranted
          ? _buildMainView()
          : _buildPermissionRequiredView(),
    );
  }

  Widget _buildPermissionRequiredView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Permissions Required',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'This app needs Bluetooth and Location permissions to connect to your scale.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _checkAndRequestPermissions,
            icon: const Icon(Icons.check_circle),
            label: const Text('Grant Permissions'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    // Your main app UI
    return const Center(child: Text('Ready to scan!'));
  }
}
```

---

## 🍎 iOS Permission Implementation

### Info.plist Configuration

Ensure you have added usage descriptions (see [Platform Setup](04-platform-setup.md)):

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to connect to your KGiTON scale device</string>
```

### iOS Permission Flow

iOS handles permissions slightly differently:

```dart
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestIOSPermissions() async {
  if (!Platform.isIOS) return false;

  // Request Bluetooth permission
  final bluetoothStatus = await Permission.bluetooth.request();
  
  if (bluetoothStatus.isGranted) {
    return true;
  } else if (bluetoothStatus.isPermanentlyDenied) {
    // User permanently denied, open settings
    await openAppSettings();
    return false;
  }
  
  return false;
}
```

---

## 🔍 Permission States

### Understanding Permission States

```dart
final status = await Permission.bluetoothScan.status;

if (status.isGranted) {
  // Permission granted - proceed
} else if (status.isDenied) {
  // Permission denied - can request again
  await Permission.bluetoothScan.request();
} else if (status.isPermanentlyDenied) {
  // User selected "Don't ask again"
  // Must open app settings
  await openAppSettings();
} else if (status.isRestricted) {
  // iOS: Restricted by parental controls
} else if (status.isLimited) {
  // iOS: Limited access granted
}
```

### Complete Status Handler

```dart
Future<void> handlePermissionStatus(Permission permission) async {
  final status = await permission.status;

  switch (status) {
    case PermissionStatus.granted:
      print('✅ Permission granted');
      break;
      
    case PermissionStatus.denied:
      print('❌ Permission denied - requesting...');
      final newStatus = await permission.request();
      await handlePermissionStatus(permission); // Check again
      break;
      
    case PermissionStatus.permanentlyDenied:
      print('🚫 Permission permanently denied');
      _showOpenSettingsDialog();
      break;
      
    case PermissionStatus.restricted:
      print('⚠️ Permission restricted (parental controls)');
      break;
      
    case PermissionStatus.limited:
      print('⚡ Limited permission granted');
      break;
      
    case PermissionStatus.provisional:
      print('📋 Provisional permission');
      break;
  }
}

void _showOpenSettingsDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Permission Required'),
      content: const Text(
        'Please enable Bluetooth permission in Settings to use this feature.'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            openAppSettings();
          },
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );
}
```

---

## 🎯 Best Practices

### 1. Request Permissions at the Right Time

❌ **Don't** request on app launch:
```dart
void main() {
  runApp(MyApp());
  // DON'T request here!
  Permission.bluetooth.request();
}
```

✅ **Do** request when needed:
```dart
Future<void> onScanButtonPressed() async {
  // Request right before using
  final granted = await Permission.bluetoothScan.request();
  if (granted.isGranted) {
    await sdk.scanForDevices();
  }
}
```

### 2. Provide Clear Rationale

✅ **Good**: Explain why permission is needed
```dart
showDialog(
  builder: (context) => AlertDialog(
    title: Text('Bluetooth Permission'),
    content: Text(
      'We need Bluetooth access to:\n'
      '• Scan for your scale device\n'
      '• Connect to the scale\n'
      '• Receive weight measurements'
    ),
    ...
  ),
);
```

### 3. Handle All Permission States

```dart
Future<bool> ensurePermissions() async {
  final status = await Permission.bluetoothScan.status;

  if (status.isGranted) return true;
  if (status.isDenied) {
    final result = await Permission.bluetoothScan.request();
    return result.isGranted;
  }
  if (status.isPermanentlyDenied) {
    await openAppSettings();
    return false;
  }
  
  return false;
}
```

### 4. Cache Permission Status

```dart
class PermissionsManager {
  bool? _cachedPermissionStatus;
  DateTime? _lastCheck;

  Future<bool> hasPermissions() async {
    // Cache for 1 minute
    if (_cachedPermissionStatus != null &&
        _lastCheck != null &&
        DateTime.now().difference(_lastCheck!) < Duration(minutes: 1)) {
      return _cachedPermissionStatus!;
    }

    _cachedPermissionStatus = await _checkPermissions();
    _lastCheck = DateTime.now();
    return _cachedPermissionStatus!;
  }

  Future<bool> _checkPermissions() async {
    // Actual permission check
    return await Permission.bluetoothScan.isGranted;
  }
}
```

---

## 🚨 Troubleshooting Permissions

### Issue 1: Permission Always Denied

**Symptoms**: Permission request always returns denied

**Solutions**:
1. Check platform configuration (AndroidManifest.xml / Info.plist)
2. Verify permission_handler is properly installed
3. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Issue 2: Location Service Disabled

**Android specific**: Even with permission, location must be ON

```dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkLocationService() async {
  if (!Platform.isAndroid) return true;

  final serviceEnabled = await Permission.location.serviceStatus.isEnabled;
  
  if (!serviceEnabled) {
    // Prompt user to enable location
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Service Disabled'),
        content: Text(
          'Please enable Location Services in Settings to scan for Bluetooth devices.'
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
    return false;
  }
  
  return true;
}
```

### Issue 3: Permissions Reset After Update

**Problem**: Permissions lost after app update

**Solution**: Always check permissions before critical operations

```dart
@override
void initState() {
  super.initState();
  // Re-check on app start
  _checkPermissions();
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    // Re-check when app returns from background
    _checkPermissions();
  }
}
```

---

## ✅ Permissions Checklist

- [ ] `permission_handler` package added
- [ ] Platform permissions configured (AndroidManifest.xml / Info.plist)
- [ ] Permission request implemented
- [ ] Permission rationale dialog created
- [ ] All permission states handled
- [ ] Settings redirect implemented
- [ ] Location service check (Android)
- [ ] Permission checks before BLE operations
- [ ] Tested on real devices

---

## 📊 Permission Summary

| Action | Required Permission | Platform |
|--------|-------------------|----------|
| Scan for devices | Bluetooth Scan / Location | Android, iOS |
| Connect to device | Bluetooth Connect / Bluetooth | Android, iOS |
| Receive weight data | Same as connect | Android, iOS |
| Control buzzer | Same as connect | Android, iOS |

---

## ✅ Permissions Setup Complete!

You now have proper permission handling!

### Next Steps

👉 **[6. Basic Integration](06-basic-integration.md)** - Start integrating the SDK

Or jump to:
- [Complete Examples](12-complete-examples.md) - See full working examples
- [Troubleshooting](11-troubleshooting.md) - Common permission issues

---

**Ready to integrate? → [6. Basic Integration](06-basic-integration.md)**

© 2025 PT KGiTON. All rights reserved.
