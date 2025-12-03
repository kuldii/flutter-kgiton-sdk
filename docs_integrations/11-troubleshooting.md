# 11. Troubleshooting

Common issues and solutions when using the KGiTON SDK.

---

## 🔍 Device Scanning Issues

### No Devices Found

**Symptoms:** Scan completes but no devices appear

**Solutions:**

1. **Check Bluetooth is ON**
   ```dart
   // For Android
   if (Platform.isAndroid) {
     final bluetoothOn = await Permission.bluetooth.status.isGranted;
     if (!bluetoothOn) {
       showDialog(...); // Prompt user to enable Bluetooth
     }
   }
   ```

2. **Verify Permissions**
   ```bash
   # Check if permissions granted
   - Android: Bluetooth Scan, Bluetooth Connect, Location
   - iOS: Bluetooth, Location When In Use
   ```

3. **Ensure Location Services ON** (Android)
   - Settings → Location → Turn ON

4. **Check Device is Powered ON**
   - Verify scale has battery
   - Check scale is not in sleep mode

5. **Reduce Scan Timeout**
   ```dart
   // Try shorter timeout
   await sdk.scanForDevices(timeout: Duration(seconds: 5));
   ```

---

## 🔌 Connection Issues

### Connection Fails Immediately

**Error:** `BLEConnectionException`

**Solutions:**

1. **Device Out of Range**
   - Move closer to scale (within 10 meters)
   - Remove obstacles between device and scale

2. **Device Already Connected**
   - Close other apps using the scale
   - Restart scale device
   - Restart phone Bluetooth

3. **Wrong Device ID**
   ```dart
   // Verify device ID is correct
   print('Connecting to: ${device.id}');
   ```

### Connection Drops Randomly

**Solutions:**

1. **Improve Signal Strength**
   - Keep devices closer
   - Reduce interference (WiFi routers, microwaves)

2. **Implement Auto-Reconnect**
   ```dart
   sdk.connectionStateStream.listen((state) {
     if (state == ScaleConnectionState.disconnected) {
       Timer(Duration(seconds: 3), () => _reconnect());
     }
   });
   ```

3. **Check Battery Levels**
   - Low battery can cause unstable connections
   - Replace scale batteries

---

## 🔑 License Key Issues

### Invalid License Key

**Error:** `LicenseKeyException: Invalid license format`

**Solutions:**

1. **Check Format**
   ```
   Correct: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
   Wrong:   XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

2. **Verify No Extra Spaces**
   ```dart
   final cleanKey = licenseKey.trim();
   ```

3. **Contact Support**
   - If license is correct but still fails
   - Email: support@kgiton.com

### License Expired

**Error:** `LicenseKeyException: License expired`

**Solution:**
- Contact PT KGiTON for renewal
- Email: sales@kgiton.com

---

## ⚖️ Weight Data Issues

### No Weight Data Received

**Solutions:**

1. **Check Connection State**
   ```dart
   if (sdk.connectionState != ScaleConnectionState.authenticated) {
     print('Not fully connected');
   }
   ```

2. **Verify Stream Subscription**
   ```dart
   sdk.weightStream.listen(
     (weight) => print('Weight: $weight'),
     onError: (e) => print('Stream error: $e'),
   );
   ```

3. **Wake Up Scale**
   - Place object on scale
   - Press scale button

### Weight Values Incorrect

**Solutions:**

1. **Calibrate Scale**
   - Follow scale manufacturer instructions
   - Use known weight for testing

2. **Check Unit Conversion**
   ```dart
   // Ensure correct unit display
   print('Raw: ${weight.rawWeight} kg');
   print('Display: ${weight.displayWeight}');
   ```

---

## 📱 Platform-Specific Issues

### Android Issues

**Issue: Location Permission Denied**

```dart
// Request location permission
final status = await Permission.location.request();
if (status.isPermanentlyDenied) {
  await openAppSettings();
}
```

**Issue: Location Services Disabled**

```dart
// Prompt user to enable location
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Enable Location'),
    content: Text('Location services must be enabled to scan for Bluetooth devices'),
    actions: [
      ElevatedButton(
        onPressed: () async {
          await openAppSettings();
          Navigator.pop(context);
        },
        child: Text('Open Settings'),
      ),
    ],
  ),
);
```

### iOS Issues

**Issue: Bluetooth Permission Denied**

```xml
<!-- Ensure Info.plist has usage description -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>We need Bluetooth to connect to your scale</string>
```

**Issue: Pod Install Fails**

```bash
cd ios
pod deintegrate
pod repo update  
pod install
```

---

## 🐛 Build & Installation Issues

### Flutter Pub Get Fails

```bash
# Clear cache and retry
flutter pub cache clean
flutter pub get
```

### Android Build Fails

**Error:** `Minimum SDK version mismatch`

**Solution:** Update `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdk 21  // Must be 21 or higher
    }
}
```

### iOS Build Fails

**Error:** `Deployment target too low`

**Solution:** Update `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

---

## 🔧 Runtime Errors

### App Crashes on Scan

**Cause:** Missing permissions

**Solution:**
```dart
// Check permissions before scanning
final hasPermissions = await PermissionsHelper.checkBLEPermissions();
if (!hasPermissions) {
  await PermissionsHelper.requestBLEPermissions();
}
await sdk.scanForDevices();
```

### Memory Leaks

**Cause:** Not disposing streams

**Solution:**
```dart
class _ScalePageState extends State<ScalePage> {
  StreamSubscription? _weightSub;
  
  @override
  void initState() {
    super.initState();
    _weightSub = sdk.weightStream.listen(...);
  }
  
  @override
  void dispose() {
    _weightSub?.cancel();  // Important!
    sdk.dispose();
    super.dispose();
  }
}
```

---

## 📊 Performance Issues

### Slow Scanning

**Solutions:**

1. **Reduce Scan Timeout**
   ```dart
   await sdk.scanForDevices(timeout: Duration(seconds: 5));
   ```

2. **Filter Devices**
   ```dart
   sdk.devicesStream
     .map((devices) => devices.where((d) => d.rssi > -80).toList())
     .listen(...);
   ```

### UI Freezing

**Cause:** Heavy operations on UI thread

**Solution:** Use isolates or compute
```dart
final processedWeight = await compute(_processWeight, rawWeight);
```

---

## 🆘 Getting Help

### Debug Logging

```dart
import 'package:logger/logger.dart';

final logger = Logger();

// Enable verbose logging
sdk.devicesStream.listen((devices) {
  logger.d('Found ${devices.length} devices');
  for (var device in devices) {
    logger.d('  - ${device.name}: ${device.rssi} dBm');
  }
});
```

### Collect Information

When reporting issues, include:
- SDK version: 1.1.0
- Flutter version: `flutter --version`
- Platform: Android/iOS version
- Device model
- Error messages/stack traces
- Steps to reproduce

### Contact Support

**For Authorized Users:**
- 📧 Email: support@kgiton.com
- 🐛 GitHub: [Create Issue](https://github.com/kuldii/flutter-kgiton-sdk/issues)

**Include:**
- Problem description
- Error logs
- Code snippets
- What you've tried

---

## ✅ Troubleshooting Checklist

- [ ] Bluetooth enabled on device
- [ ] All permissions granted
- [ ] Location services ON (Android)
- [ ] Scale device powered ON and nearby
- [ ] Valid license key
- [ ] Platform configuration correct
- [ ] Latest SDK version
- [ ] Proper error handling in code
- [ ] Streams properly disposed

---

## 📚 Related Documentation

- [FAQ](16-faq.md) - Common questions
- [Error Handling](09-error-handling.md) - Exception types
- [Platform Setup](04-platform-setup.md) - Configuration guide

---

**Still Having Issues?**

Contact support: support@kgiton.com

© 2025 PT KGiTON. All rights reserved.
