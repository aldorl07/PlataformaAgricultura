import 'dart:async';
import 'dart:typed_data';
import 'service_interfaces.dart';
import '../features/auth/models/user_model.dart';
import '../features/catalog/models/product_model.dart';
import '../features/quote/models/order_model.dart';
import '../features/admin/models/sales_log_model.dart';
import '../features/admin/models/market_price_model.dart';

class MockDb {
  static final List<UserModel> users = [];
  static final List<ProductModel> products = [];
  static final List<OrderModel> orders = [];
  static final List<SalesLogModel> salesLogs = [];
  static final List<MarketPriceModel> marketPrices = [];
  static final List<Map<String, dynamic>> telemetryEvents = [];
  
  static UserModel? loggedInUser;
  static final StreamController<UserModel?> authStreamController = StreamController<UserModel?>.broadcast();

  static void initSeedData() {
    if (users.isNotEmpty) return; // already seeded
    
    final cropPhotos = {
      'papa': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500',
      'maiz': 'https://images.unsplash.com/photo-1551754625-70c9048723ad?w=500',
      'cebada': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=500',
      'habas': 'https://images.unsplash.com/photo-1592417817098-8f3d6eb19675?w=500',
      'hortalizas': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500',
      'quinua': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500',
      'arveja': 'https://images.unsplash.com/photo-1587570220977-83b3e2b202bb?w=500',
      'otros': 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=500',
    };

    // 1. Admin
    final admin = UserModel(
      id: 'admin_1',
      email: 'admin@chupacadirecto.pe',
      role: 'admin',
      fullName: 'Dr. Alejandro Torres (Investigador UC)',
      phone: '+51 964552211',
      preferredContact: 'email',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
    users.add(admin);

    // 2. Farmers (5 verified)
    final communities = [
      'Ahuac', 'Chongos Bajo', 'Huachac', 'Tres de Diciembre', 'San Juan de Jarpa'
    ];
    final crops = [
      ['papa', 'maiz', 'habas'],
      ['maiz', 'cebada', 'arveja'],
      ['hortalizas', 'papa', 'quinua'],
      ['papa', 'hortalizas', 'otros'],
      ['cebada', 'habas', 'quinua']
    ];
    final names = [
      'Juan Pérez', 'María Quispe', 'Félix Huamán', 'Sonia Cárdenas', 'Zenón Limaco'
    ];

    for (int i = 0; i < 5; i++) {
      final farmer = UserModel(
        id: 'farmer_${i + 1}',
        email: 'farmer${i + 1}@chupaca.pe',
        role: 'farmer',
        fullName: names[i],
        phone: '+51 98765432$i',
        preferredContact: 'whatsapp',
        farmerProfile: FarmerProfile(
          dni: '1234567$i',
          community: communities[i],
          latitude: -12.0621 + (i * 0.01),
          longitude: -75.2858 - (i * 0.01),
          experienceYears: 10 + (i * 2),
          mainCrops: crops[i],
          isVerified: true,
          verifiedAt: DateTime.now().subtract(const Duration(days: 20)),
          verifiedBy: 'admin_1',
        ),
        registrationStartedAt: DateTime.now().subtract(const Duration(days: 25, hours: 2)),
        registrationCompletedAt: DateTime.now().subtract(const Duration(days: 25, hours: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      );
      users.add(farmer);

      // Add 3 products per farmer
      final cropTypes = crops[i];
      final productNames = {
        'papa': ['Papa Yungay de Tierra Alta', 'Papa Amarilla Orgánica', 'Papa Canchán Seleccionada'],
        'maiz': ['Maíz Blanco del Valle', 'Maíz Choclo Fresco', 'Maíz Amarillo Seco'],
        'cebada': ['Cebada en Grano Extra', 'Cebada para Cerveza', 'Cebada Molida'],
        'habas': ['Habas Verdes Grandes', 'Habas Secas para Tostar', 'Habas Peladas'],
        'hortalizas': ['Lechuga Orgánica Crespa', 'Zanahoria Dulce de Parcela', 'Brócoli Premium'],
        'quinua': ['Quinua Blanca de Chupaca', 'Quinua Roja Orgánica', 'Quinua Negra Silvestre'],
        'arveja': ['Arveja Verde Fresca', 'Arveja Amarilla Seca', 'Arveja Criolla'],
        'otros': ['Ajo Morado de Siembra', 'Olluco Silvestre de Altura', 'Mashua Seleccionada'],
      };

      for (int j = 0; j < 3; j++) {
        final crop = cropTypes[j % cropTypes.length];
        final namesList = productNames[crop] ?? ['Producto Agrícola'];
        final pName = namesList[j % namesList.length];
        
        final product = ProductModel(
          id: 'prod_f${i + 1}_$j',
          farmerId: 'farmer_${i + 1}',
          name: pName,
          cropType: crop,
          variety: 'Variedad Local ${j + 1}',
          description: 'Cosecha fresca y orgánica cultivada de forma artesanal en la comunidad de ${communities[i]} mediante riego natural y abono orgánico.',
          unit: j == 0 ? 'kg' : (j == 1 ? 'saco' : 'arroba'),
          pricePerUnit: 1.20 + (j * 0.8) + (i * 0.3),
          stock: 150.0 + (j * 100) + (i * 50),
          photos: [cropPhotos[crop] ?? cropPhotos['otros']!],
          harvestDate: DateTime.now().subtract(Duration(days: j * 3)),
          isActive: true,
          createdAt: DateTime.now().subtract(Duration(days: j * 5)),
        );
        products.add(product);
      }
    }

    // 3. Buyers (3 users)
    final buyerNames = ['Restaurante El Valle', 'Comercializadora Huancayo', 'Supermercado Junín'];
    final businessTypes = ['restaurant', 'wholesale_market', 'retail'];
    
    for (int i = 0; i < 3; i++) {
      final buyer = UserModel(
        id: 'buyer_${i + 1}',
        email: 'buyer${i + 1}@gmail.com',
        role: 'buyer',
        fullName: buyerNames[i],
        phone: '+51 95544332$i',
        preferredContact: 'whatsapp',
        buyerProfile: BuyerProfile(
          businessName: buyerNames[i],
          ruc: '2045612378$i',
          businessType: businessTypes[i],
          deliveryAddress: 'Av. Giráldez $i${i}0, Huancayo',
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      );
      users.add(buyer);
    }

    // 4. Market Prices (10 entries for comparison)
    final cropTypesList = ['papa', 'maiz', 'cebada', 'habas', 'hortalizas', 'quinua', 'arveja', 'otros'];
    final cropNamesList = ['Papa', 'Maíz', 'Cebada', 'Habas', 'Hortalizas', 'Quinua', 'Arveja', 'Otros'];
    final referencePrices = [1.80, 2.50, 1.90, 3.20, 1.50, 8.50, 4.00, 3.00];

    for (int i = 0; i < cropTypesList.length; i++) {
      final mPrice = MarketPriceModel(
        id: 'mprice_$i',
        cropType: cropTypesList[i],
        cropName: cropNamesList[i],
        marketName: 'Mercado Mayorista de Huancayo',
        pricePerKg: referencePrices[i],
        source: 'MIDAGRI - SISAP',
        effectiveDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      marketPrices.add(mPrice);
    }

    // Add extra reference prices
    marketPrices.add(MarketPriceModel(
      id: 'mprice_8',
      cropType: 'papa',
      cropName: 'Papa Blanca',
      marketName: 'Mercado Chupaca',
      pricePerKg: 1.60,
      source: 'MIDAGRI',
      effectiveDate: DateTime.now(),
    ));

    marketPrices.add(MarketPriceModel(
      id: 'mprice_9',
      cropType: 'maiz',
      cropName: 'Maíz Choclo',
      marketName: 'Mercado Chupaca',
      pricePerKg: 2.20,
      source: 'MIDAGRI',
      effectiveDate: DateTime.now(),
    ));

    // 5. Sample completed orders + SalesLogs
    for (int i = 0; i < 3; i++) {
      final order = OrderModel(
        id: 'order_seed_$i',
        buyerId: 'buyer_1',
        items: [
          OrderItem(
            productId: products[i].id,
            farmerId: products[i].farmerId,
            productName: products[i].name,
            quantity: 50.0,
            unit: products[i].unit,
            unitPrice: products[i].pricePerUnit,
            lineTotal: 50.0 * products[i].pricePerUnit,
          ),
          OrderItem(
            productId: products[i + 5].id,
            farmerId: products[i + 5].farmerId,
            productName: products[i + 5].name,
            quantity: 20.0,
            unit: products[i + 5].unit,
            unitPrice: products[i + 5].pricePerUnit,
            lineTotal: 20.0 * products[i + 5].pricePerUnit,
          ),
        ],
        subtotal: (50.0 * products[i].pricePerUnit) + (20.0 * products[i + 5].pricePerUnit),
        shippingCost: 80.0,
        platformFee: ((50.0 * products[i].pricePerUnit) + (20.0 * products[i + 5].pricePerUnit)) * 0.02,
        totalAmount: ((50.0 * products[i].pricePerUnit) + (20.0 * products[i + 5].pricePerUnit)) * 1.02 + 80.0,
        estimatedSavings: ((50.0 * products[i].pricePerUnit) + (20.0 * products[i + 5].pricePerUnit)) * 0.25,
        savingsPercent: 25.0,
        deliveryAddress: 'Av. Giráldez 110, Huancayo',
        deliveryDate: DateTime.now().subtract(Duration(days: i * 2)),
        buyerNotes: 'Entregar por la mañana, por favor.',
        status: 'completed',
        statusHistory: [
          StatusChange(status: 'pending', changedAt: DateTime.now().subtract(Duration(days: i * 2, hours: 4)), changedBy: 'buyer_1'),
          StatusChange(status: 'approved', changedAt: DateTime.now().subtract(Duration(days: i * 2, hours: 3)), changedBy: products[i].farmerId),
          StatusChange(status: 'dispatched', changedAt: DateTime.now().subtract(Duration(days: i * 2, hours: 2)), changedBy: products[i].farmerId),
          StatusChange(status: 'completed', changedAt: DateTime.now().subtract(Duration(days: i * 2)), changedBy: 'buyer_1'),
        ],
        createdAt: DateTime.now().subtract(Duration(days: i * 2, hours: 4)),
      );
      orders.add(order);

      // Create SalesLogs for completed orders
      final log = SalesLogModel(
        id: 'log_seed_$i',
        orderId: order.id,
        transactionDate: order.createdAt.add(const Duration(hours: 4)),
        farmerId: products[i].farmerId,
        buyerId: order.buyerId,
        products: order.items.map((x) => SalesLogProduct(
          name: x.productName,
          cropType: products.firstWhere((p) => p.id == x.productId).cropType,
          quantity: x.quantity,
          unit: x.unit,
          unitPrice: x.unitPrice,
          lineTotal: x.lineTotal,
        )).toList(),
        totalAmount: order.totalAmount,
        totalVolumeKg: 70.0,
        platformFeePaid: order.platformFee,
        estimatedSavingsVsIntermediary: order.estimatedSavings,
        savingsPercent: order.savingsPercent,
        farmerNetRevenue: order.subtotal - order.platformFee,
        farmerCommunity: users.firstWhere((u) => u.id == products[i].farmerId).farmerProfile?.community ?? 'Ahuac',
        createdAt: order.createdAt.add(const Duration(hours: 4)),
      );
      salesLogs.add(log);
    }
  }
}

class MockAuthService implements IAuthService {
  MockAuthService() {
    MockDb.initSeedData();
  }

  @override
  UserModel? get currentUser => MockDb.loggedInUser;

  @override
  Stream<UserModel?> get authStateChanges => MockDb.authStreamController.stream;

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final normalizedEmail = email.toLowerCase().trim();
    final user = MockDb.users.firstWhere(
      (u) => u.email == normalizedEmail,
      orElse: () => throw Exception('Usuario no encontrado o contraseña incorrecta'),
    );

    MockDb.loggedInUser = user;
    MockDb.authStreamController.add(user);
    return user;
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String role,
    required String fullName,
    required String phone,
    required String preferredContact,
    FarmerProfile? farmerProfile,
    BuyerProfile? buyerProfile,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final normalizedEmail = email.toLowerCase().trim();
    if (MockDb.users.any((u) => u.email == normalizedEmail)) {
      throw Exception('El correo electrónico ya está registrado');
    }

    final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final user = UserModel(
      id: newId,
      email: normalizedEmail,
      role: role,
      fullName: fullName,
      phone: phone,
      preferredContact: preferredContact,
      farmerProfile: farmerProfile,
      buyerProfile: buyerProfile,
      registrationStartedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      registrationCompletedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    MockDb.users.add(user);
    MockDb.loggedInUser = user;
    MockDb.authStreamController.add(user);
    
    // Log telemetry event for registration complete
    MockTelemetryService().logEvent(
      eventType: 'registration_complete',
      userId: newId,
      metadata: {'role': role, 'fullName': fullName},
    );

    return user;
  }

  @override
  Future<void> signOut() async {
    MockDb.loggedInUser = null;
    MockDb.authStreamController.add(null);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Sign in as a dummy buyer
    final user = MockDb.users.firstWhere((u) => u.role == 'buyer');
    MockDb.loggedInUser = user;
    MockDb.authStreamController.add(user);
    return user;
  }
}

class MockFirestoreService implements IFirestoreService {
  MockFirestoreService() {
    MockDb.initSeedData();
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    try {
      return MockDb.users.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final index = MockDb.users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      MockDb.users[index] = user;
      // Sync auth state if this is the logged in user
      if (MockDb.loggedInUser?.id == user.id) {
        MockDb.loggedInUser = user;
        MockDb.authStreamController.add(user);
      }
    }
  }

  @override
  Future<void> updateFarmerVerification(String userId, bool isVerified, String adminId) async {
    final index = MockDb.users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = MockDb.users[index];
      if (user.farmerProfile != null) {
        final updatedProfile = FarmerProfile(
          dni: user.farmerProfile!.dni,
          community: user.farmerProfile!.community,
          latitude: user.farmerProfile!.latitude,
          longitude: user.farmerProfile!.longitude,
          experienceYears: user.farmerProfile!.experienceYears,
          mainCrops: user.farmerProfile!.mainCrops,
          isVerified: isVerified,
          verifiedAt: isVerified ? DateTime.now() : null,
          verifiedBy: isVerified ? adminId : null,
        );
        MockDb.users[index] = user.copyWith(farmerProfile: updatedProfile);
      }
    }
  }

  @override
  Future<List<UserModel>> getFarmers() async {
    return MockDb.users.where((u) => u.role == 'farmer').toList();
  }

  @override
  Future<Map<String, dynamic>> getReachStats() async {
    final farmers = MockDb.users.where((u) => u.role == 'farmer').toList();
    final buyers = MockDb.users.where((u) => u.role == 'buyer').toList();
    
    final Map<String, int> farmersPerCommunity = {};
    for (final f in farmers) {
      final community = f.farmerProfile?.community ?? 'Desconocida';
      farmersPerCommunity[community] = (farmersPerCommunity[community] ?? 0) + 1;
    }

    return {
      'totalFarmers': farmers.length,
      'totalBuyers': buyers.length,
      'verifiedCount': farmers.where((f) => f.farmerProfile?.isVerified == true).length,
      'farmersPerCommunity': farmersPerCommunity,
    };
  }

  @override
  Future<List<ProductModel>> getProducts({
    String? search,
    String? cropType,
    String? community,
    double? minPrice,
    double? maxPrice,
    double? minStock,
    bool? verified,
  }) async {
    Iterable<ProductModel> filtered = MockDb.products.where((p) => p.isActive);

    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      filtered = filtered.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.variety.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q));
    }

    if (cropType != null && cropType.isNotEmpty && cropType.toLowerCase() != 'todos') {
      filtered = filtered.where((p) => p.cropType.toLowerCase() == cropType.toLowerCase());
    }

    if (community != null && community.isNotEmpty) {
      filtered = filtered.where((p) {
        final farmer = MockDb.users.firstWhere((u) => u.id == p.farmerId, orElse: () => UserModel(id: '', email: '', role: '', fullName: '', phone: '', preferredContact: '', createdAt: DateTime.now()));
        return farmer.farmerProfile?.community.toLowerCase() == community.toLowerCase();
      });
    }

    if (minPrice != null) {
      filtered = filtered.where((p) => p.pricePerUnit >= minPrice);
    }

    if (maxPrice != null) {
      filtered = filtered.where((p) => p.pricePerUnit <= maxPrice);
    }

    if (minStock != null) {
      filtered = filtered.where((p) => p.stock >= minStock);
    }

    if (verified != null && verified) {
      filtered = filtered.where((p) {
        final farmer = MockDb.users.firstWhere((u) => u.id == p.farmerId, orElse: () => UserModel(id: '', email: '', role: '', fullName: '', phone: '', preferredContact: '', createdAt: DateTime.now()));
        return farmer.farmerProfile?.isVerified == true;
      });
    }

    return filtered.toList();
  }

  @override
  Future<ProductModel?> getProduct(String id) async {
    try {
      return MockDb.products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createProduct(ProductModel product) async {
    MockDb.products.add(product);
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    final index = MockDb.products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      MockDb.products[index] = product;
    }
  }

  @override
  Future<void> updateProductStock(String productId, double newStock) async {
    final index = MockDb.products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      MockDb.products[index] = MockDb.products[index].copyWith(stock: newStock);
    }
  }

  @override
  Future<void> softDeleteProduct(String productId) async {
    final index = MockDb.products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      MockDb.products[index] = MockDb.products[index].copyWith(isActive: false);
    }
  }

  @override
  Future<void> createOrder(OrderModel order) async {
    MockDb.orders.add(order);
    
    // Deduct stock atomically
    for (final item in order.items) {
      final productIdx = MockDb.products.indexWhere((p) => p.id == item.productId);
      if (productIdx != -1) {
        final currentStock = MockDb.products[productIdx].stock;
        MockDb.products[productIdx] = MockDb.products[productIdx].copyWith(
          stock: (currentStock - item.quantity).clamp(0, double.infinity),
        );
      }
    }
  }

  @override
  Future<List<OrderModel>> getOrders({required String userId, required String role}) async {
    if (role == 'buyer') {
      return MockDb.orders.where((o) => o.buyerId == userId).toList();
    } else if (role == 'farmer') {
      return MockDb.orders.where((o) => o.items.any((item) => item.farmerId == userId)).toList();
    } else {
      return MockDb.orders;
    }
  }

  @override
  Future<OrderModel?> getOrder(String id) async {
    try {
      return MockDb.orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status, String userId) async {
    final index = MockDb.orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = MockDb.orders[index];
      
      final history = List<StatusChange>.from(order.statusHistory);
      history.add(StatusChange(status: status, changedAt: DateTime.now(), changedBy: userId));
      
      final updatedOrder = OrderModel(
        id: order.id,
        buyerId: order.buyerId,
        items: order.items,
        subtotal: order.subtotal,
        shippingCost: order.shippingCost,
        platformFee: order.platformFee,
        totalAmount: order.totalAmount,
        estimatedSavings: order.estimatedSavings,
        savingsPercent: order.savingsPercent,
        deliveryAddress: order.deliveryAddress,
        deliveryDate: order.deliveryDate,
        buyerNotes: order.buyerNotes,
        status: status,
        statusHistory: history,
        createdAt: order.createdAt,
      );
      MockDb.orders[index] = updatedOrder;

      // On completed status -> write to SalesLog
      if (status == 'completed') {
        final volume = order.items.fold(0.0, (sum, item) => sum + item.quantity);
        final farmerId = order.items.isNotEmpty ? order.items.first.farmerId : '';
        final farmer = MockDb.users.firstWhere((u) => u.id == farmerId, orElse: () => UserModel(id: '', email: '', role: '', fullName: '', phone: '', preferredContact: '', createdAt: DateTime.now()));
        
        final log = SalesLogModel(
          id: 'log_${DateTime.now().millisecondsSinceEpoch}',
          orderId: order.id,
          transactionDate: DateTime.now(),
          farmerId: farmerId,
          buyerId: order.buyerId,
          products: order.items.map((x) => SalesLogProduct(
            name: x.productName,
            cropType: MockDb.products.firstWhere((p) => p.id == x.productId).cropType,
            quantity: x.quantity,
            unit: x.unit,
            unitPrice: x.unitPrice,
            lineTotal: x.lineTotal,
          )).toList(),
          totalAmount: order.totalAmount,
          totalVolumeKg: volume,
          platformFeePaid: order.platformFee,
          estimatedSavingsVsIntermediary: order.estimatedSavings,
          savingsPercent: order.savingsPercent,
          farmerNetRevenue: order.subtotal - order.platformFee,
          farmerCommunity: farmer.farmerProfile?.community ?? 'Chupaca',
          createdAt: DateTime.now(),
        );
        MockDb.salesLogs.add(log);

        // Update farmer's firstTransactionAt if not set
        final farmerIdx = MockDb.users.indexWhere((u) => u.id == farmerId);
        if (farmerIdx != -1 && MockDb.users[farmerIdx].firstTransactionAt == null) {
          MockDb.users[farmerIdx] = MockDb.users[farmerIdx].copyWith(
            firstTransactionAt: DateTime.now(),
          );
        }
      }
      
      // On cancelled status -> restore stock
      if (status == 'cancelled') {
        for (final item in order.items) {
          final productIdx = MockDb.products.indexWhere((p) => p.id == item.productId);
          if (productIdx != -1) {
            final currentStock = MockDb.products[productIdx].stock;
            MockDb.products[productIdx] = MockDb.products[productIdx].copyWith(
              stock: currentStock + item.quantity,
            );
          }
        }
      }
    }
  }

  @override
  Future<List<SalesLogModel>> getSalesLogs() async {
    return MockDb.salesLogs;
  }

  @override
  Future<List<MarketPriceModel>> getMarketPrices() async {
    return MockDb.marketPrices;
  }

  @override
  Future<void> createMarketPrice(MarketPriceModel price) async {
    MockDb.marketPrices.add(price);
  }

  @override
  Future<Map<String, dynamic>> getResearchDashboardData() async {
    // Computes all statistics for the 6 research variables
    final logs = MockDb.salesLogs;
    final totalTx = logs.length;
    
    double totalRevenue = 0;
    double totalSavings = 0;
    double totalFees = 0;
    double totalNetMargins = 0;

    for (final l in logs) {
      totalRevenue += l.totalAmount;
      totalSavings += l.estimatedSavingsVsIntermediary;
      totalFees += l.platformFeePaid;
      totalNetMargins += (l.farmerNetRevenue / l.totalAmount);
    }

    final avgSavings = totalTx > 0 ? (totalSavings / totalRevenue) * 100 : 0.0;
    final avgMargin = totalTx > 0 ? (totalNetMargins / totalTx) * 100 : 0.0;

    final reach = await getReachStats();
    
    // Telemetry events calculations
    final sessions = MockDb.telemetryEvents.map((e) => e['sessionId']).toSet().length;
    final abandoned = MockDb.telemetryEvents.where((e) => e['eventType'] == 'registration_abandon').length;
    final completedReg = MockDb.telemetryEvents.where((e) => e['eventType'] == 'registration_complete').length;
    final totalRegAttempts = abandoned + completedReg;
    final abandonRate = totalRegAttempts > 0 ? (abandoned / totalRegAttempts) * 100 : 0.0;

    return {
      'X1_accessibility': {
        'avgLoadTime': 1.68,
        'mobilePercent': 83.3,
        'deviceCompatibility': 15,
      },
      'X2_usability': {
        'avgFirstTransactionTime': 14.5,
        'registrationAbandonRate': abandonRate > 0 ? abandonRate : 8.0,
        'sessionsCount': sessions > 0 ? sessions : 45,
      },
      'X3_marketReach': {
        'totalFarmers': reach['totalFarmers'],
        'verifiedFarmers': reach['verifiedCount'],
        'totalBuyers': reach['totalBuyers'],
        'districtsWithFarmers': (reach['farmersPerCommunity'] as Map).keys.length,
        'farmersPerDistrict': reach['farmersPerCommunity'],
      },
      'Y1_salesRevenue': {
        'totalSales': totalRevenue,
        'avgRevenuePerTransaction': totalTx > 0 ? totalRevenue / totalTx : 0.0,
        'transactionCount': totalTx,
      },
      'Y2_marketingCosts': {
        'avgIntermediationCostPct': 35.0, // Pre-test intermediary cost percentage
        'avgPlatformCostPerTx': totalTx > 0 ? totalFees / totalTx : 0.0,
        'totalSavingsGenerated': totalSavings,
        'savingsPercent': avgSavings > 0 ? avgSavings : 25.0,
      },
      'Y3_profitMargins': {
        'avgNetMarginPerFarmer': avgMargin > 0 ? avgMargin : 38.5,
        'incomeToTotalCostRatio': 1.62,
        'preTestAvgMargin': 15.0, // Historical Pre-Test baseline
        'postTestAvgMargin': avgMargin > 0 ? avgMargin : 38.5,
      }
    };
  }
}

class MockStorageService implements IStorageService {
  @override
  Future<String> uploadProductPhoto(String name, Uint8List bytes) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Return a dummy image url representing the upload
    return 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500';
  }
}

class MockTelemetryService implements ITelemetryService {
  @override
  Future<void> logEvent({
    required String eventType,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    MockDb.telemetryEvents.add({
      'eventType': eventType,
      'userId': userId,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
      'sessionId': 'sess_${userId ?? "anonymous"}'
    });
  }

  @override
  Future<Map<String, dynamic>> getTelemetryAnalytics() async {
    return {
      'avgPageLoadTime': 1.68,
      'pageLoadByDevice': {
        'mobile': 83.3,
        'desktop': 12.5,
        'tablet': 4.2,
      },
      'registrationFunnelDropoff': {
        'step1': 100.0,
        'step2': 85.0,
        'step3': 92.0,
      },
    };
  }
}
