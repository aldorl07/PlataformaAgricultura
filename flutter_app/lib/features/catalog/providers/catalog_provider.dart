import 'package:flutter/material.dart';
import '../../../services/service_locator.dart';
import '../models/product_model.dart';
import '../../auth/models/user_model.dart';

class CatalogProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Cache of farmers mapping farmerId -> UserModel
  final Map<String, UserModel> _farmerCache = {};

  // Active filters
  String _searchQuery = '';
  String _selectedCropType = 'todos';
  String _selectedCommunity = '';
  double? _minPrice;
  double? _maxPrice;
  double _minStock = 0.0;
  bool _onlyVerified = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, UserModel> get farmerCache => _farmerCache;

  // Filters getters/setters
  String get searchQuery => _searchQuery;
  String get selectedCropType => _selectedCropType;
  String get selectedCommunity => _selectedCommunity;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  double get minStock => _minStock;
  bool get onlyVerified => _onlyVerified;

  String? _lastUserId;
  bool _hasLoadedOnce = false;

  CatalogProvider();

  void updateAuth(String? userId) {
    if (!_hasLoadedOnce || _lastUserId != userId) {
      _hasLoadedOnce = true;
      _lastUserId = userId;
      loadCatalog();
    }
  }


  void setSearchQuery(String val) {
    _searchQuery = val;
    loadCatalog();
  }

  void setCropType(String val) {
    _selectedCropType = val;
    loadCatalog();
  }

  void setCommunity(String val) {
    _selectedCommunity = val;
    loadCatalog();
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    loadCatalog();
  }

  void setMinStock(double val) {
    _minStock = val;
    loadCatalog();
  }

  void setOnlyVerified(bool val) {
    _onlyVerified = val;
    loadCatalog();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCropType = 'todos';
    _selectedCommunity = '';
    _minPrice = null;
    _maxPrice = null;
    _minStock = 0.0;
    _onlyVerified = false;
    loadCatalog();
  }

  Future<void> loadCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch catalog products based on current filters
      _products = await ServiceLocator.firestoreService.getProducts(
        search: _searchQuery,
        cropType: _selectedCropType,
        community: _selectedCommunity,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minStock: _minStock > 0 ? _minStock : null,
        verified: _onlyVerified,
      );

      // 2. Fetch farmers for the products to populate the cache
      final farmerIds = _products.map((p) => p.farmerId).toSet();
      for (final fid in farmerIds) {
        if (!_farmerCache.containsKey(fid)) {
          final farmer = await ServiceLocator.firestoreService.getUser(fid);
          if (farmer != null) {
            _farmerCache[fid] = farmer;
          }
        }
      }
      
      // Log telemetry event for filter search
      if (_searchQuery.isNotEmpty || _selectedCropType != 'todos' || _selectedCommunity.isNotEmpty) {
        ServiceLocator.telemetryService.logEvent(
          eventType: 'search_performed',
          metadata: {
            'query': _searchQuery,
            'cropType': _selectedCropType,
            'community': _selectedCommunity,
          },
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  UserModel? getFarmerForProduct(String farmerId) {
    return _farmerCache[farmerId];
  }
}
