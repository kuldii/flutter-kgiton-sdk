/// Cart item model
class CartItem {
  final String cartItemId;
  final String cartId;
  final CartItemInfo item;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt; // Optional updated_at field

  CartItem({
    required this.cartItemId,
    required this.cartId,
    required this.item,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    try {
      return CartItem(
        cartItemId: json['cart_item_id'] as String,
        cartId: json['cart_id'] as String,
        item: CartItemInfo.fromJson(json['item'] as Map<String, dynamic>),
        quantity: (json['quantity'] as num).toDouble(),
        unitPrice: (json['unit_price'] as num).toDouble(),
        totalPrice: (json['total_price'] as num).toDouble(),
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      );
    } catch (e) {
      print('[CartItem] Error parsing: $e');
      print('[CartItem] JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_item_id': cartItemId,
      'cart_id': cartId,
      'item': item.toJson(),
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      if (notes != null) 'notes': notes,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

/// Cart item info (simplified item)
class CartItemInfo {
  final String id;
  final String name;
  final String unit;
  final double? price; // Optional price field from API response

  CartItemInfo({required this.id, required this.name, required this.unit, this.price});

  factory CartItemInfo.fromJson(Map<String, dynamic> json) {
    try {
      return CartItemInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        unit: json['unit'] as String,
        price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      );
    } catch (e) {
      print('[CartItemInfo] Error parsing: $e');
      print('[CartItemInfo] JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'unit': unit, if (price != null) 'price': price};
  }
}

/// Cart summary
class CartSummary {
  final int totalItems;
  final double totalQuantity;
  final double subtotal;
  final double? processingFee; // Optional processing fee from API
  final double? grandTotal; // Optional grand total from API

  CartSummary({required this.totalItems, required this.totalQuantity, required this.subtotal, this.processingFee, this.grandTotal});

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    try {
      return CartSummary(
        totalItems: json['total_items'] as int,
        totalQuantity: (json['total_quantity'] as num).toDouble(),
        subtotal: (json['subtotal'] as num).toDouble(),
        processingFee: json['processing_fee'] != null ? (json['processing_fee'] as num).toDouble() : null,
        grandTotal: json['grand_total'] != null ? (json['grand_total'] as num).toDouble() : null,
      );
    } catch (e) {
      print('[CartSummary] Error parsing: $e');
      print('[CartSummary] JSON keys: ${json.keys.toList()}');
      print('[CartSummary] JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'total_items': totalItems,
      'total_quantity': totalQuantity,
      'subtotal': subtotal,
      if (processingFee != null) 'processing_fee': processingFee,
      if (grandTotal != null) 'grand_total': grandTotal,
    };
  }
}

/// Cart data with items and summary
class CartData {
  final String cartId;
  final List<CartItem> items;
  final CartSummary summary;

  CartData({required this.cartId, required this.items, required this.summary});

  factory CartData.fromJson(Map<String, dynamic> json) {
    try {
      // Parse cart_id
      final cartId = json['cart_id'] as String;

      // Parse items
      final itemsList = json['items'] as List;
      final items = itemsList.map((e) {
        try {
          return CartItem.fromJson(e as Map<String, dynamic>);
        } catch (itemError) {
          print('[CartData] Error parsing cart item: $itemError');
          print('[CartData] Item data: $e');
          rethrow;
        }
      }).toList();

      // Parse summary
      CartSummary summary;
      try {
        summary = CartSummary.fromJson(json['summary'] as Map<String, dynamic>);
      } catch (summaryError) {
        print('[CartData] Error parsing summary: $summaryError');
        print('[CartData] Summary data: ${json['summary']}');
        rethrow;
      }

      return CartData(cartId: cartId, items: items, summary: summary);
    } catch (e) {
      print('[CartData] Error in fromJson: $e');
      print('[CartData] Full JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'cart_id': cartId, 'items': items.map((e) => e.toJson()).toList(), 'summary': summary.toJson()};
  }
}

/// Process cart result
class ProcessCartData {
  final String transactionId;
  final double subtotal;
  final double processingFee;
  final double total;
  final int itemCount;

  ProcessCartData({required this.transactionId, required this.subtotal, required this.processingFee, required this.total, required this.itemCount});

  factory ProcessCartData.fromJson(Map<String, dynamic> json) {
    return ProcessCartData(
      transactionId: json['transaction_id'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      processingFee: (json['processing_fee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      itemCount: json['item_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'transaction_id': transactionId, 'subtotal': subtotal, 'processing_fee': processingFee, 'total': total, 'item_count': itemCount};
  }
}

/// Add to cart request
class AddToCartRequest {
  final String cartId;
  final String licenseKey;
  final String itemId;
  final double quantity;
  final String? notes;

  AddToCartRequest({required this.cartId, required this.licenseKey, required this.itemId, required this.quantity, this.notes});

  Map<String, dynamic> toJson() {
    return {'cart_id': cartId, 'license_key': licenseKey, 'item_id': itemId, 'quantity': quantity, if (notes != null) 'notes': notes};
  }
}

/// Update cart item request
class UpdateCartItemRequest {
  final double quantity;
  final String? notes;

  UpdateCartItemRequest({required this.quantity, this.notes});

  Map<String, dynamic> toJson() {
    return {'quantity': quantity, if (notes != null) 'notes': notes};
  }
}

/// Process cart request
class ProcessCartRequest {
  final String cartId;
  final String licenseKey;

  ProcessCartRequest({required this.cartId, required this.licenseKey});

  Map<String, dynamic> toJson() {
    return {'cart_id': cartId, 'license_key': licenseKey};
  }
}
