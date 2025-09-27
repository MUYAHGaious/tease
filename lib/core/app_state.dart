import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/mock_auth_service.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Authentication state
  bool _isAuthenticated = false;
  bool _isLoading = false;
  UserModel? _currentUser;
  String? _authError;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  String? get authError => _authError;
  bool get hasUser => _currentUser != null;

  // User info getters
  String get userName => _currentUser?.displayName ?? 'User';
  String get userEmail => _currentUser?.email ?? '';
  String? get userProfileImage => _currentUser?.profileImageUrl;

  // Initialize authentication state
  Future<void> initialize() async {
    _setLoading(true);

    try {
      // Initialize mock auth service
      await MockAuthService.initialize();

      // Check if user is logged in (mock)
      final isLoggedIn = await MockAuthService.isLoggedIn();

      if (isLoggedIn) {
        // Get current user from mock service
        final currentUser = await MockAuthService.getCurrentUser();
        if (currentUser != null) {
          _setUser(currentUser);
          _setAuthenticated(true);
        } else {
          await _clearAuthState();
        }
      } else {
        await _clearAuthState();
      }
    } catch (e) {
      debugPrint('Error initializing app state: $e');
      await _clearAuthState();
    } finally {
      _setLoading(false);
    }
  }

  // Login user (mock)
  Future<bool> login(String identifier, String password, {bool rememberMe = false}) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await MockAuthService.login(
        identifier: identifier,
        password: password,
        rememberMe: rememberMe,
      );

      if (result.success && result.data != null) {
        _setUser(result.data!);
        _setAuthenticated(true);
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Register user (mock)
  Future<bool> register({
    required String email,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    String idCardNumber = '',
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await MockAuthService.register(
        email: email,
        phone: phone,
        password: password,
        firstName: firstName,
        lastName: lastName,
        idCardNumber: idCardNumber,
      );

      if (result.success && result.data != null) {
        _setUser(result.data!);
        _setAuthenticated(true);
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Registration failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Logout user (mock)
  Future<void> logout() async {
    _setLoading(true);

    try {
      await MockAuthService.logout();
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      await _clearAuthState();
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateUser(UserModel updatedUser) async {
    try {
      _setUser(updatedUser);
      return true;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  // Refresh user data (mock)
  Future<bool> refreshUserData() async {
    if (!_isAuthenticated) return false;

    try {
      final currentUser = await MockAuthService.getCurrentUser();
      if (currentUser != null) {
        _setUser(currentUser);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
      return false;
    }
  }

  // Quick login for development (switch between users)
  Future<bool> quickLogin(UserModel user) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await MockAuthService.quickLogin(user);

      if (result.success && result.data != null) {
        _setUser(result.data!);
        _setAuthenticated(true);
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Quick login failed.');
      _setLoading(false);
      return false;
    }
  }

  // Verify PIN and update role
  Future<bool> verifyPinAndUpdateRole({
    required String affiliation,
    required String position,
    required String pin,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await MockAuthService.verifyPinAndUpdateRole(
        affiliation: affiliation,
        position: position,
        pin: pin,
      );

      if (result.success && result.data != null) {
        _setUser(result.data!);
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('PIN verification failed.');
      _setLoading(false);
      return false;
    }
  }

  // Get mock users for development
  List<UserModel> getMockUsers() {
    return MockAuthService.getMockUsers();
  }

  // Private helper methods
  void _setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void _setError(String? error) {
    _authError = error;
    notifyListeners();
  }

  Future<void> _clearAuthState() async {
    _isAuthenticated = false;
    _currentUser = null;
    _authError = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _authError = null;
    notifyListeners();
  }
}