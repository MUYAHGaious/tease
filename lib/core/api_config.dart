class ApiConfig {
  // Backend service URLs - update these to match your backend deployment
  static const String baseUrl = 'http://localhost'; // Change to your server IP
  
  // Microservice endpoints
  static const String authServiceUrl = '$baseUrl:3001/api/v1';
  static const String userServiceUrl = '$baseUrl:3002/api/v1';
  static const String busServiceUrl = '$baseUrl:3003/api/v1';
  
  // API timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
  
  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Request headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Rate limiting
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // milliseconds
}