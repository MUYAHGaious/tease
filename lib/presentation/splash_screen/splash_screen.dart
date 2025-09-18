import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setSystemUIOverlay();
    _initializeAnimation();
    _startSplashTimer();
  }

  void _initializeAnimation() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start fade in animation immediately
    _fadeController.forward();
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
    // Navigate after 2.5 seconds for optimal user experience with image
    Future.delayed(const Duration(milliseconds: 2500), () {
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

      // Always go to welcome screen for auth flow
      Navigator.pushReplacementNamed(context, '/welcome');
    } catch (e) {
      // If there's any error, go to welcome screen
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  Future<bool> _checkAuthStatus() async {
    try {
      // Import the auth service to check login status
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      // Simple check - if we have both token and logged in flag
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
      return true; // Default to first time if we can't check
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a4d3a), // Immediate background to prevent white screen
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
            ],
          ),
        ),
        child: Image.asset(
          'assets/images/bus.png',
          width: 100.w,
          height: 100.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Image loading error: $error');
            return Container(
              width: 100.w,
              height: 100.h,
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_bus,
                      color: Colors.white,
                      size: 20.w,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'TEASE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
