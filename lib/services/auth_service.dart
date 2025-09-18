import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Registration
  static Future<ApiResponse<UserModel>> register({
    required String email,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required String idCardNumber,
  }) async {
    try {
      final response = await ApiClient.post(
        '${ApiConfig.authServiceUrl}/auth/register',
        data: {
          'email': email,
          'phone': phone,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'idCardNumber': idCardNumber,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final userData = response.data['data']['user'];
        final accessToken = response.data['data']['accessToken'];
        final refreshToken = response.data['data']['refreshToken'];

        // Save tokens
        await ApiClient.saveTokens(accessToken, refreshToken);
        
        // Save user data
        final user = UserModel.fromJson(userData);
        await _saveUserData(user);

        return ApiResponse.success(user, response.data['message'] ?? 'Registration successful');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Registration failed');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Registration failed. Please try again.');
    }
  }

  // User Login
  static Future<ApiResponse<UserModel>> login({
    required String identifier, // email or phone
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await ApiClient.post(
        '${ApiConfig.authServiceUrl}/auth/login',
        data: {
          'identifier': identifier,
          'password': password,
          'rememberMe': rememberMe,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final userData = response.data['data']['user'];
        final accessToken = response.data['data']['accessToken'];
        final refreshToken = response.data['data']['refreshToken'];

        // Save tokens
        await ApiClient.saveTokens(accessToken, refreshToken);
        
        // Save user data
        final user = UserModel.fromJson(userData);
        await _saveUserData(user);

        return ApiResponse.success(user, response.data['message'] ?? 'Login successful');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Login failed');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Login failed. Please try again.');
    }
  }

  // Get Current User
  static Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final response = await ApiClient.get('${ApiConfig.authServiceUrl}/auth/me');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final user = UserModel.fromJson(response.data['data']);
        await _saveUserData(user);
        return ApiResponse.success(user, 'User data retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get user data');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to get user data. Please try again.');
    }
  }

  // Logout
  static Future<ApiResponse<bool>> logout() async {
    try {
      // Attempt to logout on server
      await ApiClient.post('${ApiConfig.authServiceUrl}/auth/logout');
    } catch (e) {
      // Continue with local logout even if server logout fails
      print('Server logout failed: $e');
    }

    // Clear local data
    await ApiClient.clearTokens();
    await _clearUserData();
    
    return ApiResponse.success(true, 'Logged out successfully');
  }

  // Password Reset Request
  static Future<ApiResponse<bool>> requestPasswordReset(String email) async {
    try {
      final response = await ApiClient.post(
        '${ApiConfig.authServiceUrl}/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResponse.success(true, response.data['message'] ?? 'Password reset email sent');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Password reset request failed');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Password reset request failed. Please try again.');
    }
  }

  // Verify Email
  static Future<ApiResponse<bool>> verifyEmail(String token) async {
    try {
      final response = await ApiClient.post(
        '${ApiConfig.authServiceUrl}/auth/verify-email',
        data: {'token': token},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResponse.success(true, response.data['message'] ?? 'Email verified successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Email verification failed');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Email verification failed. Please try again.');
    }
  }

  // Check Email Availability
  static Future<ApiResponse<bool>> checkEmailAvailability(String email) async {
    try {
      final response = await ApiClient.get(
        '${ApiConfig.authServiceUrl}/auth/check-email?email=${Uri.encodeComponent(email)}',
      );

      if (response.statusCode == 200) {
        final isAvailable = response.data['available'] ?? false;
        if (isAvailable) {
          return ApiResponse.success(true, 'Email is available');
        } else {
          return ApiResponse.error('Email is already taken');
        }
      } else {
        return ApiResponse.error('Unable to check email availability');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      // Fallback - assume available to not block signup in case of network issues
      return ApiResponse.success(true, 'Email availability check unavailable');
    }
  }

  // Change Password
  static Future<ApiResponse<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiClient.post(
        '${ApiConfig.authServiceUrl}/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResponse.success(true, response.data['message'] ?? 'Password changed successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Password change failed');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Password change failed. Please try again.');
    }
  }

  // Helper methods for local data management
  static Future<UserModel?> getCachedUser() async {
    final userJson = _prefs?.getString(ApiConfig.userDataKey);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final userMap = jsonDecode(userJson);
        return UserModel.fromJson(userMap);
      } catch (e) {
        print('Error parsing cached user data: $e');
        await _clearUserData();
      }
    }
    return null;
  }

  static Future<void> _saveUserData(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs?.setString(ApiConfig.userDataKey, userJson);
  }

  static Future<void> _clearUserData() async {
    await _prefs?.remove(ApiConfig.userDataKey);
  }

  // Verify PIN and update user role
  static Future<ApiResponse<UserModel>> verifyPinAndUpdateRole({
    required String affiliation,
    required String position,
    required String pin,
  }) async {
    try {
      final response = await ApiClient.post(
        '${ApiConfig.authServiceUrl}/auth/verify-pin',
        data: {
          'affiliation': affiliation,
          'position': position,
          'pin': pin,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final userData = response.data['data']['user'];
        final user = UserModel.fromJson(userData);
        await _saveUserData(user);
        return ApiResponse.success(user, response.data['message'] ?? 'PIN verified successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'PIN verification failed');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('PIN verification failed. Please try again.');
    }
  }

  // Update user affiliation and position (without PIN)
  static Future<ApiResponse<UserModel>> updateUserRole({
    required String affiliation,
    String? position,
  }) async {
    try {
      final response = await ApiClient.put(
        '${ApiConfig.authServiceUrl}/auth/update-role',
        data: {
          'affiliation': affiliation,
          if (position != null) 'position': position,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final userData = response.data['data']['user'];
        final user = UserModel.fromJson(userData);
        await _saveUserData(user);
        return ApiResponse.success(user, response.data['message'] ?? 'Role updated successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Role update failed');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Role update failed. Please try again.');
    }
  }

  // Check authentication status
  static Future<bool> isAuthenticated() async {
    return await ApiClient.isLoggedIn();
  }
}

// Generic API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;

  ApiResponse.success(this.data, this.message) : success = true;
  ApiResponse.error(this.message) : success = false, data = null;
}