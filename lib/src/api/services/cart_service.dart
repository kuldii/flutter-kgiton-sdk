import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/cart_models.dart';

/// Cart Service
///
/// Provides methods for cart operations:
/// - Add item to cart
/// - View cart
/// - Update cart item quantity
/// - Remove item from cart
/// - Clear cart
/// - Process cart (create transaction)
class KgitonCartService {
  final KgitonApiClient _client;

  KgitonCartService(this._client);

  /// Add an item to the cart
  ///
  /// [cartId] - UUID of the cart (generate with uuid package)
  /// [licenseKey] - License key associated with the item
  /// [itemId] - ID of the item to add
  /// [quantity] - Quantity to add
  /// [notes] - Optional notes for the item
  ///
  /// Returns the added [CartItem]
  ///
  /// Note: If the same item already exists in the cart,
  /// the quantity will be added to the existing quantity
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if validation fails
  /// - [KgitonNotFoundException] if item or license not found
  /// - [KgitonApiException] for other errors
  Future<CartItem> addToCart({
    required String cartId,
    required String licenseKey,
    required String itemId,
    required double quantity,
    String? notes,
  }) async {
    final request = AddToCartRequest(cartId: cartId, licenseKey: licenseKey, itemId: itemId, quantity: quantity, notes: notes);

    final response = await _client.post<CartItem>(
      KgitonApiEndpoints.addToCart,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => CartItem.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to add item to cart: ${response.message}');
    }

    return response.data!;
  }

  /// View cart contents
  ///
  /// [cartId] - UUID of the cart
  /// [licenseKey] - Optional: filter items by license key
  ///
  /// Returns [CartData] containing cart items and summary
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if cart is empty or not found
  /// - [KgitonApiException] for other errors
  Future<CartData> viewCart({required String cartId, String? licenseKey}) async {
    final queryParams = <String, String>{'cart_id': cartId};

    if (licenseKey != null) {
      queryParams['license_key'] = licenseKey;
    }

    final response = await _client.get<CartData>(
      KgitonApiEndpoints.viewCart,
      queryParameters: queryParams,
      requiresAuth: true,
      fromJsonT: (json) => CartData.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to view cart: ${response.message}');
    }

    return response.data!;
  }

  /// Update cart item quantity
  ///
  /// [cartItemId] - ID of the cart item to update
  /// [quantity] - New quantity
  /// [notes] - Optional new notes
  ///
  /// Returns the updated [CartItem]
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if cart item not found
  /// - [KgitonValidationException] if validation fails
  /// - [KgitonApiException] for other errors
  Future<CartItem> updateCartItem({required String cartItemId, required double quantity, String? notes}) async {
    final request = UpdateCartItemRequest(quantity: quantity, notes: notes);

    final response = await _client.put<CartItem>(
      KgitonApiEndpoints.updateCartItem(cartItemId),
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => CartItem.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to update cart item: ${response.message}');
    }

    return response.data!;
  }

  /// Remove a specific item from cart
  ///
  /// [cartItemId] - ID of the cart item to remove
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if cart item not found
  /// - [KgitonApiException] for other errors
  Future<void> removeCartItem(String cartItemId) async {
    final response = await _client.delete(KgitonApiEndpoints.removeFromCart(cartItemId), requiresAuth: true);

    if (!response.success) {
      throw Exception('Failed to remove cart item: ${response.message}');
    }
  }

  /// Clear entire cart
  ///
  /// [cartId] - UUID of the cart to clear
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<void> clearCart(String cartId) async {
    final response = await _client.delete(KgitonApiEndpoints.clearCart, requiresAuth: true);

    if (!response.success) {
      throw Exception('Failed to clear cart: ${response.message}');
    }
  }

  /// Clear all cart items for a specific license key
  ///
  /// ⚠️ **Note**: You typically don't need to call this manually.
  /// The `processCart()` method automatically clears the cart after successful transaction.
  ///
  /// [licenseKey] - License key to clear carts for
  ///
  /// Use this method only if you need to manually clear cart without processing:
  /// ```dart
  /// // Clear cart without creating transaction (e.g., user wants to start over)
  /// await cartService.clearCartByLicense(licenseKey: licenseKey);
  /// ```
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if license_key is missing
  /// - [KgitonApiException] for other errors
  Future<void> clearCartByLicense({required String licenseKey}) async {
    final response = await _client.delete(KgitonApiEndpoints.clearCartByLicense, body: {'license_key': licenseKey}, requiresAuth: true);

    if (!response.success) {
      throw Exception('Failed to clear cart by license: ${response.message}');
    }
  }

  /// Process cart and create transaction
  ///
  /// [cartId] - UUID of the cart to process
  /// [licenseKey] - License key for the transaction
  ///
  /// Returns [ProcessCartData] containing transaction details
  ///
  /// ✅ This method automatically clears the cart after successful transaction creation.
  ///
  /// This method will:
  /// 1. Create a transaction with all cart items
  /// 2. Add processing fee
  /// 3. **Automatically clear cart** from backend (using clearCartByLicense)
  /// 4. Return transaction details
  ///
  /// If transaction creation fails, cart will NOT be cleared (user can retry).
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final result = await cartService.processCart(
  ///     cartId: cartId,
  ///     licenseKey: licenseKey,
  ///   );
  ///
  ///   // Cart is already cleared from backend ✅
  ///   print('Transaction: ${result.transactionId}');
  ///
  ///   // Just clear local state
  ///   setState(() => _cartItems.clear());
  /// } catch (e) {
  ///   print('Checkout failed: $e');
  ///   // Cart NOT cleared - user can retry
  /// }
  /// ```
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if cart is empty or not found
  /// - [KgitonValidationException] if validation fails
  /// - [KgitonApiException] for other errors
  Future<ProcessCartData> processCart({required String cartId, required String licenseKey}) async {
    final request = ProcessCartRequest(cartId: cartId, licenseKey: licenseKey);

    final response = await _client.post<ProcessCartData>(
      KgitonApiEndpoints.processCart,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => ProcessCartData.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw Exception('Failed to process cart: ${response.message}');
    }

    // Automatically clear cart after successful transaction
    await clearCartByLicense(licenseKey: licenseKey);

    return response.data!;
  }
}
