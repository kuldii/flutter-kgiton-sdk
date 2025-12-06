# BLE Scale Integration Guide

Complete guide for integrating KGiTON BLE scale devices into your Flutter application.

---

## Table of Contents

1. [Basic Integration](#basic-integration)
2. [Connection Management](#connection-management)
3. [Weight Data Streaming](#weight-data-streaming)
4. [Buzzer Control](#buzzer-control)
5. [Error Handling](#error-handling)
6. [Best Practices](#best-practices)
7. [API Reference](#api-reference)

---

## Basic Integration

### Initialize Service

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

class MyScaleWidget extends StatefulWidget {
  @override
  State<MyScaleWidget> createState() => _MyScaleWidgetState();
}

class _MyScaleWidgetState extends State<MyScaleWidget> {
  final sdk = KGiTONScaleService();
  
  @override
  void initState() {
    super.initState();
    _setupStreams();
  }
  
  void _setupStreams() {
    // Setup your stream listeners here
  }
  
  @override
  void dispose() {
    sdk.disconnect();
    super.dispose();
  }
}
```

### Scan for Devices

```dart
Future<void> scanForDevices() async {
  // Check permissions first
  final hasPermissions = await PermissionHelper.checkBLEPermissions();
  if (!hasPermissions) {
    await PermissionHelper.requestBLEPermissions();
    return;
  }
  
  // Start scanning
  await sdk.scanForDevices(
    timeout: Duration(seconds: 15),
  );
  
  // Devices will be emitted through devicesStream
}
```

### Listen to Devices

```dart
void _setupStreams() {
  sdk.devicesStream.listen((devices) {
    setState(() {
      _devices = devices;
    });
    
    print('Found ${devices.length} devices');
    for (var device in devices) {
      print('- ${device.name} (${device.rssi} dBm)');
    }
  });
}
```

---

## Connection Management

### Connect to Device

```dart
Future<void> connectToScale(String deviceId) async {
  try {
    await sdk.connectWithLicenseKey(
      deviceId: deviceId,
      licenseKey: 'YOUR-LICENSE-KEY',
    );
    
    print('✅ Connected successfully');
    
  } on KGiTONException catch (e) {
    print('❌ Connection failed: ${e.message}');
    
    if (e.code == 'LICENSE_INVALID') {
      // Show license error to user
    } else if (e.code == 'DEVICE_NOT_FOUND') {
      // Show device not found error
    }
  }
}
```

### Monitor Connection State

```dart
void _setupStreams() {
  sdk.connectionStateStream.listen((state) {
    switch (state) {
      case ScaleConnectionState.disconnected:
        print('Disconnected');
        _showStatus('Disconnected');
        break;
        
      case ScaleConnectionState.scanning:
        print('Scanning...');
        _showStatus('Looking for devices...');
        break;
        
      case ScaleConnectionState.connecting:
        print('Connecting...');
        _showStatus('Connecting to scale...');
        break;
        
      case ScaleConnectionState.connected:
        print('Connected (not authenticated)');
        _showStatus('Verifying license...');
        break;
        
      case ScaleConnectionState.authenticated:
        print('✅ Authenticated - Ready to use');
        _showStatus('Connected');
        break;
        
      case ScaleConnectionState.error:
        print('❌ Error state');
        _showStatus('Connection error');
        break;
    }
  });
}
```

### Disconnect

```dart
Future<void> disconnect() async {
  await sdk.disconnect();
  print('Disconnected from scale');
}
```

### Auto-Reconnect Pattern

```dart
StreamSubscription? _connectionSubscription;

void _setupAutoReconnect() {
  _connectionSubscription = sdk.connectionStateStream.listen((state) {
    if (state == ScaleConnectionState.disconnected) {
      // Wait a bit before reconnecting
      Future.delayed(Duration(seconds: 2), () {
        if (mounted && _shouldReconnect) {
          _reconnect();
        }
      });
    }
  });
}

Future<void> _reconnect() async {
  if (_lastDeviceId != null && _licenseKey != null) {
    try {
      await sdk.connectWithLicenseKey(
        deviceId: _lastDeviceId!,
        licenseKey: _licenseKey!,
      );
    } catch (e) {
      print('Reconnect failed: $e');
    }
  }
}
```

---

## Weight Data Streaming

### Listen to Weight Updates

Weight data is streamed at approximately 10 Hz (10 updates per second):

```dart
void _setupStreams() {
  sdk.weightStream.listen((weight) {
    setState(() {
      _currentWeight = weight.displayWeight;
    });
    
    print('Weight: ${weight.displayWeight} ${weight.unit}');
    print('Raw value: ${weight.rawValue}');
    print('Stable: ${weight.isStable}');
  });
}
```

### Detect Stable Weight

```dart
double? _stableWeight;
Timer? _stabilityTimer;

void _setupStreams() {
  sdk.weightStream.listen((weight) {
    if (weight.isStable && weight.displayWeight > 0) {
      // Start timer to confirm stability
      _stabilityTimer?.cancel();
      _stabilityTimer = Timer(Duration(milliseconds: 500), () {
        if (weight.isStable) {
          _onStableWeight(weight.displayWeight);
        }
      });
    } else {
      _stabilityTimer?.cancel();
    }
    
    setState(() => _currentWeight = weight.displayWeight);
  });
}

void _onStableWeight(double weight) {
  print('✅ Stable weight detected: $weight kg');
  _stableWeight = weight;
  
  // Trigger buzzer feedback
  sdk.triggerBuzzer('BEEP');
  
  // Auto-add to cart, etc.
}
```

### Throttle Weight Updates

If 10 Hz is too fast for your UI:

```dart
import 'dart:async';

StreamSubscription? _weightSubscription;
DateTime _lastUpdate = DateTime.now();

void _setupStreams() {
  _weightSubscription = sdk.weightStream.listen((weight) {
    final now = DateTime.now();
    
    // Update UI max every 100ms (10 Hz -> 10 Hz, but throttled)
    if (now.difference(_lastUpdate).inMilliseconds >= 100) {
      setState(() => _currentWeight = weight.displayWeight);
      _lastUpdate = now;
    }
  });
}
```

---

## Buzzer Control

### Buzzer Commands

```dart
// Short beep (success feedback)
await sdk.triggerBuzzer('BEEP');

// Continuous buzz
await sdk.triggerBuzzer('BUZZ');

// Long beep (warning/alert)
await sdk.triggerBuzzer('LONG');

// Turn off buzzer
await sdk.triggerBuzzer('OFF');
```

### Usage Examples

```dart
// Success feedback
Future<void> onItemAdded() async {
  await sdk.triggerBuzzer('BEEP');
  showSnackBar('Item added to cart');
}

// Error feedback
Future<void> onError() async {
  await sdk.triggerBuzzer('LONG');
  showSnackBar('Error occurred');
}

// Weighing in progress
Future<void> startWeighing() async {
  await sdk.triggerBuzzer('BUZZ');
  // User is placing item on scale
}

Future<void> onStableWeight(double weight) async {
  await sdk.triggerBuzzer('OFF'); // Stop buzz
  await Future.delayed(Duration(milliseconds: 100));
  await sdk.triggerBuzzer('BEEP'); // Success beep
}
```

---

## Error Handling

### Exception Types

```dart
try {
  await sdk.connectWithLicenseKey(
    deviceId: deviceId,
    licenseKey: licenseKey,
  );
} on KGiTONException catch (e) {
  // SDK-specific errors
  print('Error code: ${e.code}');
  print('Message: ${e.message}');
  
  switch (e.code) {
    case 'BLUETOOTH_DISABLED':
      _showError('Please enable Bluetooth');
      break;
    case 'LICENSE_INVALID':
      _showError('Invalid license key');
      break;
    case 'DEVICE_NOT_FOUND':
      _showError('Scale not found');
      break;
    case 'CONNECTION_TIMEOUT':
      _showError('Connection timeout');
      break;
    default:
      _showError('Connection failed: ${e.message}');
  }
} catch (e) {
  // Other errors
  print('Unexpected error: $e');
  _showError('An unexpected error occurred');
}
```

### Common Error Codes

| Code | Description | Solution |
|------|-------------|----------|
| `BLUETOOTH_DISABLED` | Bluetooth is off | Ask user to enable Bluetooth |
| `PERMISSION_DENIED` | BLE permissions not granted | Request permissions |
| `LICENSE_INVALID` | License key is invalid/expired | Verify license with support |
| `DEVICE_NOT_FOUND` | Device not found during scan | Check device is powered on |
| `CONNECTION_TIMEOUT` | Connection attempt timed out | Retry connection |
| `DEVICE_DISCONNECTED` | Device disconnected unexpectedly | Implement auto-reconnect |

---

## Best Practices

### 1. Always Dispose Resources

```dart
@override
void dispose() {
  _weightSubscription?.cancel();
  _connectionSubscription?.cancel();
  sdk.disconnect();
  super.dispose();
}
```

### 2. Check Connection State Before Operations

```dart
Future<void> addToCart() async {
  if (!sdk.isAuthenticated) {
    showError('Please connect to scale first');
    return;
  }
  
  // Proceed with operation
  final weight = _currentWeight;
  // ...
}
```

### 3. Handle Background/Foreground Transitions

```dart
class _MyScaleWidgetState extends State<MyScaleWidget> 
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    sdk.disconnect();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App going to background
      sdk.disconnect();
    } else if (state == AppLifecycleState.resumed) {
      // App returning to foreground
      if (_shouldAutoReconnect) {
        _reconnect();
      }
    }
  }
}
```

### 4. Provide User Feedback

```dart
void _setupStreams() {
  // Show connection status
  sdk.connectionStateStream.listen((state) {
    String message;
    Color color;
    
    switch (state) {
      case ScaleConnectionState.authenticated:
        message = 'Connected';
        color = Colors.green;
        break;
      case ScaleConnectionState.connecting:
        message = 'Connecting...';
        color = Colors.orange;
        break;
      default:
        message = 'Disconnected';
        color = Colors.red;
    }
    
    _showStatusBar(message, color);
  });
}
```

### 5. Validate Weight Data

```dart
bool isValidWeight(double weight) {
  // Check minimum weight threshold
  if (weight < 0.01) {
    return false;
  }
  
  // Check maximum scale capacity
  if (weight > 30.0) {
    return false;
  }
  
  return true;
}

void _onWeight(WeightData weight) {
  if (!isValidWeight(weight.displayWeight)) {
    return; // Ignore invalid readings
  }
  
  setState(() => _currentWeight = weight.displayWeight);
}
```

---

## API Reference

### KGiTONScaleService

#### Properties

```dart
// Current connection state
ScaleConnectionState get connectionState

// Check if connected
bool get isConnected

// Check if authenticated
bool get isAuthenticated

// Currently connected device (null if not connected)
ScaleDevice? get connectedDevice
```

#### Streams

```dart
// Discovered devices during scan
Stream<List<ScaleDevice>> get devicesStream

// Real-time weight data (~10 Hz)
Stream<WeightData> get weightStream

// Connection state changes
Stream<ScaleConnectionState> get connectionStateStream
```

#### Methods

```dart
// Start scanning for devices
Future<void> scanForDevices({
  Duration timeout = const Duration(seconds: 10),
})

// Stop scanning
Future<void> stopScan()

// Connect to device with license key
Future<void> connectWithLicenseKey({
  required String deviceId,
  required String licenseKey,
})

// Disconnect from device
Future<void> disconnect()

// Control buzzer
// commands: 'BEEP', 'BUZZ', 'LONG', 'OFF'
Future<void> triggerBuzzer(String command)
```

### ScaleDevice

```dart
class ScaleDevice {
  final String id;          // Device Bluetooth ID
  final String name;        // Device name
  final int rssi;           // Signal strength (dBm)
}
```

### WeightData

```dart
class WeightData {
  final double displayWeight;  // Weight in kg (formatted)
  final int rawValue;          // Raw sensor value
  final String unit;           // Unit (always 'kg')
  final bool isStable;         // True if reading is stable
}
```

### ScaleConnectionState

```dart
enum ScaleConnectionState {
  disconnected,   // Not connected
  scanning,       // Scanning for devices
  connecting,     // Attempting to connect
  connected,      // Connected but not authenticated
  authenticated,  // Connected and authenticated (ready to use)
  error,          // Error state
}
```

---

## Complete Example

See [example/lib/main.dart](../example/lib/main.dart) for a complete working implementation with Material Design 3 UI.

---

## Next Steps

- **API Integration**: Learn how to sync data with backend - [API_INTEGRATION.md](API_INTEGRATION.md)
- **Cart System**: Implement shopping cart - [CART_GUIDE.md](CART_GUIDE.md)
- **Troubleshooting**: Common issues and solutions - [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
