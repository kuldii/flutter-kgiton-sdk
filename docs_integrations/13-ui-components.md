# 13. UI Components

Ready-to-use UI widgets and components for KGiTON scale integration.

---

## 🎨 Weight Display Widget

### Basic Weight Card

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

class WeightCard extends StatelessWidget {
  final WeightData? weight;
  final VoidCallback? onTap;

  const WeightCard({
    super.key,
    this.weight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Weight',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
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

---

## 📱 Device List Widget

### Device Card with Signal Indicator

```dart
class DeviceCard extends StatelessWidget {
  final ScaleDevice device;
  final VoidCallback onTap;
  final bool isConnected;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    this.isConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    final signalStrength = _getSignalStrength(device.rssi);
    
    return Card(
      elevation: isConnected ? 4 : 2,
      color: isConnected ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: Icon(
          Icons.scale,
          color: signalStrength.color,
          size: 32,
        ),
        title: Text(
          device.name,
          style: TextStyle(
            fontWeight: isConnected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${device.rssi} dBm • ${signalStrength.label}'),
            Text(
              device.id,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        trailing: isConnected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: isConnected ? null : onTap,
        isThreeLine: true,
      ),
    );
  }

  SignalStrength _getSignalStrength(int rssi) {
    if (rssi.abs() < 70) {
      return SignalStrength('Excellent', Colors.green);
    } else if (rssi.abs() < 85) {
      return SignalStrength('Good', Colors.orange);
    } else {
      return SignalStrength('Fair', Colors.red);
    }
  }
}

class SignalStrength {
  final String label;
  final Color color;

  SignalStrength(this.label, this.color);
}
```

---

## 🔘 Buzzer Control Panel

```dart
class BuzzerControlPanel extends StatelessWidget {
  final Future<void> Function(String) onBuzzerCommand;

  const BuzzerControlPanel({
    super.key,
    required this.onBuzzerCommand,
  });

  @override
  Widget build(BuildContext context) {
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
                _BuzzerButton(
                  label: 'BEEP',
                  icon: Icons.volume_up,
                  onPressed: () => onBuzzerCommand('BEEP'),
                ),
                _BuzzerButton(
                  label: 'BUZZ',
                  icon: Icons.vibration,
                  onPressed: () => onBuzzerCommand('BUZZ'),
                ),
                _BuzzerButton(
                  label: 'LONG',
                  icon: Icons.notifications_active,
                  onPressed: () => onBuzzerCommand('LONG'),
                ),
                _BuzzerButton(
                  label: 'OFF',
                  icon: Icons.volume_off,
                  color: Colors.grey,
                  onPressed: () => onBuzzerCommand('OFF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BuzzerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _BuzzerButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: color != null
          ? ElevatedButton.styleFrom(backgroundColor: color)
          : null,
    );
  }
}
```

---

## 🔄 Connection Status Indicator

```dart
class ConnectionStatusIndicator extends StatelessWidget {
  final ScaleConnectionState state;

  const ConnectionStatusIndicator({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final status = _getStatus(state);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 16, color: status.color),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  StatusInfo _getStatus(ScaleConnectionState state) {
    switch (state) {
      case ScaleConnectionState.disconnected:
        return StatusInfo('Disconnected', Icons.bluetooth_disabled, Colors.grey);
      case ScaleConnectionState.connecting:
        return StatusInfo('Connecting...', Icons.bluetooth_searching, Colors.orange);
      case ScaleConnectionState.connected:
        return StatusInfo('Connected', Icons.bluetooth_connected, Colors.blue);
      case ScaleConnectionState.authenticated:
        return StatusInfo('Ready', Icons.check_circle, Colors.green);
      case ScaleConnectionState.disconnecting:
        return StatusInfo('Disconnecting...', Icons.bluetooth_disabled, Colors.grey);
    }
  }
}

class StatusInfo {
  final String label;
  final IconData icon;
  final Color color;

  StatusInfo(this.label, this.icon, this.color);
}
```

---

## 🔍 Scanning Indicator

```dart
class ScanningIndicator extends StatelessWidget {
  final bool isScanning;

  const ScanningIndicator({super.key, required this.isScanning});

  @override
  Widget build(BuildContext context) {
    if (!isScanning) return const SizedBox.shrink();

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Scanning for devices...'),
        ],
      ),
    );
  }
}
```

---

## 📊 Weight History List

```dart
class WeightHistoryList extends StatelessWidget {
  final List<WeightRecord> records;

  const WeightHistoryList({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text('No weight records yet'),
      );
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return ListTile(
          leading: const Icon(Icons.scale, color: Colors.blue),
          title: Text(
            '${record.weight.toStringAsFixed(2)} kg',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(_formatDateTime(record.timestamp)),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteRecord(context, record),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} '
           '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}';
  }

  void _deleteRecord(BuildContext context, WeightRecord record) {
    // Implementation
  }
}

class WeightRecord {
  final double weight;
  final DateTime timestamp;

  WeightRecord({required this.weight, required this.timestamp});
}
```

---

## ✅ Usage Example

```dart
class ScaleUI extends StatelessWidget {
  final KGiTONScaleService sdk;

  const ScaleUI({super.key, required this.sdk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KGiTON Scale'),
        actions: [
          StreamBuilder<ScaleConnectionState>(
            stream: sdk.connectionStateStream,
            builder: (context, snapshot) {
              return ConnectionStatusIndicator(
                state: snapshot.data ?? ScaleConnectionState.disconnected,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<WeightData>(
            stream: sdk.weightStream,
            builder: (context, snapshot) {
              return WeightCard(weight: snapshot.data);
            },
          ),
          BuzzerControlPanel(
            onBuzzerCommand: (cmd) => sdk.triggerBuzzer(cmd),
          ),
        ],
      ),
    );
  }
}
```

---

## 📚 Related Documentation

- [Basic Integration](06-basic-integration.md)
- [Complete Examples](12-complete-examples.md)
- [Best Practices](10-best-practices.md)

---

© 2025 PT KGiTON. All rights reserved.
