import '../features/auth/models/user_model.dart';
import '../features/catalog/models/product_model.dart';
import '../features/quote/models/order_model.dart';
import '../features/admin/models/sales_log_model.dart';
import '../features/admin/models/market_price_model.dart';

abstract class IAuthService {
  UserModel? get currentUser;
  Stream<UserModel?> get authStateChanges;
  
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String role,
    required String fullName,
    required String phone,
    required String preferredContact,
    FarmerProfile? farmerProfile,
    BuyerProfile? buyerProfile,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
  Future<UserModel> signInWithGoogle();
}

abstract class IFirestoreService {
  Future<UserModel?> getUser(String userId);
  Future<void> updateUser(UserModel user);
  Future<void> updateFarmerVerification(String userId, bool isVerified, String adminId);
  Future<List<UserModel>> getFarmers();
  Future<Map<String, dynamic>> getReachStats();

  Future<List<ProductModel>> getProducts({
    String? search,
    String? cropType,
    String? community,
    double? minPrice,
    double? maxPrice,
    double? minStock,
    bool? verified,
  });
  
  Future<ProductModel?> getProduct(String id);
  Future<void> createProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> updateProductStock(String productId, double newStock);
  Future<void> softDeleteProduct(String productId);

  Future<void> createOrder(OrderModel order);
  Future<List<OrderModel>> getOrders({required String userId, required String role});
  Future<OrderModel?> getOrder(String id);
  Future<void> updateOrderStatus(String orderId, String status, String userId);

  Future<List<SalesLogModel>> getSalesLogs();
  Future<List<MarketPriceModel>> getMarketPrices();
  Future<void> createMarketPrice(MarketPriceModel price);
  Future<Map<String, dynamic>> getResearchDashboardData();
}

abstract class IStorageService {
  Future<String> uploadProductPhoto(String filePath);
}

abstract class ITelemetryService {
  Future<void> logEvent({
    required String eventType,
    String? userId,
    Map<String, dynamic>? metadata,
  });
  Future<Map<String, dynamic>> getTelemetryAnalytics();
}
