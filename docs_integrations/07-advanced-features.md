# 7. Advanced Features

Learn advanced patterns and features for building robust scale integration applications.

---

## 🎯 What You'll Learn

- Auto-reconnection after connection loss
- Multi-device management patterns
- Background operation handling
- Custom weight data processing
- Connection retry strategies
- State persistence
- Performance optimization

---

## 🔄 Auto-Reconnection

### Basic Auto-Reconnect Pattern

```dart
class AutoReconnectService {
  final KGiTONScaleService _sdk;
  ScaleDevice? _lastDevice;
  String? _lastLicenseKey;
  bool _shouldReconnect = false;
  Timer? _reconnectTimer;

  AutoReconnectService(this._sdk) {
    _setupConnectionMonitoring();
  }

  void _setupConnectionMonitoring() {
    _sdk.connectionStateStream.listen((state) {
      if (state == ScaleConnectionState.disconnected && _shouldReconnect) {
        _scheduleReconnect();
      } else if (state == ScaleConnectionState.authenticated) {
        _cancelReconnect();
      }
    });
  }

  Future<void> connectWithAutoReconnect({
    required ScaleDevice device,
    required String licenseKey,
  }) async {
    _lastDevice = device;
    _lastLicenseKey = licenseKey;
    _shouldReconnect = true;

    await _sdk.connectWithLicenseKey(
      deviceId: device.id,
      licenseKey: licenseKey,
    );
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), _attemptReconnect);
  }

  Future<void> _attemptReconnect() async {
    if (!_shouldReconnect || _lastDevice == null || _lastLicenseKey == null) {
      return;
    }

    try {
      await _sdk.connectWithLicenseKey(
        deviceId: _lastDevice!.id,
        licenseKey: _lastLicenseKey!,
      );
    } catch (e) {
      print('Reconnect failed: $e');
      _scheduleReconnect(); // Try again
    }
  }

  void stopAutoReconnect() {
    _shouldReconnect = false;
    _cancelReconnect();
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void dispose() {
    stopAutoReconnect();
  }
}
```

### Usage

```dart
class ScalePage extends StatefulWidget {
  @override
  State<ScalePage> createState() => _ScalePageState();
}

class _ScalePageState extends State<ScalePage> {
  final _sdk = KGiTONScaleService();
  late final AutoReconnectService _reconnectService;

  @override
  void initState() {
    super.initState();
    _reconnectService = AutoReconnectService(_sdk);
  }

  Future<void> _connect(ScaleDevice device, String licenseKey) async {
    await _reconnectService.connectWithAutoReconnect(
      device: device,
      licenseKey: licenseKey,
    );
  }

  @override
  void dispose() {
    _reconnectService.dispose();
    _sdk.dispose();
    super.dispose();
  }
}
```

---

## 📊 Advanced Weight Data Processing

### Weight Averaging

```dart
class WeightAverager {
  final List<double> _readings = [];
  final int _sampleSize;

  WeightAverager({int sampleSize = 10}) : _sampleSize = sampleSize;

  double addReading(double weight) {
    _readings.add(weight);
    
    if (_readings.length > _sampleSize) {
      _readings.removeAt(0);
    }

    return getAverage();
  }

  double getAverage() {
    if (_readings.isEmpty) return 0.0;
    return _readings.reduce((a, b) => a + b) / _readings.length;
  }

  void clear() {
    _readings.clear();
  }
}
```

### Stable Weight Detection

```dart
class StableWeightDetector {
  final double _threshold;
  final int _requiredStableReadings;
  final List<double> _recentReadings = [];

  StableWeightDetector({
    double threshold = 0.01, // kg
    int requiredStableReadings = 5,
  })  : _threshold = threshold,
        _requiredStableReadings = requiredStableReadings;

  bool isStable(double newWeight) {
    _recentReadings.add(newWeight);

    if (_recentReadings.length > _requiredStableReadings) {
      _recentReadings.removeAt(0);
    }

    if (_recentReadings.length < _requiredStableReadings) {
      return false;
    }

    // Check if all readings are within threshold
    final min = _recentReadings.reduce((a, b) => a < b ? a : b);
    final max = _recentReadings.reduce((a, b) => a > b ? a : b);

    return (max - min) <= _threshold;
  }

  double? getStableWeight() {
    if (!isStable(_recentReadings.last)) return null;
    return _recentReadings.reduce((a, b) => a + b) / _recentReadings.length;
  }

  void reset() {
    _recentReadings.clear();
  }
}
```

### Usage with Stream Transformation

```dart
class _ScalePageState extends State<ScalePage> {
  final _averager = WeightAverager(sampleSize: 10);
  final _stableDetector = StableWeightDetector();

  @override
  void initState() {
    super.initState();
    _setupAdvancedWeightProcessing();
  }

  void _setupAdvancedWeightProcessing() {
    _sdk.weightStream.listen((weight) {
      // Get averaged weight
      final averaged = _averager.addReading(weight.rawWeight);

      // Check if stable
      if (_stableDetector.isStable(weight.rawWeight)) {
        final stable = _stableDetector.getStableWeight();
        print('Stable weight detected: $stable kg');
        _onStableWeight(stable!);
      }

      setState(() {
        _displayWeight = averaged.toStringAsFixed(3);
      });
    });
  }

  void _onStableWeight(double weight) {
    // Trigger buzzer or save weight
    _sdk.triggerBuzzer('BEEP');
    _saveWeight(weight);
  }
}
```

---

## 🔄 Connection Retry Strategy

### Exponential Backoff

```dart
class ConnectionRetryStrategy {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;

  int _currentRetry = 0;

  ConnectionRetryStrategy({
    this.maxRetries = 5,
    this.initialDelay = const Duration(seconds: 2),
    this.backoffMultiplier = 2.0,
  });

  Duration getNextDelay() {
    if (_currentRetry >= maxRetries) {
      throw Exception('Max retries exceeded');
    }

    final delay = initialDelay * pow(backoffMultiplier, _currentRetry);
    _currentRetry++;
    
    return Duration(milliseconds: delay.inMilliseconds.toInt());
  }

  void reset() {
    _currentRetry = 0;
  }

  bool get hasRetriesLeft => _currentRetry < maxRetries;
}
```

### Retry-Enabled Connection

```dart
Future<ControlResponse> connectWithRetry({
  required ScaleDevice device,
  required String licenseKey,
  ConnectionRetryStrategy? strategy,
}) async {
  strategy ??= ConnectionRetryStrategy();

  while (strategy.hasRetriesLeft) {
    try {
      final response = await _sdk.connectWithLicenseKey(
        deviceId: device.id,
        licenseKey: licenseKey,
      );

      if (response.success) {
        strategy.reset();
        return response;
      }
    } catch (e) {
      if (!strategy.hasRetriesLeft) {
        rethrow;
      }

      final delay = strategy.getNextDelay();
      print('Connection failed, retrying in ${delay.inSeconds}s...');
      await Future.delayed(delay);
    }
  }

  throw Exception('Connection failed after ${strategy.maxRetries} retries');
}
```

---

## 💾 State Persistence

### Save Connection State

```dart
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionStateManager {
  static const String _keyLastDeviceId = 'last_device_id';
  static const String _keyLastDeviceName = 'last_device_name';
  static const String _keyAutoReconnect = 'auto_reconnect_enabled';

  Future<void> saveLastDevice(ScaleDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastDeviceId, device.id);
    await prefs.setString(_keyLastDeviceName, device.name);
  }

  Future<Map<String, String>?> getLastDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyLastDeviceId);
    final name = prefs.getString(_keyLastDeviceName);

    if (id == null || name == null) return null;

    return {'id': id, 'name': name};
  }

  Future<void> setAutoReconnect(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoReconnect, enabled);
  }

  Future<bool> getAutoReconnect() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoReconnect) ?? false;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastDeviceId);
    await prefs.remove(_keyLastDeviceName);
  }
}
```

---

## 📱 Background Operation Handling

### App Lifecycle Management

```dart
class ScaleManager with WidgetsBindingObserver {
  final KGiTONScaleService _sdk;
  bool _wasConnected = false;
  ScaleDevice? _activeDevice;
  String? _licenseKey;

  ScaleManager(this._sdk) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
        // Handle as needed
        break;
      case AppLifecycleState.detached:
        _cleanup();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _onAppPaused() {
    _wasConnected = _sdk.isConnected;
    
    // Optional: disconnect to save battery
    if (_wasConnected) {
      print('App paused, maintaining connection');
      // Or: _sdk.disconnect();
    }
  }

  void _onAppResumed() {
    print('App resumed');
    
    // Check connection status
    if (_wasConnected && !_sdk.isConnected && _activeDevice != null) {
      _attemptReconnect();
    }
  }

  Future<void> _attemptReconnect() async {
    if (_activeDevice == null || _licenseKey == null) return;

    try {
      await _sdk.connectWithLicenseKey(
        deviceId: _activeDevice!.id,
        licenseKey: _licenseKey!,
      );
    } catch (e) {
      print('Auto-reconnect failed: $e');
    }
  }

  void _cleanup() {
    WidgetsBinding.instance.removeObserver(this);
    _sdk.disconnect();
  }

  void setActiveConnection(ScaleDevice device, String licenseKey) {
    _activeDevice = device;
    _licenseKey = licenseKey;
  }
}
```

---

## 🎨 Custom Weight Display Formatting

### Multiple Unit Support

```dart
enum WeightUnit { kg, g, lb, oz }

class WeightFormatter {
  static String format(double weightInKg, WeightUnit unit) {
    switch (unit) {
      case WeightUnit.kg:
        return '${weightInKg.toStringAsFixed(3)} kg';
      case WeightUnit.g:
        return '${(weightInKg * 1000).toStringAsFixed(1)} g';
      case WeightUnit.lb:
        return '${(weightInKg * 2.20462).toStringAsFixed(2)} lb';
      case WeightUnit.oz:
        return '${(weightInKg * 35.274).toStringAsFixed(2)} oz';
    }
  }

  static double convert(double weightInKg, WeightUnit from, WeightUnit to) {
    // Convert to kg first
    double inKg;
    switch (from) {
      case WeightUnit.kg:
        inKg = weightInKg;
        break;
      case WeightUnit.g:
        inKg = weightInKg / 1000;
        break;
      case WeightUnit.lb:
        inKg = weightInKg / 2.20462;
        break;
      case WeightUnit.oz:
        inKg = weightInKg / 35.274;
        break;
    }

    // Convert from kg to target unit
    switch (to) {
      case WeightUnit.kg:
        return inKg;
      case WeightUnit.g:
        return inKg * 1000;
      case WeightUnit.lb:
        return inKg * 2.20462;
      case WeightUnit.oz:
        return inKg * 35.274;
    }
  }
}
```

---

## 🔔 Advanced Notification Patterns

### Weight Change Alerts

```dart
class WeightChangeNotifier {
  final double threshold;
  double? _lastNotifiedWeight;
  final Function(double) onSignificantChange;

  WeightChangeNotifier({
    required this.threshold,
    required this.onSignificantChange,
  });

  void checkWeight(double currentWeight) {
    if (_lastNotifiedWeight == null) {
      _lastNotifiedWeight = currentWeight;
      return;
    }

    final difference = (currentWeight - _lastNotifiedWeight!).abs();
    
    if (difference >= threshold) {
      onSignificantChange(currentWeight);
      _lastNotifiedWeight = currentWeight;
    }
  }

  void reset() {
    _lastNotifiedWeight = null;
  }
}
```

---

## 📈 Performance Monitoring

### Connection Metrics

```dart
class ConnectionMetrics {
  DateTime? _connectionStartTime;
  int _reconnectCount = 0;
  int _failedAttempts = 0;
  final List<Duration> _connectionDurations = [];

  void onConnectionStart() {
    _connectionStartTime = DateTime.now();
  }

  void onConnectionSuccess() {
    if (_connectionStartTime != null) {
      final duration = DateTime.now().difference(_connectionStartTime!);
      _connectionDurations.add(duration);
    }
  }

  void onConnectionFailed() {
    _failedAttempts++;
  }

  void onReconnect() {
    _reconnectCount++;
  }

  Map<String, dynamic> getMetrics() {
    return {
      'reconnect_count': _reconnectCount,
      'failed_attempts': _failedAttempts,
      'average_connection_time': _getAverageConnectionTime(),
      'total_connections': _connectionDurations.length,
    };
  }

  Duration? _getAverageConnectionTime() {
    if (_connectionDurations.isEmpty) return null;
    
    final total = _connectionDurations.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    
    return Duration(milliseconds: total ~/ _connectionDurations.length);
  }

  void reset() {
    _connectionStartTime = null;
    _reconnectCount = 0;
    _failedAttempts = 0;
    _connectionDurations.clear();
  }
}
```

---

## ✅ Advanced Features Summary

You've learned:

- ✅ Auto-reconnection patterns
- ✅ Advanced weight processing (averaging, stable detection)
- ✅ Retry strategies with exponential backoff
- ✅ State persistence with SharedPreferences
- ✅ Background operation handling
- ✅ Custom weight formatting
- ✅ Performance monitoring

### Next Steps

👉 **[8. API Reference](08-api-reference.md)** - Complete API documentation

Or explore:
- [Best Practices](10-best-practices.md) - Optimization tips
- [Complete Examples](12-complete-examples.md) - Real-world implementations

---

© 2025 PT KGiTON. All rights reserved.
