# KGiTON SDK - Example App

Example app untuk demonstrasi penggunaan KGiTON SDK.

## Features

- ✅ Scan untuk menemukan timbangan
- ✅ Connect dengan license key
- ✅ Realtime weight display
- ✅ Connection status monitoring
- ✅ Buzzer control
- ✅ Multiple devices selection
- ✅ Disconnect functionality

## Running the Example

1. Install dependencies:
```bash
cd example
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## License Key

Untuk menjalankan example app, Anda perlu memasukkan license key yang valid.

License key harus sesuai dengan yang di-set di firmware ESP32 Anda.

## Screenshots

### Main Screen
- Display berat realtime
- Status koneksi
- Input license key
- Scan button
- Device list
- Buzzer controls

## API Usage Examples

### Initialize SDK
```dart
final sdk = KGiTONScaleService();
```

### Scan for Devices
```dart
await sdk.scanForDevices(timeout: Duration(seconds: 15));
```

### Connect with License Key
```dart
final response = await sdk.connectWithLicenseKey(
  deviceId: device.id,
  licenseKey: licenseKey,
);
```

### Listen to Weight Data
```dart
sdk.weightStream.listen((weight) {
  print('Weight: ${weight.displayWeight}');
});
```

### Control Buzzer
```dart
await sdk.triggerBuzzer('BEEP'); // BEEP, BUZZ, LONG, OFF
```

### Disconnect
```dart
await sdk.disconnect();
// OR with license key:
await sdk.disconnectWithLicenseKey(licenseKey);
```

## Usage Flow

1. **Input License Key** - Masukkan license key yang valid
2. **Start Scan** - Tap tombol Bluetooth untuk scan devices
3. **Select Device** - Pilih device dari list yang muncul
4. **Auto-Connect** - Otomatis connect dengan license key
5. **View Weight** - Data berat muncul realtime setelah authenticated
6. **Control Buzzer** - Gunakan button untuk control buzzer
7. **Disconnect** - Tap floating button merah untuk disconnect

## Troubleshooting

### Permission Error
Pastikan permissions sudah diberikan di Settings > Apps > Example App > Permissions

### Device Not Found
- Pastikan ESP32 sudah menyala
- Pastikan Bluetooth aktif
- Pastikan device belum terhubung ke aplikasi lain

### Connection Failed
- Cek license key sudah benar
- Pastikan device dalam jangkauan
- Coba restart Bluetooth

## Code Structure

```
example/
├── lib/
│   └── main.dart          # Main app dengan complete example
├── pubspec.yaml           # Dependencies
└── README.md             # Documentation
```

## Key Components

### ScalePage Widget
Widget utama yang mendemonstrasikan semua fitur SDK:
- Weight display dengan format besar
- Connection status card dengan warna
- License key input field
- Scan/connect/disconnect buttons
- Device list dengan selection
- Buzzer control buttons

### State Management
Menggunakan StatefulWidget dengan StreamListener untuk reactive updates dari SDK.

### Error Handling
Menggunakan SnackBar untuk menampilkan error dan success messages.

## Platform Requirements

### Android
Minimum SDK: API 21 (Android 5.0)

Permissions in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### iOS
Minimum Version: iOS 12.0

Permissions in `Info.plist`:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Need Bluetooth to connect to scale</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Need location for Bluetooth scanning</string>
```

## Learn More

Lihat [README.md](../README.md) di parent directory untuk dokumentasi lengkap SDK.

For licensing information, see [AUTHORIZATION.md](../AUTHORIZATION.md).
