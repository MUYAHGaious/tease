import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../utils/page_transitions.dart';
import '../onboarding/onboarding_screen.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/gradient_background_widget.dart';
import './widgets/loading_indicator_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  String _loadingText = 'Initializing...';
  bool _showRetryOption = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Mock user data for demonstration
  final Map<String, dynamic> _mockUserData = {
    "isAuthenticated": false,
    "isFirstTime": true,
    "hasLocationPermission": false,
    "lastBookingId": null,
    "preferredRoutes": [],
  };

  // Mock app initialization data
  final List<Map<String, dynamic>> _mockBusOperators = [
    {
      "id": 1,
      "name": "Guarantee Express",
      "logo":
          "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=100&h=100&fit=crop",
      "rating": 4.5,
      "routes": ["Douala - Yaoundé", "Bamenda - Douala"],
    },
    {
      "id": 2,
      "name": "Finexs Express",
      "logo":
          "https://images.pexels.com/photos/1545743/pexels-photo-1545743.jpeg?w=100&h=100&fit=crop",
      "rating": 4.2,
      "routes": ["Kumba - Douala", "Limbe - Douala"],
    },
  ];

  final List<Map<String, dynamic>> _mockCachedRoutes = [
    {
      "id": 1,
      "from": "Douala",
      "to": "Yaoundé",
      "duration": "4h 30m",
      "price": "XFA 3500",
      "lastSearched": DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      "id": 2,
      "from": "Bamenda",
      "to": "Douala",
      "duration": "6h 15m",
      "price": "XFA 4500",
      "lastSearched": DateTime.now().subtract(const Duration(days: 5)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _startInitialization() async {
    try {
      // Set system UI overlay style for dark theme
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.lightTheme.colorScheme.primary,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      await _performInitializationSteps();
    } catch (e) {
      _handleInitializationError();
    }
  }

  Future<void> _performInitializationSteps() async {
    // Step 1: Check authentication status
    setState(() => _loadingText = 'Checking authentication...');
    await Future.delayed(const Duration(milliseconds: 400));

    final bool isAuthenticated = _mockUserData["isAuthenticated"] as bool;

    // Step 2: Load cached data
    setState(() => _loadingText = 'Loading cached routes...');
    await Future.delayed(const Duration(milliseconds: 300));

    // Simulate loading cached routes
    final cachedRoutes = _mockCachedRoutes;
    debugPrint('Loaded ${cachedRoutes.length} cached routes');

    // Step 3: Fetch bus operator data
    setState(() => _loadingText = 'Fetching bus operators...');
    await Future.delayed(const Duration(milliseconds: 350));

    // Simulate fetching bus operators
    final operators = _mockBusOperators;
    debugPrint('Loaded ${operators.length} bus operators');

    // Step 4: Prepare offline storage
    setState(() => _loadingText = 'Preparing offline storage...');
    await Future.delayed(const Duration(milliseconds: 250));

    // Step 5: Check for app updates
    setState(() => _loadingText = 'Checking for updates...');
    await Future.delayed(const Duration(milliseconds: 200));

    // Step 6: Complete initialization
    setState(() => _loadingText = 'Almost ready...');
    await Future.delayed(const Duration(milliseconds: 200));

    // Navigate based on user state
    await _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    final bool isAuthenticated = _mockUserData["isAuthenticated"] as bool;
    final bool isFirstTime = _mockUserData["isFirstTime"] as bool;
    final bool hasLocationPermission =
        _mockUserData["hasLocationPermission"] as bool;

    // Wait for logo animation to complete (1200ms + 200ms delay) before starting fade
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Start fade out animation and wait for completion
    await _fadeController.forward();
    
    // Add small buffer to ensure smooth transition
    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      // Use custom transition for smooth navigation to onboarding
      Navigator.of(context).pushReplacementWithTransition(
        const OnboardingScreen(),
        transition: (page) => AppPageTransitions.fadeSlideTransition(page: page),
      );
    }
  }

  void _handleInitializationError() {
    if (mounted) {
      setState(() {
        _loadingText = 'Connection timeout';
        _showRetryOption = true;
      });
    }
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _showRetryOption = false;
      _loadingText = 'Retrying...';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    await _startInitialization();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: GradientBackgroundWidget(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: AnimatedLogoWidget(),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    constraints: BoxConstraints(minHeight: 15.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _showRetryOption
                            ? _buildRetrySection()
                            : LoadingIndicatorWidget(
                                loadingText: _loadingText,
                              ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                      'Version 1.0.0',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRetrySection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: CustomIconWidget(
              iconName: 'wifi_off',
              color: const Color(0xFFC8E53F),
              size: 8.w,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            _loadingText,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              'Please check your connection and try again',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _retryInitialization,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8E53F),
                foregroundColor: const Color(0xFF1A4A47),
                elevation: 8,
                shadowColor: const Color(0xFFC8E53F).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'refresh',
                    color: const Color(0xFF1A4A47),
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Try Again',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1A4A47),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
