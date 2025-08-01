import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/action_button_widget.dart';
import './widgets/navigation_dots_widget.dart';
import './widgets/onboarding_page_widget.dart';
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

  // Mock data for onboarding screens
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Smart Search & Booking",
      "description":
          "Find your perfect bus route with AI-powered search suggestions and real-time availability updates.",
      "imageUrl":
          "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    },
    {
      "title": "Interactive Seat Selection",
      "description":
          "Choose your ideal seat with our visual seat map featuring real-time availability and comfort ratings.",
      "imageUrl":
          "https://images.unsplash.com/photo-1570125909232-eb263c188f7e?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    },
    {
      "title": "Digital Ticket Management",
      "description":
          "Access your tickets instantly with animated QR codes and comprehensive trip details at your fingertips.",
      "imageUrl":
          "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
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

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/login');
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
                      return OnboardingPageWidget(
                        title: data["title"] as String,
                        description: data["description"] as String,
                        imageUrl: data["imageUrl"] as String,
                        parallaxOffset: _parallaxAnimation.value,
                        isLastPage: index == _totalPages - 1,
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
