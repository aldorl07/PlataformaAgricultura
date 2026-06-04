class ProductModel {
  final String id;
  final String farmerId;
  final String name;
  final String cropType; // papa, maiz, cebada, habas, hortalizas, quinua, arveja, otros
  final String variety;
  final String description;
  final String unit; // kg, arroba, saco, tonelada
  final double pricePerUnit;
  final double stock;
  final List<String> photos;
  final DateTime? harvestDate;
  final bool isActive;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.cropType,
    required this.variety,
    required this.description,
    required this.unit,
    required this.pricePerUnit,
    required this.stock,
    required this.photos,
    this.harvestDate,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmerId': farmerId,
      'name': name,
      'cropType': cropType,
      'variety': variety,
      'description': description,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'stock': stock,
      'photos': photos,
      'harvestDate': harvestDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      farmerId: map['farmerId'] ?? '',
      name: map['name'] ?? '',
      cropType: map['cropType'] ?? 'papa',
      variety: map['variety'] ?? '',
      description: map['description'] ?? '',
      unit: map['unit'] ?? 'kg',
      pricePerUnit: (map['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toDouble() ?? 0.0,
      photos: List<String>.from(map['photos'] ?? []),
      harvestDate: map['harvestDate'] != null ? DateTime.tryParse(map['harvestDate']) : null,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  ProductModel copyWith({
    String? name,
    String? cropType,
    String? variety,
    String? description,
    String? unit,
    double? pricePerUnit,
    double? stock,
    List<String>? photos,
    DateTime? harvestDate,
    bool? isActive,
  }) {
    return ProductModel(
      id: id,
      farmerId: farmerId,
      name: name ?? this.name,
      cropType: cropType ?? this.cropType,
      variety: variety ?? this.variety,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      stock: stock ?? this.stock,
      photos: photos ?? this.photos,
      harvestDate: harvestDate ?? this.harvestDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
