import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/action_button_widget.dart';
import './widgets/navigation_dots_widget.dart';
import './widgets/professional_onboarding_page.dart';
import './widgets/progress_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _parallaxController;
  late AnimationController _fadeController;
  late Animation<double> _parallaxAnimation;
  late Animation<double> _fadeAnimation;

  int _currentPage = 0;
  final int _totalPages = 3;

  // Professional onboarding data showcasing amazing features
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "🎤 Voice AI Booking",
      "subtitle": "Book tickets with your voice",
      "description":
          "Simply speak to book your tickets! Our advanced AI understands natural language and handles everything from destination selection to payment processing.",
      "features": ["Voice recognition", "Natural language processing", "Hands-free booking", "Smart suggestions"],
      "icon": Icons.mic,
      "color": Color(0xFF6C63FF),
      "gradient": [Color(0xFF6C63FF), Color(0xFF4834D4)],
    },
    {
      "title": "🗺️ Real-time Bus Tracking",
      "subtitle": "Track buses & students live",
      "description":
          "Watch buses move in real-time on interactive maps. For school buses, track student locations with ETA calculations and safety notifications.",
      "features": ["Live GPS tracking", "Student ETA calculations", "Safety alerts", "Driver interface"],
      "icon": Icons.location_on,
      "color": Color(0xFF00D2FF),
      "gradient": [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
    },
    {
      "title": "🎯 Smart City Search",
      "subtitle": "Find routes intelligently",
      "description":
          "Our AI-powered search suggests the best routes from 30+ cities with predictive suggestions and real-time availability updates.",
      "features": ["30+ cities covered", "Predictive search", "Route optimization", "Price comparisons"],
      "icon": Icons.search,
      "color": Color(0xFFFF6B6B),
      "gradient": [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _parallaxAnimation = Tween<double>(
      begin: 0.0,
      end: 100.0,
    ).animate(CurvedAnimation(
      parent: _parallaxController,
      curve: Curves.easeOutCubic,
    ));

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
    _parallaxController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      HapticFeedback.mediumImpact();
      _parallaxController.forward();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToHome();
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Mark that user has seen onboarding
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    
    // Navigate to signup for new users to register
    Navigator.pushReplacementNamed(context, '/signup');
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    _parallaxController.reset();

    // Trigger haptic feedback for page changes
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // Main content with PageView
              PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return AnimatedBuilder(
                    animation: _parallaxAnimation,
                    builder: (context, child) {
                      return ProfessionalOnboardingPage(
                        title: data["title"] as String,
                        subtitle: data["subtitle"] as String,
                        description: data["description"] as String,
                        features: List<String>.from(data["features"]),
                        icon: data["icon"] as IconData,
                        color: data["color"] as Color,
                        gradient: List<Color>.from(data["gradient"]),
                        parallaxOffset: _parallaxAnimation.value,
                      );
                    },
                  );
                },
              ),

              // Top section with progress and skip button
              Positioned(
                top: 2.h,
                left: 5.w,
                right: 5.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Progress indicator
                    ProgressIndicatorWidget(
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                    ),

                    // Skip button
                    GestureDetector(
                      onTap: _skipOnboarding,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface
                              .withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          "Skip",
                          style: AppTheme.lightTheme.textTheme.labelMedium!
                              .copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom section with navigation and action button
              Positioned(
                bottom: 4.h,
                left: 5.w,
                right: 5.w,
                child: Column(
                  children: [
                    // Navigation dots
                    NavigationDotsWidget(
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                    ),

                    SizedBox(height: 4.h),

                    // Action button
                    ActionButtonWidget(
                      text: _currentPage == _totalPages - 1
                          ? "Get Started"
                          : "Next",
                      onPressed: _nextPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
