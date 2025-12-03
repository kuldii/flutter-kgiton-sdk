# 1. Prerequisites

Before integrating the KGiTON SDK into your Flutter project, ensure you have all the necessary tools, devices, and knowledge.

---

## 🔧 Development Environment

### Required Software

#### 1. Flutter SDK
- **Minimum Version**: Flutter 3.3.0
- **Recommended**: Latest stable version

**Check your Flutter version**:
```bash
flutter --version
```

**Upgrade Flutter** (if needed):
```bash
flutter upgrade
```

#### 2. Dart SDK
- **Minimum Version**: Dart 3.0.0
- **Included with**: Flutter SDK

**Check your Dart version**:
```bash
dart --version
```

#### 3. IDE / Code Editor

**Option A: Android Studio (Recommended)**
- Version: Latest stable
- Plugins required:
  - Flutter plugin
  - Dart plugin

**Option B: Visual Studio Code**
- Version: Latest stable
- Extensions required:
  - Flutter extension
  - Dart extension

**Option C: IntelliJ IDEA**
- Version: Latest stable
- Plugins: Flutter, Dart

### Platform-Specific Tools

#### 📱 Android Development

1. **Android Studio** (includes Android SDK)
   - Minimum API Level: 21 (Android 5.0)
   - Target API Level: 34 (Android 14) or higher

2. **Android SDK Tools**:
   - Android SDK Build-Tools
   - Android SDK Platform-Tools
   - Android Emulator (for testing)

3. **Java Development Kit (JDK)**:
   - JDK 11 or higher

**Verify Android setup**:
```bash
flutter doctor -v
```

#### 🍎 iOS Development

1. **macOS** (required for iOS development)
   - macOS 11.0 or higher

2. **Xcode**:
   - Version: 13.0 or higher
   - Command Line Tools installed

3. **CocoaPods**:
   - Version: 1.11.0 or higher

**Install CocoaPods** (if not installed):
```bash
sudo gem install cocoapods
```

**Verify iOS setup**:
```bash
flutter doctor -v
pod --version
```

---

## 📱 Hardware Requirements

### Development Machine

**Minimum**:
- RAM: 8 GB
- Storage: 10 GB free space
- Processor: Intel i5 or equivalent

**Recommended**:
- RAM: 16 GB or more
- Storage: 20 GB+ free space (SSD preferred)
- Processor: Intel i7 or Apple Silicon

### Test Devices

#### Physical Devices (Required)

You **must** have at least one of:

1. **Android Device**
   - Android 5.0 (API 21) or higher
   - Bluetooth 4.0 (BLE) support
   - USB debugging enabled

2. **iOS Device**
   - iOS 12.0 or higher
   - Bluetooth 4.0 (BLE) support
   - Registered in your Apple Developer account

⚠️ **Important**: BLE functionality **cannot** be fully tested on emulators/simulators. You need real hardware.

#### KGiTON Scale Device

- At least 1 KGiTON BLE scale device
- Device should be powered on and within range
- Device firmware should be up to date

---

## 🔑 Account & Access Requirements

### 1. KGiTON License

**Required**:
- ✅ Valid KGiTON SDK license key
- ✅ Authorized by PT KGiTON
- ✅ License agreement signed

**Don't have a license?**  
📋 See [Authorization Guide](02-authorization.md) for details on obtaining one.

### 2. GitHub Access (If Using Private Repository)

If the SDK is hosted in a private repository:
- GitHub account
- Personal Access Token (PAT) with repo access
- Added as collaborator to the repository

### 3. Apple Developer Account (For iOS)

**Required for iOS deployment**:
- Apple Developer Program membership ($99/year)
- Team ID and signing certificates
- Provisioning profiles configured

---

## 📚 Required Knowledge

### Flutter & Dart

**You should understand**:
- ✅ Flutter widget basics (StatefulWidget, StatelessWidget)
- ✅ Dart async programming (Future, async/await)
- ✅ Dart Streams (listen, subscription)
- ✅ State management basics
- ✅ Material Design widgets

**Learning Resources**:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Asynchronous Programming](https://dart.dev/codelabs/async-await)

### Bluetooth Low Energy (Optional)

**Helpful to know**:
- BLE basic concepts (GATT, Services, Characteristics)
- BLE connection lifecycle
- BLE permissions and security

**Not required**: The SDK abstracts most BLE complexity.

---

## 🔍 Pre-Integration Checklist

Before proceeding to installation, verify:

### Environment Setup

- [ ] Flutter SDK installed and updated
- [ ] IDE with Flutter plugins installed
- [ ] Android SDK configured (for Android)
- [ ] Xcode and CocoaPods installed (for iOS)
- [ ] `flutter doctor` shows no critical issues

### Hardware & Devices

- [ ] Physical Android or iOS device available
- [ ] Device has BLE support
- [ ] KGiTON scale device available
- [ ] Scale device is powered on

### Access & Authorization

- [ ] Valid KGiTON license key obtained
- [ ] License agreement reviewed and accepted
- [ ] GitHub access configured (if needed)
- [ ] Apple Developer account active (for iOS)

### Knowledge & Skills

- [ ] Comfortable with Flutter development
- [ ] Understand async/await and Streams
- [ ] Familiar with permission handling
- [ ] Basic understanding of state management

---

## 🧪 Verify Your Setup

Run these commands to ensure everything is ready:

### 1. Check Flutter Doctor

```bash
flutter doctor -v
```

**Expected**: All items show ✓ (or doctor suggests fixes)

### 2. Create Test Project

```bash
flutter create test_kgiton_app
cd test_kgiton_app
flutter pub get
```

### 3. Test Build

**Android**:
```bash
flutter build apk --debug
```

**iOS** (macOS only):
```bash
flutter build ios --debug --no-codesign
```

### 4. Test Run

Connect your device and run:
```bash
flutter devices
flutter run
```

**Expected**: App launches successfully on your device.

---

## 🚨 Troubleshooting Setup Issues

### Flutter Doctor Issues

**Problem**: Android license not accepted
```bash
# Solution:
flutter doctor --android-licenses
```

**Problem**: Xcode not configured
```bash
# Solution:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### CocoaPods Issues

**Problem**: CocoaPods not found
```bash
# Solution (macOS):
sudo gem install cocoapods
pod setup
```

**Problem**: Pod install fails
```bash
# Solution:
cd ios
pod deintegrate
pod install --repo-update
```

### Device Connection Issues

**Android**:
1. Enable Developer Options: Settings → About Phone → Tap Build Number 7 times
2. Enable USB Debugging: Settings → Developer Options → USB Debugging
3. Accept computer authorization on device

**iOS**:
1. Trust computer: Settings → General → Device Management
2. Enable Developer Mode: Settings → Privacy & Security → Developer Mode
3. Ensure device is registered in Apple Developer account

---

## ✅ Prerequisites Complete!

If all checks pass, you're ready to proceed!

### Next Steps

👉 **[2. Authorization & Licensing](02-authorization.md)** - Get your license key

Or skip to:
- [Installation](03-installation.md) - If you already have a license
- [Platform Setup](04-platform-setup.md) - If SDK is installed

---

## 📞 Need Help?

**Setup Issues**:
- Consult [Troubleshooting Guide](11-troubleshooting.md)
- Check [FAQ](16-faq.md)

**Technical Support** (for authorized users):
- 📧 support@kgiton.com
- 🌐 https://kgiton.com

---

**Ready to continue? → [2. Authorization & Licensing](02-authorization.md)**

© 2025 PT KGiTON. All rights reserved.
