import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiClient {
  static late Dio _dio;
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    _dio = Dio(BaseOptions(
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
      sendTimeout: Duration(milliseconds: ApiConfig.sendTimeout),
      headers: ApiConfig.defaultHeaders,
    ));

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authentication token if available
          final token = await getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle token refresh on 401 errors
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request
              final token = await getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              } catch (e) {
                // If retry fails, clear tokens and continue with error
                await clearTokens();
              }
            } else {
              // Token refresh failed, clear tokens
              await clearTokens();
            }
          }
          handler.next(error);
        },
      ),
    );

    // Add logging in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  // Get methods
  static Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(url, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Post methods
  static Future<Response> post(String url, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(url, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Put methods
  static Future<Response> put(String url, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(url, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Delete methods
  static Future<Response> delete(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(url, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Token management
  static Future<String?> getAccessToken() async {
    return _prefs?.getString(ApiConfig.accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return _prefs?.getString(ApiConfig.refreshTokenKey);
  }

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _prefs?.setString(ApiConfig.accessTokenKey, accessToken);
    await _prefs?.setString(ApiConfig.refreshTokenKey, refreshToken);
    await _prefs?.setBool(ApiConfig.isLoggedInKey, true);
  }

  static Future<void> clearTokens() async {
    await _prefs?.remove(ApiConfig.accessTokenKey);
    await _prefs?.remove(ApiConfig.refreshTokenKey);
    await _prefs?.remove(ApiConfig.userDataKey);
    await _prefs?.setBool(ApiConfig.isLoggedInKey, false);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Private helper methods
  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await _dio.post(
        '${ApiConfig.authServiceUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newAccessToken = response.data['data']['accessToken'];
        final newRefreshToken = response.data['data']['refreshToken'];
        await saveTokens(newAccessToken, newRefreshToken);
        return true;
      }
    } catch (e) {
      print('Token refresh failed: $e');
    }
    return false;
  }

  static ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException('Connection timeout. Please check your internet connection.');
      case DioExceptionType.sendTimeout:
        return ApiException('Request timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return ApiException('Server response timeout. Please try again.');
      case DioExceptionType.badResponse:
        if (error.response?.data != null) {
          final message = error.response?.data['message'] ?? 'An error occurred';
          return ApiException(message, statusCode: error.response?.statusCode);
        }
        return ApiException('Server error. Please try again later.');
      case DioExceptionType.cancel:
        return ApiException('Request cancelled.');
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true) {
          return ApiException('No internet connection. Please check your network.');
        }
        return ApiException('An unexpected error occurred. Please try again.');
      default:
        return ApiException('An unexpected error occurred. Please try again.');
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}