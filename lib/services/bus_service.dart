import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/bus_models.dart';
import 'auth_service.dart';

class BusService {
  // Get all bus operators
  static Future<ApiResponse<List<BusOperator>>> getBusOperators({
    int page = 1,
    int limit = 20,
    String? search,
    bool? verified,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (verified != null) queryParams['verified'] = verified;

      final response = await ApiClient.get(
        '${ApiConfig.busServiceUrl}/operators',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final operatorsData = response.data['data']['operators'] as List;
        final operators = operatorsData.map((json) => BusOperator.fromJson(json)).toList();
        return ApiResponse.success(operators, 'Bus operators retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get bus operators');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to get bus operators. Please try again.');
    }
  }

  // Get bus operator by ID
  static Future<ApiResponse<BusOperator>> getBusOperator(String operatorId) async {
    try {
      final response = await ApiClient.get('${ApiConfig.busServiceUrl}/operators/$operatorId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final operator = BusOperator.fromJson(response.data['data']);
        return ApiResponse.success(operator, 'Bus operator retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get bus operator');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to get bus operator. Please try again.');
    }
  }

  // Search routes between locations
  static Future<ApiResponse<List<BusRoute>>> searchRoutes({
    required String from,
    required String to,
    double radius = 5.0,
    DateTime? date,
    String? busType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'from': from,
        'to': to,
        'radius': radius,
      };
      if (date != null) queryParams['date'] = date.toIso8601String().split('T')[0];
      if (busType != null && busType.isNotEmpty) queryParams['busType'] = busType;

      final response = await ApiClient.get(
        '${ApiConfig.busServiceUrl}/routes/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final routesData = response.data['data']['routes'] as List;
        final routes = routesData.map((json) => BusRoute.fromJson(json)).toList();
        return ApiResponse.success(routes, 'Routes found successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'No routes found');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to search routes. Please try again.');
    }
  }

  // Get route details
  static Future<ApiResponse<BusRoute>> getRoute(String routeId) async {
    try {
      final response = await ApiClient.get('${ApiConfig.busServiceUrl}/routes/$routeId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final route = BusRoute.fromJson(response.data['data']);
        return ApiResponse.success(route, 'Route retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get route');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to get route. Please try again.');
    }
  }

  // Get bus details
  static Future<ApiResponse<Bus>> getBus(String busId) async {
    try {
      final response = await ApiClient.get('${ApiConfig.busServiceUrl}/buses/$busId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final bus = Bus.fromJson(response.data['data']);
        return ApiResponse.success(bus, 'Bus retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get bus details');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to get bus details. Please try again.');
    }
  }

  // Get buses by operator
  static Future<ApiResponse<List<Bus>>> getBusesByOperator(
    String operatorId, {
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await ApiClient.get(
        '${ApiConfig.busServiceUrl}/operators/$operatorId/buses',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final busesData = response.data['data']['buses'] as List;
        final buses = busesData.map((json) => Bus.fromJson(json)).toList();
        return ApiResponse.success(buses, 'Buses retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get buses');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to get buses. Please try again.');
    }
  }

  // Get routes by operator
  static Future<ApiResponse<List<BusRoute>>> getRoutesByOperator(
    String operatorId, {
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await ApiClient.get(
        '${ApiConfig.busServiceUrl}/operators/$operatorId/routes',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final routesData = response.data['data']['routes'] as List;
        final routes = routesData.map((json) => BusRoute.fromJson(json)).toList();
        return ApiResponse.success(routes, 'Routes retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get routes');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to get routes. Please try again.');
    }
  }

  // Get popular routes
  static Future<ApiResponse<List<BusRoute>>> getPopularRoutes({
    int limit = 10,
    String? location,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (location != null && location.isNotEmpty) queryParams['location'] = location;

      final response = await ApiClient.get(
        '${ApiConfig.busServiceUrl}/routes/popular',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final routesData = response.data['data']['routes'] as List;
        final routes = routesData.map((json) => BusRoute.fromJson(json)).toList();
        return ApiResponse.success(routes, 'Popular routes retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get popular routes');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to get popular routes. Please try again.');
    }
  }

  // Get nearby routes based on location
  static Future<ApiResponse<List<BusRoute>>> getNearbyRoutes({
    required double latitude,
    required double longitude,
    double radius = 10.0,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'limit': limit,
      };

      final response = await ApiClient.get(
        '${ApiConfig.busServiceUrl}/routes/nearby',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final routesData = response.data['data']['routes'] as List;
        final routes = routesData.map((json) => BusRoute.fromJson(json)).toList();
        return ApiResponse.success(routes, 'Nearby routes retrieved successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'No nearby routes found');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to get nearby routes. Please try again.');
    }
  }

  // Calculate fare for a route
  static Future<ApiResponse<double>> calculateFare(
    String routeId, {
    int passengers = 1,
    String? busType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'passengers': passengers,
      };
      if (busType != null && busType.isNotEmpty) queryParams['busType'] = busType;

      final response = await ApiClient.get(
        '${ApiConfig.busServiceUrl}/routes/$routeId/fare',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final fare = (response.data['data']['fare'] as num).toDouble();
        return ApiResponse.success(fare, 'Fare calculated successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to calculate fare');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to calculate fare. Please try again.');
    }
  }

  // Search locations (for autocomplete)
  static Future<ApiResponse<List<Location>>> searchLocations(String query) async {
    try {
      final response = await ApiClient.get(
        '${ApiConfig.busServiceUrl}/locations/search',
        queryParameters: {'q': query, 'limit': 10},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final locationsData = response.data['data']['locations'] as List;
        final locations = locationsData.map((json) => Location.fromJson(json)).toList();
        return ApiResponse.success(locations, 'Locations found successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'No locations found');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to search locations. Please try again.');
    }
  }
}