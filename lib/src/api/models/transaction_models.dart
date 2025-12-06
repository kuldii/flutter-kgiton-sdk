import 'api_response.dart' show Pagination;

/// Transaction model
class Transaction {
  final String id;
  final String licenseId;
  final double subtotal;
  final double processingFee;
  final double total;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.licenseId,
    required this.subtotal,
    required this.processingFee,
    required this.total,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      licenseId: json['license_id'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      processingFee: (json['processing_fee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'license_id': licenseId,
      'subtotal': subtotal,
      'processing_fee': processingFee,
      'total': total,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Transaction detail item
class TransactionDetailItem {
  final String id;
  final String transactionId;
  final String itemId;
  final String itemName;
  final String unit;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;

  TransactionDetailItem({
    required this.id,
    required this.transactionId,
    required this.itemId,
    required this.itemName,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
  });

  factory TransactionDetailItem.fromJson(Map<String, dynamic> json) {
    return TransactionDetailItem(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      itemId: json['item_id'] as String,
      itemName: json['item_name'] as String,
      unit: json['unit'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'item_id': itemId,
      'item_name': itemName,
      'unit': unit,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      if (notes != null) 'notes': notes,
    };
  }
}

/// Transaction detail (full transaction with items)
class TransactionDetail {
  final Transaction transaction;
  final List<TransactionDetailItem> items;

  TransactionDetail({required this.transaction, required this.items});

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      transaction: Transaction.fromJson(json['transaction'] as Map<String, dynamic>),
      items: (json['items'] as List).map((e) => TransactionDetailItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'transaction': transaction.toJson(), 'items': items.map((e) => e.toJson()).toList()};
  }
}

/// Transaction list data with pagination
class TransactionListData {
  final List<Transaction> transactions;
  final Pagination pagination;

  TransactionListData({required this.transactions, required this.pagination});

  factory TransactionListData.fromJson(Map<String, dynamic> json) {
    return TransactionListData(
      transactions: (json['transactions'] as List).map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList(),
      pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'transactions': transactions.map((e) => e.toJson()).toList(), 'pagination': pagination.toJson()};
  }
}

// Pagination is exported from api_response.dart
// No need to duplicate here
