import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GreetingHeaderWidget extends StatefulWidget {
  const GreetingHeaderWidget({super.key});

  @override
  State<GreetingHeaderWidget> createState() => _GreetingHeaderWidgetState();
}

class _GreetingHeaderWidgetState extends State<GreetingHeaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _typewriterController;
  late AnimationController _gradientController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _typewriterAnimation;
  late Animation<double> _gradientAnimation;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    const userName = 'Alex'; // This would come from user data in real app
    
    if (hour < 12) {
      return 'Good Morning, $userName';
    } else if (hour < 17) {
      return 'Good Afternoon, $userName';
    } else {
      return 'Good Evening, $userName';
    }
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return Icons.wb_sunny; // Morning - sunny
    } else if (hour < 17) {
      return Icons.wb_cloudy; // Afternoon - cloudy
    } else {
      return Icons.nights_stay; // Evening - moon
    }
  }

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _typewriterController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _typewriterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typewriterController,
      curve: Curves.easeInOut,
    ));

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_gradientController);

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _typewriterController.forward();
    });
    _gradientController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _typewriterController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  void _showBurgerMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                'Menu',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                children: [
                  _buildMenuItem(
                    context,
                    'Admin Dashboard',
                    'admin_panel_settings',
                    'Manage buses, routes & bookings',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/admin-dashboard');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Driver Interface',
                    'directions_bus',
                    'Scan QR codes & manage rides',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/driver-boarding-interface');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'School Bus Booking',
                    'school',
                    'Book seats for school transport',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/school-bus-booking');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'School Bus',
                    'school_bus',
                    'Book school bus rides for students',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/school-bus-home');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Parent Dashboard',
                    'family_restroom',
                    'Manage your children\'s bus bookings',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/parent-dashboard');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Bus Booking',
                    'directions_bus',
                    'Book regular bus tickets',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/bus-booking-form');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'QR Code',
                    'qr_code',
                    'View your booking QR codes',
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/qr-code-display');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, String icon, String subtitle, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryLight.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomIconWidget(
                    iconName: icon,
                    color: AppTheme.primaryLight,
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        subtitle,
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.onSurfaceLight.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'arrow_forward_ios',
                  color: AppTheme.onSurfaceLight.withValues(alpha: 0.4),
                  size: 4.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      child: Row(
        children: [
          // App logo
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getGreetingIcon(),
                  color: Colors.white,
                  size: 4.w,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          // Greeting text with AI animations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _typewriterAnimation,
                  builder: (context, child) {
                    final greeting = _getGreeting();
                    final visibleLength = (_typewriterAnimation.value * greeting.length).round();
                    final visibleText = greeting.substring(0, visibleLength);
                    
                    return AnimatedBuilder(
                      animation: _gradientAnimation,
                      builder: (context, child) {
                        return ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                Color(0xFF1a4d3a), // Deep forest green from splash
                                Color(0xFF2d5a3d), // Medium forest green
                                Color(0xFF4a7c59), // Lighter forest green
                              ],
                              stops: [
                                (_gradientAnimation.value - 0.2).clamp(0.0, 1.0),
                                _gradientAnimation.value,
                                (_gradientAnimation.value + 0.2).clamp(0.0, 1.0),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          child: Text(
                            visibleText + (_typewriterAnimation.value < 1.0 ? '|' : ''),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          // Hamburger menu
          GestureDetector(
            onTap: () => _showBurgerMenu(context),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.menu,
                color: Colors.black54,
                size: 6.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
