import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../utils/page_transitions.dart';
import '../home_screen/home_screen.dart';
import '../location_picker/location_picker.dart';
import './widgets/onboarding_step_one.dart';
import './widgets/onboarding_step_two.dart';
import './widgets/onboarding_step_three.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _skipToEnd() {
    setState(() {
      _currentStep = 2;
    });
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleLocationPermission() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);

    try {
      // Simulate permission request process
      await Future.delayed(const Duration(milliseconds: 800));

      // Add haptic feedback for iOS
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        HapticFeedback.mediumImpact();
      }

      // Add small delay before navigation for smooth transition
      await Future.delayed(const Duration(milliseconds: 300));

      // Navigate to main app
      if (mounted) {
        Navigator.of(context).pushReplacementWithTransition(
          const HomeScreen(),
          transition: (page) => AppPageTransitions.fadeSlideTransition(page: page),
        );
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

  void _completeOnboarding() async {
    if (_isLoading) return;
    
    HapticFeedback.selectionClick();
    
    // Add small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      Navigator.of(context).pushReplacementWithTransition(
        const LocationPicker(),
        transition: (page) => AppPageTransitions.fadeSlideTransition(page: page),
      );
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
                      _completeOnboarding();
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A4A47),
              Color(0xFF2A5D5A),
              Color(0xFF1A4A47),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                Color(0xFF1A4A47),
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: _previousStep,
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: Colors.white,
                  size: 24,
                ),
              ),
              actions: [
                if (_currentStep < 2)
                  TextButton(
                    onPressed: _skipToEnd,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Progress indicator
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      child: Row(
                        children: [
                          for (int i = 0; i < 3; i++)
                            Expanded(
                              child: Container(
                                height: 0.5.h,
                                margin: EdgeInsets.symmetric(horizontal: 1.w),
                                decoration: BoxDecoration(
                                  color: i <= _currentStep
                                      ? const Color(0xFFC8E53F)
                                      : Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(0.25.h),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Page content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentStep = index;
                          });
                        },
                        children: [
                          OnboardingStepOne(
                            onNext: _nextStep,
                            onSkip: _skipToEnd,
                          ),
                          OnboardingStepTwo(
                            onNext: _nextStep,
                            onSkip: _skipToEnd,
                          ),
                          OnboardingStepThree(
                            onLocationPermission: _handleLocationPermission,
                            onSkip: _completeOnboarding,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
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