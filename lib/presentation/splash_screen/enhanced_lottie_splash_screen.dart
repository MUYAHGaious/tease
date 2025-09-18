import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';

class EnhancedLottieSplashScreen extends StatefulWidget {
  const EnhancedLottieSplashScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedLottieSplashScreen> createState() =>
      _EnhancedLottieSplashScreenState();
}

class _EnhancedLottieSplashScreenState extends State<EnhancedLottieSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isLottieLoaded = false;
  bool _isAnimationComplete = false;

  @override
  void initState() {
    super.initState();
    _setSystemUIOverlay();
    _initializeAnimations();
    _startSplashTimer();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _scaleController.forward();
      }
    });
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

  void _startSplashTimer() {
    // Navigate after 3.5 seconds for optimal user experience
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  Future<void> _navigateToNextScreen() async {
    try {
      // Check if user is already logged in
      final isLoggedIn = await _checkAuthStatus();

      if (isLoggedIn) {
        // User is logged in, go to home dashboard
        Navigator.pushReplacementNamed(context, '/home-dashboard');
        return;
      }

      // Check if it's first time user
      final isFirstTime = await _checkFirstTimeUser();

      if (isFirstTime) {
        // First time user, show onboarding
        Navigator.pushReplacementNamed(context, '/onboarding-flow');
      } else {
        // Returning user but not logged in, go to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // If there's any error, default to onboarding for safety
      Navigator.pushReplacementNamed(context, '/onboarding-flow');
    }
  }

  Future<bool> _checkAuthStatus() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      return accessToken != null && accessToken.isNotEmpty && isLoggedIn;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkFirstTimeUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      return !hasSeenOnboarding;
    } catch (e) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a4d3a),
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a4d3a),
              Color(0xFF2d5a3d),
              Color(0xFF1a4d3a),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Enhanced Lottie Animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Lottie.asset(
                  'assets/lottie-splash-screen.json',
                  width: 100.w,
                  height: 100.h,
                  fit: BoxFit.cover,
                  repeat: false,
                  animate: true,
                  frameRate: FrameRate.max,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                  options: LottieOptions(
                    enableMergePaths: true,
                  ),
                  onLoaded: (composition) {
                    print(
                        'Enhanced Lottie splash screen loaded successfully - Duration: ${composition.duration}');
                    if (mounted) {
                      setState(() {
                        _isLottieLoaded = true;
                      });
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('Lottie error: $error');
                    return _buildFallbackContent();
                  },
                ),
              ),
            ),

            // Overlay content
            Positioned(
              bottom: 10.h,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Loading indicator
                    Container(
                      width: 4.w,
                      height: 4.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Loading your experience...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackContent() {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a4d3a),
            const Color(0xFF2d5a3d),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      color: Colors.white,
                      size: 15.w,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 4.h),

            // App title
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'TEASE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 1.h),

            // Subtitle
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Transport Excellence & Accessibility',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.0,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
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
