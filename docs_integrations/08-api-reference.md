# 8. API Reference

Complete API documentation for the KGiTON SDK.

---

## 📚 Main Class: KGiTONScaleService

The primary class for interacting with KGiTON scale devices.

### Constructor

```dart
KGiTONScaleService()
```

Creates a new instance of the scale service.

**Example:**
```dart
final sdk = KGiTONScaleService();
```

---

## 📡 Streams

### devicesStream

```dart
Stream<List<ScaleDevice>> get devicesStream
```

Stream of discovered BLE scale devices during scanning.

**Returns:** List of `ScaleDevice` objects

**Example:**
```dart
sdk.devicesStream.listen((devices) {
  print('Found ${devices.length} devices');
  for (var device in devices) {
    print('${device.name} - ${device.rssi} dBm');
  }
});
```

### weightStream

```dart
Stream<WeightData> get weightStream
```

Stream of real-time weight measurements from connected device.

**Returns:** `WeightData` objects with current weight

**Update Frequency:** ~10 Hz

**Example:**
```dart
sdk.weightStream.listen((weight) {
  print('Weight: ${weight.displayWeight}');
  print('Raw: ${weight.rawWeight} kg');
});
```

### connectionStateStream

```dart
Stream<ScaleConnectionState> get connectionStateStream
```

Stream of connection state changes.

**Returns:** `ScaleConnectionState` enum values

**States:**
- `disconnected`
- `connecting`
- `connected`
- `authenticated`
- `disconnecting`

**Example:**
```dart
sdk.connectionStateStream.listen((state) {
  switch (state) {
    case ScaleConnectionState.disconnected:
      print('Not connected');
      break;
    case ScaleConnectionState.connecting:
      print('Connecting...');
      break;
    case ScaleConnectionState.connected:
      print('Connected');
      break;
    case ScaleConnectionState.authenticated:
      print('Authenticated and ready');
      break;
    case ScaleConnectionState.disconnecting:
      print('Disconnecting...');
      break;
  }
});
```

---

## 🔍 Methods

### scanForDevices()

```dart
Future<void> scanForDevices({
  Duration timeout = const Duration(seconds: 10),
})
```

Start scanning for nearby KGiTON scale devices.

**Parameters:**
- `timeout` (Duration, optional): How long to scan. Default: 10 seconds

**Returns:** `Future<void>`

**Throws:**
- `BLEOperationException` if Bluetooth is not available
- `PermissionException` if permissions not granted

**Example:**
```dart
try {
  await sdk.scanForDevices(timeout: Duration(seconds: 15));
} catch (e) {
  print('Scan failed: $e');
}
```

### stopScan()

```dart
void stopScan()
```

Stop the current device scan.

**Example:**
```dart
sdk.stopScan();
```

### connectWithLicenseKey()

```dart
Future<ControlResponse> connectWithLicenseKey({
  required String deviceId,
  required String licenseKey,
})
```

Connect to a scale device using license key authentication.

**Parameters:**
- `deviceId` (String, required): Device ID from ScaleDevice
- `licenseKey` (String, required): Your KGiTON license key

**Returns:** `Future<ControlResponse>`

**Throws:**
- `LicenseKeyException` if license is invalid
- `BLEConnectionException` if connection fails
- `DeviceNotFoundException` if device not found

**Example:**
```dart
try {
  final response = await sdk.connectWithLicenseKey(
    deviceId: device.id,
    licenseKey: 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX',
  );
  
  if (response.success) {
    print('Connected: ${response.message}');
  }
} on LicenseKeyException catch (e) {
  print('Invalid license: ${e.message}');
} on BLEConnectionException catch (e) {
  print('Connection failed: ${e.message}');
}
```

### disconnect()

```dart
Future<void> disconnect()
```

Disconnect from the currently connected device (without license key).

**Returns:** `Future<void>`

**Example:**
```dart
await sdk.disconnect();
```

### disconnectWithLicenseKey()

```dart
Future<ControlResponse> disconnectWithLicenseKey(String licenseKey)
```

Disconnect from device with license key (for authenticated connections).

**Parameters:**
- `licenseKey` (String, required): Your license key

**Returns:** `Future<ControlResponse>`

**Example:**
```dart
final response = await sdk.disconnectWithLicenseKey(licenseKey);
print(response.message);
```

### triggerBuzzer()

```dart
Future<void> triggerBuzzer(String command)
```

Control the device buzzer.

**Parameters:**
- `command` (String, required): Buzzer command

**Valid Commands:**
- `'BEEP'` - Short beep
- `'BUZZ'` - Vibration-like sound
- `'LONG'` - Extended beep
- `'OFF'` - Turn off buzzer

**Returns:** `Future<void>`

**Throws:**
- `DeviceNotConnectedException` if not connected
- `BLEOperationException` if operation fails

**Example:**
```dart
try {
  await sdk.triggerBuzzer('BEEP');
} on DeviceNotConnectedException {
  print('Not connected to device');
}
```

### dispose()

```dart
void dispose()
```

Clean up resources and close streams. Call when done using the SDK.

**Example:**
```dart
@override
void dispose() {
  sdk.dispose();
  super.dispose();
}
```

---

## 📊 Properties

### connectionState

```dart
ScaleConnectionState get connectionState
```

Current connection state.

**Returns:** `ScaleConnectionState`

**Example:**
```dart
if (sdk.connectionState == ScaleConnectionState.authenticated) {
  print('Ready to use');
}
```

### isConnected

```dart
bool get isConnected
```

Whether currently connected to a device.

**Returns:** `bool`

**Example:**
```dart
if (sdk.isConnected) {
  await sdk.triggerBuzzer('BEEP');
}
```

### isAuthenticated

```dart
bool get isAuthenticated
```

Whether connection is authenticated with license key.

**Returns:** `bool`

**Example:**
```dart
if (sdk.isAuthenticated) {
  print('Authenticated connection');
}
```

### connectedDevice

```dart
ScaleDevice? get connectedDevice
```

Currently connected device, or null if not connected.

**Returns:** `ScaleDevice?`

**Example:**
```dart
final device = sdk.connectedDevice;
if (device != null) {
  print('Connected to: ${device.name}');
}
```

### availableDevices

```dart
List<ScaleDevice> get availableDevices
```

List of devices discovered during last scan.

**Returns:** `List<ScaleDevice>`

**Example:**
```dart
final devices = sdk.availableDevices;
print('Found ${devices.length} devices');
```

---

## 🎯 Models

### ScaleDevice

Represents a discovered BLE scale device.

**Properties:**
```dart
class ScaleDevice {
  final String id;           // Device unique identifier
  final String name;         // Device name (e.g., "KGiTON Scale")
  final int rssi;           // Signal strength in dBm
  
  ScaleDevice({
    required this.id,
    required this.name,
    required this.rssi,
  });
}
```

**Example:**
```dart
final device = ScaleDevice(
  id: '00:11:22:33:44:55',
  name: 'KGiTON Scale',
  rssi: -65,
);

print('${device.name} (${device.rssi} dBm)');
```

### WeightData

Represents weight measurement data.

**Properties:**
```dart
class WeightData {
  final double rawWeight;      // Raw weight in kg
  final String displayWeight;  // Formatted weight string
  final DateTime timestamp;    // When measurement was taken
  final String unit;          // Weight unit (typically "kg")
  
  WeightData({
    required this.rawWeight,
    required this.displayWeight,
    required this.timestamp,
    this.unit = 'kg',
  });
}
```

**Example:**
```dart
sdk.weightStream.listen((weight) {
  print('Weight: ${weight.displayWeight}');
  print('Raw: ${weight.rawWeight} kg');
  print('Time: ${weight.timestamp}');
  print('Unit: ${weight.unit}');
});
```

### ScaleConnectionState

Enum representing connection states.

**Values:**
```dart
enum ScaleConnectionState {
  disconnected,   // No connection
  connecting,     // Attempting to connect
  connected,      // Connected but not authenticated
  authenticated,  // Fully connected and authorized
  disconnecting,  // Disconnecting in progress
}
```

**Extension Methods:**
```dart
extension ScaleConnectionStateExtension on ScaleConnectionState {
  bool get isConnected => this == ScaleConnectionState.connected || 
                         this == ScaleConnectionState.authenticated;
  
  bool get isDisconnected => this == ScaleConnectionState.disconnected;
  
  bool get isAuthent icated => this == ScaleConnectionState.authenticated;
}
```

### ControlResponse

Response from control operations (connect/disconnect).

**Properties:**
```dart
class ControlResponse {
  final bool success;      // Whether operation succeeded
  final String message;    // Response message
  
  ControlResponse({
    required this.success,
    required this.message,
  });
}
```

**Example:**
```dart
final response = await sdk.connectWithLicenseKey(...);

if (response.success) {
  print('Success: ${response.message}');
} else {
  print('Failed: ${response.message}');
}
```

---

## ⚠️ Exceptions

See [Error Handling Guide](09-error-handling.md) for complete exception documentation.

### Common Exceptions

- `LicenseKeyException` - Invalid or expired license
- `BLEConnectionException` - Bluetooth connection error
- `BLEOperationException` - BLE operation failed
- `DeviceNotFoundException` - Device not found
- `DeviceNotConnectedException` - Operation requires connection
- `DeviceNotAuthenticatedException` - Operation requires authentication

---

## 📖 Usage Examples

### Complete Integration Example

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

class ScaleService {
  final _sdk = KGiTONScaleService();
  
  void init() {
    // Listen to streams
    _sdk.devicesStream.listen(_onDevicesUpdate);
    _sdk.weightStream.listen(_onWeightUpdate);
    _sdk.connectionStateStream.listen(_onConnectionStateChange);
  }
  
  Future<void> scanAndConnect(String licenseKey) async {
    // Scan for devices
    await _sdk.scanForDevices(timeout: Duration(seconds: 15));
    
    // Get first device
    final devices = _sdk.availableDevices;
    if (devices.isEmpty) {
      throw Exception('No devices found');
    }
    
    // Connect to first device
    final response = await _sdk.connectWithLicenseKey(
      deviceId: devices.first.id,
      licenseKey: licenseKey,
    );
    
    if (!response.success) {
      throw Exception('Connection failed: ${response.message}');
    }
  }
  
  void _onDevicesUpdate(List<ScaleDevice> devices) {
    print('Devices: ${devices.length}');
  }
  
  void _onWeightUpdate(WeightData weight) {
    print('Weight: ${weight.displayWeight}');
  }
  
  void _onConnectionStateChange(ScaleConnectionState state) {
    print('State: ${state.name}');
  }
  
  void dispose() {
    _sdk.disconnect();
    _sdk.dispose();
  }
}
```

---

## 📚 Related Documentation

- [Basic Integration](06-basic-integration.md) - Integration walkthrough
- [Advanced Features](07-advanced-features.md) - Advanced patterns
- [Error Handling](09-error-handling.md) - Exception handling
- [Best Practices](10-best-practices.md) - Recommended patterns

---

**API Version:** 1.1.0  
**Last Updated:** December 3, 2025

© 2025 PT KGiTON. All rights reserved.
