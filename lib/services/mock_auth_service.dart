import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

// 2025 Design Constants
const Color primaryColor = Color(0xFF008B8B);

class MockAuthService {
  static SharedPreferences? _prefs;
  static const String _currentUserKey = 'mock_current_user';
  static const String _isLoggedInKey = 'mock_is_logged_in';

  // Mock users with different roles for development
  static final List<UserModel> _mockUsers = [
    // Ordinary user
    UserModel(
      id: 'user_1',
      email: 'john.doe@example.com',
      firstName: 'John',
      lastName: 'Doe',
      phone: '+237123456789',
      role: 'ordinary_user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // University student
    UserModel(
      id: 'student_1',
      email: 'alice.student@ictuniversity.cm',
      firstName: 'Alice',
      lastName: 'Johnson',
      phone: '+237987654321',
      role: 'ordinary_user',
      affiliation: 'ict_university',
      position: 'student',
      pinVerified: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // University staff
    UserModel(
      id: 'staff_1',
      email: 'dr.smith@ictuniversity.cm',
      firstName: 'Dr. Michael',
      lastName: 'Smith',
      phone: '+237555666777',
      role: 'ordinary_user',
      affiliation: 'ict_university',
      position: 'staff',
      pinVerified: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Bus conductor
    UserModel(
      id: 'conductor_1',
      email: 'conductor@buscompany.cm',
      firstName: 'Emmanuel',
      lastName: 'Nkomo',
      phone: '+237111222333',
      role: 'conductor',
      affiliation: 'agency',
      position: 'conductor',
      pinVerified: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Bus driver
    UserModel(
      id: 'driver_1',
      email: 'driver@buscompany.cm',
      firstName: 'Paul',
      lastName: 'Biya',
      phone: '+237444555666',
      role: 'driver',
      affiliation: 'agency',
      position: 'driver',
      pinVerified: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Booking clerk
    UserModel(
      id: 'clerk_1',
      email: 'clerk@busagency.cm',
      firstName: 'Marie',
      lastName: 'Dupont',
      phone: '+237777888999',
      role: 'booking_clerk',
      affiliation: 'agency',
      position: 'booking_clerk',
      pinVerified: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Schedule manager
    UserModel(
      id: 'manager_1',
      email: 'manager@busagency.cm',
      firstName: 'Jean-Claude',
      lastName: 'Mbarga',
      phone: '+237123987456',
      role: 'schedule_manager',
      affiliation: 'agency',
      position: 'schedule_manager',
      pinVerified: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Mock login with email/phone
  static Future<MockApiResponse<UserModel>> login({
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) async {
    await Future.delayed(
        const Duration(milliseconds: 800)); // Simulate network delay

    // Find user by email or phone
    final user = _mockUsers.firstWhere(
      (u) => u.email == identifier || u.phone == identifier,
      orElse: () => throw Exception('User not found'),
    );

    // Save login state
    await _saveCurrentUser(user);
    await _prefs?.setBool(_isLoggedInKey, true);

    return MockApiResponse.success(
      user,
      'Welcome back, ${user.firstName}!',
    );
  }

  // Mock logout
  static Future<MockApiResponse<bool>> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));

    await _prefs?.remove(_currentUserKey);
    await _prefs?.setBool(_isLoggedInKey, false);

    return MockApiResponse.success(true, 'Logged out successfully');
  }

  // Get current user
  static Future<UserModel?> getCurrentUser() async {
    final userJson = _prefs?.getString(_currentUserKey);
    if (userJson != null) {
      final userMap = jsonDecode(userJson);
      return UserModel.fromJson(userMap);
    }
    return null;
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    return _prefs?.getBool(_isLoggedInKey) ?? false;
  }

  // Mock PIN verification for role elevation
  static Future<MockApiResponse<UserModel>> verifyPinAndUpdateRole({
    required String affiliation,
    required String position,
    required String pin,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // Mock PIN validation (in real app, this would be server-side)
    final validPins = {
      'ict_university': '1234',
      'agency': '5678',
    };

    if (validPins[affiliation] != pin) {
      return MockApiResponse.error('Invalid PIN. Please try again.');
    }

    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      return MockApiResponse.error('No user logged in');
    }

    // Update user with new role
    final updatedUser = currentUser.copyWith(
      affiliation: affiliation,
      position: position,
      pinVerified: true,
      role: position == 'student' || position == 'staff'
          ? 'ordinary_user'
          : position,
    );

    await _saveCurrentUser(updatedUser);

    return MockApiResponse.success(
      updatedUser,
      'Access granted! Welcome to ${_getAffiliationDisplayName(affiliation)}.',
    );
  }

  // Mock register
  static Future<MockApiResponse<UserModel>> register({
    required String email,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required String idCardNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Check if email already exists
    final existingUser = _mockUsers.any((u) => u.email == email);
    if (existingUser) {
      return MockApiResponse.error('Email already registered');
    }

    // Create new user
    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      idCardNumber: idCardNumber,
      role: 'ordinary_user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Add to mock users list
    _mockUsers.add(newUser);

    // Save login state
    await _saveCurrentUser(newUser);
    await _prefs?.setBool(_isLoggedInKey, true);

    return MockApiResponse.success(
      newUser,
      'Account created successfully! Welcome, ${newUser.firstName}!',
    );
  }

  // Get mock users for development/testing
  static List<UserModel> getMockUsers() => List.from(_mockUsers);

  // Quick login for development (switch between users)
  static Future<MockApiResponse<UserModel>> quickLogin(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 300));

    await _saveCurrentUser(user);
    await _prefs?.setBool(_isLoggedInKey, true);

    return MockApiResponse.success(
      user,
      'Switched to ${user.fullName} (${user.role})',
    );
  }

  // Helper methods
  static Future<void> _saveCurrentUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs?.setString(_currentUserKey, userJson);
  }

  // Public method to update user affiliation without PIN
  static Future<MockApiResponse<UserModel>> updateUserAffiliation({
    required String affiliation,
    required String position,
  }) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      return MockApiResponse.error('No user logged in');
    }

    final updatedUser = currentUser.copyWith(
      affiliation: affiliation,
      position: position,
      pinVerified: false,
    );

    await _saveCurrentUser(updatedUser);

    return MockApiResponse.success(
      updatedUser,
      '${_getAffiliationDisplayName(affiliation)} affiliation updated',
    );
  }

  static String _getAffiliationDisplayName(String affiliation) {
    switch (affiliation) {
      case 'ict_university':
        return 'ICT University';
      case 'agency':
        return 'Bus Agency Portal';
      default:
        return 'System';
    }
  }

  // Get role-specific dashboard data
  static Map<String, dynamic> getRoleDashboardConfig(UserModel user) {
    switch (user.role) {
      case 'conductor':
      case 'driver':
        return {
          'primaryActions': [
            {
              'title': 'Scan Tickets',
              'icon': 'qr_code_scanner',
              'route': '/ticket-scanner'
            },
            {
              'title': 'Bus Status',
              'icon': 'directions_bus',
              'route': '/bus-status'
            },
            {
              'title': 'Passenger List',
              'icon': 'people',
              'route': '/passenger-list'
            },
            {'title': 'Emergency', 'icon': 'emergency', 'route': '/emergency'},
          ],
          'showBookingHistory': false,
          'showFavorites': false,
          'showSchoolBus': false,
        };

      case 'booking_clerk':
      case 'schedule_manager':
        return {
          'primaryActions': [
            {
              'title': 'Manage Seats',
              'icon': 'airline_seat_recline_normal',
              'route': '/seat-management'
            },
            {
              'title': 'Bookings',
              'icon': 'book_online',
              'route': '/booking-management'
            },
            {'title': 'Routes', 'icon': 'route', 'route': '/route-management'},
            {'title': 'Reports', 'icon': 'analytics', 'route': '/reports'},
          ],
          'showBookingHistory': true,
          'showFavorites': false,
          'showSchoolBus': false,
        };

      default:
        if (user.canAccessSchoolBus) {
          return {
            'primaryActions': [
              {
                'title': 'Book Ticket',
                'icon': 'add_circle_outline',
                'route': '/search-booking'
              },
              {
                'title': 'School Bus',
                'icon': 'school',
                'route': '/school-bus-home'
              },
              {
                'title': 'Track Buses',
                'icon': 'location_on',
                'route': '/bus-tracking-map'
              },
              {
                'title': 'My Tickets',
                'icon': 'confirmation_number_outlined',
                'route': '/my-tickets'
              },
            ],
            'showBookingHistory': true,
            'showFavorites': true,
            'showSchoolBus': true,
          };
        }
        return {
          'primaryActions': [
            {
              'title': 'Book Ticket',
              'icon': 'add_circle_outline',
              'route': '/search-booking'
            },
            {
              'title': 'Search Buses',
              'icon': 'search',
              'route': '/search-booking'
            },
            {
              'title': 'Track Buses',
              'icon': 'location_on',
              'route': '/bus-tracking-map'
            },
            {
              'title': 'My Tickets',
              'icon': 'confirmation_number_outlined',
              'route': '/my-tickets'
            },
          ],
          'showBookingHistory': true,
          'showFavorites': true,
          'showSchoolBus': false,
        };
    }
  }
}

// Mock API Response wrapper
class MockApiResponse<T> {
  final bool success;
  final T? data;
  final String message;

  MockApiResponse.success(this.data, this.message) : success = true;
  MockApiResponse.error(this.message)
      : success = false,
        data = null;
}
