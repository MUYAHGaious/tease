import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'widgets/animated_logo_widget.dart';
import 'widgets/animated_background_widget.dart';

class EnhancedSplashScreen extends StatefulWidget {
  const EnhancedSplashScreen({super.key});

  @override
  State<EnhancedSplashScreen> createState() => _EnhancedSplashScreenState();
}

class _EnhancedSplashScreenState extends State<EnhancedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  bool _isCheckingAuth = true;
  String _statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _checkAuthenticationStatus();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      setState(() {
        _statusMessage = 'Checking authentication...';
      });

      // Add minimum splash duration for UX
      await Future.delayed(const Duration(seconds: 2));

      final isAuthenticated = await AuthService.isAuthenticated();

      if (isAuthenticated) {
        setState(() {
          _statusMessage = 'Verifying session...';
        });

        // Try to get current user data
        final result = await AuthService.getCurrentUser();

        if (result.success && result.data != null) {
          setState(() {
            _statusMessage = 'Welcome back, ${result.data!.displayName}!';
          });

          // Small delay to show welcome message
          await Future.delayed(const Duration(milliseconds: 800));

          if (mounted) {
            _navigateBasedOnUserRole(result.data!);
          }
        } else {
          // Session expired or invalid, clear tokens
          await AuthService.logout();
          _navigateToAuth();
        }
      } else {
        setState(() {
          _statusMessage = 'Setting up your experience...';
        });

        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToAuth();
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Connection error. Please check your network.';
      });

      // Wait a bit then navigate to auth anyway
      await Future.delayed(const Duration(seconds: 2));
      _navigateToAuth();
    }
  }

  void _navigateBasedOnUserRole(UserModel user) {
    // Determine navigation based on user role and completion status
    String route;

    if (user.affiliation == null || user.position == null) {
      // User hasn't completed welcome
      route = '/login';
    } else if (user.isConductor || user.isDriver) {
      // Staff with operational roles
      route = '/conductor-dashboard';
    } else if (user.isBookingClerk || user.isScheduleManager) {
      // Administrative roles
      route = '/admin-dashboard';
    } else if (user.isUniversityAffiliated) {
      // University affiliated users
      route = '/school-dashboard';
    } else {
      // Ordinary users
      route = '/home-dashboard';
    }

    Navigator.pushReplacementNamed(context, route);
  }

  void _navigateToAuth() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/signup');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          const AnimatedBackgroundWidget(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated logo
                        AnimatedBuilder(
                          animation: _logoAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _logoAnimation.value,
                              child: Container(
                                width: 25.w,
                                height: 25.w,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.directions_bus,
                                  color: Colors.white,
                                  size: 12.w,
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 5.h),

                        // App title with animation
                        AnimatedBuilder(
                          animation: _textAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _textAnimation.value,
                              child: Transform.translate(
                                offset:
                                    Offset(0, 30 * (1 - _textAnimation.value)),
                                child: Column(
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.white.withValues(alpha: 0.8),
                                          ],
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        'TEASE',
                                        style: TextStyle(
                                          fontSize: 48.sp,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 4,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      'Transport Excellence & Service',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color:
                                            Colors.white.withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Status message and loading indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Column(
                    children: [
                      // Loading indicator
                      if (_isCheckingAuth) ...[
                        Container(
                          width: 6.w,
                          height: 6.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                      ],

                      // Status message
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      // Version info
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
