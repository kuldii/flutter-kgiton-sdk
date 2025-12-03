# 9. Error Handling

Complete guide to handling errors and exceptions in the KGiTON SDK.

---

## 🎯 Exception Types

### LicenseKeyException

**When:** Invalid, expired, or malformed license key

```dart
try {
  await sdk.connectWithLicenseKey(
    deviceId: device.id,
    licenseKey: 'INVALID-KEY',
  );
} on LicenseKeyException catch (e) {
  print('License error: ${e.message}');
  // Show license error to user
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('License Issue'),
      content: Text(e.message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

**Common Causes:**
- Invalid license format
- Expired license
- License for wrong device
- License not authorized

### BLEConnectionException

**When:** Bluetooth connection fails

```dart
try {
  await sdk.connectWithLicenseKey(
    deviceId: device.id,
    licenseKey: licenseKey,
  );
} on BLEConnectionException catch (e) {
  print('Connection failed: ${e.message}');
  // Retry logic
  final retry = await showRetryDialog(context);
  if (retry) {
    await _retryConnection();
  }
}
```

**Common Causes:**
- Device out of range
- Bluetooth turned off
- Device already connected to another app
- Interference

### BLEOperationException

**When:** BLE operation (read/write) fails

```dart
try {
  await sdk.triggerBuzzer('BEEP');
} on BLEOperationException catch (e) {
  print('Buzzer failed: ${e.message}');
  // Handle gracefully
  _showSnackBar('Could not trigger buzzer');
}
```

**Common Causes:**
- Weak signal
- Device disconnected during operation
- Device not ready

### DeviceNotConnectedException

**When:** Operation requires active connection

```dart
try {
  await sdk.triggerBuzzer('BEEP');
} on DeviceNotConnectedException catch (e) {
  print('Not connected: ${e.message}');
  // Redirect to connection screen
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ConnectionPage()),
  );
}
```

### DeviceNotAuthenticatedException

**When:** Operation requires authenticated connection

```dart
try {
  // Some authenticated operation
} on DeviceNotAuthenticatedException catch (e) {
  print('Not authenticated: ${e.message}');
  // Request authentication
  await _authenticateDevice();
}
```

### DeviceNotFoundException

**When:** Specified device not found during scan

```dart
try {
  await sdk.connectWithLicenseKey(
    deviceId: 'unknown-device-id',
    licenseKey: licenseKey,
  );
} on DeviceNotFoundException catch (e) {
  print('Device not found: ${e.message}');
  // Trigger new scan
  await _startScan();
}
```

---

## 🛡️ Error Handling Patterns

### Comprehensive Try-Catch

```dart
Future<void> connectToDevice(ScaleDevice device, String licenseKey) async {
  try {
    final response = await sdk.connectWithLicenseKey(
      deviceId: device.id,
      licenseKey: licenseKey,
    );
    
    if (response.success) {
      _showSuccess('Connected to ${device.name}');
    } else {
      _showError('Connection failed: ${response.message}');
    }
  } on LicenseKeyException catch (e) {
    _showError('Invalid license: ${e.message}');
    _promptForNewLicense();
  } on BLEConnectionException catch (e) {
    _showError('Connection failed: ${e.message}');
    _offerRetry();
  } on DeviceNotFoundException catch (e) {
    _showError('Device not found');
    _startScan();
  } catch (e) {
    _showError('Unexpected error: $e');
    _reportError(e);
  }
}
```

### Error Recovery

```dart
class ErrorRecovery {
  static Future<void> handleConnectionError(
    dynamic error,
    {
      required VoidCallback onRetry,
      required VoidCallback onCancel,
    }
  ) async {
    if (error is BLEConnectionException) {
      final retry = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Connection Failed'),
          content: Text('${error.message}\n\nWould you like to try again?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Retry'),
            ),
          ],
        ),
      );
      
      if (retry == true) {
        onRetry();
      } else {
        onCancel();
      }
    }
  }
}
```

---

## 📊 Error Logging

```dart
class ErrorLogger {
  static final logger = Logger();
  
  static void logError(dynamic error, StackTrace? stackTrace) {
    logger.e('Error occurred', error: error, stackTrace: stackTrace);
    
    // Send to analytics/crash reporting
    if (error is LicenseKeyException) {
      _trackLicenseError(error);
    } else if (error is BLEConnectionException) {
      _trackConnectionError(error);
    }
  }
  
  static void _trackLicenseError(LicenseKeyException e) {
    // Track in analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'license_error',
      parameters: {'message': e.message},
    );
  }
  
  static void _trackConnectionError(BLEConnectionException e) {
    FirebaseAnalytics.instance.logEvent(
      name: 'connection_error',
      parameters: {'message': e.message},
    );
  }
}
```

---

## ✅ Best Practices

1. **Always catch specific exceptions first**
2. **Provide user-friendly error messages**
3. **Log errors for debugging**
4. **Implement retry logic where appropriate**
5. **Handle connection state changes gracefully**

---

## 📚 Related Documentation

- [API Reference](08-api-reference.md)
- [Troubleshooting](11-troubleshooting.md)
- [Best Practices](10-best-practices.md)

---

© 2025 PT KGiTON. All rights reserved.
