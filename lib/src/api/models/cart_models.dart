import 'item_models.dart';

/// Cart item model
class CartItem {
  final String id;
  final String userId;
  final String licenseKey;
  final String itemId;
  final double quantity;
  final int? quantityPcs;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Item? item; // Optional item details

  CartItem({
    required this.id,
    required this.userId,
    required this.licenseKey,
    required this.itemId,
    required this.quantity,
    this.quantityPcs,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.item,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      licenseKey: json['license_key'] as String,
      itemId: json['item_id'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      quantityPcs: json['quantity_pcs'] as int?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      item: json['item'] != null ? Item.fromJson(json['item'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'license_key': licenseKey,
      'item_id': itemId,
      'quantity': quantity,
      if (quantityPcs != null) 'quantity_pcs': quantityPcs,
      if (notes != null) 'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (item != null) 'item': item!.toJson(),
    };
  }

  /// Calculate estimated price for this cart item
  double calculateEstimatedPrice() {
    if (item == null) return 0.0;

    double total = 0.0;

    // Calculate based on weight
    total += quantity * item!.price;

    // Calculate based on pieces if available
    if (quantityPcs != null && item!.pricePerPcs != null) {
      total += quantityPcs! * item!.pricePerPcs!;
    }

    return total;
  }
}

/// Cart summary model
class CartSummary {
  final int totalItems;
  final double estimatedTotal;
  final List<CartItem> items;

  CartSummary({required this.totalItems, required this.estimatedTotal, required this.items});

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      totalItems: json['total_items'] as int,
      estimatedTotal: (json['estimated_total'] as num).toDouble(),
      items: (json['items'] as List).map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'total_items': totalItems, 'estimated_total': estimatedTotal, 'items': items.map((e) => e.toJson()).toList()};
  }
}

/// Add item to cart request
class AddCartRequest {
  final String licenseKey;
  final String itemId;
  final double quantity;
  final int? quantityPcs;
  final String? notes;
  final bool? forceNew;

  AddCartRequest({required this.licenseKey, required this.itemId, required this.quantity, this.quantityPcs, this.notes, this.forceNew});

  Map<String, dynamic> toJson() {
    return {
      'license_key': licenseKey,
      'item_id': itemId,
      'quantity': quantity,
      if (quantityPcs != null) 'quantity_pcs': quantityPcs,
      if (notes != null) 'notes': notes,
      if (forceNew != null) 'force_new': forceNew,
    };
  }

  /// Validate request data
  bool isValid() {
    return quantity > 0 && (quantityPcs == null || quantityPcs! > 0);
  }
}

/// Update cart item request
class UpdateCartRequest {
  final double? quantity;
  final int? quantityPcs;
  final String? notes;

  UpdateCartRequest({this.quantity, this.quantityPcs, this.notes});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (quantity != null) map['quantity'] = quantity;
    if (quantityPcs != null) map['quantity_pcs'] = quantityPcs;
    if (notes != null) map['notes'] = notes;

    return map;
  }

  /// Validate request data
  bool isValid() {
    // At least one field must be provided
    if (quantity == null && quantityPcs == null && notes == null) {
      return false;
    }

    // Validate quantity if provided
    if (quantity != null && quantity! <= 0) {
      return false;
    }

    // Validate quantityPcs if provided
    if (quantityPcs != null && quantityPcs! <= 0) {
      return false;
    }

    return true;
  }

  /// Check if request has any updates
  bool hasUpdates() {
    return quantity != null || quantityPcs != null || notes != null;
  }
}
