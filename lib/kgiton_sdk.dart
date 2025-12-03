/// KGiTON BLE Scale SDK
///
/// Flutter SDK untuk integrasi timbangan berbasis ESP32 via BLE.
/// Mendukung autentikasi license key, kontrol buzzer, dan streaming data berat realtime.
library kgiton_sdk;

// Core Services
export 'src/kgiton_scale_service.dart';

// Models
export 'src/models/scale_device.dart';
export 'src/models/scale_connection_state.dart';
export 'src/models/weight_data.dart';
export 'src/models/control_response.dart';

// Constants
export 'src/constants/ble_constants.dart';

// Exceptions
export 'src/exceptions/kgiton_exceptions.dart';
