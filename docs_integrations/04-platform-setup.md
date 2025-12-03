# 4. Platform Setup

Configure Android and iOS platforms to enable Bluetooth Low Energy (BLE) functionality for the KGiTON SDK.

---

## 📱 Android Setup

### Minimum Requirements

- Android API Level: 21 (Android 5.0 Lollipop)
- Target API Level: 34 (Android 14) or higher
- Bluetooth 4.0 (BLE) hardware support

### Step 1: Configure AndroidManifest.xml

Location: `android/app/src/main/AndroidManifest.xml`

Add the following permissions before the `<application>` tag:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Bluetooth Permissions -->
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    
    <!-- BLE Scan Permissions (Android 12+) -->
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"
        android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    
    <!-- Location Permissions (required for BLE scanning on Android <12) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- BLE Feature -->
    <uses-feature 
        android:name="android.hardware.bluetooth_le" 
        android:required="true" />
    
    <application
        android:label="your_app_name"
        ...>
        <!-- Your app configuration -->
    </application>
</manifest>
```

#### Complete Example

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- ============= BLUETOOTH PERMISSIONS ============= -->
    
    <!-- Basic Bluetooth (All Android versions) -->
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    
    <!-- Android 12+ (API 31+) Bluetooth Permissions -->
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"
        android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    
    <!-- Location (Required for BLE scan on Android < 12) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Declare BLE hardware requirement -->
    <uses-feature 
        android:name="android.hardware.bluetooth_le" 
        android:required="true" />
    
    <!-- ================================================= -->
    
    <application
        android:label="KGiTON Scale App"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
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

### Step 2: Configure build.gradle

Location: `android/app/build.gradle`

Update the minimum SDK version:

```gradle
android {
    compileSdk 34  // Or higher
    
    defaultConfig {
        applicationId "com.yourcompany.yourapp"
        minSdk 21      // Minimum: Android 5.0
        targetSdk 34   // Target: Android 14 or higher
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}
```

### Step 3: Enable ProGuard Rules (Optional for Release)

Location: `android/app/proguard-rules.pro`

Create if it doesn't exist and add:

```proguard
# KGiTON SDK
-keep class com.kgiton.** { *; }

# Flutter Blue Plus (BLE library)
-keep class com.boskokg.flutter_blue_plus.** { *; }

# Bluetooth
-keep class android.bluetooth.** { *; }
```

Then enable in `build.gradle`:

```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        signingConfig signingConfigs.release
    }
}
```

### Step 4: Verify Android Configuration

Run the following command to check for issues:

```bash
cd android
./gradlew assembleDebug
```

**Expected**: Build completes successfully without errors.

---

## 🍎 iOS Setup

### Minimum Requirements

- iOS Version: 12.0 or higher
- Xcode: 13.0 or higher
- CocoaPods: 1.11.0 or higher
- Bluetooth 4.0 (BLE) hardware support

### Step 1: Configure Info.plist

Location: `ios/Runner/Info.plist`

Add the following entries inside the `<dict>` tag:

```xml
<dict>
    <!-- Existing entries... -->
    
    <!-- Bluetooth Usage Description -->
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>This app needs Bluetooth to connect to your KGiTON scale device</string>
    
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>This app needs Bluetooth to communicate with your scale</string>
    
    <!-- Location Usage (Required for BLE on older iOS versions) -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs location permission to scan for Bluetooth devices</string>
    
    <!-- Background Modes (Optional - for background BLE) -->
    <key>UIBackgroundModes</key>
    <array>
        <string>bluetooth-central</string>
    </array>
</dict>
```

#### Complete Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App Configuration -->
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleName</key>
    <string>KGiTON Scale App</string>
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    
    <!-- ============= BLUETOOTH PERMISSIONS ============= -->
    
    <!-- Bluetooth Always Usage (iOS 13+) -->
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>This app needs Bluetooth to connect to your KGiTON scale device and receive weight data</string>
    
    <!-- Bluetooth Peripheral Usage (iOS 12 and below) -->
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>This app needs Bluetooth to communicate with your KGiTON scale</string>
    
    <!-- Location When In Use (Required for BLE scanning) -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs location permission to scan for nearby Bluetooth devices</string>
    
    <!-- Background Modes (Optional - allows BLE in background) -->
    <key>UIBackgroundModes</key>
    <array>
        <string>bluetooth-central</string>
    </array>
    
    <!-- ================================================= -->
    
    <!-- Launch Screen -->
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    
    <!-- Other Settings -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
```

### Step 2: Update Deployment Target

Location: `ios/Podfile`

Ensure minimum iOS version is 12.0:

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # Set minimum deployment target
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

### Step 3: Install CocoaPods Dependencies

```bash
cd ios
pod deintegrate  # Clean previous installations
pod install      # Install dependencies
cd ..
```

**Expected Output**:
```
Analyzing dependencies
Downloading dependencies
Installing kgiton_sdk (1.1.0)
Installing flutter_blue_plus (...)
...
Pod installation complete!
```

### Step 4: Configure Xcode Project (Optional)

Open Xcode to verify settings:

```bash
open ios/Runner.xcworkspace
```

In Xcode:
1. Select **Runner** project
2. Select **Runner** target
3. Go to **General** tab
4. Verify **Deployment Target** is iOS 12.0 or higher
5. Go to **Signing & Capabilities**
6. Ensure **Background Modes** includes **Bluetooth LE accessories** (if needed)

### Step 5: Verify iOS Configuration

Build the iOS app:

```bash
flutter build ios --debug --no-codesign
```

**Expected**: Build completes successfully.

---

## 🔍 Verify Platform Setup

### Android Verification

```bash
# Build APK
flutter build apk --debug

# Install on connected device
flutter install
```

### iOS Verification

```bash
# Build iOS app
flutter build ios --debug --no-codesign

# Or run directly
flutter run -d [your-ios-device-id]
```

### Check for Common Issues

Run Flutter doctor:
```bash
flutter doctor -v
```

Look for:
- ✅ Android toolchain configured
- ✅ Xcode configured (for iOS)
- ✅ Connected devices detected

---

## 🚨 Troubleshooting Platform Issues

### Android Issues

#### Issue 1: Gradle Build Failed

**Error**:
```
FAILURE: Build failed with an exception.
* What went wrong:
Could not determine the dependencies of task ':app:compileDebugJavaWithJavac'.
```

**Solutions**:
1. Clean build:
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

2. Check `build.gradle` syntax
3. Update Gradle version in `android/gradle/wrapper/gradle-wrapper.properties`

#### Issue 2: minSdkVersion Conflict

**Error**:
```
uses-sdk:minSdkVersion 16 cannot be smaller than version 21 declared in library
```

**Solution**:
Update `android/app/build.gradle`:
```gradle
defaultConfig {
    minSdk 21  // Change from 16 to 21
}
```

#### Issue 3: Duplicate Permission Entries

**Error**:
```
Attribute android:name="android.permission.BLUETOOTH" is already defined
```

**Solution**:
Remove duplicate `<uses-permission>` tags in AndroidManifest.xml

### iOS Issues

#### Issue 1: CocoaPods Install Failed

**Error**:
```
[!] Unable to find a specification for 'kgiton_sdk'
```

**Solutions**:
```bash
cd ios
pod deintegrate
pod repo update
pod install
cd ..
```

#### Issue 2: Info.plist Syntax Error

**Error**:
```
The data couldn't be read because it isn't in the correct format.
```

**Solution**:
1. Open `ios/Runner/Info.plist` in Xcode
2. Ensure proper XML syntax
3. Validate with: `plutil -lint ios/Runner/Info.plist`

#### Issue 3: Deployment Target Too Low

**Error**:
```
The iOS deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 11.0, but the range of supported deployment target versions is 12.0 to 17.2
```

**Solution**:
Update `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

Then:
```bash
cd ios
pod install
```

---

## 📊 Platform Configuration Checklist

### Android Checklist

- [ ] `minSdk` set to 21 in `build.gradle`
- [ ] All Bluetooth permissions added to `AndroidManifest.xml`
- [ ] Location permissions added (required for BLE scan)
- [ ] `bluetooth_le` feature declared
- [ ] ProGuard rules configured (if using release build)
- [ ] Build completes without errors

### iOS Checklist

- [ ] Deployment target set to iOS 12.0 in `Podfile`
- [ ] `NSBluetoothAlwaysUsageDescription` added to `Info.plist`
- [ ] `NSLocationWhenInUseUsageDescription` added to `Info.plist`
- [ ] Background modes configured (if needed)
- [ ] CocoaPods dependencies installed
- [ ] Build completes without errors

---

## 🎯 Platform-Specific Features

### Android-Specific

**Location Services Check**:
```dart
import 'dart:io';

if (Platform.isAndroid) {
  // Android requires location services ON for BLE scan
  final serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    await location.requestService();
  }
}
```

### iOS-Specific

**Background BLE** (Optional):
If you need BLE in background, ensure:
1. Background mode enabled in Info.plist
2. Handle background state in your app:

```dart
import 'dart:io';

if (Platform.isIOS) {
  // Handle app lifecycle for background BLE
  WidgetsBinding.instance.addObserver(
    // Your lifecycle observer
  );
}
```

---

## ✅ Platform Setup Complete!

Both Android and iOS are now configured for BLE!

### What You've Configured

**Android**:
- ✅ Bluetooth permissions
- ✅ Location permissions
- ✅ BLE feature declaration
- ✅ Minimum SDK version

**iOS**:
- ✅ Bluetooth usage descriptions
- ✅ Location permission
- ✅ Deployment target
- ✅ CocoaPods dependencies

### Next Steps

👉 **[5. Permissions Setup](05-permissions-setup.md)** - Handle runtime permissions

Or jump to:
- [Basic Integration](06-basic-integration.md) - Start coding
- [Complete Examples](12-complete-examples.md) - See working code

---

**Need Help?**

- 📧 support@kgiton.com
- 📚 [Troubleshooting Guide](11-troubleshooting.md)
- 🐛 [GitHub Issues](https://github.com/kuldii/flutter-kgiton-sdk/issues)

---

**Ready for permissions? → [5. Permissions Setup](05-permissions-setup.md)**

© 2025 PT KGiTON. All rights reserved.
