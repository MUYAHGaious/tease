// Bus Operator Model
class BusOperator {
  final String id;
  final String companyName;
  final String licenseNumber;
  final String contactEmail;
  final String contactPhone;
  final String? website;
  final Map<String, dynamic> address;
  final String verificationStatus;
  final double rating;
  final int totalRatings;
  final bool isActive;
  final DateTime createdAt;

  BusOperator({
    required this.id,
    required this.companyName,
    required this.licenseNumber,
    required this.contactEmail,
    required this.contactPhone,
    this.website,
    required this.address,
    required this.verificationStatus,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory BusOperator.fromJson(Map<String, dynamic> json) {
    return BusOperator(
      id: json['id']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      licenseNumber: json['licenseNumber']?.toString() ?? '',
      contactEmail: json['contactEmail']?.toString() ?? '',
      contactPhone: json['contactPhone']?.toString() ?? '',
      website: json['website']?.toString(),
      address: json['address'] as Map<String, dynamic>? ?? {},
      verificationStatus: json['verificationStatus']?.toString() ?? 'PENDING',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['totalRatings'] as int? ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'licenseNumber': licenseNumber,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'website': website,
      'address': address,
      'verificationStatus': verificationStatus,
      'rating': rating,
      'totalRatings': totalRatings,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isVerified => verificationStatus == 'VERIFIED';
}

// Bus Model
class Bus {
  final String id;
  final String operatorId;
  final String registrationNumber;
  final String busType;
  final Map<String, dynamic> specifications;
  final Map<String, dynamic>? currentLocation;
  final String status;
  final int totalSeats;
  final List<String> amenities;
  final DateTime createdAt;

  Bus({
    required this.id,
    required this.operatorId,
    required this.registrationNumber,
    required this.busType,
    required this.specifications,
    this.currentLocation,
    this.status = 'ACTIVE',
    this.totalSeats = 40,
    this.amenities = const [],
    required this.createdAt,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id']?.toString() ?? '',
      operatorId: json['operatorId']?.toString() ?? '',
      registrationNumber: json['registrationNumber']?.toString() ?? '',
      busType: json['busType']?.toString() ?? 'STANDARD',
      specifications: json['specifications'] as Map<String, dynamic>? ?? {},
      currentLocation: json['currentLocation'] as Map<String, dynamic>?,
      status: json['status']?.toString() ?? 'ACTIVE',
      totalSeats: json['totalSeats'] as int? ?? 40,
      amenities: (json['amenities'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operatorId': operatorId,
      'registrationNumber': registrationNumber,
      'busType': busType,
      'specifications': specifications,
      'currentLocation': currentLocation,
      'status': status,
      'totalSeats': totalSeats,
      'amenities': amenities,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'ACTIVE';
}

// Route Model
class BusRoute {
  final String id;
  final String operatorId;
  final String routeNumber;
  final String routeName;
  final String routeType;
  final Location origin;
  final Location destination;
  final List<Location> stops;
  final Map<String, dynamic> fareStructure;
  final double distance;
  final String status;
  final DateTime createdAt;

  BusRoute({
    required this.id,
    required this.operatorId,
    required this.routeNumber,
    required this.routeName,
    required this.routeType,
    required this.origin,
    required this.destination,
    this.stops = const [],
    required this.fareStructure,
    this.distance = 0.0,
    this.status = 'ACTIVE',
    required this.createdAt,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      id: json['id']?.toString() ?? '',
      operatorId: json['operatorId']?.toString() ?? '',
      routeNumber: json['routeNumber']?.toString() ?? '',
      routeName: json['routeName']?.toString() ?? '',
      routeType: json['routeType']?.toString() ?? 'REGULAR',
      origin: Location.fromJson(json['origin'] as Map<String, dynamic>? ?? {}),
      destination: Location.fromJson(json['destination'] as Map<String, dynamic>? ?? {}),
      stops: (json['stops'] as List<dynamic>?)
          ?.map((stop) => Location.fromJson(stop as Map<String, dynamic>))
          .toList() ?? [],
      fareStructure: json['fareStructure'] as Map<String, dynamic>? ?? {},
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'ACTIVE',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operatorId': operatorId,
      'routeNumber': routeNumber,
      'routeName': routeName,
      'routeType': routeType,
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'fareStructure': fareStructure,
      'distance': distance,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'ACTIVE';
  double get baseFare => (fareStructure['baseFare'] as num?)?.toDouble() ?? 0.0;
}

// Location Model
class Location {
  final String name;
  final String city;
  final String? state;
  final String? country;
  final Coordinates coordinates;

  Location({
    required this.name,
    required this.city,
    this.state,
    this.country,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      coordinates: Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'state': state,
      'country': country,
      'coordinates': coordinates.toJson(),
    };
  }

  String get fullAddress {
    final parts = [name, city, state, country].where((part) => part?.isNotEmpty == true).toList();
    return parts.join(', ');
  }
}

// Coordinates Model
class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

// Bus Search Filter
class BusSearchFilter {
  final String? from;
  final String? to;
  final DateTime? date;
  final String? busType;
  final double? maxPrice;
  final List<String> amenities;
  final double? radius;

  BusSearchFilter({
    this.from,
    this.to,
    this.date,
    this.busType,
    this.maxPrice,
    this.amenities = const [],
    this.radius,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (from != null) json['from'] = from;
    if (to != null) json['to'] = to;
    if (date != null) json['date'] = date!.toIso8601String();
    if (busType != null) json['busType'] = busType;
    if (maxPrice != null) json['maxPrice'] = maxPrice;
    if (amenities.isNotEmpty) json['amenities'] = amenities;
    if (radius != null) json['radius'] = radius;
    return json;
  }
}