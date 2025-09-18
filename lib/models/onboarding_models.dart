// Onboarding progress and session management models
import 'package:flutter/material.dart';

class OnboardingProgress {
  final String sessionType;
  final int currentStep;
  final Map<String, dynamic> collectedData;
  final bool isCompleted;
  final DateTime? expiresAt;
  final DateTime createdAt;

  OnboardingProgress({
    required this.sessionType,
    required this.currentStep,
    required this.collectedData,
    this.isCompleted = false,
    this.expiresAt,
    required this.createdAt,
  });

  factory OnboardingProgress.fromJson(Map<String, dynamic> json) {
    return OnboardingProgress(
      sessionType: json['sessionType'] ?? '',
      currentStep: json['step'] ?? 1,
      collectedData: Map<String, dynamic>.from(json['data'] ?? {}),
      isCompleted: json['completed'] ?? false,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.tryParse(json['expiresAt'])
          : null,
      createdAt: json['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionType': sessionType,
      'step': currentStep,
      'data': collectedData,
      'completed': isCompleted,
      'expiresAt': expiresAt?.toIso8601String(),
      'timestamp': createdAt.millisecondsSinceEpoch,
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isValid => !isExpired && !isCompleted;

  OnboardingProgress copyWith({
    String? sessionType,
    int? currentStep,
    Map<String, dynamic>? collectedData,
    bool? isCompleted,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return OnboardingProgress(
      sessionType: sessionType ?? this.sessionType,
      currentStep: currentStep ?? this.currentStep,
      collectedData: collectedData ?? Map<String, dynamic>.from(this.collectedData),
      isCompleted: isCompleted ?? this.isCompleted,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class OnboardingStep {
  final int stepNumber;
  final String title;
  final String subtitle;
  final OnboardingStepType type;
  final List<OnboardingOption>? options;
  final Map<String, dynamic>? validation;
  final bool isRequired;

  OnboardingStep({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.type,
    this.options,
    this.validation,
    this.isRequired = true,
  });

  factory OnboardingStep.fromJson(Map<String, dynamic> json) {
    return OnboardingStep(
      stepNumber: json['stepNumber'] ?? 1,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      type: OnboardingStepType.values.firstWhere(
        (e) => e.toString() == 'OnboardingStepType.${json['type']}',
        orElse: () => OnboardingStepType.selection,
      ),
      options: (json['options'] as List<dynamic>?)
          ?.map((option) => OnboardingOption.fromJson(option))
          .toList(),
      validation: json['validation'] as Map<String, dynamic>?,
      isRequired: json['isRequired'] ?? true,
    );
  }
}

enum OnboardingStepType {
  affiliation,    // Select affiliation (ICT University, Agency, None)
  position,       // Select position based on affiliation
  pinEntry,       // Enter PIN for verification
  feeStatus,      // Check fee payment status (ICT University)
  confirmation,   // Final confirmation step
  selection,      // General selection step
  input,          // Text input step
}

class OnboardingOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isRecommended;
  final Map<String, dynamic>? metadata;

  OnboardingOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isRecommended = false,
    this.metadata,
  });

  factory OnboardingOption.fromJson(Map<String, dynamic> json) {
    return OnboardingOption(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      icon: _getIconFromString(json['icon']),
      color: Color(json['color'] ?? 0xFF1a4d3a),
      isRecommended: json['isRecommended'] ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'icon': icon.codePoint,
      'color': color.value,
      'isRecommended': isRecommended,
      'metadata': metadata,
    };
  }

  static IconData _getIconFromString(dynamic iconData) {
    if (iconData is int) {
      return IconData(iconData, fontFamily: 'MaterialIcons');
    }
    // Default icons for common options
    final iconMap = {
      'school': Icons.school,
      'business': Icons.business,
      'person': Icons.person,
      'directions_bus': Icons.directions_bus,
      'admin_panel_settings': Icons.admin_panel_settings,
    };
    return iconMap[iconData?.toString()] ?? Icons.help;
  }
}

// ICT University specific models
class UniversityAffiliation {
  final String studentId;
  final String position; // 'student', 'staff'
  final String department;
  final bool feesPaid;
  final DateTime? feeExpiryDate;
  final String academicYear;

  UniversityAffiliation({
    required this.studentId,
    required this.position,
    required this.department,
    this.feesPaid = false,
    this.feeExpiryDate,
    required this.academicYear,
  });

  factory UniversityAffiliation.fromJson(Map<String, dynamic> json) {
    return UniversityAffiliation(
      studentId: json['studentId'] ?? '',
      position: json['position'] ?? '',
      department: json['department'] ?? '',
      feesPaid: json['feesPaid'] ?? false,
      feeExpiryDate: json['feeExpiryDate'] != null
          ? DateTime.tryParse(json['feeExpiryDate'])
          : null,
      academicYear: json['academicYear'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'position': position,
      'department': department,
      'feesPaid': feesPaid,
      'feeExpiryDate': feeExpiryDate?.toIso8601String(),
      'academicYear': academicYear,
    };
  }

  bool get hasValidAccess => feesPaid && 
      (feeExpiryDate == null || DateTime.now().isBefore(feeExpiryDate!));

  String get accessStatus {
    if (!feesPaid) return 'Fees not paid';
    if (feeExpiryDate != null && DateTime.now().isAfter(feeExpiryDate!)) {
      return 'Access expired';
    }
    return 'Active';
  }

  int get daysRemaining {
    if (feeExpiryDate == null) return -1;
    final difference = feeExpiryDate!.difference(DateTime.now()).inDays;
    return difference < 0 ? 0 : difference;
  }
}

// Agency affiliation models
class AgencyAffiliation {
  final String employeeId;
  final String agencyName;
  final String position; // 'driver', 'conductor', 'booking_clerk', 'schedule_manager'
  final DateTime hireDate;
  final bool isActive;
  final Map<String, dynamic> permissions;

  AgencyAffiliation({
    required this.employeeId,
    required this.agencyName,
    required this.position,
    required this.hireDate,
    this.isActive = true,
    this.permissions = const {},
  });

  factory AgencyAffiliation.fromJson(Map<String, dynamic> json) {
    return AgencyAffiliation(
      employeeId: json['employeeId'] ?? '',
      agencyName: json['agencyName'] ?? '',
      position: json['position'] ?? '',
      hireDate: DateTime.tryParse(json['hireDate'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
      permissions: Map<String, dynamic>.from(json['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'agencyName': agencyName,
      'position': position,
      'hireDate': hireDate.toIso8601String(),
      'isActive': isActive,
      'permissions': permissions,
    };
  }

  bool get canScanTickets => ['conductor', 'driver'].contains(position);
  bool get canManageBookings => ['booking_clerk', 'schedule_manager'].contains(position);
  bool get hasAdminAccess => position == 'schedule_manager';
}

// PIN recovery models
class PinRecoveryRequest {
  final String affiliationType;
  final String position;
  final String phoneNumber;
  final String? recoveryCode;
  final bool isVerified;
  final DateTime expiresAt;

  PinRecoveryRequest({
    required this.affiliationType,
    required this.position,
    required this.phoneNumber,
    this.recoveryCode,
    this.isVerified = false,
    required this.expiresAt,
  });

  factory PinRecoveryRequest.fromJson(Map<String, dynamic> json) {
    return PinRecoveryRequest(
      affiliationType: json['affiliationType'] ?? '',
      position: json['position'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      recoveryCode: json['recoveryCode'],
      isVerified: json['isVerified'] ?? false,
      expiresAt: DateTime.tryParse(json['expiresAt'] ?? '') ?? 
          DateTime.now().add(Duration(minutes: 10)),
    );
  }

  bool get hasExpired => DateTime.now().isAfter(expiresAt);
  
  int get minutesRemaining {
    if (hasExpired) return 0;
    return expiresAt.difference(DateTime.now()).inMinutes;
  }
}