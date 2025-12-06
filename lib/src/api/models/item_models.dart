/// Item model
class Item {
  final String id;
  final String licenseId;
  final String name;
  final String unit;
  final double price;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Item({
    required this.id,
    required this.licenseId,
    required this.name,
    required this.unit,
    required this.price,
    required this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      licenseId: json['license_id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'license_id': licenseId,
      'name': name,
      'unit': unit,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

/// Item list data
class ItemListData {
  final List<Item> items;
  final int count;

  ItemListData({required this.items, required this.count});

  factory ItemListData.fromJson(Map<String, dynamic> json) {
    return ItemListData(items: (json['items'] as List).map((e) => Item.fromJson(e as Map<String, dynamic>)).toList(), count: json['count'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'items': items.map((e) => e.toJson()).toList(), 'count': count};
  }
}

/// Create item request
class CreateItemRequest {
  final String licenseKey;
  final String name;
  final String unit;
  final double price;

  CreateItemRequest({required this.licenseKey, required this.name, required this.unit, required this.price});

  Map<String, dynamic> toJson() {
    return {'license_key': licenseKey, 'name': name, 'unit': unit, 'price': price};
  }
}

/// Update item request
class UpdateItemRequest {
  final String? name;
  final String? unit;
  final double? price;

  UpdateItemRequest({this.name, this.unit, this.price});

  Map<String, dynamic> toJson() {
    return {if (name != null) 'name': name, if (unit != null) 'unit': unit, if (price != null) 'price': price};
  }
}
