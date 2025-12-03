# 16. FAQ - Frequently Asked Questions

Common questions and answers about the KGiTON SDK.

---

## 📋 Table of Contents

- [General Questions](#general-questions)
- [Licensing & Authorization](#licensing--authorization)
- [Installation & Setup](#installation--setup)
- [Integration & Development](#integration--development)
- [Troubleshooting](#troubleshooting)
- [Performance & Optimization](#performance--optimization)
- [Platform-Specific](#platform-specific)

---

## General Questions

### Q: What is the KGiTON SDK?

**A:** The KGiTON SDK is a Flutter package that enables integration with KGiTON BLE scale devices. It provides APIs for device scanning, connection management, real-time weight data streaming, and device control.

### Q: Which platforms are supported?

**A:** The SDK supports:
- ✅ Android (API Level 21+)
- ✅ iOS (12.0+)
- ❌ Web (not supported - requires BLE hardware)
- ❌ Desktop (not supported)

### Q: Is the SDK open source?

**A:** No. The KGiTON SDK is proprietary commercial software owned by PT KGiTON. Use requires explicit authorization.

### Q: What's the difference between kgiton_sdk and kgiton_ble_sdk?

**A:**
- **kgiton_sdk**: High-level SDK with business logic (license auth, weight processing, etc.) - Proprietary
- **kgiton_ble_sdk**: Low-level BLE communication library - MIT licensed, used internally

You should use **kgiton_sdk** for your applications.

### Q: Can I use the SDK in multiple projects?

**A:** It depends on your license agreement. Contact PT KGiTON for multi-project licensing options.

---

## Licensing & Authorization

### Q: How do I get a license key?

**A:** Contact PT KGiTON:
1. Email: support@kgiton.com
2. Subject: "KGiTON SDK License Request"
3. Include company info and use case
4. Review and sign license agreement
5. Receive license key

See [Authorization Guide](02-authorization.md) for details.

### Q: Is there a free trial?

**A:** Contact sales@kgiton.com to discuss evaluation options for qualified organizations.

### Q: How much does the SDK cost?

**A:** Pricing varies by license type (Development, Commercial, Enterprise). Contact sales@kgiton.com for a quote.

### Q: What happens if my license expires?

**A:**
- New connections will fail
- Existing connections may be terminated
- You must renew to restore access
- Renewal reminders sent 30, 14, 7 days before expiration

### Q: Can I transfer my license to another developer?

**A:** License transfers require approval from PT KGiTON. Contact support@kgiton.com.

### Q: Where should I store my license key?

**A:** Never hardcode it! Use:
- ✅ Environment variables (.env file)
- ✅ Secure storage (flutter_secure_storage)
- ✅ Remote configuration (your backend)
- ❌ NOT in source code or version control

See [Authorization Guide](02-authorization.md#securing-your-license-key).

---

## Installation & Setup

### Q: Why does `flutter pub get` fail?

**A:** Common reasons:
1. **No repository access**: Verify you have access to the GitHub repository
2. **Wrong URL**: Check the repository URL is correct
3. **Network issues**: Check internet connection
4. **Cache issues**: Try `flutter pub cache clean`

### Q: Can I install from a local path?

**A:** Yes, for development:
```yaml
kgiton_sdk:
  path: /path/to/local/kgiton-sdk
```
For production, use Git dependency.

### Q: Do I need to configure anything after installation?

**A:** Yes:
1. Platform permissions (AndroidManifest.xml / Info.plist)
2. Minimum SDK versions
3. Runtime permission handling

See [Platform Setup](04-platform-setup.md).

### Q: How do I update to the latest version?

**A:**
```bash
flutter pub upgrade kgiton_sdk
```

Check [CHANGELOG.md](../CHANGELOG.md) for breaking changes.

### Q: What's the minimum Flutter version required?

**A:** Flutter 3.3.0 or higher, Dart 3.0.0 or higher.

---

## Integration & Development

### Q: How do I scan for devices?

**A:**
```dart
await sdk.scanForDevices(timeout: Duration(seconds: 15));
```

Listen to `sdk.devicesStream` for discovered devices.

See [Basic Integration](06-basic-integration.md#step-2-scan-for-devices).

### Q: How do I connect to a device?

**A:**
```dart
final response = await sdk.connectWithLicenseKey(
  deviceId: device.id,
  licenseKey: 'YOUR-LICENSE-KEY',
);
```

See [Basic Integration](06-basic-integration.md#step-3-connect-to-device).

### Q: How do I get weight data?

**A:** Listen to the weight stream:
```dart
sdk.weightStream.listen((weight) {
  print('Weight: ${weight.displayWeight}');
});
```

See [Basic Integration](06-basic-integration.md#step-4-display-weight-data).

### Q: Can I connect to multiple devices simultaneously?

**A:** No, the SDK supports one active connection at a time. To switch devices:
1. Disconnect from current device
2. Connect to new device

### Q: How do I handle connection loss?

**A:** Listen to connection state:
```dart
sdk.connectionStateStream.listen((state) {
  if (state == ScaleConnectionState.disconnected) {
    // Handle disconnection
  }
});
```

Implement auto-reconnect - see [Advanced Features](07-advanced-features.md).

### Q: What buzzer commands are available?

**A:**
- `'BEEP'` - Short beep
- `'BUZZ'` - Vibration-like buzz
- `'LONG'` - Long beep
- `'OFF'` - Turn off buzzer

```dart
await sdk.triggerBuzzer('BEEP');
```

### Q: How do I properly dispose the SDK?

**A:**
```dart
@override
void dispose() {
  sdk.disconnect();
  sdk.dispose();
  super.dispose();
}
```

### Q: Can I use the SDK with state management like Bloc/Provider/Riverpod?

**A:** Yes! The SDK works with any state management solution. The streams can be integrated into:
- Bloc (via StreamSubscription)
- Provider (via StreamProvider)
- Riverpod (via StreamProvider)
- GetX (via Rx)

---

## Troubleshooting

### Q: Why can't I find any devices?

**A:** Check:
1. ✅ Bluetooth is ON
2. ✅ Location permission granted (Android)
3. ✅ Location services enabled (Android)
4. ✅ Scale device is powered on
5. ✅ Scale is within range
6. ✅ Scale is not connected to another app

### Q: Connection fails with "Invalid license key"

**A:**
1. Verify license key format: `XXXXX-XXXXX-XXXXX-XXXXX-XXXXX`
2. Check license hasn't expired
3. Verify license is for correct device
4. Contact support if persists

### Q: Why does weight data stop updating?

**A:** Possible causes:
1. Device disconnected - check connection state
2. Scale went to sleep - wake it up
3. Low battery on scale
4. BLE connection interrupted

### Q: App crashes on scan/connect

**A:**
1. Check permissions are granted
2. Verify platform configuration
3. Check Flutter doctor output
4. See [Troubleshooting Guide](11-troubleshooting.md)

### Q: "Permission denied" error on Android 12+

**A:** Android 12+ requires:
```xml
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

And runtime permission request:
```dart
await Permission.bluetoothScan.request();
await Permission.bluetoothConnect.request();
```

### Q: iOS asks for location permission, why?

**A:** iOS requires location permission for BLE scanning to prevent location tracking abuse. Grant the permission - the SDK doesn't actually track location.

---

## Performance & Optimization

### Q: How often does weight data update?

**A:** Approximately 10 Hz (10 times per second) when connected.

### Q: Does the SDK affect battery life?

**A:** BLE is designed for low power consumption. Battery impact is minimal when:
- Only connecting when needed
- Properly disconnecting when done
- Not scanning continuously

### Q: Can I reduce the scan timeout?

**A:** Yes:
```dart
await sdk.scanForDevices(timeout: Duration(seconds: 5)); // Shorter scan
```

But you may miss devices with weaker signals.

### Q: How can I improve connection reliability?

**A:**
1. Keep devices within 10 meters
2. Reduce physical obstacles
3. Ensure scale battery is good
4. Implement retry logic
5. Use auto-reconnect pattern

See [Best Practices](10-best-practices.md).

### Q: What's the maximum connection range?

**A:** Typical BLE range is 10 meters in open space. Walls and obstacles reduce this significantly.

---

## Platform-Specific

### Android Questions

**Q: What's the minimum Android version?**  
**A:** Android 5.0 (API Level 21)

**Q: Why do I need location permission on Android?**  
**A:** Android requires location permission for BLE scanning (even though SDK doesn't track location). It's a platform requirement.

**Q: Location services must be ON?**  
**A:** Yes, on Android <12. Not required on Android 12+ if you use `BLUETOOTH_SCAN` permission.

**Q: How to handle Android 12+ permissions?**  
**A:** Use both old and new permissions:
```xml
<!-- Android < 12 -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.LOCATION" />

<!-- Android 12+ -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

### iOS Questions

**Q: What's the minimum iOS version?**  
**A:** iOS 12.0

**Q: Do I need an Apple Developer account?**  
**A:** Yes, for deploying to physical devices (required for BLE testing).

**Q: Pod install fails, what to do?**  
**A:**
```bash
cd ios
pod deintegrate
pod repo update
pod install
```

**Q: Can I test on iOS Simulator?**  
**A:** No. Simulator doesn't support Bluetooth. You need a physical device.

**Q: Background BLE on iOS?**  
**A:** Add to Info.plist:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
</array>
```

---

## Development Best Practices

### Q: Should I scan continuously?

**A:** No. Scan only when needed:
```dart
// Good: Scan when user taps button
onPressed: () => sdk.scanForDevices(...)

// Bad: Scan in initState
initState() {
  sdk.scanForDevices(...) // Don't do this!
}
```

### Q: How to handle app lifecycle (background/foreground)?

**A:**
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    // App in background - consider disconnecting
  } else if (state == AppLifecycleState.resumed) {
    // App in foreground - check connection
  }
}
```

### Q: Should I keep connection alive always?

**A:** Only if needed. For best battery life:
- Connect when user needs scale
- Disconnect when done
- Implement reconnect button

### Q: How to test without physical scale?

**A:** You can't fully test without hardware. For development:
1. Use mock data for UI testing
2. Test error handling paths
3. Get a development scale device

### Q: Best way to display errors to users?

**A:** User-friendly messages:
```dart
catch (e) {
  String message;
  if (e is LicenseKeyException) {
    message = 'License key issue. Please contact support.';
  } else if (e is BLEConnectionException) {
    message = 'Connection failed. Please try again.';
  } else {
    message = 'An error occurred. Please try again.';
  }
  // Show to user
}
```

---

## Support & Resources

### Q: Where can I get help?

**A:** For authorized users:
- 📧 Email: support@kgiton.com
- 🐛 GitHub: [Report Issues](https://github.com/kuldii/flutter-kgiton-sdk/issues)
- 📚 Documentation: This guide!

### Q: How do I report a bug?

**A:**
1. Check [Troubleshooting Guide](11-troubleshooting.md)
2. Search existing GitHub issues
3. Create new issue with:
   - SDK version
   - Flutter version
   - Platform (Android/iOS)
   - Steps to reproduce
   - Error messages/logs

### Q: How do I request a feature?

**A:** Email support@kgiton.com with:
- Feature description
- Use case
- Why it's needed
- Enterprise license holders get priority

### Q: Is documentation available offline?

**A:** Yes! Clone the repository and read markdown files locally.

### Q: Where's the changelog?

**A:** [CHANGELOG.md](../CHANGELOG.md) in the repository root.

---

## Didn't Find Your Answer?

**Check These Resources:**
- 📚 [Complete Documentation](README.md)
- 🔧 [Troubleshooting Guide](11-troubleshooting.md)
- 📖 [API Reference](08-api-reference.md)
- 💡 [Best Practices](10-best-practices.md)

**Still Need Help?**
- 📧 Email: support@kgiton.com
- 🌐 Website: https://kgiton.com

---

**Response Time**: Within 24 hours (business days) for authorized users.

© 2025 PT KGiTON. All rights reserved.
