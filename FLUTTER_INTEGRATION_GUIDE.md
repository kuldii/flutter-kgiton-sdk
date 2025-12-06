# KGiTON SDK - Flutter Integration Guide

Complete step-by-step guide for integrating KGiTON SDK into your Flutter application.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Project Setup](#project-setup)
4. [Basic Integration](#basic-integration)
5. [Advanced Features](#advanced-features)
6. [Complete Example](#complete-example)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Tools
- Flutter SDK ≥ 3.10.1
- Dart SDK ≥ 3.0.0
- Android Studio / Xcode
- Git

### Platform Requirements

**Android:**
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 33+
- Gradle: 8.0+

**iOS:**
- Minimum: iOS 12.0
- Xcode: 14+

### KGiTON Account
- Valid license key from PT KGiTON
- Registered owner account
- Active internet connection

**Get License:** Contact support@kgiton.com

---

## Installation

### Step 1: Add Dependency

Add KGiTON SDK to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # KGiTON SDK (choose one method)
  
  # Method 1: Git (Recommended for private repo)
  kgiton_sdk:
    git:
      url: https://github.com/kuldii/flutter-kgiton-sdk.git
      ref: main
  
  # Method 2: Path (for local development)
  # kgiton_sdk:
  #   path: ../kgiton_sdk
  
  # Required dependencies
  permission_handler: ^11.3.1
  uuid: ^4.5.1
```

### Step 2: Install Packages

```bash
flutter pub get
```

### Step 3: Verify Installation

```bash
flutter pub deps | grep kgiton_sdk
```

You should see: `kgiton_sdk 1.1.0`

---

## Project Setup

### Android Configuration

#### 1. Update `android/app/build.gradle`

```gradle
android {
    namespace = "com.yourcompany.yourapp"
    compileSdk = 34
    
    defaultConfig {
        applicationId = "com.yourcompany.yourapp"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
}
```

#### 2. Add Permissions in `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Bluetooth Permissions -->
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    
    <!-- Android 12+ (SDK 31+) -->
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"
        android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    
    <!-- Android 10-11 REQUIRED for BLE -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- BLE Feature -->
    <uses-feature 
        android:name="android.hardware.bluetooth_le" 
        android:required="true" />
    
    <application
        android:label="Your App Name"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
              
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

#### 3. Update `android/build.gradle`

```gradle
buildscript {
    ext.kotlin_version = '1.9.10'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

### iOS Configuration

#### 1. Update `ios/Podfile`

```ruby
platform :ios, '12.0'

# Uncomment if using frameworks
# use_frameworks!

# Disable Bitcode
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

#### 2. Add Permissions in `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Existing keys... -->
    
    <!-- Bluetooth Permission (Always) -->
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>We need Bluetooth to connect to your KGiTON scale device</string>
    
    <!-- Bluetooth Permission (Peripheral) -->
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>We need Bluetooth to connect to your KGiTON scale device</string>
    
    <!-- Location Permission -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Location is required to discover Bluetooth devices nearby</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Location is required to discover Bluetooth devices nearby</string>
</dict>
</plist>
```

#### 3. Run Pod Install

```bash
cd ios
pod install
cd ..
```

---

## Basic Integration

### 1. Import SDK

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
```

### 2. Request Permissions

```dart
Future<bool> requestPermissions() async {
  // Use SDK's built-in permission helper
  final granted = await PermissionHelper.requestBLEPermissions();
  
  if (!granted) {
    final errorMsg = await PermissionHelper.getPermissionErrorMessage();
    print('⚠️ Permissions not granted: $errorMsg');
    
    // Show dialog to user
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permissions Required'),
        content: Text(errorMsg),
        actions: [
          TextButton(
            onPressed: () => openAppSettings(),
            child: Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
    
    return false;
  }
  
  return true;
}
```

### 3. Initialize Services

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Initialize services
  late final KGiTONScaleService scaleService;
  late final KgitonApiService apiService;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize BLE scale service
    scaleService = KGiTONScaleService();
    
    // Initialize API service
    apiService = KgitonApiService(
      baseUrl: 'https://dev-api.kgiton.com',
    );
    
    // Load saved configuration (tokens, etc)
    apiService.loadConfiguration();
  }
  
  @override
  void dispose() {
    scaleService.disconnect();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScaleScreen(
        scaleService: scaleService,
        apiService: apiService,
      ),
    );
  }
}
```

### 4. Scan for Devices

```dart
class ScaleScreen extends StatefulWidget {
  final KGiTONScaleService scaleService;
  final KgitonApiService apiService;
  
  const ScaleScreen({
    required this.scaleService,
    required this.apiService,
  });
  
  @override
  State<ScaleScreen> createState() => _ScaleScreenState();
}

class _ScaleScreenState extends State<ScaleScreen> {
  List<ScaleDevice> _devices = [];
  bool _isScanning = false;
  
  @override
  void initState() {
    super.initState();
    _setupListeners();
  }
  
  void _setupListeners() {
    // Listen to discovered devices
    widget.scaleService.devicesStream.listen((devices) {
      setState(() {
        _devices = devices;
      });
    });
  }
  
  Future<void> _scanDevices() async {
    // Check permissions first
    final hasPermissions = await requestPermissions();
    if (!hasPermissions) return;
    
    setState(() => _isScanning = true);
    
    try {
      await widget.scaleService.scanForDevices(
        timeout: Duration(seconds: 15),
      );
    } catch (e) {
      print('Scan error: $e');
    } finally {
      setState(() => _isScanning = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('KGiTON Scale')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _isScanning ? null : _scanDevices,
            child: Text(_isScanning ? 'Scanning...' : 'Scan Devices'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text('Signal: ${device.rssi} dBm'),
                  trailing: ElevatedButton(
                    onPressed: () => _connectToDevice(device),
                    child: Text('Connect'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### 5. Connect to Device

```dart
Future<void> _connectToDevice(ScaleDevice device) async {
  try {
    await widget.scaleService.connectWithLicenseKey(
      deviceId: device.id,
      licenseKey: 'YOUR-LICENSE-KEY',
    );
    
    print('✅ Connected successfully');
    
  } on KGiTONException catch (e) {
    print('❌ Connection failed: ${e.message}');
    
    // Show error to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connection failed: ${e.message}')),
    );
  }
}
```

### 6. Listen to Weight Data

```dart
void _setupListeners() {
  // Connection state
  widget.scaleService.connectionStateStream.listen((state) {
    print('Connection state: ${state.name}');
    setState(() => _connectionState = state);
  });
  
  // Weight data (real-time ~10 Hz)
  widget.scaleService.weightStream.listen((weight) {
    setState(() {
      _currentWeight = weight.displayWeight;
      _isStable = weight.isStable;
    });
    
    print('Weight: ${weight.displayWeight} kg (stable: ${weight.isStable})');
  });
}
```

### 7. Control Buzzer

```dart
Future<void> _triggerBuzzer(String command) async {
  try {
    await widget.scaleService.triggerBuzzer(command);
    print('✅ Buzzer: $command');
  } catch (e) {
    print('❌ Buzzer error: $e');
  }
}

// Usage
ElevatedButton(
  onPressed: () => _triggerBuzzer('BEEP'),
  child: Text('Beep'),
),
ElevatedButton(
  onPressed: () => _triggerBuzzer('BUZZ'),
  child: Text('Buzz'),
),
```

---

## Advanced Features

### API Integration

#### 1. Login

```dart
Future<void> login(String email, String password) async {
  try {
    final authData = await widget.apiService.auth.login(
      email: email,
      password: password,
    );
    
    print('✅ Logged in: ${authData.user.name}');
    // Token automatically saved
    
  } on UnauthorizedException {
    print('❌ Invalid credentials');
  } catch (e) {
    print('❌ Login failed: $e');
  }
}
```

#### 2. Item Management

```dart
// Load items for license
Future<List<Item>> loadItems(String licenseKey) async {
  try {
    final data = await apiService.owner.listItems(
      licenseKey,
      page: 1,
      limit: 100,
    );
    
    return data.items;
  } catch (e) {
    print('❌ Failed to load items: $e');
    return [];
  }
}

// Create item
Future<Item> createItem({
  required String licenseKey,
  required String name,
  required String unit,
  required double price,
}) async {
  try {
    return await apiService.owner.createItem(
      licenseKey: licenseKey,
      name: name,
      unit: unit,
      price: price,
    );
  } catch (e) {
    print('❌ Failed to create item: $e');
    rethrow;
  }
}
```

### State Management Integration

#### Using Provider

```dart
// 1. Add provider to pubspec.yaml
dependencies:
  provider: ^6.0.0

// 2. Create provider
class ScaleProvider extends ChangeNotifier {
  final KGiTONScaleService _service = KGiTONScaleService();
  
  double _weight = 0.0;
  ScaleConnectionState _state = ScaleConnectionState.disconnected;
  
  double get weight => _weight;
  ScaleConnectionState get state => _state;
  bool get isConnected => _state == ScaleConnectionState.authenticated;
  
  ScaleProvider() {
    _service.weightStream.listen((data) {
      _weight = data.displayWeight;
      notifyListeners();
    });
    
    _service.connectionStateStream.listen((state) {
      _state = state;
      notifyListeners();
    });
  }
  
  Future<void> connect(String deviceId, String licenseKey) async {
    await _service.connectWithLicenseKey(
      deviceId: deviceId,
      licenseKey: licenseKey,
    );
  }
  
  Future<void> disconnect() async {
    await _service.disconnect();
  }
  
  @override
  void dispose() {
    _service.disconnect();
    super.dispose();
  }
}

// 3. Use in app
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ScaleProvider()),
  ],
  child: MyApp(),
);

// 4. Access in widgets
Widget build(BuildContext context) {
  final scaleProvider = Provider.of<ScaleProvider>(context);
  
  return Text('Weight: ${scaleProvider.weight} kg');
}
```

---

## Complete Example

See full working example: [`example/lib/main.dart`](example/lib/main.dart)

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KGiTON Scale Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ScaleDemoScreen(),
    );
  }
}

class ScaleDemoScreen extends StatefulWidget {
  @override
  State<ScaleDemoScreen> createState() => _ScaleDemoScreenState();
}

class _ScaleDemoScreenState extends State<ScaleDemoScreen> {
  late final KGiTONScaleService _scaleService;
  late final KgitonApiService _apiService;
  
  List<ScaleDevice> _devices = [];
  double _weight = 0.0;
  ScaleConnectionState _connectionState = ScaleConnectionState.disconnected;
  
  @override
  void initState() {
    super.initState();
    _scaleService = KGiTONScaleService();
    _apiService = KgitonApiService();
    _setupListeners();
  }
  
  void _setupListeners() {
    _scaleService.devicesStream.listen((devices) {
      setState(() => _devices = devices);
    });
    
    _scaleService.weightStream.listen((weight) {
      setState(() => _weight = weight.displayWeight);
    });
    
    _scaleService.connectionStateStream.listen((state) {
      setState(() => _connectionState = state);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KGiTON Scale Demo'),
        actions: [
          IconButton(
            icon: Icon(Icons.bluetooth_searching),
            onPressed: _scanDevices,
          ),
        ],
      ),
      body: Column(
        children: [
          // Weight display
          Container(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  '${_weight.toStringAsFixed(2)} kg',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 16),
                Chip(
                  label: Text(_connectionState.name),
                  backgroundColor: _connectionState == 
                    ScaleConnectionState.authenticated 
                      ? Colors.green 
                      : Colors.grey,
                ),
              ],
            ),
          ),
          
          // Device list
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text('${device.rssi} dBm'),
                  trailing: ElevatedButton(
                    onPressed: () => _connect(device),
                    child: Text('Connect'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _scanDevices() async {
    final granted = await PermissionHelper.requestBLEPermissions();
    if (!granted) return;
    
    await _scaleService.scanForDevices();
  }
  
  Future<void> _connect(ScaleDevice device) async {
    try {
      await _scaleService.connectWithLicenseKey(
        deviceId: device.id,
        licenseKey: 'YOUR-LICENSE-KEY',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }
  
  @override
  void dispose() {
    _scaleService.disconnect();
    super.dispose();
  }
}
```

---

## Best Practices

### 1. Always Dispose Resources

```dart
@override
void dispose() {
  scaleService.disconnect();
  _weightSubscription?.cancel();
  _connectionSubscription?.cancel();
  super.dispose();
}
```

### 2. Handle Errors Gracefully

```dart
try {
  await scaleService.connectWithLicenseKey(...);
} on KGiTONException catch (e) {
  switch (e.code) {
    case 'BLUETOOTH_DISABLED':
      _showError('Please enable Bluetooth');
      break;
    case 'LICENSE_INVALID':
      _showError('Invalid license key');
      break;
    default:
      _showError('Connection failed: ${e.message}');
  }
} catch (e) {
  _showError('Unexpected error: $e');
}
```

### 3. Provide User Feedback

```dart
void _showConnectionStatus(ScaleConnectionState state) {
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
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: Duration(seconds: 2),
    ),
  );
}
```

### 4. Implement Auto-Reconnect

```dart
StreamSubscription? _connectionSubscription;

void _setupAutoReconnect() {
  _connectionSubscription = scaleService.connectionStateStream.listen((state) {
    if (state == ScaleConnectionState.disconnected && _shouldReconnect) {
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) _reconnect();
      });
    }
  });
}
```

### 5. Optimize Weight Updates

```dart
DateTime _lastUpdate = DateTime.now();

scaleService.weightStream.listen((weight) {
  final now = DateTime.now();
  
  // Throttle to 10 updates per second max
  if (now.difference(_lastUpdate).inMilliseconds >= 100) {
    setState(() => _currentWeight = weight.displayWeight);
    _lastUpdate = now;
  }
});
```

---

## Troubleshooting

### Common Issues

#### 1. No Devices Found

**Causes:**
- Permissions not granted
- Bluetooth disabled
- Location Services disabled (Android 10-11)
- Scale not powered on

**Solution:**
```dart
// Check permissions
final granted = await PermissionHelper.checkBLEPermissions();
if (!granted) {
  final error = await PermissionHelper.getPermissionErrorMessage();
  print(error);
}

// Check Bluetooth
// Android: Settings → Connections → Bluetooth
// iOS: Settings → Bluetooth
```

#### 2. Connection Timeout

**Causes:**
- Weak signal (RSSI < -80 dBm)
- Scale already connected to another device
- Invalid license key

**Solution:**
```dart
// Move closer to scale
// Check RSSI value
if (device.rssi < -80) {
  print('⚠️ Weak signal, move closer');
}

// Verify license key
final licenseKey = 'YOUR-KEY';
print('Using license: $licenseKey');
```

#### 3. Weight Data Not Received

**Causes:**
- Not authenticated
- Connection lost
- Stream not listened

**Solution:**
```dart
// Check authentication
if (!scaleService.isAuthenticated) {
  print('❌ Not authenticated');
  return;
}

// Verify stream listener
scaleService.weightStream.listen((weight) {
  print('✅ Weight received: ${weight.displayWeight}');
});
```

#### 4. Build Errors

**Android:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

**iOS:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### Getting Help

**Documentation:**
- [Getting Started](docs_integrations/GETTING_STARTED.md)
- [BLE Integration](docs_integrations/BLE_INTEGRATION.md)
- [API Integration](docs_integrations/API_INTEGRATION.md)
- [Troubleshooting](docs_integrations/TROUBLESHOOTING.md)

**Support:**
- 📧 Email: support@kgiton.com
- 🐛 Issues: https://github.com/kuldii/flutter-kgiton-sdk/issues
- 📚 Docs: [docs_integrations/](docs_integrations/)

---

## Next Steps

1. **Test Basic Integration**
   - ✅ Scan devices
   - ✅ Connect to scale
   - ✅ Display weight

2. **Add API Integration**
   - ✅ User login
   - ✅ Load items

3. **Implement UI/UX**
   - ✅ Material Design 3
   - ✅ Loading states
   - ✅ Error handling

4. **Production Ready**
   - ✅ Error logging
   - ✅ Crashlytics
   - ✅ Analytics

---

**SDK Version:** 1.1.0  
**Last Updated:** December 6, 2025  
**Platform:** Android + iOS  
**Flutter:** ≥3.10.1  

© 2025 PT KGiTON. All rights reserved.
