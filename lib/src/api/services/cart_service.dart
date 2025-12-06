import '../api_constants.dart';
import '../kgiton_api_client.dart';
import '../models/cart_models.dart';
import '../exceptions/api_exceptions.dart';

/// Cart Service
///
/// Provides methods for shopping cart operations:
/// - Add item to cart
/// - Get cart items by license key
/// - Get cart summary
/// - Get single cart item
/// - Update cart item
/// - Delete single cart item
/// - Delete all items by license key (clear cart)
///
/// Example usage:
/// ```dart
/// // Add item to cart
/// final cartItem = await cartService.addItemToCart(
///   AddCartRequest(
///     licenseKey: 'ABC123',
///     itemId: 'item-uuid',
///     quantity: 2.5,
///     quantityPcs: 10,
///     notes: 'Extra fresh',
///   ),
/// );
///
/// // Get cart items
/// final cartItems = await cartService.getCartItems('ABC123');
///
/// // Get cart summary
/// final summary = await cartService.getCartSummary('ABC123');
///
/// // Update cart item
/// await cartService.updateCartItem(
///   'cart-item-id',
///   UpdateCartRequest(quantity: 3.0, quantityPcs: 15),
/// );
///
/// // Clear cart after checkout
/// await cartService.deleteAllByLicenseKey('ABC123');
/// ```
class KgitonCartService {
  final KgitonApiClient _client;

  KgitonCartService(this._client);

  /// Add item to cart or update if already exists
  ///
  /// [request] - Add cart request with license key, item id, quantity, etc.
  ///
  /// Returns the created or updated [CartItem]
  ///
  /// Behavior with [forceNew] parameter:
  /// - `forceNew: true` → Always create new entry (ideal for scale app with multiple weighings)
  /// - `forceNew: false` or `null` → Update existing if found, create new if not exists (default behavior)
  ///
  /// Use Cases:
  /// - **Scale App**: Use `forceNew: true` to create new entry for each weighing,
  ///   allowing users to see history of multiple weighings for the same item.
  /// - **E-commerce App**: Use `forceNew: false` or omit parameter to update
  ///   quantity of existing cart item.
  ///
  /// Example:
  /// ```dart
  /// // Scale app - multiple weighings
  /// await addItemToCart(AddCartRequest(
  ///   licenseKey: 'ABC123',
  ///   itemId: 'orange-uuid',
  ///   quantity: 0.5,
  ///   notes: 'First weighing',
  ///   forceNew: true, // Creates new entry
  /// ));
  ///
  /// await addItemToCart(AddCartRequest(
  ///   licenseKey: 'ABC123',
  ///   itemId: 'orange-uuid',
  ///   quantity: 0.3,
  ///   notes: 'Second weighing',
  ///   forceNew: true, // Creates another new entry
  /// ));
  /// // Result: 2 separate cart entries for oranges
  ///
  /// // E-commerce app - update quantity
  /// await addItemToCart(AddCartRequest(
  ///   licenseKey: 'ABC123',
  ///   itemId: 'apple-uuid',
  ///   quantity: 2.0,
  /// )); // Creates new entry
  ///
  /// await addItemToCart(AddCartRequest(
  ///   licenseKey: 'ABC123',
  ///   itemId: 'apple-uuid',
  ///   quantity: 3.0,
  /// )); // Updates quantity to 3.0
  /// // Result: 1 cart entry with updated quantity
  /// ```
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if validation fails (quantity <= 0)
  /// - [KgitonNotFoundException] if item not found
  /// - [KgitonApiException] for other errors
  Future<CartItem> addItemToCart(AddCartRequest request) async {
    // Validate request
    if (!request.isValid()) {
      throw KgitonValidationException(message: 'Invalid cart request: quantity must be greater than 0');
    }

    final response = await _client.post<CartItem>(
      KgitonApiEndpoints.addToCart,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => CartItem.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to add item to cart: ${response.message}');
    }

    return response.data!;
  }

  /// Get all cart items for a specific license key
  ///
  /// [licenseKey] - The license key to filter cart items
  ///
  /// Returns list of [CartItem] with item details included
  ///
  /// Note: Results are sorted by created_at descending (newest first)
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<List<CartItem>> getCartItems(String licenseKey) async {
    final endpoint = KgitonApiEndpoints.getCartByLicenseKey(licenseKey);

    final response = await _client.get<List<CartItem>>(
      endpoint,
      requiresAuth: true,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
        }
        throw KgitonApiException(message: 'Invalid response format for cart items');
      },
    );

    if (!response.success) {
      throw KgitonApiException(message: 'Failed to get cart items: ${response.message}');
    }

    return response.data ?? [];
  }

  /// Get cart summary including total items and estimated total price
  ///
  /// [licenseKey] - The license key to filter cart items
  ///
  /// Returns [CartSummary] with total items, estimated total, and items list
  ///
  /// Estimated total is calculated as:
  /// - (quantity × item.price) + (quantity_pcs × item.price_per_pcs)
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<CartSummary> getCartSummary(String licenseKey) async {
    final endpoint = KgitonApiEndpoints.getCartSummary(licenseKey);

    final response = await _client.get<CartSummary>(
      endpoint,
      requiresAuth: true,
      fromJsonT: (json) => CartSummary.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to get cart summary: ${response.message}');
    }

    return response.data!;
  }

  /// Get single cart item by ID
  ///
  /// [cartItemId] - The cart item ID (UUID)
  ///
  /// Returns [CartItem] with item details included
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if cart item not found
  /// - [KgitonApiException] for other errors
  Future<CartItem> getCartItem(String cartItemId) async {
    final endpoint = KgitonApiEndpoints.getCartItem(cartItemId);

    final response = await _client.get<CartItem>(endpoint, requiresAuth: true, fromJsonT: (json) => CartItem.fromJson(json as Map<String, dynamic>));

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to get cart item: ${response.message}');
    }

    return response.data!;
  }

  /// Update cart item quantity or notes
  ///
  /// [cartItemId] - The cart item ID to update
  /// [request] - Update request with new quantity, quantity_pcs, or notes
  ///
  /// Returns the updated [CartItem]
  ///
  /// Note: At least one field (quantity, quantity_pcs, or notes) must be provided
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonValidationException] if validation fails
  /// - [KgitonNotFoundException] if cart item not found
  /// - [KgitonApiException] for other errors
  Future<CartItem> updateCartItem(String cartItemId, UpdateCartRequest request) async {
    // Validate request
    if (!request.isValid()) {
      throw KgitonValidationException(message: 'Invalid update request: at least one field must be provided and values must be greater than 0');
    }

    final endpoint = KgitonApiEndpoints.updateCartItem(cartItemId);

    final response = await _client.put<CartItem>(
      endpoint,
      body: request.toJson(),
      requiresAuth: true,
      fromJsonT: (json) => CartItem.fromJson(json as Map<String, dynamic>),
    );

    if (!response.success || response.data == null) {
      throw KgitonApiException(message: 'Failed to update cart item: ${response.message}');
    }

    return response.data!;
  }

  /// Delete a single cart item
  ///
  /// [cartItemId] - The cart item ID to delete
  ///
  /// Returns true if deletion was successful
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonNotFoundException] if cart item not found
  /// - [KgitonApiException] for other errors
  Future<bool> deleteCartItem(String cartItemId) async {
    final endpoint = KgitonApiEndpoints.deleteCartItem(cartItemId);

    final response = await _client.delete(endpoint, requiresAuth: true);

    if (!response.success) {
      throw KgitonApiException(message: 'Failed to delete cart item: ${response.message}');
    }

    return true;
  }

  /// Delete all cart items for a specific license key (clear cart)
  ///
  /// [licenseKey] - The license key to clear cart for
  ///
  /// Returns true if deletion was successful
  ///
  /// Note: This is typically used after successful checkout/transaction creation
  /// Does not throw error if cart is empty (0 items deleted)
  ///
  /// Throws:
  /// - [KgitonAuthenticationException] if not authenticated
  /// - [KgitonApiException] for other errors
  Future<bool> deleteAllByLicenseKey(String licenseKey) async {
    final endpoint = KgitonApiEndpoints.deleteCartByLicenseKey(licenseKey);

    final response = await _client.delete(endpoint, requiresAuth: true);

    if (!response.success) {
      throw KgitonApiException(message: 'Failed to clear cart: ${response.message}');
    }

    return true;
  }

  /// Convenience method: Clear cart after successful checkout
  ///
  /// [licenseKey] - The license key to clear cart for
  ///
  /// This is an alias for [deleteAllByLicenseKey] with a more descriptive name
  Future<bool> clearCartAfterCheckout(String licenseKey) async {
    return deleteAllByLicenseKey(licenseKey);
  }

  /// Convenience method: Get cart item count for a license key
  ///
  /// [licenseKey] - The license key to count items for
  ///
  /// Returns the number of items in the cart
  Future<int> getCartItemCount(String licenseKey) async {
    final summary = await getCartSummary(licenseKey);
    return summary.totalItems;
  }

  /// Convenience method: Check if cart is empty
  ///
  /// [licenseKey] - The license key to check
  ///
  /// Returns true if cart is empty
  Future<bool> isCartEmpty(String licenseKey) async {
    final count = await getCartItemCount(licenseKey);
    return count == 0;
  }
}
