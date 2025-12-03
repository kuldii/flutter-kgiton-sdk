# 2. Authorization & Licensing

The KGiTON SDK is proprietary software that requires explicit authorization from PT KGiTON. This guide explains how to obtain and activate your license.

---

## 🔐 Understanding KGiTON Licensing

### Why License is Required

The KGiTON SDK is **commercial software**, not open source. It is protected by:
- ✅ Copyright law
- ✅ Proprietary license agreement
- ✅ Technical license key validation
- ✅ International treaties

**Unauthorized use is prohibited** and may result in:
- ❌ License termination
- ❌ Legal action
- ❌ Financial penalties

### What the License Covers

Your license grants you:
- ✅ Right to use the SDK in authorized projects
- ✅ Access to SDK source code
- ✅ Technical support
- ✅ Updates and bug fixes during license period
- ✅ Documentation and examples

### What is NOT Allowed

- ❌ Sharing or redistributing the SDK
- ❌ Reverse engineering or decompiling
- ❌ Removing proprietary notices
- ❌ Sublicensing to third parties
- ❌ Using beyond authorized scope

---

## 📋 How to Obtain a License

### Step 1: Contact PT KGiTON

Send an email to: **support@kgiton.com**

**Email Template**:

```
Subject: KGiTON SDK License Request

Dear KGiTON Team,

I am interested in obtaining a license for the KGiTON Flutter SDK.

Company/Organization: [Your Company Name]
Contact Person: [Your Full Name]
Job Title: [Your Position]
Business Email: [Your Email]
Phone Number: [Your Phone]
Country: [Your Country]

Intended Use Case:
[Briefly describe how you plan to use the SDK - 2-3 sentences]

Project Timeline:
[Expected start date and duration]

Number of Developers:
[How many developers will use the SDK]

Please provide information about:
1. Available license types and pricing
2. License agreement for review
3. Technical support options

Thank you,
[Your Name]
```

### Step 2: Review License Options

PT KGiTON will send you information about available license types:

#### Development License

**For**: Development and testing  
**Duration**: Typically 3-6 months  
**Devices**: Limited to development environment  
**Support**: Email support  
**Price**: Contact sales  

**Best for**:
- Proof of concept projects
- Evaluation and testing
- Development phase

#### Commercial License

**For**: Production deployment  
**Duration**: 1 year or perpetual  
**Devices**: As specified in agreement  
**Support**: Priority email support  
**Price**: Contact sales  

**Best for**:
- Commercial applications
- Released products
- Active deployments

#### Enterprise License

**For**: Large-scale deployments  
**Duration**: Custom terms  
**Devices**: Unlimited or custom  
**Support**: Dedicated support channel  
**Price**: Custom pricing  

**Includes**:
- Custom feature development options
- On-site training
- Service Level Agreement (SLA)
- Extended support

### Step 3: Review & Sign Agreement

1. **Receive License Agreement**: PT KGiTON sends the commercial license agreement
2. **Review Terms**: Read all terms and conditions carefully
3. **Legal Review**: Have your legal team review (recommended)
4. **Sign Agreement**: Complete signature process
5. **Payment**: Complete payment if applicable

**Key Terms to Review**:
- License scope and limitations
- Duration and renewal terms
- Support and maintenance
- Liability and warranties
- Termination clauses
- Confidentiality obligations

### Step 4: Receive License Credentials

Once approved, you will receive:

1. **License Key**: Unique license identifier
   ```
   Format: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
   Example: A1B2C-3D4E5-F6G7H-8I9J0-K1L2M
   ```

2. **Access Credentials**: If repository is private
   - GitHub Personal Access Token
   - Or repository invite

3. **Welcome Package**:
   - License certificate (PDF)
   - Quick start guide
   - Support contact information
   - Sample license keys for testing

4. **Documentation Access**:
   - Full API documentation
   - Integration guides
   - Example projects

---

## 🔑 Understanding Your License Key

### License Key Format

```
XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
  │      │      │      │      │
  │      │      │      │      └─ Checksum (validation)
  │      │      │      └─ Expiration (encoded)
  │      │      └─ Device limit (encoded)
  │      └─ License type (Dev/Commercial/Enterprise)
  └─ Customer ID
```

### License Key Properties

Each license key contains:
- Customer identification
- License type and tier
- Expiration date (if applicable)
- Device/user limits
- Feature flags
- Validation checksum

### How the SDK Uses Your License

```dart
// Your license key is used during connection
final response = await sdk.connectWithLicenseKey(
  deviceId: device.id,
  licenseKey: 'A1B2C-3D4E5-F6G7H-8I9J0-K1L2M', // Your actual license
);

// The SDK validates:
// 1. License key format
// 2. License key authenticity
// 3. License expiration
// 4. Usage limits
// 5. Device authorization
```

---

## 🔒 Securing Your License Key

### Security Best Practices

#### ❌ DO NOT:

```dart
// WRONG: Hardcoded in source code
class MyApp {
  final licenseKey = 'A1B2C-3D4E5-F6G7H-8I9J0-K1L2M'; // Visible in version control!
}

// WRONG: Committed to Git
const LICENSE_KEY = 'A1B2C-3D4E5-F6G7H-8I9J0-K1L2M';
```

#### ✅ DO:

**Option 1: Environment Variables** (Recommended)
```dart
// Store in .env file (add to .gitignore)
// .env
KGITON_LICENSE_KEY=A1B2C-3D4E5-F6G7H-8I9J0-K1L2M

// Load with flutter_dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
final licenseKey = dotenv.env['KGITON_LICENSE_KEY']!;
```

**Option 2: Secure Storage**
```dart
// Store in device secure storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Write (once, during setup)
await storage.write(key: 'kgiton_license', value: licenseKey);

// Read when needed
final licenseKey = await storage.read(key: 'kgiton_license');
```

**Option 3: Remote Configuration**
```dart
// Fetch from your secure backend
final response = await http.get('https://your-api.com/config');
final licenseKey = response.data['kgiton_license_key'];
```

### License Storage Checklist

- [ ] License key NOT hardcoded in source
- [ ] License key NOT in version control
- [ ] .env file added to .gitignore
- [ ] Secure storage used for production
- [ ] Key retrieval implemented
- [ ] Error handling for missing key

---

## ✅ Verify Your License

### Online Verification

Visit: **https://kgiton.com/verify-license**

Enter your license key to check:
- ✅ License status (Active/Expired/Revoked)
- ✅ License type
- ✅ Expiration date
- ✅ Authorized projects
- ✅ Usage limits

### Programmatic Verification

```dart
// The SDK validates automatically on connect
try {
  final response = await sdk.connectWithLicenseKey(
    deviceId: device.id,
    licenseKey: yourLicenseKey,
  );
  
  if (response.success) {
    print('✅ License valid: ${response.message}');
  } else {
    print('❌ License issue: ${response.message}');
  }
} catch (e) {
  if (e is LicenseKeyException) {
    // Handle license errors
    print('License error: ${e.message}');
    // Possible reasons:
    // - Invalid format
    // - Expired license
    // - Exceeded usage limits
    // - Revoked license
  }
}
```

---

## 📅 License Management

### License Expiration

**Development Licenses**: Typically 3-6 months  
**Commercial Licenses**: 1 year (renewable)  
**Enterprise Licenses**: Custom terms

**Before Expiration**:
- You'll receive renewal reminders (30, 14, 7 days before)
- Contact sales@kgiton.com to renew
- Existing deployments continue working until expiration

**After Expiration**:
- New connections will fail
- Existing connections may be terminated
- Need to renew to restore access

### License Renewal Process

1. Contact PT KGiTON 30 days before expiration
2. Review updated terms (if any)
3. Complete renewal payment
4. Receive new license key (or extension of current)

### License Upgrade

To upgrade from Development to Commercial:
1. Email: sales@kgiton.com
2. Provide current license key
3. Discuss upgrade terms
4. Complete upgrade process
5. Receive new license credentials

---

## 🚨 License Violations

### Common Violations

1. **Unauthorized Sharing**
   - Sharing license key with unauthorized parties
   - Using same key across multiple organizations

2. **Scope Violation**
   - Using Development license in production
   - Exceeding device/user limits

3. **Redistribution**
   - Including SDK in unauthorized open-source projects
   - Sharing SDK source code

### Consequences

- ⚠️ Warning for first-time violations
- ❌ License suspension
- ❌ License termination
- ⚖️ Legal action for serious violations

### If You Suspect Violation

If you believe someone is using your license unauthorized:
1. Email: security@kgiton.com
2. Change your license key immediately
3. Review access logs
4. Update security measures

---

## 📞 Licensing Support

### For License Inquiries

**Sales & Licensing**:
- 📧 Email: sales@kgiton.com
- 🌐 Web: https://kgiton.com/licensing
- 📱 Phone: [Your Phone Number]

**Business Hours**: Monday - Friday, 9:00 AM - 5:00 PM WIB (GMT+7)

### For Technical Issues

**Technical Support** (authorized users only):
- 📧 Email: support@kgiton.com
- Response: Within 24 hours (business days)

### For Security Issues

**Security Team**:
- 📧 Email: security@kgiton.com
- Response: Within 48 hours

---

## 📖 Additional Resources

- [License Agreement](../LICENSE) - Full legal terms
- [Security Policy](../SECURITY.md) - Security guidelines
- [FAQ](16-faq.md) - Common licensing questions

---

## ✅ Authorization Complete!

Once you have your license key, you're ready to install the SDK!

### Next Steps

👉 **[3. Installation](03-installation.md)** - Install the SDK in your project

Or jump to:
- [Platform Setup](04-platform-setup.md) - Configure Android/iOS
- [Basic Integration](06-basic-integration.md) - Start coding

---

**Questions?** Contact: support@kgiton.com

© 2025 PT KGiTON. All rights reserved.
