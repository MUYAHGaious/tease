import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
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
      duration: const Duration(
          milliseconds: 1500), // Longer duration for better fade effect
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut, // Smoother curve
    ));

    // Start fade in animation with a small delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _fadeController.forward();
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
    // Navigate after 3 seconds for optimal user experience
    Future.delayed(const Duration(milliseconds: 3000), () {
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
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home-dashboard');
        }
        return;
      }

      // Check if this is first time user
      final isFirstTime = await _checkFirstTimeUser();

      if (mounted) {
        if (isFirstTime) {
          // First time user, go to welcome screen
          Navigator.pushReplacementNamed(context, '/welcome');
        } else {
          // Returning user, go to welcome screen
          Navigator.pushReplacementNamed(context, '/welcome');
        }
      }
    } catch (e) {
      // If there's any error, go to welcome screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
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
      final hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;

      // For development/testing purposes, always show welcome in debug mode
      if (kDebugMode) {
        return true; // Always show welcome in debug mode for testing
      }

      return !hasSeenWelcome;
    } catch (e) {
      return true; // Default to first time if we can't check
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF008B8B), // Teal background matching app theme
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: const BoxDecoration(
          color: Color(0xFF008B8B), // Solid teal background
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/White.png',
              width: 70.w,
              height: 70.w,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image doesn't load
                return Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.image,
                    color: Colors.black,
                    size: 35.w,
                  ),
                );
              },
            ),
          ),
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
