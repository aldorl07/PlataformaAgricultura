import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../services/service_locator.dart';
import '../../catalog/models/product_model.dart';
import '../../admin/models/market_price_model.dart';
import '../models/order_model.dart';

class CartItem {
  final ProductModel product;
  double quantity;
  final String farmerName;

  CartItem({
    required this.product,
    required this.quantity,
    required this.farmerName,
  });

  double get lineTotal => product.pricePerUnit * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Shipping simulation state
  String _deliveryAddress = '';
  String _transportMethod = 'shared_freight'; // own_truck, shared_freight, pickup
  double _shippingCost = 80.0;
  DateTime? _deliveryDate;
  String _buyerNotes = '';

  Map<String, CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get deliveryAddress => _deliveryAddress;
  String get transportMethod => _transportMethod;
  double get shippingCost => _shippingCost;
  DateTime? get deliveryDate => _deliveryDate;
  String get buyerNotes => _buyerNotes;

  // Reference wholesale prices to calculate savings
  List<MarketPriceModel> _marketPrices = [];

  CartProvider() {
    _loadMarketPrices();
  }

  Future<void> _loadMarketPrices() async {
    try {
      _marketPrices = await ServiceLocator.firestoreService.getMarketPrices();
    } catch (_) {}
  }

  void addToCart(ProductModel product, String farmerName, {double quantity = 10.0}) {
    if (_items.containsKey(product.id)) {
      final currentQty = _items[product.id]!.quantity;
      _items[product.id]!.quantity = (currentStockAdjust(product, currentQty + quantity));
    } else {
      _items[product.id] = CartItem(
        product: product,
        quantity: currentStockAdjust(product, quantity),
        farmerName: farmerName,
      );
    }
    notifyListeners();
  }

  double currentStockAdjust(ProductModel product, double qty) {
    if (qty > product.stock) return product.stock;
    if (qty < 1) return 1.0;
    return qty;
  }

  void updateQuantity(String productId, double quantity) {
    if (_items.containsKey(productId)) {
      final item = _items[productId]!;
      _items[productId]!.quantity = currentStockAdjust(item.product, quantity);
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _deliveryAddress = '';
    _transportMethod = 'shared_freight';
    _shippingCost = 80.0;
    _deliveryDate = null;
    _buyerNotes = '';
    notifyListeners();
  }

  // Cost breakdown
  double get subtotal => _items.values.fold(0.0, (sum, item) => sum + item.lineTotal);
  
  double get platformFee => subtotal * 0.02; // 2% commission
  
  double get totalAmount => subtotal + platformFee + _shippingCost;

  // Intermediary savings calculations (Y2)
  double get estimatedSavings {
    double totalSavings = 0.0;
    for (final item in _items.values) {
      final cropType = item.product.cropType;
      // find reference price
      final ref = _marketPrices.firstWhere(
        (mp) => mp.cropType == cropType,
        orElse: () => MarketPriceModel(
          id: '',
          cropType: cropType,
          cropName: '',
          marketName: '',
          pricePerKg: item.product.pricePerUnit * 1.30, // 30% mark-up fallback
          source: '',
          effectiveDate: DateTime.now(),
        ),
      );

      final savingPerKg = (ref.pricePerKg - item.product.pricePerUnit).clamp(0, double.infinity);
      totalSavings += savingPerKg * item.quantity;
    }
    return totalSavings;
  }

  double get savingsPercent {
    if (subtotal == 0) return 0.0;
    final traditionalCost = subtotal + estimatedSavings;
    return (estimatedSavings / traditionalCost) * 100;
  }

  void setDeliveryAddress(String address) {
    _deliveryAddress = address;
    notifyListeners();
  }

  void setTransportMethod(String method) {
    _transportMethod = method;
    if (method == 'shared_freight') {
      _shippingCost = 80.0;
    } else if (method == 'own_truck' || method == 'pickup') {
      _shippingCost = 0.0;
    } else {
      _shippingCost = 150.0; // custom truck rate
    }
    notifyListeners();
  }

  void setDeliveryDate(DateTime date) {
    _deliveryDate = date;
    notifyListeners();
  }

  void setBuyerNotes(String notes) {
    _buyerNotes = notes;
    notifyListeners();
  }

  Future<bool> checkout(String buyerId) async {
    if (_items.isEmpty) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final orderId = 'order_${const Uuid().v4()}';
      
      final orderItems = _items.values.map((item) => OrderItem(
        productId: item.product.id,
        farmerId: item.product.farmerId,
        productName: item.product.name,
        quantity: item.quantity,
        unit: item.product.unit,
        unitPrice: item.product.pricePerUnit,
        lineTotal: item.lineTotal,
      )).toList();

      final order = OrderModel(
        id: orderId,
        buyerId: buyerId,
        items: orderItems,
        subtotal: subtotal,
        shippingCost: _shippingCost,
        platformFee: platformFee,
        totalAmount: totalAmount,
        estimatedSavings: estimatedSavings,
        savingsPercent: savingsPercent,
        deliveryAddress: _deliveryAddress,
        deliveryDate: _deliveryDate,
        buyerNotes: _buyerNotes,
        status: 'pending',
        statusHistory: [
          StatusChange(
            status: 'pending',
            changedAt: DateTime.now(),
            changedBy: buyerId,
          ),
        ],
        createdAt: DateTime.now(),
      );

      // Write order to DB (which reduces stock)
      await ServiceLocator.firestoreService.createOrder(order);
      
      // Log telemetry event
      ServiceLocator.telemetryService.logEvent(
        eventType: 'order_submitted',
        userId: buyerId,
        metadata: {
          'orderId': orderId,
          'totalAmount': totalAmount,
          'savings': estimatedSavings,
        },
      );

      clearCart();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
