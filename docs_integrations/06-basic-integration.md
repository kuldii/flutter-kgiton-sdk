# 6. Basic Integration

Learn how to integrate the KGiTON SDK into your Flutter app with step-by-step examples.

---

## 🎯 What You'll Build

In this guide, you'll create a basic scale app that can:
- ✅ Scan for KGiTON scale devices
- ✅ Connect using license key
- ✅ Display real-time weight data
- ✅ Control device buzzer
- ✅ Handle disconnection

**Estimated Time**: 30 minutes

---

## 📁 Project Structure

Organize your project like this:

```
lib/
├── main.dart                    # App entry point
├── pages/
│   └── scale_page.dart         # Main scale interface
├── utils/
│   └── permissions_helper.dart  # Permission handling
└── widgets/
    ├── device_list_item.dart   # Device card widget
    └── weight_display.dart     # Weight display widget
```

---

## 🚀 Step 1: Initialize the SDK

### Import the SDK

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';
```

### Create Service Instance

```dart
class ScalePage extends StatefulWidget {
  const ScalePage({super.key});

  @override
  State<ScalePage> createState() => _ScalePageState();
}

class _ScalePageState extends State<ScalePage> {
  // Initialize the SDK service
  final _sdk = KGiTONScaleService();

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    // We'll add listeners in next steps
  }

  @override
  void dispose() {
    // Clean up when widget is disposed
    _sdk.disconnect();
    _sdk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KGiTON Scale')),
      body: const Center(child: Text('Scale Integration')),
    );
  }
}
```

---

## 📡 Step 2: Scan for Devices

### Add State Variables

```dart
class _ScalePageState extends State<ScalePage> {
  final _sdk = KGiTONScaleService();
  
  // State variables
  List<ScaleDevice> _devices = [];
  bool _isScanning = false;
  String? _errorMessage;

  // ... rest of code
}
```

### Set Up Device Stream Listener

```dart
void _setupListeners() {
  // Listen to discovered devices
  _sdk.devicesStream.listen(
    (devices) {
      setState(() {
        _devices = devices;
      });
    },
    onError: (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    },
  );
}
```

### Implement Scan Function

```dart
Future<void> _startScan() async {
  setState(() {
    _isScanning = true;
    _errorMessage = null;
  });

  try {
    // Scan for 15 seconds
    await _sdk.scanForDevices(
      timeout: const Duration(seconds: 15),
    );
  } catch (e) {
    setState(() {
      _errorMessage = 'Scan failed: $e';
    });
  } finally {
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }
}

void _stopScan() {
  _sdk.stopScan();
  setState(() {
    _isScanning = false;
  });
}
```

### Display Devices

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('KGiTON Scale'),
      actions: [
        IconButton(
          icon: Icon(_isScanning ? Icons.bluetooth_searching : Icons.bluetooth),
          onPressed: _isScanning ? _stopScan : _startScan,
        ),
      ],
    ),
    body: _buildBody(),
  );
}

Widget _buildBody() {
  if (_errorMessage != null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _startScan,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  if (_devices.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isScanning ? Icons.bluetooth_searching : Icons.bluetooth_disabled,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _isScanning ? 'Scanning for devices...' : 'No devices found',
            style: const TextStyle(fontSize: 16),
          ),
          if (!_isScanning) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _startScan,
              icon: const Icon(Icons.search),
              label: const Text('Start Scan'),
            ),
          ],
        ],
      ),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: _devices.length,
    itemBuilder: (context, index) {
      final device = _devices[index];
      return _buildDeviceCard(device);
    },
  );
}

Widget _buildDeviceCard(ScaleDevice device) {
  final signalStrength = device.rssi.abs() < 70
      ? 'Excellent'
      : device.rssi.abs() < 85
          ? 'Good'
          : 'Fair';

  final signalColor = device.rssi.abs() < 70
      ? Colors.green
      : device.rssi.abs() < 85
          ? Colors.orange
          : Colors.red;

  return Card(
    child: ListTile(
      leading: Icon(
        Icons.scale,
        color: signalColor,
        size: 32,
      ),
      title: Text(
        device.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${device.rssi} dBm • $signalStrength\n${device.id}',
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => _showConnectDialog(device),
    ),
  );
}
```

---

## 🔐 Step 3: Connect to Device

### Add Connection State

```dart
class _ScalePageState extends State<ScalePage> {
  // ... previous variables
  
  ScaleDevice? _connectedDevice;
  ScaleConnectionState _connectionState = ScaleConnectionState.disconnected;
  final _licenseKeyController = TextEditingController();

  @override
  void dispose() {
    _licenseKeyController.dispose();
    _sdk.disconnect();
    _sdk.dispose();
    super.dispose();
  }
}
```

### Listen to Connection State

```dart
void _setupListeners() {
  // Device stream
  _sdk.devicesStream.listen((devices) {
    setState(() => _devices = devices);
  });

  // Connection state stream
  _sdk.connectionStateStream.listen((state) {
    setState(() {
      _connectionState = state;
    });
  });
}
```

### Show Connect Dialog

```dart
void _showConnectDialog(ScaleDevice device) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Connect to ${device.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _licenseKeyController,
            decoration: const InputDecoration(
              labelText: 'License Key',
              hintText: 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.vpn_key),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter your KGiTON license key to connect',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _connectToDevice(device);
          },
          child: const Text('Connect'),
        ),
      ],
    ),
  );
}
```

### Implement Connection

```dart
Future<void> _connectToDevice(ScaleDevice device) async {
  final licenseKey = _licenseKeyController.text.trim();

  if (licenseKey.isEmpty) {
    _showSnackBar('Please enter license key', isError: true);
    return;
  }

  // Show loading
  _showSnackBar('Connecting to ${device.name}...');

  try {
    final response = await _sdk.connectWithLicenseKey(
      deviceId: device.id,
      licenseKey: licenseKey,
    );

    if (response.success) {
      setState(() {
        _connectedDevice = device;
      });
      _showSnackBar('✅ ${response.message}');
    } else {
      _showSnackBar('❌ ${response.message}', isError: true);
    }
  } catch (e) {
    String errorMessage = 'Connection failed';
    
    if (e is LicenseKeyException) {
      errorMessage = 'Invalid license: ${e.message}';
    } else if (e is BLEConnectionException) {
      errorMessage = 'Connection error: ${e.message}';
    } else if (e is DeviceNotAuthenticatedException) {
      errorMessage = 'Authentication failed: ${e.message}';
    }
    
    _showSnackBar(errorMessage, isError: true);
  }
}

void _showSnackBar(String message, {bool isError = false}) {
  if (!mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
```

---

## ⚖️ Step 4: Display Weight Data

### Add Weight State

```dart
class _ScalePageState extends State<ScalePage> {
  // ... previous variables
  
  WeightData? _currentWeight;
}
```

### Listen to Weight Stream

```dart
void _setupListeners() {
  // ... previous listeners

  // Weight stream
  _sdk.weightStream.listen((weight) {
    setState(() {
      _currentWeight = weight;
    });
  });
}
```

### Create Weight Display Widget

Create `lib/widgets/weight_display.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

class WeightDisplay extends StatelessWidget {
  final WeightData? weight;

  const WeightDisplay({super.key, this.weight});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Weight',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              weight?.displayWeight ?? '0.000 kg',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            if (weight != null) ...[
              const SizedBox(height: 8),
              Text(
                'Raw: ${weight!.rawWeight.toStringAsFixed(3)} kg',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Updated: ${_formatTime(weight!.timestamp)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}';
  }
}
```

### Use Weight Display

```dart
Widget _buildConnectedView() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Device Info
        Card(
          child: ListTile(
            leading: const Icon(Icons.scale, color: Colors.green, size: 32),
            title: Text(_connectedDevice?.name ?? 'Unknown'),
            subtitle: Text(
              '${_connectedDevice?.id ?? "N/A"}\n'
              'RSSI: ${_connectedDevice?.rssi ?? 0} dBm',
            ),
            isThreeLine: true,
          ),
        ),
        const SizedBox(height: 16),

        // Weight Display
        WeightDisplay(weight: _currentWeight),
        
        const SizedBox(height: 16),

        // We'll add buzzer controls next
      ],
    ),
  );
}
```

---

## 🔊 Step 5: Control Buzzer

### Add Buzzer Control Widget

```dart
Widget _buildBuzzerControls() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Buzzer Control',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBuzzerButton('BEEP', Icons.volume_up),
              _buildBuzzerButton('BUZZ', Icons.vibration),
              _buildBuzzerButton('LONG', Icons.notifications_active),
              _buildBuzzerButton('OFF', Icons.volume_off, isOff: true),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildBuzzerButton(String command, IconData icon, {bool isOff = false}) {
  return ElevatedButton.icon(
    onPressed: () => _triggerBuzzer(command),
    icon: Icon(icon),
    label: Text(command),
    style: isOff
        ? ElevatedButton.styleFrom(backgroundColor: Colors.grey)
        : null,
  );
}
```

### Implement Buzzer Trigger

```dart
Future<void> _triggerBuzzer(String command) async {
  try {
    await _sdk.triggerBuzzer(command);
    _showSnackBar('Buzzer: $command');
  } catch (e) {
    if (e is DeviceNotConnectedException) {
      _showSnackBar('Device not connected', isError: true);
    } else if (e is BLEOperationException) {
      _showSnackBar('Buzzer failed: ${e.message}', isError: true);
    } else {
      _showSnackBar('Error: $e', isError: true);
    }
  }
}
```

### Add to Connected View

```dart
Widget _buildConnectedView() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Device Info Card
        _buildDeviceInfoCard(),
        const SizedBox(height: 16),

        // Weight Display
        WeightDisplay(weight: _currentWeight),
        const SizedBox(height: 16),

        // Buzzer Controls
        _buildBuzzerControls(),
      ],
    ),
  );
}
```

---

## 🔌 Step 6: Handle Disconnection

### Add Disconnect Button

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('KGiTON Scale'),
      actions: [
        if (!_connectionState.isConnected)
          IconButton(
            icon: Icon(_isScanning 
              ? Icons.bluetooth_searching 
              : Icons.bluetooth),
            onPressed: _isScanning ? _stopScan : _startScan,
          ),
      ],
    ),
    body: _connectionState.isConnected
        ? _buildConnectedView()
        : _buildDisconnectedView(),
    floatingActionButton: _connectionState.isConnected
        ? FloatingActionButton(
            onPressed: _disconnect,
            backgroundColor: Colors.red,
            child: const Icon(Icons.bluetooth_disabled),
          )
        : null,
  );
}
```

### Implement Disconnect

```dart
Future<void> _disconnect() async {
  final licenseKey = _licenseKeyController.text.trim();

  try {
    if (licenseKey.isNotEmpty && 
        _connectionState == ScaleConnectionState.authenticated) {
      // Disconnect with license key for authenticated connection
      final response = await _sdk.disconnectWithLicenseKey(licenseKey);
      _showSnackBar(response.message);
    } else {
      // Regular disconnect
      await _sdk.disconnect();
      _showSnackBar('Disconnected');
    }

    setState(() {
      _connectedDevice = null;
      _currentWeight = null;
    });
  } catch (e) {
    _showSnackBar('Disconnect failed: $e', isError: true);
  }
}
```

---

## 📱 Complete Basic Integration

### Full Code Example

Here's the complete `scale_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import '../widgets/weight_display.dart';

class ScalePage extends StatefulWidget {
  const ScalePage({super.key});

  @override
  State<ScalePage> createState() => _ScalePageState();
}

class _ScalePageState extends State<ScalePage> {
  final _sdk = KGiTONScaleService();
  final _licenseKeyController = TextEditingController();

  List<ScaleDevice> _devices = [];
  ScaleDevice? _connectedDevice;
  WeightData? _currentWeight;
  ScaleConnectionState _connectionState = ScaleConnectionState.disconnected;
  bool _isScanning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _sdk.devicesStream.listen((devices) {
      setState(() => _devices = devices);
    });

    _sdk.weightStream.listen((weight) {
      setState(() => _currentWeight = weight);
    });

    _sdk.connectionStateStream.listen((state) {
      setState(() => _connectionState = state);
    });
  }

  @override
  void dispose() {
    _sdk.disconnect();
    _sdk.dispose();
    _licenseKeyController.dispose();
    super.dispose();
  }

  // Add all the methods we created above:
  // _startScan(), _stopScan(), _connectToDevice(), 
  // _disconnect(), _triggerBuzzer(), etc.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KGiTON Scale'),
        centerTitle: true,
        actions: [
          if (!_connectionState.isConnected)
            IconButton(
              icon: Icon(_isScanning 
                ? Icons.bluetooth_searching 
                : Icons.bluetooth),
              onPressed: _isScanning ? _stopScan : _startScan,
            ),
        ],
      ),
      body: _connectionState.isConnected
          ? _buildConnectedView()
          : _buildDisconnectedView(),
      floatingActionButton: _connectionState.isConnected
          ? FloatingActionButton(
              onPressed: _disconnect,
              backgroundColor: Colors.red,
              child: const Icon(Icons.bluetooth_disabled),
            )
          : null,
    );
  }
}
```

---

## ✅ Basic Integration Complete!

You now have a fully functional KGiTON scale app!

### What You've Built

- ✅ Device scanning with signal strength indicator
- ✅ License-based authentication
- ✅ Real-time weight display
- ✅ Buzzer controls
- ✅ Proper error handling
- ✅ Connection state management

### Next Steps

👉 **[7. Advanced Features](07-advanced-features.md)** - Multi-device, auto-reconnect, etc.

Or explore:
- [Complete Examples](12-complete-examples.md) - Full working apps
- [UI Components](13-ui-components.md) - Pre-built widgets
- [Best Practices](10-best-practices.md) - Optimization tips

---

**Ready for advanced features? → [7. Advanced Features](07-advanced-features.md)**

© 2025 PT KGiTON. All rights reserved.
