# 10. Best Practices

Recommended patterns and best practices for KGiTON SDK integration.

---

## 🎯 Connection Management

### ✅ DO: Disconnect When Done

```dart
@override
void dispose() {
  sdk.disconnect();  // Clean up connection
  sdk.dispose();     // Release resources
  super.dispose();
}
```

### ❌ DON'T: Keep Unnecessary Connections

```dart
// Bad: Keeping connection when not needed
void onAppMinimized() {
  // Connection still active, draining battery
}

// Good: Disconnect when app goes to background
void onAppMinimized() {
  if (sdk.isConnected) {
    sdk.disconnect();
  }
}
```

---

## 🔋 Battery Optimization

### Scan Wisely

```dart
// ✅ Good: Limited scan duration
await sdk.scanForDevices(timeout: Duration(seconds: 10));

// ❌ Bad: Continuous scanning
while (true) {
  await sdk.scanForDevices(timeout: Duration(minutes: 5));
}
```

### Connect Only When Needed

```dart
// ✅ Good: Connect on demand
void onUserNeedsWeight() async {
  await sdk.connectWithLicenseKey(...);
  // Use scale
  await sdk.disconnect();
}

// ❌ Bad: Always connected
void initState() {
  super.initState();
  sdk.connectWithLicenseKey(...);  // Stays connected forever
}
```

---

## 🔐 License Key Security

### ✅ DO: Use Secure Storage

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Store securely
await storage.write(key: 'license_key', value: licenseKey);

// Retrieve when needed
final key = await storage.read(key: 'license_key');
```

### ❌ DON'T: Hardcode Keys

```dart
// ❌ Bad: Visible in source code
final licenseKey = 'A1B2C-3D4E5-F6G7H-8I9J0-K1L2M';

// ✅ Good: Load from secure storage
final licenseKey = await _loadLicenseKey();
```

---

## 📊 Weight Data Handling

### Implement Debouncing

```dart
class WeightDebouncer {
  Timer? _timer;
  final Duration delay;

  WeightDebouncer({this.delay = const Duration(milliseconds: 500)});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

// Usage
final debouncer = WeightDebouncer();

sdk.weightStream.listen((weight) {
  debouncer(() {
    // Only called after weight stabilizes for 500ms
    _saveWeight(weight);
  });
});
```

---

## 🎯 Error Handling

### Always Handle Exceptions

```dart
// ✅ Good: Comprehensive error handling
try {
  await sdk.connectWithLicenseKey(...);
} on LicenseKeyException catch (e) {
  _handleLicenseError(e);
} on BLEConnectionException catch (e) {
  _handleConnectionError(e);
} catch (e) {
  _handleUnknownError(e);
}

// ❌ Bad: No error handling
await sdk.connectWithLicenseKey(...);  // Can crash app
```

---

## 🔄 State Management

### Use Streams Properly

```dart
class ScaleController {
  StreamSubscription? _devicesSub;
  StreamSubscription? _weightSub;
  StreamSubscription? _stateSub;

  void init() {
    _devicesSub = sdk.devicesStream.listen(_onDevices);
    _weightSub = sdk.weightStream.listen(_onWeight);
    _stateSub = sdk.connectionStateStream.listen(_onState);
  }

  void dispose() {
    _devicesSub?.cancel();
    _weightSub?.cancel();
    _stateSub?.cancel();
  }
}
```

---

## 🧪 Testing

### Mock for Unit Tests

```dart
class MockScaleService implements KGiTONScaleService {
  @override
  Stream<List<ScaleDevice>> get devicesStream => Stream.value([
    ScaleDevice(id: 'mock-1', name: 'Mock Scale', rssi: -50),
  ]);

  @override
  Future<ControlResponse> connectWithLicenseKey({
    required String deviceId,
    required String licenseKey,
  }) async {
    return ControlResponse(success: true, message: 'Mock connected');
  }
}

// Use in tests
test('Connection test', () async {
  final mockSdk = MockScaleService();
  // Test with mock
});
```

---

## 📱 UI/UX

### Show Connection Status

```dart
Widget _buildStatusIndicator() {
  return StreamBuilder<ScaleConnectionState>(
    stream: sdk.connectionStateStream,
    builder: (context, snapshot) {
      final state = snapshot.data ?? ScaleConnectionState.disconnected;
      
      return Row(
        children: [
          Icon(
            _getIconFor State(state),
            color: _getColorForState(state),
          ),
          Text(_getTextForState(state)),
        ],
      );
    },
  );
}
```

### Provide Feedback

```dart
// ✅ Good: User knows what's happening
await _showLoadingDialog();
try {
  await sdk.connectWithLicenseKey(...);
  _hideLoadingDialog();
  _showSuccessMessage('Connected!');
} catch (e) {
  _hideLoadingDialog();
  _showErrorMessage('Connection failed');
}
```

---

## ⚡ Performance

### Limit Stream Updates

```dart
// Use distinct() to avoid duplicate updates
sdk.weightStream
  .distinct((a, b) => (a.rawWeight - b.rawWeight).abs() < 0.001)
  .listen((weight) {
    setState(() => _weight = weight);
  });
```

### Cache Device List

```dart
List<ScaleDevice>? _cachedDevices;
DateTime? _lastScan;

Future<List<ScaleDevice>> getDevices() async {
  final now = DateTime.now();
  
  if (_cachedDevices != null && 
      _lastScan != null &&
      now.difference(_lastScan!) < Duration(minutes: 1)) {
    return _cachedDevices!;
  }
  
  await sdk.scanForDevices();
  _cachedDevices = sdk.availableDevices;
  _lastScan = now;
  
  return _cachedDevices!;
}
```

---

## 🔒 Security

### Validate User Input

```dart
bool _isValidLicenseKey(String key) {
  // Format: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
  final regex = RegExp(r'^[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}$');
  return regex.hasMatch(key);
}

Future<void> connect(String licenseKey) async {
  if (!_isValidLicenseKey(licenseKey)) {
    throw Exception('Invalid license key format');
  }
  
  await sdk.connectWithLicenseKey(...);
}
```

---

## 📚 Code Organization

### Separate Concerns

```dart
// Good structure
lib/
├── services/
│   └── scale_service.dart          // SDK wrapper
├── models/
│   └── weight_record.dart          // Data models
├── controllers/
│   └── scale_controller.dart       // Business logic
└── ui/
    ├── pages/
    │   └── scale_page.dart         // UI
    └── widgets/
        └── weight_display.dart     // Reusable widgets
```

---

## ✅ Best Practices Checklist

- [ ] Disconnect when not in use
- [ ] Secure license key storage
- [ ] Comprehensive error handling
- [ ] Proper stream subscription management
- [ ] User feedback for all operations
- [ ] Battery-efficient scanning
- [ ] Input validation
- [ ] Clean code organization
- [ ] Unit tests with mocks
- [ ] Performance optimization

---

## 📚 Related Documentation

- [Advanced Features](07-advanced-features.md)
- [Error Handling](09-error-handling.md)
- [API Reference](08-api-reference.md)

---

© 2025 PT KGiTON. All rights reserved.
