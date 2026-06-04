class OrderModel {
  final String id;
  final String buyerId;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingCost;
  final double platformFee; // 2% platform commission
  final double totalAmount;
  final double estimatedSavings; // savings vs intermediaries (Y2)
  final double savingsPercent;
  final String deliveryAddress;
  final DateTime? deliveryDate;
  final String buyerNotes;
  final String status; // 'pending', 'approved', 'dispatched', 'completed', 'cancelled'
  final List<StatusChange> statusHistory;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.platformFee,
    required this.totalAmount,
    required this.estimatedSavings,
    required this.savingsPercent,
    required this.deliveryAddress,
    this.deliveryDate,
    required this.buyerNotes,
    required this.status,
    required this.statusHistory,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyerId': buyerId,
      'items': items.map((x) => x.toMap()).toList(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'platformFee': platformFee,
      'totalAmount': totalAmount,
      'estimatedSavings': estimatedSavings,
      'savingsPercent': savingsPercent,
      'deliveryAddress': deliveryAddress,
      'deliveryDate': deliveryDate?.toIso8601String(),
      'buyerNotes': buyerNotes,
      'status': status,
      'statusHistory': statusHistory.map((x) => x.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      id: docId,
      buyerId: map['buyerId'] ?? '',
      items: map['items'] != null
          ? List<OrderItem>.from((map['items'] as List).map((x) => OrderItem.fromMap(Map<String, dynamic>.from(x))))
          : [],
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (map['shippingCost'] as num?)?.toDouble() ?? 0.0,
      platformFee: (map['platformFee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      estimatedSavings: (map['estimatedSavings'] as num?)?.toDouble() ?? 0.0,
      savingsPercent: (map['savingsPercent'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: map['deliveryAddress'] ?? '',
      deliveryDate: map['deliveryDate'] != null ? DateTime.tryParse(map['deliveryDate']) : null,
      buyerNotes: map['buyerNotes'] ?? '',
      status: map['status'] ?? 'pending',
      statusHistory: map['statusHistory'] != null
          ? List<StatusChange>.from((map['statusHistory'] as List).map((x) => StatusChange.fromMap(Map<String, dynamic>.from(x))))
          : [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class OrderItem {
  final String productId;
  final String farmerId;
  final String productName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double lineTotal;

  OrderItem({
    required this.productId,
    required this.farmerId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.lineTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'farmerId': farmerId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? 'kg',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (map['lineTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class StatusChange {
  final String status;
  final DateTime changedAt;
  final String changedBy;

  StatusChange({
    required this.status,
    required this.changedAt,
    required this.changedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'changedAt': changedAt.toIso8601String(),
      'changedBy': changedBy,
    };
  }

  factory StatusChange.fromMap(Map<String, dynamic> map) {
    return StatusChange(
      status: map['status'] ?? '',
      changedAt: map['changedAt'] != null
          ? DateTime.tryParse(map['changedAt']) ?? DateTime.now()
          : DateTime.now(),
      changedBy: map['changedBy'] ?? '',
    );
  }
}
