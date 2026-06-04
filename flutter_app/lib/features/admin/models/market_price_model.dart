class MarketPriceModel {
  final String id;
  final String cropType;
  final String cropName;
  final String marketName;
  final double pricePerKg;
  final String source;
  final DateTime effectiveDate;

  MarketPriceModel({
    required this.id,
    required this.cropType,
    required this.cropName,
    required this.marketName,
    required this.pricePerKg,
    required this.source,
    required this.effectiveDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropType': cropType,
      'cropName': cropName,
      'marketName': marketName,
      'pricePerKg': pricePerKg,
      'source': source,
      'effectiveDate': effectiveDate.toIso8601String(),
    };
  }

  factory MarketPriceModel.fromMap(Map<String, dynamic> map, String docId) {
    return MarketPriceModel(
      id: docId,
      cropType: map['cropType'] ?? '',
      cropName: map['cropName'] ?? '',
      marketName: map['marketName'] ?? '',
      pricePerKg: (map['pricePerKg'] as num?)?.toDouble() ?? 0.0,
      source: map['source'] ?? 'MIDAGRI',
      effectiveDate: map['effectiveDate'] != null
          ? DateTime.tryParse(map['effectiveDate']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
