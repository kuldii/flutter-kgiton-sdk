# Android 10 BLE Scanning - Troubleshooting & Solutions

## 🚨 Masalah Umum di Android 10

Android 10 (API level 29) memperkenalkan pembatasan privasi yang lebih ketat untuk BLE scanning. Banyak developer mengalami masalah dimana BLE scan tidak menemukan perangkat apapun di Android 10.

### Penyebab Utama

1. **Location Permission Tidak Diberikan**
   - Android 10 memerlukan `ACCESS_FINE_LOCATION` permission untuk BLE scanning
   - Permission ini harus di-request secara runtime, tidak cukup hanya di AndroidManifest.xml

2. **Location Service Tidak Aktif**
   - Selain permission, Location Service di device settings harus dalam keadaan ON
   - Tanpa Location Service aktif, BLE scan akan gagal silent (tidak mengembalikan device apapun)

3. **Runtime Permission Tidak Di-handle dengan Benar**
   - Developer sering lupa request permission sebelum melakukan scan
   - Atau tidak check apakah permission sudah granted atau belum

---

## ✅ Solusi yang Sudah Diimplementasikan di SDK

KGiTON SDK versi terbaru sudah meng-handle masalah ini dengan:

### 1. **AndroidManifest.xml yang Lengkap**

SDK sudah mengonfigurasi permissions yang tepat untuk semua versi Android:

```xml
<!-- BLE Permissions for Android 12+ (API 31+) -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"
    android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- BLE Permissions for Android 11 and below (API 30-) -->
<uses-permission android:name="android.permission.BLUETOOTH" 
    android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" 
    android:maxSdkVersion="30" />

<!-- Location Permissions - REQUIRED for BLE scanning on Android 10-11 (API 29-30) -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" 
    android:maxSdkVersion="30" />
```

### 2. **Runtime Permission Checking di Native Code**

Di level Kotlin, SDK melakukan pengecekan yang comprehensive:

```kotlin
// Check permissions based on Android version
private fun checkBlePermissions(): Boolean {
    return when {
        // Android 12+
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            // Check BLUETOOTH_SCAN & BLUETOOTH_CONNECT
        }
        
        // Android 10-11 - REQUIRES FINE_LOCATION
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> {
            val hasBluetooth = // check BLUETOOTH
            val hasBluetoothAdmin = // check BLUETOOTH_ADMIN
            val hasFineLocation = // check FINE_LOCATION
            
            hasBluetooth && hasBluetoothAdmin && hasFineLocation
        }
        
        // Android 9 and below
        else -> {
            // Check BLUETOOTH, BLUETOOTH_ADMIN, COARSE_LOCATION
        }
    }
}

// Check if location service is enabled
private fun isLocationEnabled(): Boolean {
    val locationManager = context.getSystemService(Context.LOCATION_SERVICE)
    return locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) || 
           locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
}
```

### 3. **Permission Helper di Flutter/Dart**

SDK menyediakan `PermissionHelper` class untuk memudahkan handling permissions:

```dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

// Request permissions sebelum scanning
final granted = await PermissionHelper.requestBLEPermissions();

if (!granted) {
  // Handle permission denied
  final errorMsg = await PermissionHelper.getPermissionErrorMessage();
  print(errorMsg);
}
```

### 4. **Error Messages yang Jelas**

SDK memberikan error messages yang spesifik:

- **"PERMISSION_DENIED"**: Permissions belum granted
- **"LOCATION_DISABLED"**: Location service tidak aktif (khusus Android 10-11)
- **"BLUETOOTH_UNAVAILABLE"**: Bluetooth tidak aktif atau tidak tersedia

---

## 📱 Implementasi di Aplikasi Anda

### Step 1: Pastikan AndroidManifest.xml Benar

File `android/app/src/main/AndroidManifest.xml` harus memiliki permissions:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Bluetooth Permissions -->
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
        android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    
    <!-- CRITICAL for Android 10-11 -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <application>
        <!-- your app configuration -->
    </application>
</manifest>
```

### Step 2: Request Permissions Sebelum Scan

```dart
import 'package:flutter/material.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

class ScalePage extends StatefulWidget {
  @override
  State<ScalePage> createState() => _ScalePageState();
}

class _ScalePageState extends State<ScalePage> {
  final _scaleService = KGiTONScaleService();
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    // Check if already granted
    final granted = await PermissionHelper.checkBLEPermissions();
    
    if (granted) {
      setState(() => _permissionsGranted = true);
      return;
    }

    // Request permissions
    final result = await PermissionHelper.requestBLEPermissions();
    
    if (!result) {
      // Show error message
      final errorMsg = await PermissionHelper.getPermissionErrorMessage();
      _showPermissionDialog(errorMsg);
    } else {
      setState(() => _permissionsGranted = true);
    }
  }

  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Izin Diperlukan'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              PermissionHelper.openAppSettings();
            },
            child: Text('Buka Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _startScan() async {
    if (!_permissionsGranted) {
      await _checkAndRequestPermissions();
      return;
    }

    try {
      await _scaleService.scanForDevices(timeout: Duration(seconds: 15));
    } catch (e) {
      print('Scan error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('KGiTON Scale')),
      body: Center(
        child: ElevatedButton(
          onPressed: _permissionsGranted ? _startScan : _checkAndRequestPermissions,
          child: Text(_permissionsGranted ? 'Scan Devices' : 'Request Permissions'),
        ),
      ),
    );
  }
}
```

### Step 3: Debugging Permission Issues

Gunakan method untuk mendapatkan status permission detail:

```dart
// Get detailed permission status
final status = await PermissionHelper.getPermissionStatus();
print('Permission Status: $status');

// Output example untuk Android 10:
// {
//   platform: 'android',
//   androidVersion: 29,
//   bluetooth: 'PermissionStatus.granted',
//   location: 'PermissionStatus.denied',
//   locationServiceEnabled: false,
//   allGranted: false
// }
```

---

## 🔍 Troubleshooting Checklist

Jika BLE scanning masih tidak bekerja di Android 10, periksa:

- [ ] **AndroidManifest.xml** sudah include `ACCESS_FINE_LOCATION`
- [ ] **Runtime permission** sudah di-request menggunakan `PermissionHelper.requestBLEPermissions()`
- [ ] **Location Service** di device settings sudah ON (Settings > Location)
- [ ] **Bluetooth** di device sudah ON
- [ ] **App permissions** di device settings sudah granted (Settings > Apps > [Your App] > Permissions)
- [ ] Menggunakan **versi SDK terbaru** yang sudah include fix ini

---

## 🧪 Testing di Android 10

### Test Case 1: Fresh Install
1. Install app pertama kali
2. App harus request permissions saat pertama kali buka
3. Pastikan dialog permission muncul untuk Location dan Bluetooth
4. Grant semua permissions
5. Coba scan - harus menemukan devices

### Test Case 2: Location Service OFF
1. Grant semua permissions
2. Turn OFF Location Service di device settings
3. Coba scan - harus muncul error "Location service must be enabled..."
4. Turn ON Location Service
5. Scan lagi - harus berhasil

### Test Case 3: Permission Denied
1. Deny location permission
2. Coba scan - harus muncul error
3. App harus redirect ke Settings untuk enable permission
4. Grant permission di Settings
5. Kembali ke app, scan lagi - harus berhasil

---

## 📊 Perbedaan Requirements per Android Version

| Android Version | API Level | Required Permissions | Location Service Required? |
|----------------|-----------|---------------------|---------------------------|
| Android 9- | ≤ 28 | BLUETOOTH, BLUETOOTH_ADMIN, ACCESS_COARSE_LOCATION | No |
| Android 10 | 29 | BLUETOOTH, BLUETOOTH_ADMIN, **ACCESS_FINE_LOCATION** | **Yes** ✓ |
| Android 11 | 30 | BLUETOOTH, BLUETOOTH_ADMIN, **ACCESS_FINE_LOCATION** | **Yes** ✓ |
| Android 12+ | ≥ 31 | BLUETOOTH_SCAN, BLUETOOTH_CONNECT | No (with neverForLocation flag) |

**Catatan Penting untuk Android 10-11:**
- Harus gunakan `ACCESS_FINE_LOCATION` (bukan COARSE_LOCATION saja)
- Location Service harus aktif
- Kedua syarat ini **WAJIB**, jika tidak BLE scan akan gagal silent

---

## 💡 Tips Tambahan

### 1. Educate User
Buat UI yang menjelaskan kenapa location permission diperlukan:
```dart
Text(
  'Aplikasi memerlukan izin Lokasi untuk mencari perangkat Bluetooth. '
  'Ini adalah requirement dari Android 10 untuk alasan privasi. '
  'Data lokasi Anda tidak akan dikumpulkan.'
)
```

### 2. Check Permission Status Before Every Scan
```dart
Future<void> _startScan() async {
  // Always check before scanning
  final hasPermission = await PermissionHelper.checkBLEPermissions();
  
  if (!hasPermission) {
    // Request again
    await PermissionHelper.requestBLEPermissions();
    return;
  }

  // Proceed with scan
  await _scaleService.scanForDevices();
}
```

### 3. Handle Permission Rationale
```dart
// Show why permission is needed before requesting
final shouldRequest = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Izin Diperlukan'),
    content: Text(
      'Untuk mencari perangkat timbangan via Bluetooth, '
      'aplikasi memerlukan izin Lokasi. Ini adalah requirement Android 10.'
    ),
    actions: [
      TextButton(child: Text('Batal'), onPressed: () => Navigator.pop(context, false)),
      ElevatedButton(child: Text('Lanjutkan'), onPressed: () => Navigator.pop(context, true)),
    ],
  ),
);

if (shouldRequest == true) {
  await PermissionHelper.requestBLEPermissions();
}
```

---

## 📞 Support

Jika masih mengalami masalah setelah mengikuti guide ini:

1. Periksa log error di Android Studio / logcat
2. Pastikan menggunakan SDK versi terbaru
3. Test di device Android 10 yang real (bukan emulator)
4. Hubungi tim developer KGiTON SDK

---

## 📚 References

- [Android BLE Permissions Documentation](https://developer.android.com/guide/topics/connectivity/bluetooth/permissions)
- [Android 10 Privacy Changes](https://developer.android.com/about/versions/10/privacy/changes)
- [Permission Handler Package](https://pub.dev/packages/permission_handler)
