import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/location_illustration_widget.dart';
import './widgets/permission_benefits_widget.dart';
import './widgets/privacy_assurance_widget.dart';
import './widgets/progress_indicator_widget.dart';

class LocationPermissionOnboarding extends StatefulWidget {
  const LocationPermissionOnboarding({super.key});

  @override
  State<LocationPermissionOnboarding> createState() =>
      _LocationPermissionOnboardingState();
}

class _LocationPermissionOnboardingState
    extends State<LocationPermissionOnboarding> with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleLocationPermission() async {
    if (_isLoading) return; // Prevent multiple calls
    
    setState(() => _isLoading = true);

    try {
      // Simulate permission request process with reduced delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Add haptic feedback for iOS
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        HapticFeedback.mediumImpact();
      }

      // Add small delay before navigation for smooth transition
      await Future.delayed(const Duration(milliseconds: 300));

      // Navigate to main app
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/route-search-home');
      }
    } catch (e) {
      // Handle permission denied or error
      if (mounted) {
        _showPermissionDialog();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSkipPermission() async {
    if (_isLoading) return; // Prevent navigation during loading
    
    HapticFeedback.selectionClick();
    
    // Add small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/location-picker');
    }
  }

  void _showPermissionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPermissionBottomSheet(),
    );
  }

  Widget _buildPermissionBottomSheet() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            // Error icon
            Container(
              width: 15.w,
              height: 7.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.error
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'location_off',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 7.w,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            // Title
            Text(
              'Location Access Required',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            // Description
            Text(
              'To provide you with the best bus booking experience, please enable location access in your device settings.',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.9),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleSkipPermission();
                    },
                    child: Text('Skip'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Open app settings (platform-specific implementation would go here)
                      _handleLocationPermission();
                    },
                    child: Text('Open Settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A4A47),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Container(
                width: 100.w,
                constraints: BoxConstraints(minHeight: 90.h),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    // Progress indicator
                    const ProgressIndicatorWidget(
                      currentStep: 1,
                      totalSteps: 3,
                    ),
                    SizedBox(height: 4.h),
                    // Location illustration
                    const LocationIllustrationWidget(),
                    SizedBox(height: 4.h),
                    // Permission benefits
                    const PermissionBenefitsWidget(),
                    SizedBox(height: 4.h),
                    // Privacy assurance
                    const PrivacyAssuranceWidget(),
                    SizedBox(height: 4.h),
                    // Action buttons
                    ActionButtonsWidget(
                      onAllowPressed: _handleLocationPermission,
                      onSkipPressed: _handleSkipPermission,
                      isLoading: _isLoading,
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
