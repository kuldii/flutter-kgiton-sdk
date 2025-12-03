# 14. Testing Guide

Comprehensive testing strategies for KGiTON SDK integration.

---

## 🧪 Testing Overview

### Testing Levels
- **Unit Tests**: SDK service logic
- **Widget Tests**: UI components
- **Integration Tests**: End-to-end scenarios
- **Mock Tests**: BLE communication

---

## 📦 Test Dependencies

Add to `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  flutter_bloc_test: ^9.1.0
  integration_test:
    sdk: flutter
```

---

## 🔧 Unit Testing

### Test: SDK Initialization

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

void main() {
  group('KGiTONScaleService', () {
    late KGiTONScaleService sdk;

    setUp(() {
      sdk = KGiTONScaleService();
    });

    tearDown(() {
      sdk.dispose();
    });

    test('should initialize with disconnected state', () {
      expect(sdk.isConnected, false);
    });

    test('should emit initial weight as null', () async {
      final weight = await sdk.weightStream.first;
      expect(weight, isNull);
    });

    test('should validate license key format', () {
      expect(
        () => sdk.validateLicenseKey(''),
        throwsA(isA<InvalidLicenseException>()),
      );
    });
  });
}
```

### Test: Weight Data Processing

```dart
void main() {
  group('WeightData', () {
    test('should parse weight correctly', () {
      final data = WeightData.fromRaw('12.345');
      
      expect(data.rawWeight, 12.345);
      expect(data.displayWeight, '12.345 kg');
    });

    test('should handle invalid weight format', () {
      expect(
        () => WeightData.fromRaw('invalid'),
        throwsA(isA<WeightParsingException>()),
      );
    });

    test('should apply weight threshold', () {
      final data = WeightData.fromRaw('0.001');
      
      expect(data.isSignificant(threshold: 0.01), false);
      expect(data.isSignificant(threshold: 0.0001), true);
    });
  });
}
```

---

## 🎨 Widget Testing

### Test: Weight Display Widget

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeightCard Widget', () {
    testWidgets('should display weight', (tester) async {
      final weight = WeightData(rawWeight: 12.5, timestamp: DateTime.now());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeightCard(weight: weight),
          ),
        ),
      );

      expect(find.text('12.500 kg'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
    });

    testWidgets('should show zero when weight is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeightCard(weight: null),
          ),
        ),
      );

      expect(find.text('0.000 kg'), findsOneWidget);
    });

    testWidgets('should trigger callback on tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeightCard(
              weight: null,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(WeightCard));
      expect(tapped, true);
    });
  });
}
```

### Test: Device List Widget

```dart
void main() {
  group('DeviceCard Widget', () {
    testWidgets('should display device info', (tester) async {
      final device = ScaleDevice(
        id: '00:11:22:33:44:55',
        name: 'KGiTON-001',
        rssi: -75,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceCard(
              device: device,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('KGiTON-001'), findsOneWidget);
      expect(find.text(contains('-75 dBm')), findsOneWidget);
    });

    testWidgets('should show connected indicator', (tester) async {
      final device = ScaleDevice(
        id: '00:11:22:33:44:55',
        name: 'KGiTON-001',
        rssi: -75,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeviceCard(
              device: device,
              onTap: () {},
              isConnected: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
```

---

## 🔌 Mocking BLE

### Create Mock SDK

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

@GenerateMocks([KGiTONScaleService])
void main() {}

// Run: flutter pub run build_runner build
```

### Use Mock in Tests

```dart
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'sdk_test.mocks.dart';

void main() {
  group('Mocked SDK Tests', () {
    late MockKGiTONScaleService mockSdk;

    setUp(() {
      mockSdk = MockKGiTONScaleService();
    });

    test('should connect with license key', () async {
      when(mockSdk.connectWithLicenseKey(
        deviceId: anyNamed('deviceId'),
        licenseKey: anyNamed('licenseKey'),
      )).thenAnswer((_) async => true);

      final result = await mockSdk.connectWithLicenseKey(
        deviceId: '00:11:22:33:44:55',
        licenseKey: 'TEST-LICENSE-KEY',
      );

      expect(result, true);
      verify(mockSdk.connectWithLicenseKey(
        deviceId: '00:11:22:33:44:55',
        licenseKey: 'TEST-LICENSE-KEY',
      )).called(1);
    });

    test('should emit weight stream', () async {
      final weightStream = Stream.fromIterable([
        WeightData(rawWeight: 10.5, timestamp: DateTime.now()),
        WeightData(rawWeight: 11.0, timestamp: DateTime.now()),
      ]);

      when(mockSdk.weightStream).thenAnswer((_) => weightStream);

      final weights = await mockSdk.weightStream.take(2).toList();

      expect(weights.length, 2);
      expect(weights[0].rawWeight, 10.5);
      expect(weights[1].rawWeight, 11.0);
    });
  });
}
```

---

## 🧩 Integration Testing

### Test: Full Connection Flow

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Tests', () {
    testWidgets('Full connection and weight reading flow', (tester) async {
      await tester.pumpWidget(const MyApp());

      // Wait for app to load
      await tester.pumpAndSettle();

      // Tap scan button
      await tester.tap(find.byIcon(Icons.bluetooth));
      await tester.pumpAndSettle();

      // Wait for devices to appear
      await tester.pump(const Duration(seconds: 5));

      // Tap first device
      await tester.tap(find.byType(DeviceCard).first);
      await tester.pumpAndSettle();

      // Verify connection status
      expect(find.text('Connected'), findsOneWidget);

      // Wait for weight data
      await tester.pump(const Duration(seconds: 2));

      // Verify weight is displayed
      expect(find.textContaining('kg'), findsOneWidget);
    });
  });
}
```

---

## 📊 Test Coverage

### Generate Coverage Report

```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html
```

### Coverage Goals
- **Minimum**: 80% code coverage
- **Target**: 90% code coverage
- **Critical paths**: 100% coverage

---

## ✅ Test Checklist

- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] Integration tests pass
- [ ] Code coverage ≥ 80%
- [ ] No memory leaks
- [ ] Performance benchmarks met
- [ ] Error scenarios covered
- [ ] Edge cases tested

---

## 🔍 Performance Testing

```dart
void main() {
  test('Weight processing performance', () {
    final stopwatch = Stopwatch()..start();
    
    for (int i = 0; i < 1000; i++) {
      WeightData.fromRaw('${i.toDouble()}');
    }
    
    stopwatch.stop();
    
    expect(stopwatch.elapsedMilliseconds, lessThan(100));
  });
}
```

---

## 📚 Related Documentation

- [Best Practices](10-best-practices.md)
- [Troubleshooting](11-troubleshooting.md)
- [Complete Examples](12-complete-examples.md)

---

© 2025 PT KGiTON. All rights reserved.
