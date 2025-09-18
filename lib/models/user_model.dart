class UserModel {
  final String id;
  final String email;
  final String? phone;
  final String firstName;
  final String lastName;
  final String? idCardNumber;
  final String role;
  final String? affiliation;
  final String? position;
  final bool pinVerified;
  final Map<String, dynamic>? privileges;
  final String? profileImage;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? verificationStatus;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.phone,
    required this.firstName,
    required this.lastName,
    this.idCardNumber,
    this.role = 'ordinary_user',
    this.affiliation,
    this.position,
    this.pinVerified = false,
    this.privileges,
    this.profileImage,
    this.preferences,
    this.verificationStatus,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get full name
  String get fullName => '$firstName $lastName';

  // Get display name (first name or full name)
  String get displayName => firstName.isNotEmpty ? firstName : fullName;

  // Get name for display (compatibility)
  String get name => fullName;

  // Get affiliations list for compatibility
  List<String> get affiliations {
    List<String> result = [];
    if (affiliation != null) result.add(affiliation!);
    return result;
  }

  // Check if email is verified
  bool get isEmailVerified => verificationStatus?['email'] == true;

  // Check if phone is verified
  bool get isPhoneVerified => verificationStatus?['phone'] == true;

  // Get profile image URL or null
  String? get profileImageUrl => profileImage?.isNotEmpty == true ? profileImage : null;

  // Role-based getters
  bool get isOrdinaryUser => role == 'ordinary_user';
  bool get isStudent => position == 'student';
  bool get isStaff => position == 'staff';
  bool get isConductor => position == 'conductor' || role == 'conductor';
  bool get isDriver => position == 'driver' || role == 'driver';
  bool get isBookingClerk => position == 'booking_clerk' || role == 'booking_clerk';
  bool get isScheduleManager => position == 'schedule_manager' || role == 'schedule_manager';
  
  // Affiliation getters
  bool get isUniversityAffiliated => affiliation == 'ict_university';
  bool get isAgencyAffiliated => affiliation == 'agency';
  
  // Permission checks
  bool get canScanTickets => isConductor || isDriver;
  bool get canManageSeats => isBookingClerk || isScheduleManager;
  bool get canChangeBusStatus => isConductor || isDriver;
  bool get canAccessSchoolBus => isUniversityAffiliated && pinVerified;

  // Factory constructor from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      idCardNumber: json['idCardNumber']?.toString(),
      role: json['role']?.toString() ?? 'ordinary_user',
      affiliation: json['affiliation']?.toString(),
      position: json['position']?.toString(),
      pinVerified: json['pinVerified'] ?? false,
      privileges: json['privileges'] as Map<String, dynamic>?,
      profileImage: json['profileImage']?.toString(),
      preferences: json['preferences'] as Map<String, dynamic>?,
      verificationStatus: json['verificationStatus'] as Map<String, dynamic>?,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
        ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
        : DateTime.now(),
      updatedAt: json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
        : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'idCardNumber': idCardNumber,
      'role': role,
      'affiliation': affiliation,
      'position': position,
      'pinVerified': pinVerified,
      'privileges': privileges,
      'profileImage': profileImage,
      'preferences': preferences,
      'verificationStatus': verificationStatus,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? idCardNumber,
    String? role,
    String? affiliation,
    String? position,
    bool? pinVerified,
    Map<String, dynamic>? privileges,
    String? profileImage,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? verificationStatus,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      role: role ?? this.role,
      affiliation: affiliation ?? this.affiliation,
      position: position ?? this.position,
      pinVerified: pinVerified ?? this.pinVerified,
      privileges: privileges ?? this.privileges,
      profileImage: profileImage ?? this.profileImage,
      preferences: preferences ?? this.preferences,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// User preferences helper class
class UserPreferences {
  final String theme;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final String language;
  final String currency;
  final bool locationTracking;

  UserPreferences({
    this.theme = 'light',
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.language = 'en',
    this.currency = 'USD',
    this.locationTracking = true,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme']?.toString() ?? 'light',
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      smsNotifications: json['smsNotifications'] ?? false,
      language: json['language']?.toString() ?? 'en',
      currency: json['currency']?.toString() ?? 'USD',
      locationTracking: json['locationTracking'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'smsNotifications': smsNotifications,
      'language': language,
      'currency': currency,
      'locationTracking': locationTracking,
    };
  }

  UserPreferences copyWith({
    String? theme,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    String? language,
    String? currency,
    bool? locationTracking,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      locationTracking: locationTracking ?? this.locationTracking,
    );
  }
}