# Cart Logic Guide

## Overview

KGiTON SDK menggunakan **backend-first approach** untuk semua operasi cart. Semua data cart disimpan di backend, dan aplikasi hanya perlu call SDK methods untuk berinteraksi dengan cart.

⚠️ **Important Changes (v1.1.0):**
- `processCart()` now **auto-clears** cart by default after successful transaction
- Added support for `paymentMethod`, `notes`, and `autoClear` parameters
- UPSERT behavior: adding same item **adds quantity** (not replace)

## Key Concepts

### 1. Cart ID
- Cart diidentifikasi dengan UUID yang unik
- Generate cart ID sekali per session menggunakan package `uuid`
- Semua item dalam satu cart menggunakan cart ID yang sama
- Cart ID dapat di-reuse selama belum di-process (checkout)
- **Generate new cart ID** after successful checkout

```dart
import 'package:uuid/uuid.dart';

final cartId = Uuid().v4(); // Generate once per session
```

### 2. Backend Handles All Logic

**Backend bertanggung jawab untuk:**
- ✅ Menyimpan cart items
- ✅ UPSERT logic (add quantity if item exists)
- ✅ Validasi item ownership (license key matching)
- ✅ Calculate totals (subtotal, processing fee, grand total)
- ✅ **Auto-clear cart after transaction (NEW)**

**Aplikasi hanya perlu:**
- ✅ Call SDK methods
- ✅ Handle UI state
- ✅ Reload cart dari backend setelah operasi add/update/remove
- ✅ Clear local state after checkout

### 3. UPSERT Behavior

⚠️ **Critical: `addToCart()` uses UPSERT logic**

When adding item that **already exists** in cart (same `cart_id` AND `item_id`):
- Backend **ADDS** quantity to existing quantity
- Backend does NOT replace or create duplicate

**Example 1: New Item**
```dart
// Cart kosong
await addToCart(itemId: 'A', quantity: 2.0);
// Result: Item A quantity = 2.0
```

**Example 2: Adding to Existing Item (UPSERT)**
```dart
// Cart: Item A quantity = 2.0
await addToCart(itemId: 'A', quantity: 1.5);
// Result: Item A quantity = 3.5 (2.0 + 1.5) ⚠️ ADDED, not replaced!
```

**Example 3: Multiple Different Items**
```dart
await addToCart(itemId: 'A', quantity: 2.0);  // Item A: 2.0
await addToCart(itemId: 'B', quantity: 1.0);  // Item B: 1.0
await addToCart(itemId: 'A', quantity: 1.5);  // Item A: 3.5 (UPSERT!)
await addToCart(itemId: 'C', quantity: 3.5);  // Item C: 3.5
// Result: 3 items (A=3.5, B=1.0, C=3.5)
```

**To SET specific quantity (not add):**
```dart
// Use updateCartItem instead
await updateCartItem(
  cartItemId: cartItemId,
  quantity: 5.0, // Sets to 5.0, not adds 5.0
);
```

## Complete Workflow

### Step 1: Generate Cart ID
```dart
import 'package:uuid/uuid.dart';

class ScaleScreen extends StatefulWidget {
  // ...
}

class _ScaleScreenState extends State<ScaleScreen> {
  late final String _cartId;

  @override
  void initState() {
    super.initState();
    _cartId = Uuid().v4(); // Generate once
  }
}
```

### Step 2: Add Items to Cart

```dart
Future<void> addItemToCart(String itemId, double quantity) async {
  try {
    // Add item to backend
    final cartItem = await apiService.cart.addToCart(
      cartId: _cartId,
      licenseKey: _licenseKey,
      itemId: itemId,
      quantity: quantity,
      notes: 'Optional notes',
    );
    
    print('Item added: ${cartItem.cartItemId}');
    
    // Reload cart from backend to get updated state
    await loadCart();
    
  } catch (e) {
    print('Error adding item: $e');
  }
}
```

### Step 3: View Cart

```dart
Future<void> loadCart() async {
  try {
    final cartData = await apiService.cart.viewCart(
      cartId: _cartId,
      licenseKey: _licenseKey, // Optional filter
    );
    
    print('Total items: ${cartData.summary.totalItems}');
    print('Total quantity: ${cartData.summary.totalQuantity}');
    print('Subtotal: ${cartData.summary.subtotal}');
    print('Processing fee: ${cartData.summary.processingFee}');
    print('Grand total: ${cartData.summary.grandTotal}');
    
    for (var item in cartData.items) {
      print('- ${item.item.name}: ${item.quantity} ${item.item.unit}');
    }
    
  } catch (e) {
    if (e.toString().contains('Cart is empty')) {
      print('Cart is empty');
    } else {
      print('Error loading cart: $e');
    }
  }
}
```

### Step 4: Update Item Quantity (Optional)

```dart
Future<void> updateItemQuantity(String cartItemId, double newQuantity) async {
  try {
    final updatedItem = await apiService.cart.updateCartItem(
      cartItemId: cartItemId,
      quantity: newQuantity, // Set new quantity (not add)
    );
    
    print('Updated: ${updatedItem.item.name} to ${updatedItem.quantity}');
    
    // Reload cart
    await loadCart();
    
  } catch (e) {
    print('Error updating item: $e');
  }
}
```

### Step 5: Remove Item (Optional)

```dart
Future<void> removeItem(String cartItemId) async {
  try {
    await apiService.cart.removeCartItem(cartItemId);
    print('Item removed');
    
    // Reload cart
    await loadCart();
    
  } catch (e) {
    print('Error removing item: $e');
  }
}
```

### Step 6: Process Cart (Checkout)

⚠️ **NEW in v1.1.0: Auto-clear by default**

**Option A: Default Auto-Clear (Recommended)**
```dart
Future<void> checkout() async {
  try {
    // Backend auto-clears cart after successful transaction
    final result = await apiService.cart.processCart(
      cartId: _cartId,
      licenseKey: _licenseKey,
      paymentMethod: 'qris',      // Optional
      notes: 'Order from mobile', // Optional
      // autoClear: true (default)
    );
    
    print('✅ Transaction ID: ${result.transactionId}');
    print('✅ Cart auto-cleared by backend');
    
    // Clear local state only
    setState(() {
      _cartItems.clear();
      _cartId = Uuid().v4(); // New cart ID for next session
    });
    
  } catch (e) {
    print('❌ Checkout failed: $e');
### ✅ DO

1. **Always reload cart after adding/updating/removing items**
   ```dart
   await apiService.cart.addToCart(...);
   await loadCart(); // Get latest state from backend
   ```

2. **Use try-catch for all cart operations**
   ```dart
   try {
     await apiService.cart.addToCart(...);
   } catch (e) {
     // Handle error
   }
   ```

3. **Generate cart ID once per session**
   ```dart
   late final String _cartId;
   
   @override
   void initState() {
     super.initState();
     _cartId = Uuid().v4();
   }
   ```

4. **Handle empty cart gracefully**
   ```dart
   try {
     final cart = await apiService.cart.viewCart(...);
   } catch (e) {
     if (e.toString().contains('Cart is empty')) {
       // Show empty cart UI
     }
   }
   ```

5. **Use same cart ID for all items in one transaction**
   ```dart
   final cartId = Uuid().v4();
   await addToCart(cartId: cartId, itemId: 'A', ...);
   await addToCart(cartId: cartId, itemId: 'B', ...);
   await processCart(cartId: cartId);
   ```

### ❌ DON'T

1. **Don't maintain local cart state that's out of sync with backend**
   ```dart
   // ❌ Bad: Local state may be out of sync
   List<CartItem> _localCart = [];
   _localCart.add(newItem); // Not synced with backend
   
   // ✅ Good: Always load from backend
   await loadCart(); // Get from backend
   ```

2. **Don't assume item quantity is replaced when adding (UPSERT!)**
   ```dart
   // ❌ Bad assumption - UPSERT adds quantity!
   await addToCart(itemId: 'A', quantity: 2.0);  // Item A = 2.0
   await addToCart(itemId: 'A', quantity: 3.0);  // Item A = 5.0 (ADDED!)
   
   // ✅ To set specific quantity, use updateCartItem
   await updateCartItem(cartItemId: id, quantity: 3.0); // Sets to 3.0
   ```

3. **Don't reuse cart ID after checkout**
   ```dart
   // ❌ Bad: Reusing cart ID after transaction
   await processCart(cartId: cartId);
   await addToCart(cartId: cartId, ...); // Don't reuse!
   
   // ✅ Good: Generate new cart ID
   await processCart(cartId: cartId);
   cartId = Uuid().v4(); // New cart ID
   await addToCart(cartId: cartId, ...);
   ```

4. **Don't manually clear after processCart (unless autoClear=false)**
   ```dart
   // ❌ Bad: Redundant manual clear
   await processCart(cartId: cartId); // Auto-clears by default
   await clearCartByLicense(licenseKey: key); // Unnecessary!
   
   // ✅ Good: Trust auto-clear
   await processCart(cartId: cartId);
   setState(() => _cartItems.clear()); // Clear local only
   ```

5. **Don't forget to handle errors**
   ```dart
   // ❌ Bad: No error handling
   final cart = await apiService.cart.viewCart(...);
   
   // ✅ Good: Always handle errors
   try {
     final cart = await apiService.cart.viewCart(...);
   } catch (e) {
     // Handle error
   }
   ```it processCart(cartId: cartId);
   ```

### ❌ DON'T

1. **Don't maintain local cart state that's out of sync with backend**
   ```dart
   // ❌ Bad: Local state may be out of sync
   List<CartItem> _localCart = [];
   _localCart.add(newItem); // Not synced with backend
   
   // ✅ Good: Always load from backend
   await loadCart(); // Get from backend
   ```

2. **Don't assume item quantity is replaced when adding**
   ```dart
   // ❌ Bad assumption
   await addToCart(itemId: 'A', quantity: 2.0);
   await addToCart(itemId: 'A', quantity: 3.0); // Quantity becomes 5.0, not 3.0!
   
   // ✅ If you want to set specific quantity, use updateCartItem
   await updateCartItem(cartItemId: id, quantity: 3.0);
   ```

3. **Don't reuse cart ID after checkout**
   ```dart
   // ❌ Bad: Reusing cart ID after transaction
   await processCart(cartId: cartId);
   await addToCart(cartId: cartId, ...); // Don't reuse!
   
   // ✅ Good: Generate new cart ID
   await processCart(cartId: cartId);
   cartId = Uuid().v4(); // New cart ID
   await addToCart(cartId: cartId, ...);
   ```

4. **Don't forget to handle errors**
   ```dart
   // ❌ Bad: No error handling
   final cart = await apiService.cart.viewCart(...);
   
   // ✅ Good: Always handle errors
   try {
     final cart = await apiService.cart.viewCart(...);
   } catch (e) {
     // Handle error
   }
   ```

## Common Patterns

### Pattern 1: Add Item with Confirmation

```dart
Future<void> addItemWithConfirmation(String itemId, double quantity) async {
  // Show loading
  showLoadingDialog();
  
  try {
    // Add to backend
    await apiService.cart.addToCart(
      cartId: _cartId,
      licenseKey: _licenseKey,
      itemId: itemId,
      quantity: quantity,
    );
    
    // Reload from backend
    await loadCart();
    
    // Show success
    showSuccessMessage('Item added to cart');
    
  } catch (e) {
    // Show error
    showErrorMessage('Failed to add item: $e');
  } finally {
    // Hide loading
    hideLoadingDialog();
  }
}
```

### Pattern 2: View Cart with Empty State

```dart
Future<void> viewCartBottomSheet() async {
  try {
    final cart = await apiService.cart.viewCart(
      cartId: _cartId,
      licenseKey: _licenseKey,
    );
    
    // Show bottom sheet with items
    showModalBottomSheet(
      context: context,
      builder: (context) => CartBottomSheet(
        items: cart.items,
        summary: cart.summary,
        onCheckout: () => checkout(),
      ),
    );
    
  } catch (e) {
    if (e.toString().contains('Cart is empty')) {
      // Show empty cart UI
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Cart Kosong'),
          content: Text('Belum ada item di keranjang'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Show error
      showErrorMessage('Error loading cart: $e');
    }
  }
}
```

### Pattern 3: Checkout with Confirmation

```dart
Future<void> checkoutWithConfirmation() async {
  // Load cart first to show summary
  final cart = await apiService.cart.viewCart(
    cartId: _cartId,
    licenseKey: _licenseKey,
  );
  
  // Show confirmation dialog
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Konfirmasi Checkout'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Total Items: ${cart.summary.totalItems}'),
          Text('Grand Total: Rp ${cart.summary.grandTotal}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Checkout'),
        ),
      ],
    ),
  );
  
  if (confirmed != true) return;
  
  // Show loading
  showLoadingDialog();
  
  try {
    // Process cart
    final result = await apiService.cart.processCart(
      cartId: _cartId,
      licenseKey: _licenseKey,
    );
    
    // Hide loading
    hideLoadingDialog();
    
    // Show success with transaction details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Checkout Berhasil!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Transaction ID: ${result.transactionId}'),
            Text('Total: Rp ${result.total}'),
            Text('Items: ${result.itemCount}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
    
    // Generate new cart ID
    setState(() {
      _cartId = Uuid().v4();
    });
    
  } catch (e) {
    hideLoadingDialog();
    showErrorMessage('Checkout failed: $e');
  }
}
```

## Troubleshooting

### Issue: Cart items not showing after add

**Cause:** Not reloading cart from backend after adding item

**Solution:**
```dart
await apiService.cart.addToCart(...);
await loadCart(); // Add this line
```

### Issue: Quantity keeps increasing unexpectedly

**Cause:** `addToCart` adds quantity to existing item (UPSERT behavior)

**Solution:** Use `updateCartItem` to set specific quantity
```dart
// To set quantity to 5.0 (not add 5.0)
await apiService.cart.updateCartItem(
  cartItemId: cartItemId,
  quantity: 5.0,
);
```

### Issue: Error "Cart is empty" when viewing cart

**Cause:** No items added to cart yet, or cart was already processed

**Solution:** Handle empty cart case
```dart
try {
  final cart = await apiService.cart.viewCart(...);
} catch (e) {
  if (e.toString().contains('Cart is empty')) {
    // Show empty cart UI
  }
}
```

### Issue: Error "Item not found" when adding to cart
## Summary

### Core Principles
- ✅ Backend handles all cart logic
- ✅ Always reload cart after operations
- ✅ Trust backend as single source of truth

### UPSERT Behavior ⚠️
- ✅ `addToCart` does UPSERT: **adds quantity** if item exists
- ✅ Use `updateCartItem` to **set** specific quantity (not add)

### Cart Lifecycle
- ✅ Use same cart ID for all items in one transaction
- ✅ Generate new cart ID after successful checkout
- ✅ Don't reuse cart ID after transaction

### Auto-Clear (NEW in v1.1.0) ⚠️
- ✅ `processCart()` **auto-clears** cart by default
- ✅ Set `autoClear: false` only if you need manual control
- ✅ Don't call `clearCartByLicense()` after `processCart()` (redundant)

### Best Practices
- ✅ Handle errors gracefully
- ✅ Clear local state after checkout
- ✅ Reload cart from backend to get latest statense key
  price: 10000,
  unit: 'kg',
);

// Then add to cart with same license key
await apiService.cart.addToCart(
  cartId: _cartId,
  licenseKey: _licenseKey, // Same license key
  itemId: itemId,
  quantity: 1.0,
);
```

## Summary

- ✅ Backend handles all cart logic
- ✅ Always reload cart after operations
- ✅ `addToCart` does UPSERT (add or increment quantity)
- ✅ Use same cart ID for all items in one transaction
- ✅ Generate new cart ID after checkout
- ✅ Handle errors gracefully
- ✅ Trust backend as single source of truth
