import 'package:flutter/material.dart';
import '../../../services/service_locator.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _currentUser = ServiceLocator.authService.currentUser;
    ServiceLocator.authService.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await ServiceLocator.authService.signIn(
        email: email,
        password: password,
      );
      
      // Log telemetry event
      ServiceLocator.telemetryService.logEvent(
        eventType: 'login_complete',
        userId: _currentUser?.id,
        metadata: {'role': _currentUser?.role},
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String role,
    required String fullName,
    required String phone,
    required String preferredContact,
    FarmerProfile? farmerProfile,
    BuyerProfile? buyerProfile,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await ServiceLocator.authService.signUp(
        email: email,
        password: password,
        role: role,
        fullName: fullName,
        phone: phone,
        preferredContact: preferredContact,
        farmerProfile: farmerProfile,
        buyerProfile: buyerProfile,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_currentUser != null) {
        ServiceLocator.telemetryService.logEvent(
          eventType: 'logout',
          userId: _currentUser?.id,
        );
      }
      await ServiceLocator.authService.signOut();
      _currentUser = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    try {
      await ServiceLocator.firestoreService.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
