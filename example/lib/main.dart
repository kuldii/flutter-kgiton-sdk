import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KGiTON SDK Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ScalePage(),
    );
  }
}

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
  WeightData? _weight;
  ScaleConnectionState _state = ScaleConnectionState.disconnected;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _requestPermissions();
  }

  void _setupListeners() {
    _sdk.devicesStream.listen((devices) {
      setState(() => _devices = devices);
    });

    _sdk.weightStream.listen((weight) {
      setState(() => _weight = weight);
    });

    _sdk.connectionStateStream.listen((state) {
      setState(() {
        _state = state;
        if (state.isConnected) {
          _isScanning = false;
        }
      });
    });
  }

  Future<void> _requestPermissions() async {
    await [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.location].request();
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    try {
      await _sdk.scanForDevices(timeout: const Duration(seconds: 15));
    } catch (e) {
      _showError('Scan failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _stopScan() {
    _sdk.stopScan();
    setState(() => _isScanning = false);
  }

  Future<void> _connect(ScaleDevice device) async {
    final licenseKey = _licenseKeyController.text.trim();

    if (licenseKey.isEmpty) {
      _showError('License key required');
      return;
    }

    try {
      final response = await _sdk.connectWithLicenseKey(deviceId: device.id, licenseKey: licenseKey);

      if (response.success) {
        setState(() => _connectedDevice = device);
        _showSuccess(response.message);
      } else {
        _showError(response.message);
      }
    } catch (e) {
      if (e is LicenseKeyException) {
        _showError('Invalid license key: ${e.message}');
      } else if (e is BLEConnectionException) {
        _showError('Connection failed: ${e.message}');
      } else {
        _showError('Error: $e');
      }
    }
  }

  Future<void> _disconnect() async {
    final licenseKey = _licenseKeyController.text.trim();

    try {
      if (licenseKey.isNotEmpty && _state == ScaleConnectionState.authenticated) {
        final response = await _sdk.disconnectWithLicenseKey(licenseKey);
        _showSuccess(response.message);
      } else {
        await _sdk.disconnect();
        _showSuccess('Disconnected');
      }
      setState(() => _connectedDevice = null);
    } catch (e) {
      _showError('Disconnect failed: $e');
    }
  }

  Future<void> _triggerBuzzer(String command) async {
    try {
      await _sdk.triggerBuzzer(command);
    } catch (e) {
      _showError('Buzzer failed: $e');
    }
  }

  @override
  void dispose() {
    _sdk.disconnect();
    _sdk.dispose();
    _licenseKeyController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KGiTON SDK Example'),
        centerTitle: true,
        actions: [
          if (!_state.isConnected)
            IconButton(
              icon: Icon(_isScanning ? Icons.bluetooth_searching : Icons.bluetooth),
              onPressed: _isScanning ? _stopScan : _startScan,
              tooltip: _isScanning ? 'Stop Scan' : 'Start Scan',
            ),
        ],
      ),
      body: _state.isConnected ? _buildConnectedView() : _buildDisconnectedView(),
      floatingActionButton: _state.isConnected
          ? FloatingActionButton(onPressed: _disconnect, backgroundColor: Colors.red, child: const Icon(Icons.bluetooth_disabled))
          : null,
    );
  }

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
              subtitle: Text('${_connectedDevice?.id ?? "N/A"}\nRSSI: ${_connectedDevice?.rssi ?? 0} dBm'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 16),

          // Weight Display
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('Weight', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  Text(
                    _weight?.displayWeight ?? '0.000 kg',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Buzzer Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Buzzer Control', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(onPressed: () => _triggerBuzzer('BEEP'), icon: const Icon(Icons.volume_up), label: const Text('Beep')),
                      ElevatedButton.icon(onPressed: () => _triggerBuzzer('BUZZ'), icon: const Icon(Icons.vibration), label: const Text('Buzz')),
                      ElevatedButton.icon(
                        onPressed: () => _triggerBuzzer('LONG'),
                        icon: const Icon(Icons.notifications_active),
                        label: const Text('Long'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _triggerBuzzer('OFF'),
                        icon: const Icon(Icons.volume_off),
                        label: const Text('Off'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisconnectedView() {
    return Column(
      children: [
        // License Key Input
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _licenseKeyController,
            decoration: const InputDecoration(
              labelText: 'License Key',
              border: OutlineInputBorder(),
              hintText: 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX',
              prefixIcon: Icon(Icons.vpn_key),
            ),
          ),
        ),

        // Devices List
        Expanded(
          child: _devices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isScanning ? Icons.bluetooth_searching : Icons.bluetooth, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_isScanning ? 'Scanning for devices...' : 'No devices found', style: const TextStyle(fontSize: 16)),
                      if (!_isScanning) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(onPressed: _startScan, icon: const Icon(Icons.search), label: const Text('Start Scan')),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    final signalStrength = device.rssi.abs() < 70
                        ? 'Excellent'
                        : device.rssi.abs() < 85
                        ? 'Good'
                        : 'Fair';
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.scale,
                          color: device.rssi.abs() < 70
                              ? Colors.green
                              : device.rssi.abs() < 85
                              ? Colors.orange
                              : Colors.red,
                          size: 32,
                        ),
                        title: Text(device.name),
                        subtitle: Text('${device.rssi} dBm • $signalStrength\n${device.id}'),
                        isThreeLine: true,
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _connect(device),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
