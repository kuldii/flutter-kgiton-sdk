# 3. Installation

This guide walks you through installing the KGiTON SDK in your Flutter project.

---

## 📦 Installation Methods

There are two ways to install the KGiTON SDK:

1. **Git Dependency** (Recommended) - Install directly from GitHub
2. **Local Path** (For development) - Install from local clone

---

## Method 1: Git Dependency (Recommended)

### Prerequisites

- ✅ Valid KGiTON license obtained
- ✅ GitHub account configured
- ✅ Git installed on your system

### Step 1: Open Your Project

Navigate to your Flutter project directory:

```bash
cd /path/to/your/flutter/project
```

### Step 2: Edit pubspec.yaml

Open `pubspec.yaml` and add the SDK under `dependencies`:

**For Public Repository**:
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # KGiTON SDK
  kgiton_sdk:
    git:
      url: https://github.com/kuldii/flutter-kgiton-sdk.git
      ref: main  # or specific version tag like 'v1.1.0'
```

**For Private Repository** (if applicable):
```yaml
dependencies:
  kgiton_sdk:
    git:
      url: https://[YOUR_TOKEN]@github.com/kuldii/flutter-kgiton-sdk.git
      ref: main
```

### Step 3: Get Dependencies

Run the following command to install:

```bash
flutter pub get
```

**Expected Output**:
```
Running "flutter pub get" in your_project...
Resolving dependencies...
+ kgiton_sdk 1.1.0 from git https://github.com/kuldii/flutter-kgiton-sdk.git
+ kgiton_ble_sdk 1.0.0 from git ...
+ logger 2.5.0
+ meta 1.15.0
+ shared_preferences 2.3.4
...
Got dependencies!
```

### Step 4: Verify Installation

Check that the SDK is installed:

```bash
flutter pub deps | grep kgiton
```

**Expected Output**:
```
|-- kgiton_sdk 1.1.0 from git
    |-- kgiton_ble_sdk 1.0.0 from git
    |-- logger 2.5.0
    |-- meta 1.15.0
    |-- shared_preferences 2.3.4
```

---

## Method 2: Local Path (Development)

Use this method if you have the SDK cloned locally for development.

### Step 1: Clone the Repository

```bash
# Clone to a location outside your project
cd ~/Development
git clone https://github.com/kuldii/flutter-kgiton-sdk.git
```

### Step 2: Edit pubspec.yaml

```yaml
dependencies:
  kgiton_sdk:
    path: /Users/your-username/Development/flutter-kgiton-sdk
    # Or relative path: ../kgiton-sdk
```

### Step 3: Get Dependencies

```bash
flutter pub get
```

⚠️ **Note**: Path dependencies are for local development only. For production, use Git dependency.

---

## 📚 Understanding Dependencies

The KGiTON SDK installs these dependencies:

### Direct Dependencies

```yaml
dependencies:
  # Core BLE functionality (Proprietary - requires access)
  kgiton_ble_sdk:
    git:
      url: https://github.com/kuldii/flutter-ble-sdk.git
  
  # Logging
  logger: ^2.5.0
  
  # Type safety
  meta: ^1.15.0
  
  # Secure local storage
  shared_preferences: ^2.3.4
```

### Transitive Dependencies

The SDK automatically includes:
- `flutter_blue_plus` (via kgiton_ble_sdk)
- `permission_handler` (for BLE permissions)
- Platform-specific dependencies

---

## 🔧 Configuration After Installation

### Update .gitignore

Ensure these are in your `.gitignore`:

```gitignore
# Flutter/Dart generated files
.dart_tool/
.packages
.flutter-plugins
.flutter-plugins-dependencies
pubspec.lock

# IDE
.idea/
.vscode/
*.iml

# Build outputs
build/
```

### No Additional Configuration Needed

The SDK is plug-and-play after installation. No need to:
- ❌ Modify build.gradle (Android config comes next)
- ❌ Edit Podfile (iOS config comes next)
- ❌ Add native code
- ❌ Configure build settings

---

## ✅ Verify Installation

### Test Import

Create a test file to verify the SDK can be imported:

```dart
// test_kgiton.dart
import 'package:kgiton_sdk/kgiton_sdk.dart';

void main() {
  // Try to instantiate the service
  final sdk = KGiTONScaleService();
  print('✅ KGiTON SDK imported successfully');
  print('SDK version: 1.1.0');
  
  // Check available methods
  print('Available methods:');
  print('- scanForDevices()');
  print('- connectWithLicenseKey()');
  print('- triggerBuzzer()');
  
  // Cleanup
  sdk.dispose();
}
```

Run the test:
```bash
dart test_kgiton.dart
```

**Expected Output**:
```
✅ KGiTON SDK imported successfully
SDK version: 1.1.0
Available methods:
- scanForDevices()
- connectWithLicenseKey()
- triggerBuzzer()
```

### Check Pub Outdated

Verify you have the latest version:

```bash
flutter pub outdated
```

Look for `kgiton_sdk` in the output. If outdated, update:

```bash
flutter pub upgrade kgiton_sdk
```

---

## 🚨 Troubleshooting Installation

### Issue 1: Git Repository Not Found

**Error**:
```
Git error. Command: git clone
fatal: repository not found
```

**Solutions**:
1. Verify repository URL is correct
2. Check you have access to the repository
3. If private repo, add your GitHub token:
   ```yaml
   git:
     url: https://YOUR_TOKEN@github.com/kuldii/flutter-kgiton-sdk.git
   ```

### Issue 2: Version Conflict

**Error**:
```
version solving failed
kgiton_sdk requires flutter_blue_plus ^X.Y.Z
but your project requires ^A.B.C
```

**Solution**:
Remove conflicting dependencies and let the SDK manage them:
```yaml
dependencies:
  # Remove flutter_blue_plus if you have it
  # kgiton_sdk will install the correct version
  kgiton_sdk:
    git: ...
```

### Issue 3: Pub Get Hangs

**Problem**: `flutter pub get` takes too long

**Solutions**:
1. Check internet connection
2. Clear pub cache:
   ```bash
   flutter pub cache clean
   flutter pub get
   ```
3. Use verbose mode to see progress:
   ```bash
   flutter pub get --verbose
   ```

### Issue 4: Permission Denied

**Error** (Git):
```
Permission denied (publickey)
```

**Solutions**:
1. Add SSH key to GitHub
2. Use HTTPS instead of SSH:
   ```yaml
   git:
     url: https://github.com/kuldii/flutter-kgiton-sdk.git
   ```
3. Use Personal Access Token

### Issue 5: Dependency Version Conflict

**Error**:
```
Because kgiton_sdk depends on shared_preferences ^2.3.4
and your_app depends on shared_preferences ^2.0.0
version solving failed
```

**Solution**:
Update your `shared_preferences` version to match:
```yaml
dependencies:
  shared_preferences: ^2.3.4  # Match SDK requirement
```

---

## 📱 Platform-Specific Notes

### Android

No additional steps needed yet. Platform setup covered in [Platform Setup](04-platform-setup.md).

### iOS

No additional steps needed yet. Platform setup covered in [Platform Setup](04-platform-setup.md).

### Web/Desktop

⚠️ **Not Supported**: The KGiTON SDK requires Bluetooth Low Energy, which is only available on mobile platforms.

If you run on unsupported platforms:
```dart
if (Platform.isAndroid || Platform.isIOS) {
  // Initialize SDK
  final sdk = KGiTONScaleService();
} else {
  print('⚠️ KGiTON SDK only supports Android and iOS');
}
```

---

## 🔄 Updating the SDK

### Check for Updates

```bash
flutter pub outdated
```

### Update to Latest Version

**Option 1: Update All Dependencies**
```bash
flutter pub upgrade
```

**Option 2: Update KGiTON SDK Only**
```bash
flutter pub upgrade kgiton_sdk
```

**Option 3: Specify Version** (in pubspec.yaml)
```yaml
kgiton_sdk:
  git:
    url: https://github.com/kuldii/flutter-kgiton-sdk.git
    ref: v1.2.0  # Specific version tag
```

### Migration Notes

When updating major versions, check:
- [CHANGELOG.md](../CHANGELOG.md) - Breaking changes
- [Migration Guide](15-migration-guide.md) - Update instructions

---

## 📦 Uninstalling the SDK

If you need to remove the SDK:

### Step 1: Remove from pubspec.yaml

Delete the `kgiton_sdk` entry:
```yaml
dependencies:
  # kgiton_sdk:  # Remove this
  #   git: ...
```

### Step 2: Clean Dependencies

```bash
flutter pub get
flutter clean
```

### Step 3: Remove Imports

Remove all SDK imports from your code:
```dart
// Remove this line
import 'package:kgiton_sdk/kgiton_sdk.dart';
```

---

## 📊 Installation Summary

After completing installation:

- ✅ SDK added to `pubspec.yaml`
- ✅ Dependencies resolved with `flutter pub get`
- ✅ Installation verified with test import
- ✅ Ready for platform configuration

### Installed Packages

```
kgiton_sdk (1.1.0)
├── kgiton_ble_sdk (1.0.0)
├── logger (2.5.0)
├── meta (1.15.0)
└── shared_preferences (2.3.4)
```

### Disk Usage

- SDK Source: ~52 KB
- With Dependencies: ~2.5 MB
- Build Impact: ~500 KB (Android), ~800 KB (iOS)

---

## ✅ Installation Complete!

Your SDK is now installed! Next, configure your platform(s).

### Next Steps

👉 **[4. Platform Setup](04-platform-setup.md)** - Configure Android & iOS

Or jump to:
- [Permissions Setup](05-permissions-setup.md) - Handle BLE permissions
- [Basic Integration](06-basic-integration.md) - Start coding

---

**Need Help?**

- 📧 Technical Support: support@kgiton.com
- 📚 Documentation: [README](../README.md)
- 🐛 Issues: [GitHub Issues](https://github.com/kuldii/flutter-kgiton-sdk/issues)

---

**Ready for platform setup? → [4. Platform Setup](04-platform-setup.md)**

© 2025 PT KGiTON. All rights reserved.
