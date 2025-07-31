import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/animated_background_widget.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/glassmorphism_overlay_widget.dart';
import './widgets/loading_indicator_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _isInitialized = false;
  bool _isAuthenticated = false;
  bool _isFirstTime = true;

  // Mock user data for authentication check
  final Map<String, dynamic> _mockUserData = {
    "isAuthenticated": false,
    "isFirstTime": true,
    "userPreferences": {
      "theme": "light",
      "notifications": true,
      "language": "en"
    },
    "paymentMethods": [
      {
        "id": "1",
        "type": "credit_card",
        "last4": "4242",
        "brand": "visa",
        "isDefault": true
      }
    ],
    "routeCache": [
      {
        "from": "New York",
        "to": "Boston",
        "lastSearched": "2025-07-28T14:47:04.460876"
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    _setSystemUIOverlay();
    _initializeApp();
  }

  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate authentication status check
      await Future.delayed(const Duration(milliseconds: 1000));
      final authStatus = _mockUserData["isAuthenticated"] as bool;

      // Simulate user preference loading
      await Future.delayed(const Duration(milliseconds: 500));
      final preferences =
          _mockUserData["userPreferences"] as Map<String, dynamic>;

      // Simulate payment method validation
      await Future.delayed(const Duration(milliseconds: 300));
      final paymentMethods = _mockUserData["paymentMethods"] as List;
      final hasValidPayment = paymentMethods.isNotEmpty;

      // Simulate route data caching
      await Future.delayed(const Duration(milliseconds: 200));
      final routeCache = _mockUserData["routeCache"] as List;

      setState(() {
        _isAuthenticated = authStatus;
        _isFirstTime = _mockUserData["isFirstTime"] as bool;
        _isInitialized = true;
      });

      // Additional delay for smooth animation completion
      await Future.delayed(const Duration(milliseconds: 1500));

      _navigateToNextScreen();
    } catch (e) {
      // Handle initialization errors gracefully
      setState(() {
        _isInitialized = true;
      });
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    String nextRoute;

    if (_isAuthenticated) {
      nextRoute = '/home-dashboard';
    } else if (_isFirstTime) {
      nextRoute = '/onboarding-flow';
    } else {
      nextRoute = '/home-dashboard'; // Default to home for returning users
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  void _onLogoAnimationComplete() {
    // Logo animation completed, continue with initialization
    if (_isInitialized) {
      _navigateToNextScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      body: SafeArea(
        child: SizedBox(
          width: 100.w,
          height: 100.h,
          child: Stack(
            children: [
              // Animated background with gradient
              const AnimatedBackgroundWidget(),

              // Glassmorphism overlay cards
              const GlassmorphismOverlayWidget(),

              // Main content
              Column(
                children: [
                  // Top spacer
                  SizedBox(height: 25.h),

                  // Animated logo with phantom-inspired reveal
                  Expanded(
                    flex: 3,
                    child: AnimatedLogoWidget(
                      onAnimationComplete: _onLogoAnimationComplete,
                    ),
                  ),

                  // Loading indicator
                  Expanded(
                    flex: 1,
                    child: const LoadingIndicatorWidget(),
                  ),

                  // Bottom spacer with version info
                  Container(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Column(
                      children: [
                        Text(
                          'Version 1.0.0',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                            fontSize: 10.sp,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Premium Bus Booking Experience',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Accessibility overlay for reduced motion
              if (MediaQuery.of(context).accessibleNavigation)
                Container(
                  width: 100.w,
                  height: 100.h,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'directions_bus',
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          size: 48.sp,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'BusFlow Pro',
                          style: AppTheme.lightTheme.textTheme.headlineMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }
}
