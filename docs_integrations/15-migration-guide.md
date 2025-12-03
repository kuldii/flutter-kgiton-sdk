# 15. Migration Guide

Guide for migrating between different versions of KGiTON SDK.

---

## 📋 Version Overview

| Version | Release Date | Status | Breaking Changes |
|---------|-------------|--------|------------------|
| 1.1.0   | 2025-01     | Current | No              |
| 1.0.0   | 2024-12     | Stable  | -               |

---

## 🔄 Migration Path

### From 1.0.0 to 1.1.0

**✅ No Breaking Changes**

This is a backward-compatible release with new features and improvements.

#### New Features

1. **Auto-reconnect Support**
```dart
// Old (1.0.0) - Manual reconnection
sdk.connectionStateStream.listen((state) {
  if (state == ScaleConnectionState.disconnected) {
    // Manual reconnect logic
  }
});

// New (1.1.0) - Built-in auto-reconnect
final sdk = KGiTONScaleService(
  autoReconnect: true,
  reconnectDelay: Duration(seconds: 5),
);
```

2. **Weight Threshold Filtering**
```dart
// Old (1.0.0) - Manual filtering
sdk.weightStream.listen((weight) {
  if (weight.rawWeight > 0.01) {
    // Process weight
  }
});

// New (1.1.0) - Built-in threshold
final sdk = KGiTONScaleService(
  weightThreshold: 0.01,
);
```

3. **Enhanced Error Messages**
```dart
// Old (1.0.0) - Generic errors
try {
  await sdk.connect(deviceId);
} catch (e) {
  print('Error: $e');
}

// New (1.1.0) - Specific exceptions
try {
  await sdk.connect(deviceId);
} on BLENotAvailableException {
  // BLE not available
} on DeviceNotFoundException {
  // Device not found
} on ConnectionTimeoutException {
  // Connection timeout
}
```

#### Deprecated APIs

None in this release.

#### Upgrade Steps

1. Update dependency in `pubspec.yaml`:
```yaml
dependencies:
  kgiton_sdk: ^1.1.0
```

2. Run:
```bash
flutter pub get
```

3. Review new features and update code if desired (optional).

---

## 🆕 Future Versions

### Planned for 2.0.0 (Q2 2025)

**⚠️ Breaking Changes Expected**

1. **New Connection API**
```dart
// Current (1.x)
await sdk.connectWithLicenseKey(
  deviceId: deviceId,
  licenseKey: licenseKey,
);

// Future (2.0)
await sdk.connect(
  device: device,
  credentials: LicenseCredentials(key: licenseKey),
);
```

2. **Stream API Changes**
```dart
// Current (1.x)
sdk.weightStream.listen((weight) { });
sdk.connectionStateStream.listen((state) { });

// Future (2.0)
sdk.on<WeightEvent>().listen((event) { });
sdk.on<ConnectionEvent>().listen((event) { });
```

3. **Configuration Builder Pattern**
```dart
// Future (2.0)
final sdk = KGiTONScaleService.configure()
  .withAutoReconnect(enabled: true, delay: Duration(seconds: 5))
  .withWeightThreshold(0.01)
  .withTimeout(Duration(seconds: 30))
  .build();
```

---

## 🔧 Migration Checklist

### Before Migrating

- [ ] Review changelog
- [ ] Check breaking changes
- [ ] Backup current codebase
- [ ] Review minimum SDK requirements
- [ ] Test in development environment

### During Migration

- [ ] Update `pubspec.yaml`
- [ ] Run `flutter pub get`
- [ ] Update deprecated APIs
- [ ] Fix breaking changes
- [ ] Update tests
- [ ] Run test suite

### After Migration

- [ ] Test all features
- [ ] Verify BLE connectivity
- [ ] Check error handling
- [ ] Monitor performance
- [ ] Update documentation
- [ ] Deploy to staging

---

## 📝 Version Compatibility

### Flutter Version Requirements

| SDK Version | Min Flutter | Max Flutter | Dart Version |
|-------------|-------------|-------------|--------------|
| 1.1.0       | 3.0.0       | Latest      | >=3.0.0 <4.0.0 |
| 1.0.0       | 3.0.0       | Latest      | >=3.0.0 <4.0.0 |

### Platform Support

| Platform | 1.0.0 | 1.1.0 | 2.0.0 (Planned) |
|----------|-------|-------|-----------------|
| Android  | ✅ 5.0+ | ✅ 5.0+ | ✅ 6.0+ |
| iOS      | ✅ 12.0+ | ✅ 12.0+ | ✅ 13.0+ |
| Web      | ❌     | ❌     | 🔜 Planned |
| Desktop  | ❌     | ❌     | 🔜 Planned |

---

## 🐛 Common Migration Issues

### Issue: Build Errors After Update

**Solution:**
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### Issue: Null Safety Warnings

**Solution:**
Ensure your project uses null safety:
```yaml
# pubspec.yaml
environment:
  sdk: ">=3.0.0 <4.0.0"
```

### Issue: BLE Permissions Not Working

**Solution:**
Update permission configurations:

**Android** (`AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"
                 android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

**iOS** (`Info.plist`):
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Need Bluetooth to connect to scale</string>
```

---

## 📦 Rollback Procedure

If migration fails, rollback to previous version:

1. Revert `pubspec.yaml`:
```yaml
dependencies:
  kgiton_sdk: ^1.0.0
```

2. Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter run
```

3. Restore code from backup if needed.

---

## 🔔 Stay Updated

- **Changelog**: Check `CHANGELOG.md` for all changes
- **GitHub**: Watch [repository](https://github.com/kuldii/flutter-kgiton-sdk) for updates
- **Documentation**: Visit docs for latest guides
- **Support**: Contact support@kgiton.com for help

---

## 📚 Related Documentation

- [Installation](03-installation.md)
- [API Reference](08-api-reference.md)
- [Troubleshooting](11-troubleshooting.md)

---

© 2025 PT KGiTON. All rights reserved.
