import 'dart:io';
import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  // Get user profile
  static Future<ApiResponse<UserModel>> getUserProfile() async {
    try {
      final response = await ApiClient.get('${ApiConfig.userServiceUrl}/users/profile');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final user = UserModel.fromJson(response.data['data']);
        return ApiResponse.success(user, 'Profile retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get profile');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to get profile. Please try again.');
    }
  }

  // Update user profile
  static Future<ApiResponse<UserModel>> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final data = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
      };
      
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      if (preferences != null) data['preferences'] = preferences;

      final response = await ApiClient.put(
        '${ApiConfig.userServiceUrl}/users/profile',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final user = UserModel.fromJson(response.data['data']);
        return ApiResponse.success(user, 'Profile updated successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to update profile');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to update profile. Please try again.');
    }
  }

  // Upload profile image
  static Future<ApiResponse<String>> uploadProfileImage(File imageFile) async {
    try {
      // Create FormData for file upload
      final formData = FormData();
      formData.files.add(MapEntry(
        'profileImage',
        await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      ));

      final response = await ApiClient.post(
        '${ApiConfig.userServiceUrl}/users/profile/image',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final imageUrl = response.data['data']['profileImage'] as String;
        return ApiResponse.success(imageUrl, 'Profile image uploaded successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to upload image');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to upload image. Please try again.');
    }
  }

  // Update user preferences
  static Future<ApiResponse<UserPreferences>> updatePreferences(
    UserPreferences preferences,
  ) async {
    try {
      final response = await ApiClient.put(
        '${ApiConfig.userServiceUrl}/users/preferences',
        data: {'preferences': preferences.toJson()},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final updatedPrefs = UserPreferences.fromJson(response.data['data']['preferences']);
        return ApiResponse.success(updatedPrefs, 'Preferences updated successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to update preferences');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to update preferences. Please try again.');
    }
  }

  // Delete user account
  static Future<ApiResponse<bool>> deleteAccount() async {
    try {
      final response = await ApiClient.delete('${ApiConfig.userServiceUrl}/users/profile');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Clear local data
        await ApiClient.clearTokens();
        return ApiResponse.success(true, 'Account deleted successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to delete account');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to delete account. Please try again.');
    }
  }

  // Get user statistics (if available)
  static Future<ApiResponse<Map<String, dynamic>>> getUserStats() async {
    try {
      final response = await ApiClient.get('${ApiConfig.userServiceUrl}/users/stats');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final stats = response.data['data'] as Map<String, dynamic>;
        return ApiResponse.success(stats, 'Stats retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get stats');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to get stats. Please try again.');
    }
  }
}

// FormData and MultipartFile classes for file uploads
class FormData {
  final List<MapEntry<String, dynamic>> fields = [];
  final List<MapEntry<String, MultipartFile>> files = [];

  void add(String key, dynamic value) {
    fields.add(MapEntry(key, value));
  }
}

class MultipartFile {
  final String path;
  final String? filename;

  MultipartFile._(this.path, this.filename);

  static Future<MultipartFile> fromFile(String path, {String? filename}) async {
    return MultipartFile._(path, filename);
  }
}