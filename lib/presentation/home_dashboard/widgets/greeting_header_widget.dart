import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import 'custom_menu_drawer.dart';

class GreetingHeaderWidget extends StatefulWidget {
  const GreetingHeaderWidget({super.key});

  @override
  State<GreetingHeaderWidget> createState() => _GreetingHeaderWidgetState();
}

class _GreetingHeaderWidgetState extends State<GreetingHeaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _tipController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _tipAnimation;
  
  int _currentTipIndex = 0;
  
  final List<Map<String, dynamic>> _appTips = [
    {
      'icon': Icons.flash_on,
      'tip': 'Book faster with Quick Actions',
      'color': Color(0xFF20B2AA),
    },
    {
      'icon': Icons.favorite,
      'tip': 'Save routes to Favorites',
      'color': Color(0xFF20B2AA),
    },
    {
      'icon': Icons.notification_important,
      'tip': 'Enable notifications for updates',
      'color': Color(0xFF20B2AA),
    },
    {
      'icon': Icons.qr_code_scanner,
      'tip': 'Use QR codes for quick boarding',
      'color': Color(0xFF20B2AA),
    },
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    const userName = 'Alex'; // This would come from user data in real app
    
    if (hour < 12) {
      return 'Good Morning, $userName!';
    } else if (hour < 17) {
      return 'Good Afternoon, $userName!';
    } else {
      return 'Good Evening, $userName!';
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

    _tipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _tipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tipController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _tipController.forward();
    _startTipRotation();
  }

  void _startTipRotation() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _cycleTips();
      }
    });
  }

  void _cycleTips() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        await _tipController.reverse();
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _appTips.length;
        });
        await _tipController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tipController.dispose();
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

  void _showCustomMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: const CustomMenuDrawer(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            children: [
              // Main header row
              Row(
                children: [
                  // Avatar with time-based icon
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: Color(0xFF20B2AA),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF20B2AA).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getGreetingIcon(),
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  // Greeting text - responsive
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF20B2AA),
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  // Menu button
                  GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.menu,
                        color: Color(0xFF20B2AA),
                        size: 5.w,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 2.h),
              
              // App tips section with AI-style animation
              AnimatedBuilder(
                animation: _tipAnimation,
                builder: (context, child) {
                  final currentTip = _appTips[_currentTipIndex];
                  return Transform.scale(
                    scale: 0.9 + (_tipAnimation.value * 0.1),
                    child: Transform.translate(
                      offset: Offset(
                        (1 - _tipAnimation.value) * 50 * ((_currentTipIndex % 2 == 0) ? -1 : 1), 
                        0
                      ),
                      child: Opacity(
                        opacity: _tipAnimation.value,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (currentTip['color'] as Color).withOpacity(0.15),
                                (currentTip['color'] as Color).withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (currentTip['color'] as Color).withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (currentTip['color'] as Color).withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.5.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      (currentTip['color'] as Color).withOpacity(0.3),
                                      (currentTip['color'] as Color).withOpacity(0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  currentTip['icon'],
                                  color: currentTip['color'],
                                  size: 4.5.w,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    currentTip['tip'],
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF20B2AA),
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(1.5.w),
                                decoration: BoxDecoration(
                                  color: (currentTip['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.auto_awesome,
                                  color: (currentTip['color'] as Color).withOpacity(0.8),
                                  size: 3.5.w,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
