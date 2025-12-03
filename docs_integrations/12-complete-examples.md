# 12. Complete Examples

Real-world integration examples and complete working applications.

---

## 📱 Example 1: Simple Weight Display App

Complete app for displaying weight from a scale.

### Project Structure

```
lib/
├── main.dart
├── pages/
│   └── weight_page.dart
└── widgets/
    └── weight_card.dart
```

### main.dart

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'pages/weight_page.dart';

void main() {
  runApp(const WeightApp());
}

class WeightApp extends StatelessWidget {
  const WeightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KGiTON Scale',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WeightPage(),
    );
  }
}
```

### pages/weight_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  final _sdk = KGiTONScaleService();
  final _licenseKey = 'YOUR-LICENSE-KEY-HERE';
  
  WeightData? _weight;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initPermissions();
    _setupListeners();
  }

  Future<void> _initPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void _setupListeners() {
    _sdk.weightStream.listen((weight) {
      setState(() => _weight = weight);
    });
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    await _sdk.scanForDevices(timeout: const Duration(seconds: 10));
    setState(() => _isScanning = false);
  }

  Future<void> _connect(ScaleDevice device) async {
    try {
      await _sdk.connectWithLicenseKey(
        deviceId: device.id,
        licenseKey: _licenseKey,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connected!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _sdk.disconnect();
    _sdk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weight Scale')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _weight?.displayWeight ?? '0.000 kg',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startScan,
        child: Icon(_isScanning ? Icons.bluetooth_searching : Icons.bluetooth),
      ),
    );
  }
}
```

---

## 📱 Example 2: Multi-Device Manager

App for managing multiple scales.

```dart
class MultiScaleManager extends StatefulWidget {
  @override
  State<MultiScaleManager> createState() => _MultiScaleManagerState();
}

class _MultiScaleManagerState extends State<MultiScaleManager> {
  final List<KGiTONScaleService> _scales = [];
  final List<ScaleDevice> _connectedDevices = [];

  Future<void> _addScale(ScaleDevice device, String licenseKey) async {
    final sdk = KGiTONScaleService();
    
    try {
      await sdk.connectWithLicenseKey(
        deviceId: device.id,
        licenseKey: licenseKey,
      );
      
      setState(() {
        _scales.add(sdk);
        _connectedDevices.add(device);
      });
    } catch (e) {
      sdk.dispose();
      throw e;
    }
  }

  Future<void> _removeScale(int index) async {
    await _scales[index].disconnect();
    _scales[index].dispose();
    
    setState(() {
      _scales.removeAt(index);
      _connectedDevices.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var sdk in _scales) {
      sdk.disconnect();
      sdk.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Multi-Scale Manager')),
      body: ListView.builder(
        itemCount: _connectedDevices.length,
        itemBuilder: (context, index) {
          final device = _connectedDevices[index];
          final sdk = _scales[index];
          
          return StreamBuilder<WeightData>(
            stream: sdk.weightStream,
            builder: (context, snapshot) {
              final weight = snapshot.data;
              
              return ListTile(
                title: Text(device.name),
                subtitle: Text(weight?.displayWeight ?? 'No data'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeScale(index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## 📱 Example 3: Auto-Reconnect Pattern

```dart
class AutoReconnectExample extends StatefulWidget {
  @override
  State<AutoReconnectExample> createState() => _AutoReconnectExampleState();
}

class _AutoReconnectExampleState extends State<AutoReconnectExample> {
  final _sdk = KGiTONScaleService();
  ScaleDevice? _lastDevice;
  String? _lastLicenseKey;
  Timer? _reconnectTimer;

  @override
  void initState() {
    super.initState();
    _monitorConnection();
  }

  void _monitorConnection() {
    _sdk.connectionStateStream.listen((state) {
      if (state == ScaleConnectionState.disconnected && _lastDevice != null) {
        _scheduleReconnect();
      }
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () async {
      if (_lastDevice != null && _lastLicenseKey != null) {
        try {
          await _sdk.connectWithLicenseKey(
            deviceId: _lastDevice!.id,
            licenseKey: _lastLicenseKey!,
          );
          print('Reconnected successfully');
        } catch (e) {
          print('Reconnect failed: $e');
          _scheduleReconnect(); // Try again
        }
      }
    });
  }

  Future<void> connect(ScaleDevice device, String licenseKey) async {
    _lastDevice = device;
    _lastLicenseKey = licenseKey;
    await _sdk.connectWithLicenseKey(
      deviceId: device.id,
      licenseKey: licenseKey,
    );
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _sdk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Auto-Reconnect Example')),
      body: Center(child: Text('Auto-reconnect enabled')),
    );
  }
}
```

---

## 📱 Example 4: Weight History Tracker

```dart
class WeightHistoryTracker extends StatefulWidget {
  @override
  State<WeightHistoryTracker> createState() => _WeightHistoryTrackerState();
}

class _WeightHistoryTrackerState extends State<WeightHistoryTracker> {
  final _sdk = KGiTONScaleService();
  final List<WeightRecord> _history = [];

  @override
  void initState() {
    super.initState();
    _setupWeightTracking();
  }

  void _setupWeightTracking() {
    // Only save stable weights
    final detector = StableWeightDetector();
    
    _sdk.weightStream.listen((weight) {
      if (detector.isStable(weight.rawWeight)) {
        final stable = detector.getStableWeight();
        if (stable != null) {
          _saveWeight(stable);
        }
      }
    });
  }

  void _saveWeight(double weight) {
    setState(() {
      _history.add(WeightRecord(
        weight: weight,
        timestamp: DateTime.now(),
      ));
    });
    
    // Optionally save to database
    _saveToDatabase(weight);
  }

  Future<void> _saveToDatabase(double weight) async {
    // Implementation for database storage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weight History')),
      body: ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final record = _history[index];
          return ListTile(
            title: Text('${record.weight.toStringAsFixed(2)} kg'),
            subtitle: Text(_formatTime(record.timestamp)),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute}:${time.second}';
  }
}

class WeightRecord {
  final double weight;
  final DateTime timestamp;

  WeightRecord({required this.weight, required this.timestamp});
}

class StableWeightDetector {
  final List<double> _readings = [];
  final double _threshold = 0.01;
  final int _requiredReadings = 5;

  bool isStable(double weight) {
    _readings.add(weight);
    if (_readings.length > _requiredReadings) {
      _readings.removeAt(0);
    }
    
    if (_readings.length < _requiredReadings) return false;
    
    final min = _readings.reduce((a, b) => a < b ? a : b);
    final max = _readings.reduce((a, b) => a > b ? a : b);
    
    return (max - min) <= _threshold;
  }

  double? getStableWeight() {
    if (_readings.length < _requiredReadings) return null;
    return _readings.reduce((a, b) => a + b) / _readings.length;
  }
}
```

---

## 📚 Download Examples

Complete example projects available at:
- [GitHub Repository](https://github.com/kuldii/flutter-kgiton-sdk/tree/main/example)

---

## 📖 Related Documentation

- [Basic Integration](06-basic-integration.md)
- [Advanced Features](07-advanced-features.md)
- [UI Components](13-ui-components.md)

---

© 2025 PT KGiTON. All rights reserved.
