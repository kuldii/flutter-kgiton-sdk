# KGiTON SDK Documentation

Complete integration guide for KGiTON Flutter SDK - Clean and Simple.

---

## 📚 Documentation Structure

The documentation has been simplified into **5 core guides**:

### 1. [GETTING_STARTED.md](GETTING_STARTED.md)
**Complete setup guide from zero to first integration**
- Prerequisites and platform requirements
- Installation steps
- Android & iOS platform configuration
- Permissions setup
- API configuration
- First integration test code

👉 **Start here if you're new to KGiTON SDK**

---

### 2. [BLE_INTEGRATION.md](BLE_INTEGRATION.md)
**Complete BLE scale integration guide**
- Basic integration (scan, connect, disconnect)
- Connection state management
- Real-time weight data streaming (~10 Hz)
- Buzzer control (BEEP, BUZZ, LONG, OFF)
- Error handling
- Best practices
- Complete API reference

👉 **Read this to integrate BLE scale devices**

---

### 3. [API_INTEGRATION.md](API_INTEGRATION.md)
**Complete backend API integration guide**
- Authentication (register, login, logout)
- License management (Super Admin & Owner)
- Item management (CRUD operations)
- Transaction management
- Error handling
- Complete workflows

👉 **Read this to integrate backend API**

---

### 4. [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
**Common issues and solutions**
- BLE connection issues
- Android 10-11 specific issues
- Permission problems
- API integration errors
- Cart issues
- Weight data problems
- Build/compilation errors

👉 **Check here when you encounter issues**

---

### 5. [ANDROID_10_TROUBLESHOOTING.md](ANDROID_10_TROUBLESHOOTING.md)
**Detailed Android 10-11 BLE guide**
- Why Location permission is required
- Step-by-step permission setup
- Location Services requirement
- Complete code examples

👉 **Essential for Android 10-11 support**

---

## 🚀 Quick Start Paths

### Path 1: BLE Scale Only
```
GETTING_STARTED → BLE_INTEGRATION → TROUBLESHOOTING
```

### Path 2: Backend API Only
```
GETTING_STARTED → API_INTEGRATION → TROUBLESHOOTING
```

### Path 3: Complete Integration (BLE + API)
```
GETTING_STARTED → BLE_INTEGRATION → API_INTEGRATION → TROUBLESHOOTING
```

---

## 📖 What's Covered in Each Guide

### GETTING_STARTED.md
- ✅ Prerequisites (Flutter, Dart, platform versions)
- ✅ Installation (pubspec.yaml)
- ✅ Android configuration (build.gradle, manifest)
- ✅ iOS configuration (Info.plist, Podfile)
- ✅ Permission setup (runtime permissions)
- ✅ API service initialization
- ✅ First integration test (complete example)

### BLE_INTEGRATION.md
- ✅ SDK initialization and disposal
- ✅ Device scanning
- ✅ Connection management
- ✅ Auto-reconnect pattern
- ✅ Weight data streaming
- ✅ Stable weight detection
- ✅ Throttling updates
- ✅ Buzzer control
- ✅ Exception handling
- ✅ Best practices
- ✅ Complete API reference

### API_INTEGRATION.md
- ✅ Authentication flow (register, login, logout)
- ✅ Super Admin operations (license management)
- ✅ Owner operations (items, licenses)
- ✅ Transaction management
- ✅ Error handling (all exception types)
- ✅ Complete workflows (3 real-world examples)
- ✅ Best practices (retry logic, pagination)

### TROUBLESHOOTING.md
- ✅ BLE issues (connection, scan, disconnection)
- ✅ Android 10-11 issues (location requirement)
- ✅ Permission issues
- ✅ API errors (401, 404, 429, etc.)
- ✅ Weight data issues
- ✅ Build errors
- ✅ Error code quick reference

### ANDROID_10_TROUBLESHOOTING.md
- ✅ Why Android 10-11 is different
- ✅ Location permission requirement
- ✅ Location Services requirement
- ✅ Complete manifest setup
- ✅ Permission request code
- ✅ User education examples

---

## 🆕 What's New in v1.1.0

- ✅ **Payment Method**: Optional parameter in checkout
- ✅ **Order Notes**: Optional notes parameter
- ✅ **Enhanced Models**: Nullable fields support
- ✅ **Better Debugging**: Comprehensive error logging

See [../CHANGELOG.md](../CHANGELOG.md) for full details.

---

## 💡 Tips for Reading Documentation

### Icons Used
- 👉 Recommended next step
- ✅ Feature/topic covered
- ⚠️ Important warning
- ❌ Don't do this
- 📧 Contact information

### Code Blocks
- All examples are copy-paste ready
- Complete context provided
- Error handling included

### Navigation
- Each guide links to related guides
- "Next Steps" section at the end
- Clear Table of Contents in each guide

---

## 📦 Example App

Complete working example with Material Design 3 UI:
```
../example/lib/main.dart
```

Features:
- BLE device scanning
- Connection management
- Real-time weight display
- Buzzer control
- API integration
- Transaction history

---

## 🔐 Authorization & Security

- **License Required**: See [../AUTHORIZATION.md](../AUTHORIZATION.md)
- **Security Policy**: See [../SECURITY.md](../SECURITY.md)
- **Contact**: support@kgiton.com

---

## 🆘 Getting Help

### Before Asking
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Read relevant integration guide
3. Review example app code
4. Collect error messages and logs

### Contact Support
📧 **Email**: support@kgiton.com

**Include**:
- SDK version (check pubspec.lock)
- Platform & OS version
- Flutter/Dart version
- Error messages with stack trace
- Steps to reproduce

---

## 📝 Documentation Philosophy

**Clean & Simple:**
- No redundant information
- Clear structure
- Practical examples
- Copy-paste ready code

**Comprehensive:**
- All features documented
- Real-world workflows
- Error handling covered
- Best practices included

**Easy to Navigate:**
- Clear table of contents
- Cross-references between guides
- Quick start paths
- Complete examples

---

## 🔄 Version History

- **v1.1.0** (Current) - Enhanced models, improved API
- **v1.0.0** - Initial release with BLE + API

See [../CHANGELOG.md](../CHANGELOG.md) for full changelog.

---

**Ready to start?** → [GETTING_STARTED.md](GETTING_STARTED.md)
