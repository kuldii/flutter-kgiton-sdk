# 17. Glossary

Technical terms and definitions used in the KGiTON SDK documentation.

---

## A

**AAR (Android Archive)**  
Android library package format. The SDK's Android implementation is compiled into an AAR file.

**API (Application Programming Interface)**  
A set of functions and procedures allowing the creation of applications that access the features of the SDK.

**Asynchronous**  
Operations that don't block the program flow, typically using `Future` or `async/await` in Dart.

**Authentication**  
The process of verifying the license key to establish a secure connection with the scale device.

---

## B

**BLE (Bluetooth Low Energy)**  
Also called Bluetooth Smart or Bluetooth 4.0+. A wireless technology designed for low power consumption, used by KGiTON scales.

**Build.gradle**  
Android build configuration file that specifies project dependencies, SDK versions, and build settings.

**Buzzer**  
Audio feedback device on the scale that can produce beeps or buzzes for user notifications.

---

## C

**Characteristic (BLE)**  
A data value transferred between BLE devices. Contains weight data, commands, etc.

**CocoaPods**  
Dependency manager for iOS and macOS projects, used to manage SDK's iOS dependencies.

**Connection State**  
Current status of the connection to a scale device:
- `disconnected` - No connection
- `connecting` - Attempting to connect
- `connected` - Connected but not authenticated
- `authenticated` - Fully connected and authorized
- `disconnecting` - Disconnecting in progress

---

## D

**Dart**  
Programming language used by Flutter and the KGiTON SDK.

**Device ID**  
Unique identifier for a BLE device, typically the MAC address (Android) or UUID (iOS).

**Dispose**  
Cleanup method called when a widget is removed, used to free resources like streams and connections.

**DTD (Dart Tooling Daemon)**  
Not related to this SDK. Different context.

---

## E

**Environment Variable**  
System-level variable used to store configuration like license keys, preventing hardcoding in source code.

**Exception**  
Error that occurs during SDK operation. See [Error Handling](09-error-handling.md) for types.

---

## F

**Flutter**  
Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.

**Future**  
Dart object representing a value or error that will be available at some point in the future.

---

## G

**GATT (Generic Attribute Profile)**  
BLE protocol that defines how data is organized and exchanged between devices.

**Gradle**  
Build automation tool for Android projects.

---

## I

**Info.plist**  
iOS configuration file containing app metadata and permissions.

**iOS**  
Apple's mobile operating system. Minimum version supported: 12.0.

---

## K

**KGiTON**  
Company name and brand for BLE scale devices and SDKs.

**kgiton_ble_sdk**  
Low-level BLE communication library (MIT licensed) used internally by kgiton_sdk.

**kgiton_sdk**  
High-level proprietary SDK for integrating KGiTON scale devices.

---

## L

**License Key**  
Unique authorization code required to connect to KGiTON devices.  
Format: `XXXXX-XXXXX-XXXXX-XXXXX-XXXXX`

**Listen (Stream)**  
Subscribe to a stream to receive updates:
```dart
sdk.weightStream.listen((weight) {
  // Handle weight data
});
```

---

## M

**MAC Address**  
Media Access Control address - unique identifier for network interfaces. Used as device ID on Android.

**Manifest (AndroidManifest.xml)**  
Android configuration file declaring app permissions, components, and metadata.

**Material Design**  
Google's design system used in Flutter UI components.

---

## P

**Package**  
Reusable Dart/Flutter code library. The SDK is distributed as a Flutter package.

**Permission**  
User authorization required to access device features like Bluetooth and Location.

**Podfile**  
CocoaPods configuration file for iOS dependencies.

**Proprietary Software**  
Software owned by a company with restricted licensing, not open source.

**pubspec.yaml**  
Flutter project configuration file listing dependencies and metadata.

---

## R

**RSSI (Received Signal Strength Indicator)**  
Measurement of signal strength between devices, measured in dBm. More negative = weaker signal.
- < -70 dBm: Excellent
- -70 to -85 dBm: Good  
- > -85 dBm: Fair to poor

**Raw Weight**  
Unprocessed weight value directly from the scale sensor.

---

## S

**Scale Device**  
Physical KGiTON BLE-enabled weighing scale.

**SDK (Software Development Kit)**  
Collection of software tools for developing applications. The KGiTON SDK enables scale integration.

**Service (BLE)**  
Collection of related BLE characteristics. KGiTON scales expose services for weight data, control, etc.

**Stateful Widget**  
Flutter widget that maintains mutable state.

**Stream**  
Sequence of asynchronous events. The SDK uses streams for device discovery, weight data, and connection states.

**Subscription (Stream)**  
Active listener to a stream, must be canceled when no longer needed.

---

## T

**Timeout**  
Maximum time to wait for an operation. For example, scan timeout limits how long to search for devices.

**Timestamp**  
Date and time when data was captured, included with weight measurements.

---

## U

**UUID (Universally Unique Identifier)**  
128-bit identifier used for BLE services and characteristics, and as device ID on iOS.

---

## W

**Weight Data**  
Object containing:
- `rawWeight`: Unprocessed weight (double)
- `displayWeight`: Formatted weight string
- `timestamp`: When measurement was taken
- `unit`: Weight unit (typically "kg")

**Widget**  
Basic building block of Flutter UI. Everything in Flutter is a widget.

---

## X

**Xcode**  
Apple's integrated development environment (IDE) for iOS/macOS development.

---

## Common Abbreviations

| Abbreviation | Full Term |
|-------------|-----------|
| API | Application Programming Interface |
| BLE | Bluetooth Low Energy |
| GATT | Generic Attribute Profile |
| IDE | Integrated Development Environment |
| iOS | iPhone Operating System |
| MAC | Media Access Control |
| RSSI | Received Signal Strength Indicator |
| SDK | Software Development Kit |
| UI | User Interface |
| UUID | Universally Unique Identifier |

---

## SDK-Specific Terms

### Device Discovery
Process of scanning for nearby BLE devices.

### License Authentication
Validating license key with the scale device to authorize connection.

### Weight Stream
Continuous flow of weight measurements from connected scale.

### Connection Lifecycle
Sequence of states: disconnected → connecting → connected → authenticated → disconnecting → disconnected

### Buzzer Command
Control instruction sent to scale's audio feedback device:
- `BEEP`: Short beep
- `BUZZ`: Vibration-like sound
- `LONG`: Extended beep
- `OFF`: Silence buzzer

---

## Error Terms

**BLEConnectionException**  
Error during Bluetooth connection attempt.

**BLEOperationException**  
Error during Bluetooth operation (read/write).

**DeviceNotConnectedException**  
Attempted operation on disconnected device.

**DeviceNotAuthenticatedException**  
Attempted operation without valid license authentication.

**LicenseKeyException**  
Invalid or expired license key.

**ScanTimeoutException**  
Device scan exceeded timeout period.

See [Error Handling](09-error-handling.md) for complete exception reference.

---

## Platform Terms

### Android Terms

**API Level**  
Android version number. Minimum: 21 (Android 5.0).

**Gradle**  
Android build system.

**ProGuard**  
Code optimization and obfuscation tool for Android.

### iOS Terms

**Deployment Target**  
Minimum iOS version app supports. Minimum: 12.0.

**Provisioning Profile**  
Certificate for code signing iOS apps.

**Pod**  
iOS dependency managed by CocoaPods.

---

## State Management Terms

**State**  
Data that can change over time and affects UI rendering.

**setState**  
Method to update state and trigger UI rebuild in StatefulWidget.

**Stream Subscription**  
Active listener to a stream, returns `StreamSubscription` object that can be canceled.

---

## Development Terms

**Hot Reload**  
Flutter feature to update code without restarting app.

**Hot Restart**  
Restart app while maintaining debug connection.

**Debug Mode**  
Development build with debugging tools enabled.

**Release Mode**  
Optimized production build.

---

## Networking Terms

**Pairing**  
Process of establishing trusted connection between BLE devices (not required for KGiTON SDK).

**Bonding**  
Storing pairing information for future connections.

**Advertisement**  
BLE broadcast signal allowing devices to be discovered.

---

## Related Concepts

### Permissions

**Runtime Permission**  
Permission requested while app is running (Android 6.0+).

**Usage Description**  
Text explaining why permission is needed (iOS).

**Permanent Denial**  
User selected "Don't ask again" for permission.

### Data Flow

**Upstream**  
Data flowing from app to device (commands).

**Downstream**  
Data flowing from device to app (weight measurements).

**Bidirectional**  
Communication in both directions.

---

## Need More Clarification?

If you encounter a term not listed here:

1. Check [API Reference](08-api-reference.md)
2. Search documentation with Ctrl/Cmd+F
3. Contact support: support@kgiton.com

---

## Related Documentation

- 📖 [API Reference](08-api-reference.md) - Complete API documentation
- 🔧 [Troubleshooting](11-troubleshooting.md) - Common issues
- ❓ [FAQ](16-faq.md) - Frequently asked questions
- 📚 [Complete Guide](README.md) - Full documentation index

---

**Glossary Version**: 1.0  
**Last Updated**: December 3, 2025  
**SDK Version**: 1.1.0

© 2025 PT KGiTON. All rights reserved.
