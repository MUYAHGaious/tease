import 'dart:math';

class MockDataService {
  // Cameroon cities and popular destinations
  static final List<Map<String, dynamic>> cameroonCities = [
    {
      "id": 1,
      "name": "Douala",
      "region": "Littoral",
      "isPopular": true,
      "busStationsCount": 8,
      "popularRoutes": ["Yaoundé", "Bamenda", "Kumba", "Limbe"]
    },
    {
      "id": 2,
      "name": "Yaoundé",
      "region": "Centre",
      "isPopular": true,
      "busStationsCount": 12,
      "popularRoutes": ["Douala", "Bamenda", "Bafoussam", "Ebolowa"]
    },
    {
      "id": 3,
      "name": "Bamenda",
      "region": "Northwest",
      "isPopular": true,
      "busStationsCount": 6,
      "popularRoutes": ["Douala", "Yaoundé", "Bafoussam", "Limbe"]
    },
    {
      "id": 4,
      "name": "Bafoussam",
      "region": "West",
      "isPopular": true,
      "busStationsCount": 4,
      "popularRoutes": ["Douala", "Yaoundé", "Bamenda", "Dschang"]
    },
    {
      "id": 5,
      "name": "Kumba",
      "region": "Southwest",
      "isPopular": false,
      "busStationsCount": 3,
      "popularRoutes": ["Douala", "Limbe", "Buea", "Mamfe"]
    },
    {
      "id": 6,
      "name": "Limbe",
      "region": "Southwest",
      "isPopular": false,
      "busStationsCount": 2,
      "popularRoutes": ["Douala", "Kumba", "Buea", "Bamenda"]
    },
    {
      "id": 7,
      "name": "Buea",
      "region": "Southwest",
      "isPopular": false,
      "busStationsCount": 2,
      "popularRoutes": ["Douala", "Kumba", "Limbe"]
    },
    {
      "id": 8,
      "name": "Garoua",
      "region": "North",
      "isPopular": false,
      "busStationsCount": 3,
      "popularRoutes": ["Yaoundé", "Ngaoundéré", "Maroua"]
    },
    {
      "id": 9,
      "name": "Maroua",
      "region": "Far North",
      "isPopular": false,
      "busStationsCount": 2,
      "popularRoutes": ["Garoua", "Yaoundé", "Ngaoundéré"]
    },
    {
      "id": 10,
      "name": "Ngaoundéré",
      "region": "Adamawa",
      "isPopular": false,
      "busStationsCount": 2,
      "popularRoutes": ["Yaoundé", "Garoua", "Maroua"]
    },
    {
      "id": 11,
      "name": "Ebolowa",
      "region": "South",
      "isPopular": false,
      "busStationsCount": 2,
      "popularRoutes": ["Yaoundé", "Sangmélima", "Kribi"]
    },
    {
      "id": 12,
      "name": "Bertoua",
      "region": "East",
      "isPopular": false,
      "busStationsCount": 1,
      "popularRoutes": ["Yaoundé", "Batouri"]
    }
  ];

  // Bus operators in Cameroon
  static final List<Map<String, dynamic>> busOperators = [
    {
      "id": 1,
      "name": "Guarantee Express",
      "logo": "assets/images/operators/guarantee.png",
      "rating": 4.5,
      "totalTrips": 1250,
      "onTimePercentage": 89,
      "amenities": ["WiFi", "AC", "Refreshments", "Entertainment"],
      "busTypes": ["Executive", "VIP", "Standard"]
    },
    {
      "id": 2,
      "name": "Finexs Express",
      "logo": "assets/images/operators/finexs.png", 
      "rating": 4.2,
      "totalTrips": 980,
      "onTimePercentage": 85,
      "amenities": ["AC", "Refreshments", "USB Charging"],
      "busTypes": ["VIP", "Standard"]
    },
    {
      "id": 3,
      "name": "Musango Transport",
      "logo": "assets/images/operators/musango.png",
      "rating": 4.0,
      "totalTrips": 760,
      "onTimePercentage": 82,
      "amenities": ["AC", "USB Charging"],
      "busTypes": ["Standard", "Economy"]
    },
    {
      "id": 4,
      "name": "Binam Transport",
      "logo": "assets/images/operators/binam.png",
      "rating": 3.8,
      "totalTrips": 650,
      "onTimePercentage": 78,
      "amenities": ["AC", "Music System"],
      "busTypes": ["Standard"]
    },
    {
      "id": 5,
      "name": "Central Express",
      "logo": "assets/images/operators/central.png",
      "rating": 4.3,
      "totalTrips": 890,
      "onTimePercentage": 87,
      "amenities": ["WiFi", "AC", "Refreshments"],
      "busTypes": ["Executive", "Standard"]
    }
  ];

  // Generate bus schedules dynamically
  static List<Map<String, dynamic>> generateBusSchedules(String fromCity, String toCity) {
    final List<Map<String, dynamic>> schedules = [];
    final random = Random();
    
    // Calculate base price based on distance (mock calculation)
    final basePrice = _calculatePrice(fromCity, toCity);
    
    for (int i = 0; i < busOperators.length; i++) {
      final operator = busOperators[i];
      final numTrips = random.nextInt(4) + 2; // 2-5 trips per day per operator
      
      for (int j = 0; j < numTrips; j++) {
        final hour = 6 + (j * 3) + random.nextInt(2); // Start from 6 AM, spread throughout day
        final minute = random.nextInt(60);
        
        final busType = (operator["busTypes"] as List).isNotEmpty 
            ? (operator["busTypes"] as List)[random.nextInt((operator["busTypes"] as List).length)]
            : "Standard";
            
        final priceMultiplier = busType == "Executive" ? 1.5 : 
                               busType == "VIP" ? 1.3 : 
                               busType == "Economy" ? 0.8 : 1.0;
        
        final finalPrice = (basePrice * priceMultiplier).round();
        
        schedules.add({
          "id": "${operator["id"]}_$j",
          "operatorId": operator["id"],
          "operatorName": operator["name"],
          "operatorLogo": operator["logo"],
          "operatorRating": operator["rating"],
          "busType": busType,
          "fromCity": fromCity,
          "toCity": toCity,
          "departureTime": "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}",
          "estimatedDuration": _calculateDuration(fromCity, toCity),
          "price": finalPrice,
          "currency": "XFA",
          "availableSeats": random.nextInt(20) + 5, // 5-24 available seats
          "totalSeats": 45,
          "amenities": operator["amenities"],
          "onTimePercentage": operator["onTimePercentage"],
          "nextStops": _generateNextStops(fromCity, toCity),
          "arrivalTime": _calculateArrivalTime("${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}", _calculateDuration(fromCity, toCity))
        });
      }
    }
    
    // Sort by departure time
    schedules.sort((a, b) => a["departureTime"].compareTo(b["departureTime"]));
    return schedules;
  }

  static int _calculatePrice(String fromCity, String toCity) {
    // Mock price calculation based on popular routes
    final Map<String, int> basePrices = {
      "Douala-Yaoundé": 3500,
      "Yaoundé-Douala": 3500,
      "Bamenda-Douala": 4500,
      "Douala-Bamenda": 4500,
      "Kumba-Douala": 2500,
      "Douala-Kumba": 2500,
      "Limbe-Douala": 2000,
      "Douala-Limbe": 2000,
      "Yaoundé-Bamenda": 4000,
      "Bamenda-Yaoundé": 4000,
      "Bafoussam-Douala": 3800,
      "Douala-Bafoussam": 3800,
      "Yaoundé-Bafoussam": 3200,
      "Bafoussam-Yaoundé": 3200,
    };
    
    final key = "$fromCity-$toCity";
    return basePrices[key] ?? 5000; // Default price if route not found
  }

  static String _calculateDuration(String fromCity, String toCity) {
    // Mock duration calculation
    final Map<String, String> durations = {
      "Douala-Yaoundé": "4h 30m",
      "Yaoundé-Douala": "4h 30m", 
      "Bamenda-Douala": "6h 15m",
      "Douala-Bamenda": "6h 15m",
      "Kumba-Douala": "2h 45m",
      "Douala-Kumba": "2h 45m",
      "Limbe-Douala": "2h 15m",
      "Douala-Limbe": "2h 15m",
      "Yaoundé-Bamenda": "5h 45m",
      "Bamenda-Yaoundé": "5h 45m",
      "Bafoussam-Douala": "5h 30m",
      "Douala-Bafoussam": "5h 30m",
      "Yaoundé-Bafoussam": "4h 15m",
      "Bafoussam-Yaoundé": "4h 15m",
    };
    
    final key = "$fromCity-$toCity";
    return durations[key] ?? "6h 00m";
  }

  static List<String> _generateNextStops(String fromCity, String toCity) {
    // Generate intermediate stops based on common routes
    final Map<String, List<String>> routeStops = {
      "Douala-Yaoundé": ["Edéa", "Eséka", "Mbalmayo"],
      "Yaoundé-Douala": ["Mbalmayo", "Eséka", "Edéa"],
      "Bamenda-Douala": ["Bafoussam", "Melong", "Nkongsamba"],
      "Douala-Bamenda": ["Nkongsamba", "Melong", "Bafoussam"],
      "Kumba-Douala": ["Loum", "Mbanga"],
      "Douala-Kumba": ["Mbanga", "Loum"],
    };
    
    final key = "$fromCity-$toCity";
    return routeStops[key] ?? ["Direct Route"];
  }

  static String _calculateArrivalTime(String departureTime, String duration) {
    final parts = departureTime.split(':');
    final depHour = int.parse(parts[0]);
    final depMinute = int.parse(parts[1]);
    
    final durationParts = duration.replaceAll('h', '').replaceAll('m', '').split(' ');
    final durationHours = int.parse(durationParts[0]);
    final durationMinutes = durationParts.length > 1 ? int.parse(durationParts[1]) : 0;
    
    final totalMinutes = (depHour * 60 + depMinute) + (durationHours * 60 + durationMinutes);
    final arrHour = (totalMinutes ~/ 60) % 24;
    final arrMinute = totalMinutes % 60;
    
    return "${arrHour.toString().padLeft(2, '0')}:${arrMinute.toString().padLeft(2, '0')}";
  }

  // Get popular destinations
  static List<Map<String, dynamic>> getPopularDestinations() {
    return cameroonCities.where((city) => city["isPopular"] == true).toList();
  }

  // Search cities
  static List<Map<String, dynamic>> searchCities(String query) {
    if (query.isEmpty) return [];
    
    return cameroonCities
        .where((city) => city["name"].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get recent bookings (mock data)
  static List<Map<String, dynamic>> getRecentBookings() {
    return [
      {
        "id": "BK001",
        "fromCity": "Douala",
        "toCity": "Yaoundé", 
        "departureDate": DateTime.now().subtract(const Duration(days: 5)),
        "operatorName": "Guarantee Express",
        "price": 3500,
        "status": "completed"
      },
      {
        "id": "BK002",
        "fromCity": "Bamenda",
        "toCity": "Douala",
        "departureDate": DateTime.now().subtract(const Duration(days: 12)),
        "operatorName": "Finexs Express", 
        "price": 4500,
        "status": "completed"
      }
    ];
  }

  // Payment methods available
  static List<Map<String, dynamic>> getPaymentMethods() {
    return [
      {
        "id": "mtn_momo",
        "name": "MTN Mobile Money",
        "icon": "assets/images/payment/mtn_momo.png",
        "type": "mobile_money",
        "isActive": true,
        "processingFee": 0.02, // 2%
        "minAmount": 500,
        "maxAmount": 500000
      },
      {
        "id": "orange_money", 
        "name": "Orange Money",
        "icon": "assets/images/payment/orange_money.png",
        "type": "mobile_money", 
        "isActive": true,
        "processingFee": 0.025, // 2.5%
        "minAmount": 500,
        "maxAmount": 300000
      },
      {
        "id": "visa_card",
        "name": "Visa/Mastercard",
        "icon": "assets/images/payment/visa_card.png",
        "type": "card",
        "isActive": true,
        "processingFee": 0.035, // 3.5%
        "minAmount": 1000,
        "maxAmount": 1000000
      }
    ];
  }
}