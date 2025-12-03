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

## Usage Flow

1. **Input License Key** - Masukkan license key yang valid
2. **Scan Devices** - Tap "Scan Devices" untuk mencari timbangan
3. **Select Device** - Pilih device dari list yang muncul
4. **Connected** - Setelah connected, data berat akan muncul realtime
5. **Buzzer Control** - Gunakan button untuk control buzzer
6. **Disconnect** - Tap "Disconnect" untuk memutus koneksi

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

## Learn More

Lihat README utama di parent directory untuk dokumentasi lengkap SDK.
