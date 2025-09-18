import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_models.dart';
import '../core/api_client.dart';
import '../core/api_config.dart';
import 'auth_service.dart';

class OnboardingCacheService {
  static const String _localCacheKey = 'onboarding_progress';
  static const String _sessionPrefix = 'onboarding_session_';
  static const int _cacheExpiryHours = 24;
  
  static SharedPreferences? _prefs;
  
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save onboarding progress locally and to server
  static Future<void> saveProgress(OnboardingProgress progress) async {
    try {
      // Save to local cache
      await _saveToLocal(progress);
      
      // Attempt to sync to server (non-blocking)
      _syncToServer(progress).catchError((e) {
        print('Failed to sync onboarding progress to server: $e');
        // Continue without server sync - local cache is primary
      });
    } catch (e) {
      print('Failed to save onboarding progress: $e');
      throw Exception('Failed to save progress');
    }
  }

  // Get cached progress (local first, then server fallback)
  static Future<OnboardingProgress?> getProgress(String sessionType) async {
    try {
      // Try local cache first (faster)
      final localProgress = await _getFromLocal(sessionType);
      
      if (localProgress != null && localProgress.isValid) {
        return localProgress;
      }

      // Fallback to server if local cache is invalid/expired
      final serverProgress = await _getFromServer(sessionType);
      
      if (serverProgress != null && serverProgress.isValid) {
        // Cache server data locally for next time
        await _saveToLocal(serverProgress);
        return serverProgress;
      }

      return null;
    } catch (e) {
      print('Failed to get onboarding progress: $e');
      return null;
    }
  }

  // Check if user has resumable session
  static Future<bool> hasResumableSession(String sessionType) async {
    final progress = await getProgress(sessionType);
    return progress != null && progress.isValid && !progress.isCompleted;
  }

  // Clear progress after completion
  static Future<void> clearProgress(String sessionType) async {
    try {
      // Clear local cache
      await _clearLocal(sessionType);
      
      // Mark as completed on server
      await _markCompletedOnServer(sessionType);
    } catch (e) {
      print('Failed to clear onboarding progress: $e');
    }
  }

  // Get all cached sessions for user
  static Future<List<OnboardingProgress>> getAllSessions() async {
    try {
      final sessions = <OnboardingProgress>[];
      
      // Get all local sessions
      final keys = _prefs?.getKeys() ?? <String>{};
      for (final key in keys) {
        if (key.startsWith(_sessionPrefix)) {
          final cachedData = _prefs?.getString(key);
          if (cachedData != null) {
            try {
              final data = jsonDecode(cachedData);
              final progress = OnboardingProgress.fromJson(data);
              if (progress.isValid) {
                sessions.add(progress);
              }
            } catch (e) {
              // Invalid cached data, remove it
              await _prefs?.remove(key);
            }
          }
        }
      }
      
      return sessions;
    } catch (e) {
      print('Failed to get all onboarding sessions: $e');
      return [];
    }
  }

  // Private methods for local caching
  static Future<void> _saveToLocal(OnboardingProgress progress) async {
    final cacheKey = '$_sessionPrefix${progress.sessionType}';
    final expiryDate = DateTime.now().add(Duration(hours: _cacheExpiryHours));
    
    final cacheData = progress.copyWith(expiresAt: expiryDate).toJson();
    
    await _prefs?.setString(cacheKey, jsonEncode(cacheData));
  }

  static Future<OnboardingProgress?> _getFromLocal(String sessionType) async {
    final cacheKey = '$_sessionPrefix$sessionType';
    final cachedData = _prefs?.getString(cacheKey);
    
    if (cachedData != null) {
      try {
        final data = jsonDecode(cachedData);
        final progress = OnboardingProgress.fromJson(data);
        
        // Check if cache is still valid
        if (!progress.isExpired) {
          return progress;
        } else {
          // Clean up expired cache
          await _prefs?.remove(cacheKey);
        }
      } catch (e) {
        // Invalid cached data, remove it
        await _prefs?.remove(cacheKey);
      }
    }
    
    return null;
  }

  static Future<void> _clearLocal(String sessionType) async {
    final cacheKey = '$_sessionPrefix$sessionType';
    await _prefs?.remove(cacheKey);
  }

  // Private methods for server sync
  static Future<void> _syncToServer(OnboardingProgress progress) async {
    try {
      await ApiClient.post(
        '${ApiConfig.authServiceUrl}/onboarding/progress',
        data: {
          'sessionType': progress.sessionType,
          'step': progress.currentStep,
          'data': progress.collectedData,
          'completed': progress.isCompleted,
        },
      );
    } catch (e) {
      // Server sync failed, but local cache is still valid
      print('Server sync failed: $e');
    }
  }

  static Future<OnboardingProgress?> _getFromServer(String sessionType) async {
    try {
      final response = await ApiClient.get(
        '${ApiConfig.authServiceUrl}/onboarding/progress/$sessionType',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final serverData = response.data['data'];
        if (serverData != null) {
          return OnboardingProgress(
            sessionType: serverData['sessionType'] ?? sessionType,
            currentStep: serverData['step'] ?? 1,
            collectedData: Map<String, dynamic>.from(serverData['data'] ?? {}),
            isCompleted: serverData['completed'] ?? false,
            createdAt: DateTime.tryParse(serverData['createdAt'] ?? '') ?? DateTime.now(),
            expiresAt: DateTime.tryParse(serverData['expiresAt'] ?? ''),
          );
        }
      }
      
      return null;
    } catch (e) {
      print('Failed to get progress from server: $e');
      return null;
    }
  }

  static Future<void> _markCompletedOnServer(String sessionType) async {
    try {
      await ApiClient.put(
        '${ApiConfig.authServiceUrl}/onboarding/progress/$sessionType/complete',
      );
    } catch (e) {
      print('Failed to mark completed on server: $e');
    }
  }
}

// Feature access manager for seamless user experience
class FeatureAccessManager {
  // Check if user can access a feature
  static Future<FeatureAccessResult> checkFeatureAccess(String featureName) async {
    try {
      final user = await AuthService.getCachedUser();
      
      switch (featureName) {
        case 'school_bus':
          return await _checkSchoolBusAccess(user);
        case 'conductor_tools':
          return _checkConductorAccess(user);
        case 'driver_tools':
          return _checkDriverAccess(user);
        case 'booking_management':
          return _checkBookingManagementAccess(user);
        case 'admin_panel':
          return _checkAdminAccess(user);
        default:
          return FeatureAccessResult.granted();
      }
    } catch (e) {
      return FeatureAccessResult.error('Failed to check feature access');
    }
  }

  // School bus access check
  static Future<FeatureAccessResult> _checkSchoolBusAccess(user) async {
    if (user == null) {
      return FeatureAccessResult.requiresOnboarding(
        'school_bus_onboarding',
        'Access ICT University school bus services',
      );
    }

    if (user.canAccessSchoolBus) {
      return FeatureAccessResult.granted();
    }

    // Check if there's a resumable onboarding session
    final hasSession = await OnboardingCacheService.hasResumableSession('ict_university');
    
    return FeatureAccessResult.requiresOnboarding(
      'ict_university',
      'Verify your ICT University affiliation to access school bus services',
      canResume: hasSession,
    );
  }

  static FeatureAccessResult _checkConductorAccess(user) {
    if (user == null || !user.canScanTickets) {
      return FeatureAccessResult.requiresOnboarding(
        'agency_conductor',
        'Verify your conductor credentials to access scanning tools',
      );
    }
    return FeatureAccessResult.granted();
  }

  static FeatureAccessResult _checkDriverAccess(user) {
    if (user == null || !user.isDriver) {
      return FeatureAccessResult.requiresOnboarding(
        'agency_driver',
        'Verify your driver credentials to access driver tools',
      );
    }
    return FeatureAccessResult.granted();
  }

  static FeatureAccessResult _checkBookingManagementAccess(user) {
    if (user == null || !user.canManageSeats) {
      return FeatureAccessResult.requiresOnboarding(
        'agency_booking',
        'Verify your booking clerk credentials to manage bookings',
      );
    }
    return FeatureAccessResult.granted();
  }

  static FeatureAccessResult _checkAdminAccess(user) {
    if (user == null || !user.isScheduleManager) {
      return FeatureAccessResult.denied('Administrative access required');
    }
    return FeatureAccessResult.granted();
  }

  // Initiate progressive onboarding
  static Future<void> initiateOnboarding(
    BuildContext context, 
    String sessionType, {
    bool canResume = false,
  }) async {
    if (canResume) {
      // Check for cached progress
      final progress = await OnboardingCacheService.getProgress(sessionType);
      
      if (progress != null && progress.isValid) {
        // Resume from cached progress
        Navigator.pushNamed(
          context, 
          '/progressive-onboarding',
          arguments: {
            'sessionType': sessionType,
            'resumeFrom': progress.currentStep,
            'cachedData': progress.collectedData,
          },
        );
        return;
      }
    }

    // Start fresh onboarding
    Navigator.pushNamed(
      context,
      '/progressive-onboarding',
      arguments: {
        'sessionType': sessionType,
        'startFresh': true,
      },
    );
  }
}

// Result class for feature access checks
class FeatureAccessResult {
  final bool isGranted;
  final bool requiresOnboarding;
  final String? onboardingType;
  final String? message;
  final bool canResume;
  final String? errorMessage;

  FeatureAccessResult._({
    required this.isGranted,
    this.requiresOnboarding = false,
    this.onboardingType,
    this.message,
    this.canResume = false,
    this.errorMessage,
  });

  factory FeatureAccessResult.granted() {
    return FeatureAccessResult._(isGranted: true);
  }

  factory FeatureAccessResult.requiresOnboarding(
    String onboardingType,
    String message, {
    bool canResume = false,
  }) {
    return FeatureAccessResult._(
      isGranted: false,
      requiresOnboarding: true,
      onboardingType: onboardingType,
      message: message,
      canResume: canResume,
    );
  }

  factory FeatureAccessResult.denied(String message) {
    return FeatureAccessResult._(
      isGranted: false,
      message: message,
    );
  }

  factory FeatureAccessResult.error(String errorMessage) {
    return FeatureAccessResult._(
      isGranted: false,
      errorMessage: errorMessage,
    );
  }
}