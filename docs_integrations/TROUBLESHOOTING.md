# Troubleshooting Guide

Common issues and solutions for KGiTON SDK integration.

---

## Table of Contents

1. [BLE Connection Issues](#ble-connection-issues)
2. [Android 10-11 Specific Issues](#android-10-11-specific-issues)
3. [Permission Issues](#permission-issues)
4. [API Integration Issues](#api-integration-issues)
5. [Cart Issues](#cart-issues)
6. [Weight Data Issues](#weight-data-issues)
7. [Build/Compilation Issues](#buildcompilation-issues)

---

## BLE Connection Issues

### No Devices Found During Scan

**Symptoms:**
- `devicesStream` emits empty list
- Scan completes but no devices found

**Possible Causes & Solutions:**

1. **Permissions not granted**
   ```dart
   final granted = await PermissionHelper.checkBLEPermissions();
   if (!granted) {
     await PermissionHelper.requestBLEPermissions();
   }
   ```

2. **Bluetooth disabled on device**
   - Check: Settings → Bluetooth → Enable
   - Ask user to enable Bluetooth

3. **Location Services disabled (Android 10-11)**
   - See [Android 10-11 Specific Issues](#android-10-11-specific-issues)

4. **Scale device not powered on**
   - Turn on the scale device
   - Check battery level

5. **Scale already connected to another device**
   - Disconnect from other device first
   - Turn scale off and on again

### Connection Fails with "Device Not Found"

**Solution:**
```dart
// Make sure device was discovered during scan
final devices = await sdk.devicesStream.first;
if (devices.isEmpty) {
  print('No devices found. Rescan required.');
  await sdk.scanForDevices();
}

// Use device ID from scan results
final device = devices.first;
await sdk.connectWithLicenseKey(
  deviceId: device.id,  // Use this ID, don't guess
  licenseKey: licenseKey,
);
```

### Connection Timeout

**Symptoms:**
- Connection takes too long
- Times out without success

**Solutions:**

1. **Move closer to scale**
   - RSSI should be > -80 dBm for reliable connection

2. **Reset scale device**
   - Turn off scale
   - Wait 5 seconds
   - Turn on scale
   - Try again

3. **Implement retry logic**
   ```dart
   Future<void> connectWithRetry(String deviceId, String licenseKey) async {
     int attempts = 0;
     const maxAttempts = 3;
     
     while (attempts < maxAttempts) {
       try {
         await sdk.connectWithLicenseKey(
           deviceId: deviceId,
           licenseKey: licenseKey,
         );
         return; // Success
       } catch (e) {
         attempts++;
         if (attempts >= maxAttempts) rethrow;
         
         print('Retry $attempts/$maxAttempts...');
         await Future.delayed(Duration(seconds: 2));
       }
     }
   }
   ```

### License Key Invalid

**Symptoms:**
- Connection fails with "LICENSE_INVALID" error
- Authentication fails after connection

**Solutions:**

1. **Verify license key format**
   - Format: `XXXXX-XXXXX-XXXXX-XXXXX-XXXXX`
   - Check for typos, extra spaces

2. **Check license status**
   - License might be expired or unassigned
   - Contact support@kgiton.com

3. **Check license ownership**
   - License must be assigned to your account

### Frequent Disconnections

**Symptoms:**
- Connection drops randomly
- `connectionStateStream` shows frequent disconnected state

**Solutions:**

1. **Check signal strength**
   ```dart
   // During scan, check RSSI
   sdk.devicesStream.listen((devices) {
     for (var device in devices) {
       if (device.rssi > -80) {
         print('${device.name}: Good signal');
       } else {
         print('${device.name}: Weak signal (${device.rssi} dBm)');
       }
     }
   });
   ```

2. **Implement auto-reconnect**
   ```dart
   sdk.connectionStateStream.listen((state) {
     if (state == ScaleConnectionState.disconnected) {
       if (_shouldAutoReconnect) {
         Future.delayed(Duration(seconds: 2), () {
           _reconnect();
         });
       }
     }
   });
   ```

3. **Check for interference**
   - Other Bluetooth devices nearby
   - WiFi routers on 2.4 GHz
   - Move to different location

---

## Android 10-11 Specific Issues

### BLE Scan Returns Empty (Android 10-11)

**Problem:**
Android 10 and 11 require `ACCESS_FINE_LOCATION` permission **AND** Location Services enabled for BLE scanning.

**Solution:**

1. **Add location permission to manifest**
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   ```

2. **Request permission at runtime**
   ```dart
   final granted = await PermissionHelper.requestBLEPermissions();
   if (!granted) {
     final error = await PermissionHelper.getPermissionErrorMessage();
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('Permission Required'),
         content: Text(error),
         actions: [
           TextButton(
             onPressed: () => openAppSettings(),
             child: Text('Open Settings'),
           ),
         ],
       ),
     );
   }
   ```

3. **Guide user to enable Location Services**
   ```dart
   if (Platform.isAndroid) {
     final androidVersion = await _getAndroidVersion();
     
     if (androidVersion >= 10 && androidVersion <= 11) {
       showDialog(
         context: context,
         builder: (context) => AlertDialog(
           title: Text('Enable Location Services'),
           content: Text(
             'Android 10-11 requires Location Services to be enabled '
             'for Bluetooth scanning.\n\n'
             'Please enable Location in device settings.'
           ),
           actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: Text('OK'),
             ),
           ],
         ),
       );
     }
   }
   ```

**See [ANDROID_10_TROUBLESHOOTING.md](ANDROID_10_TROUBLESHOOTING.md) for complete guide.**

---

## Permission Issues

### Permission Denied on First Request

**Solution:**
```dart
// Check if permanently denied
final status = await Permission.bluetoothScan.status;

if (status.isPermanentlyDenied) {
  // User must enable in settings
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Permission Required'),
      content: Text(
        'Bluetooth permissions are required to use this app.\n\n'
        'Please enable permissions in app settings.'
      ),
      actions: [
        TextButton(
          onPressed: () => openAppSettings(),
          child: Text('Open Settings'),
        ),
      ],
    ),
  );
} else {
  // Request again
  await PermissionHelper.requestBLEPermissions();
}
```

### Permissions Reset After App Update

**Solution:**
Request permissions again after detecting they were revoked:

```dart
@override
void initState() {
  super.initState();
  _checkPermissions();
}

Future<void> _checkPermissions() async {
  final granted = await PermissionHelper.checkBLEPermissions();
  if (!granted) {
    // Show explanation dialog before requesting
    _showPermissionExplanation();
  }
}
```

---

## API Integration Issues

### 401 Unauthorized Error

**Symptoms:**
- API calls fail with "Unauthorized"
- `UnauthorizedException` thrown

**Solutions:**

1. **Check if logged in**
   ```dart
   if (!api.isAuthenticated()) {
     // Navigate to login
     Navigator.pushNamed(context, '/login');
     return;
   }
   ```

2. **Token expired - re-login**
   ```dart
   try {
     await api.owner.listItems(licenseKey);
   } on UnauthorizedException {
     // Token expired, prompt re-login
     await api.auth.logout();
     Navigator.pushNamedAndRemoveUntil(
       context,
       '/login',
       (route) => false,
     );
   }
   ```

### 404 Not Found Error

**Symptoms:**
- Resource not found
- Invalid IDs

**Solutions:**

1. **Verify resource exists**
   ```dart
   try {
     final item = await api.owner.getItemDetail(itemId);
   } on NotFoundException {
     print('Item was deleted or ID is invalid');
     // Refresh list or show error
   }
   ```

2. **Check license key**
   - Verify license key is correct
   - License must be assigned to user

### Network Errors / Timeout

**Solutions:**

1. **Check internet connection**
   ```dart
   try {
     await api.auth.getCurrentUser();
   } catch (e) {
     if (e.toString().contains('SocketException')) {
       showError('No internet connection');
     } else {
       showError('Request failed: $e');
     }
   }
   ```

2. **Implement retry with exponential backoff**
   ```dart
   Future<T> retryWithBackoff<T>(
     Future<T> Function() operation,
   ) async {
     int attempts = 0;
     
     while (attempts < 3) {
       try {
         return await operation();
       } catch (e) {
         attempts++;
         if (attempts >= 3) rethrow;
         
         await Future.delayed(Duration(seconds: pow(2, attempts).toInt()));
       }
     }
     
     throw Exception('Max retries exceeded');
   }
   ```

### 429 Rate Limit Error

**Symptoms:**
- Too many requests
- `RateLimitException` thrown

**Solution:**
```dart
try {
  await api.cart.addToCart(...);
} on RateLimitException catch (e) {
  print('Rate limited. Retry after ${e.retryAfter} seconds');
  
  await Future.delayed(Duration(seconds: e.retryAfter ?? 60));
  // Retry operation
}
```

---

## Cart Issues

### Cart Total Incorrect

**Problem:**
Total doesn't match expected value due to UPSERT behavior.

**Explanation:**
`addToCart()` **adds** quantity if item already exists (UPSERT logic).

```dart
// ❌ Wrong assumption
await api.cart.addToCart(itemId: 'A', quantity: 2.0); // Item A = 2.0
await api.cart.addToCart(itemId: 'A', quantity: 3.0); // Item A = 5.0 (ADDED!)

// ✅ To set specific quantity, use updateCartItem
await api.cart.updateCartItem(
  cartItemId: cartItemId,
  quantity: 3.0, // Sets to 3.0, not adds 3.0
);
```

**See [CART_GUIDE.md](CART_GUIDE.md) for complete cart behavior.**

### Cart Not Cleared After Checkout

**Problem:**
Using old SDK version without auto-clear feature.

**Solution:**
Update to SDK v1.1.0+ which auto-clears cart by default:

```dart
// v1.1.0+ auto-clears by default
final result = await api.cart.processCart(
  cartId: cartId,
  licenseKey: licenseKey,
  // autoClear: true (default)
);

// Cart already cleared ✅
// Generate new cart ID
cartId = Uuid().v4();
```

### "Cart is empty" Error

**Causes:**

1. **Cart was already processed/cleared**
   - Generate new cart ID after checkout

2. **No items added yet**
   - Add items before viewing/processing

**Solution:**
```dart
try {
  final cart = await api.cart.viewCart(cartId, licenseKey);
} on NotFoundException catch (e) {
  if (e.message.contains('Cart is empty')) {
    // Show empty cart UI
    setState(() => _cartItems = []);
  }
}
```

---

## Weight Data Issues

### No Weight Data Received

**Symptoms:**
- `weightStream` not emitting data
- Weight always shows 0.0

**Solutions:**

1. **Check connection state**
   ```dart
   if (!sdk.isAuthenticated) {
     print('Not connected to scale');
     return;
   }
   ```

2. **Verify stream listener**
   ```dart
   @override
   void initState() {
     super.initState();
     
     sdk.weightStream.listen((weight) {
       print('Received weight: ${weight.displayWeight}');
       setState(() => _currentWeight = weight.displayWeight);
     });
   }
   ```

3. **Check scale device**
   - Place item on scale
   - Verify scale is responding

### Weight Updates Too Fast

**Problem:**
UI updating too frequently (10 Hz).

**Solution:**
Throttle updates:

```dart
DateTime _lastUpdate = DateTime.now();

sdk.weightStream.listen((weight) {
  final now = DateTime.now();
  
  // Update UI max every 200ms
  if (now.difference(_lastUpdate).inMilliseconds >= 200) {
    setState(() => _currentWeight = weight.displayWeight);
    _lastUpdate = now;
  }
});
```

### Weight Not Stable

**Problem:**
`isStable` always false.

**Solutions:**

1. **Place item gently on scale**
   - Avoid sudden movements
   - Wait for reading to stabilize

2. **Implement stability detection**
   ```dart
   double? _stableWeight;
   Timer? _stabilityTimer;
   
   sdk.weightStream.listen((weight) {
     if (weight.isStable && weight.displayWeight > 0.01) {
       // Start countdown
       _stabilityTimer?.cancel();
       _stabilityTimer = Timer(Duration(milliseconds: 500), () {
         if (weight.isStable) {
           _onStableWeight(weight.displayWeight);
         }
       });
     } else {
       _stabilityTimer?.cancel();
     }
   });
   ```

---

## Build/Compilation Issues

### "Unresolved reference" in Android

**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### iOS Build Fails with "No such module"

**Solution:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

### "MissingPluginException"

**Symptoms:**
- App crashes with MissingPluginException
- Plugin not registered

**Solution:**

1. **Hot restart doesn't work for plugin changes**
   ```bash
   # Stop app completely
   # Then rebuild
   flutter run
   ```

2. **Clean and rebuild**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Gradle Sync Fails

**Solution:**

1. **Update gradle wrapper**
   ```gradle
   // android/gradle/wrapper/gradle-wrapper.properties
   distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip
   ```

2. **Update gradle plugin**
   ```gradle
   // android/build.gradle
   dependencies {
     classpath 'com.android.tools.build:gradle:8.1.0'
   }
   ```

---

## Getting More Help

### Before Asking for Help

Collect this information:

1. **Flutter/Dart versions**
   ```bash
   flutter --version
   dart --version
   ```

2. **Platform & OS version**
   - Android: Check Settings → About Phone
   - iOS: Settings → General → About

3. **SDK version**
   ```yaml
   # Check pubspec.lock
   kgiton_sdk:
     # version info here
   ```

4. **Error messages**
   - Full stack trace
   - Console logs
   - Screenshots if applicable

5. **Steps to reproduce**
   - What were you doing?
   - Can you reproduce consistently?

### Contact Support

📧 **Email**: support@kgiton.com

**Include:**
- SDK version
- Platform (Android/iOS) and OS version
- Flutter/Dart version
- Error messages and logs
- Steps to reproduce
- License key (if license-related issue)

---

## Common Error Codes Quick Reference

| Code | Type | Solution |
|------|------|----------|
| `BLUETOOTH_DISABLED` | BLE | Enable Bluetooth |
| `PERMISSION_DENIED` | Permission | Grant BLE permissions |
| `LICENSE_INVALID` | Auth | Verify license key |
| `DEVICE_NOT_FOUND` | BLE | Rescan for devices |
| `CONNECTION_TIMEOUT` | BLE | Move closer, retry |
| 401 | API | Re-login required |
| 403 | API | No permission |
| 404 | API | Resource not found |
| 409 | API | Duplicate resource |
| 429 | API | Rate limited |

---

## Additional Resources

- **Getting Started**: [GETTING_STARTED.md](GETTING_STARTED.md)
- **BLE Integration**: [BLE_INTEGRATION.md](BLE_INTEGRATION.md)
- **API Integration**: [API_INTEGRATION.md](API_INTEGRATION.md)
- **Cart Guide**: [CART_GUIDE.md](CART_GUIDE.md)
- **Android 10-11**: [ANDROID_10_TROUBLESHOOTING.md](ANDROID_10_TROUBLESHOOTING.md)
