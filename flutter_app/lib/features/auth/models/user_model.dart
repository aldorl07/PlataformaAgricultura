class UserModel {
  final String id;
  final String email;
  final String role; // 'farmer', 'buyer', 'admin'
  final String fullName;
  final String phone;
  final String preferredContact; // 'whatsapp', 'call', 'email'
  
  // Farmer profile details
  final FarmerProfile? farmerProfile;
  
  // Buyer profile details
  final BuyerProfile? buyerProfile;

  // Research Telemetry
  final DateTime? registrationStartedAt;
  final DateTime? registrationCompletedAt;
  final DateTime? firstTransactionAt;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    required this.phone,
    required this.preferredContact,
    this.farmerProfile,
    this.buyerProfile,
    this.registrationStartedAt,
    this.registrationCompletedAt,
    this.firstTransactionAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'fullName': fullName,
      'phone': phone,
      'preferredContact': preferredContact,
      'farmerProfile': farmerProfile?.toMap(),
      'buyerProfile': buyerProfile?.toMap(),
      'registrationStartedAt': registrationStartedAt?.toIso8601String(),
      'registrationCompletedAt': registrationCompletedAt?.toIso8601String(),
      'firstTransactionAt': firstTransactionAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      email: map['email'] ?? '',
      role: map['role'] ?? 'buyer',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      preferredContact: map['preferredContact'] ?? 'whatsapp',
      farmerProfile: map['farmerProfile'] != null 
          ? FarmerProfile.fromMap(Map<String, dynamic>.from(map['farmerProfile']))
          : null,
      buyerProfile: map['buyerProfile'] != null
          ? BuyerProfile.fromMap(Map<String, dynamic>.from(map['buyerProfile']))
          : null,
      registrationStartedAt: map['registrationStartedAt'] != null 
          ? DateTime.tryParse(map['registrationStartedAt']) 
          : null,
      registrationCompletedAt: map['registrationCompletedAt'] != null
          ? DateTime.tryParse(map['registrationCompletedAt'])
          : null,
      firstTransactionAt: map['firstTransactionAt'] != null
          ? DateTime.tryParse(map['firstTransactionAt'])
          : null,
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? fullName,
    String? phone,
    String? preferredContact,
    FarmerProfile? farmerProfile,
    BuyerProfile? buyerProfile,
    DateTime? registrationStartedAt,
    DateTime? registrationCompletedAt,
    DateTime? firstTransactionAt,
  }) {
    return UserModel(
      id: id,
      email: email,
      role: role,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      preferredContact: preferredContact ?? this.preferredContact,
      farmerProfile: farmerProfile ?? this.farmerProfile,
      buyerProfile: buyerProfile ?? this.buyerProfile,
      registrationStartedAt: registrationStartedAt ?? this.registrationStartedAt,
      registrationCompletedAt: registrationCompletedAt ?? this.registrationCompletedAt,
      firstTransactionAt: firstTransactionAt ?? this.firstTransactionAt,
      createdAt: createdAt,
    );
  }
}

class FarmerProfile {
  final String dni;
  final String community; // one of the 9 districts of Chupaca
  final double? latitude;
  final double? longitude;
  final int experienceYears;
  final List<String> mainCrops;
  final bool isVerified;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  FarmerProfile({
    required this.dni,
    required this.community,
    this.latitude,
    this.longitude,
    required this.experienceYears,
    required this.mainCrops,
    this.isVerified = false,
    this.verifiedAt,
    this.verifiedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'dni': dni,
      'community': community,
      'latitude': latitude,
      'longitude': longitude,
      'experienceYears': experienceYears,
      'mainCrops': mainCrops,
      'isVerified': isVerified,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verifiedBy': verifiedBy,
    };
  }

  factory FarmerProfile.fromMap(Map<String, dynamic> map) {
    return FarmerProfile(
      dni: map['dni'] ?? '',
      community: map['community'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 0,
      mainCrops: List<String>.from(map['mainCrops'] ?? []),
      isVerified: map['isVerified'] ?? false,
      verifiedAt: map['verifiedAt'] != null ? DateTime.tryParse(map['verifiedAt']) : null,
      verifiedBy: map['verifiedBy'],
    );
  }
}

class BuyerProfile {
  final String businessName;
  final String ruc;
  final String businessType; // wholesale_market, restaurant, exporter, retail, other
  final String deliveryAddress;

  BuyerProfile({
    required this.businessName,
    required this.ruc,
    required this.businessType,
    required this.deliveryAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'ruc': ruc,
      'businessType': businessType,
      'deliveryAddress': deliveryAddress,
    };
  }

  factory BuyerProfile.fromMap(Map<String, dynamic> map) {
    return BuyerProfile(
      businessName: map['businessName'] ?? '',
      ruc: map['ruc'] ?? '',
      businessType: map['businessType'] ?? '',
      deliveryAddress: map['deliveryAddress'] ?? '',
    );
  }
}
