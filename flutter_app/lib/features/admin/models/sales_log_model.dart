class SalesLogModel {
  final String id;
  final String orderId;
  final DateTime transactionDate;
  final String farmerId;
  final String buyerId;
  final List<SalesLogProduct> products;
  final double totalAmount;
  final double totalVolumeKg;
  final double platformFeePaid;
  final double estimatedSavingsVsIntermediary;
  final double savingsPercent;
  final double farmerNetRevenue;
  final String farmerCommunity;
  final DateTime createdAt;

  SalesLogModel({
    required this.id,
    required this.orderId,
    required this.transactionDate,
    required this.farmerId,
    required this.buyerId,
    required this.products,
    required this.totalAmount,
    required this.totalVolumeKg,
    required this.platformFeePaid,
    required this.estimatedSavingsVsIntermediary,
    required this.savingsPercent,
    required this.farmerNetRevenue,
    required this.farmerCommunity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'transactionDate': transactionDate.toIso8601String(),
      'farmerId': farmerId,
      'buyerId': buyerId,
      'products': products.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'totalVolumeKg': totalVolumeKg,
      'platformFeePaid': platformFeePaid,
      'estimatedSavingsVsIntermediary': estimatedSavingsVsIntermediary,
      'savingsPercent': savingsPercent,
      'farmerNetRevenue': farmerNetRevenue,
      'farmerCommunity': farmerCommunity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SalesLogModel.fromMap(Map<String, dynamic> map, String docId) {
    return SalesLogModel(
      id: docId,
      orderId: map['orderId'] ?? '',
      transactionDate: map['transactionDate'] != null
          ? DateTime.tryParse(map['transactionDate']) ?? DateTime.now()
          : DateTime.now(),
      farmerId: map['farmerId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      products: map['products'] != null
          ? List<SalesLogProduct>.from((map['products'] as List).map((x) => SalesLogProduct.fromMap(Map<String, dynamic>.from(x))))
          : [],
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      totalVolumeKg: (map['totalVolumeKg'] as num?)?.toDouble() ?? 0.0,
      platformFeePaid: (map['platformFeePaid'] as num?)?.toDouble() ?? 0.0,
      estimatedSavingsVsIntermediary: (map['estimatedSavingsVsIntermediary'] as num?)?.toDouble() ?? 0.0,
      savingsPercent: (map['savingsPercent'] as num?)?.toDouble() ?? 0.0,
      farmerNetRevenue: (map['farmerNetRevenue'] as num?)?.toDouble() ?? 0.0,
      farmerCommunity: map['farmerCommunity'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class SalesLogProduct {
  final String name;
  final String cropType;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double lineTotal;

  SalesLogProduct({
    required this.name,
    required this.cropType,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.lineTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cropType': cropType,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
    };
  }

  factory SalesLogProduct.fromMap(Map<String, dynamic> map) {
    return SalesLogProduct(
      name: map['name'] ?? '',
      cropType: map['cropType'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? 'kg',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (map['lineTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
