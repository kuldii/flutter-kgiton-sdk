# API Response Parsing Fix

## Problem
Error terjadi saat parsing response API:
```
KgitonApiException: Network error: type 'List<dynamic>' is not a subtype of type 'Map<String, dynamic>' in type cast
```

## Root Cause
Backend API mengembalikan response dalam 2 format berbeda:

### Format 1: Array Langsung
```json
{
  "success": true,
  "data": [
    {"id": "1", "name": "Item 1"},
    {"id": "2", "name": "Item 2"}
  ]
}
```

### Format 2: Object dengan Property
```json
{
  "success": true,
  "data": {
    "items": [
      {"id": "1", "name": "Item 1"}
    ],
    "count": 1
  }
}
```

Model SDK hanya mendukung Format 2, sehingga ketika menerima Format 1 (array langsung), terjadi error casting.

## Solution
Update semua model list data untuk mendukung kedua format:

### Updated Models:
1. ✅ **ItemListData** (`item_models.dart`)
2. ✅ **TransactionListData** (`transaction_models.dart`)
3. ✅ **LicenseListData** (`license_models.dart`)
4. ✅ **OwnerLicensesData** (`license_models.dart`)

### Implementation Pattern:
```dart
factory ItemListData.fromJson(dynamic json) {
  // Handle if response is a List directly
  if (json is List) {
    final items = json.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
    return ItemListData(items: items, count: items.length);
  }
  
  // Handle if response is an Object with 'items' property
  if (json is Map<String, dynamic>) {
    return ItemListData(
      items: (json['items'] as List).map((e) => Item.fromJson(e as Map<String, dynamic>)).toList(),
      count: json['count'] as int,
    );
  }
  
  throw FormatException('Invalid ItemListData format');
}
```

## Changes Made:
1. Changed `fromJson` parameter from `Map<String, dynamic>` to `dynamic`
2. Added type checking: `if (json is List)` and `if (json is Map<String, dynamic>)`
3. Handle both formats gracefully
4. Made `pagination` nullable in `TransactionListData` and `LicenseListData`
5. Auto-calculate `count` when receiving array directly

## Testing
```bash
cd flutter/kgiton_sdk
flutter analyze
# No issues found! ✅

cd ../timbangan
flutter analyze
# No issues found! ✅
```

## Version
- **SDK Version**: Updated from 1.0.0 → 1.0.1
- **Fix Type**: CRITICAL - API Response Parsing
- **Date**: 2025-12-06
