import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> 
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: 90.w,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildSophisticatedHeader(context),
                  _buildDivider(),
                  Expanded(child: _buildMenuItems(context)),
                  _buildSophisticatedFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSophisticatedHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 3.h),
      child: Column(
        children: [
          // Header Row with Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menu',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // User Profile Section
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightTheme.colorScheme.primary,
                  AppTheme.lightTheme.colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(4.w),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Profile Avatar with Status Indicator
                Stack(
                  children: [
                    Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lightTheme.colorScheme.secondary,
                            AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.w),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'JS',
                          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 4.w,
                        height: 4.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(2.w),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 3.w),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Smith',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'diamond',
                              color: AppTheme.lightTheme.colorScheme.secondary,
                              size: 3.w,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Premium',
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'account_balance_wallet',
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            size: 3.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'XFA 25,000',
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      {
        'icon': 'home',
        'title': 'Home',
        'subtitle': 'Search & book tickets',
        'route': '/',
        'badge': null,
      },
      {
        'icon': 'confirmation_number',
        'title': 'My Bookings',
        'subtitle': 'View your tickets',
        'route': '/my-bookings-screen',
        'badge': '2',
      },
      {
        'icon': 'school',
        'title': 'Find School Bus',
        'subtitle': 'Book school transportation',
        'route': '/school-bus-dashboard',
        'badge': 'NEW',
      },
      {
        'icon': 'account_balance_wallet',
        'title': 'Wallet',
        'subtitle': 'XFA 25,000 available',
        'route': '/wallet-screen',
        'badge': null,
      },
      {
        'icon': 'local_offer',
        'title': 'Offers & Deals',
        'subtitle': 'Save on your next trip',
        'route': '/offers',
        'badge': 'NEW',
      },
      {
        'icon': 'history',
        'title': 'Trip History',
        'subtitle': 'Previous journeys',
        'route': '/history',
        'badge': null,
      },
      {
        'icon': 'support_agent',
        'title': 'Customer Support',
        'subtitle': '24/7 assistance',
        'route': '/support',
        'badge': null,
      },
      {
        'icon': 'settings',
        'title': 'Settings',
        'subtitle': 'App preferences',
        'route': '/settings-screen',
        'badge': null,
      },
      {
        'icon': 'help',
        'title': 'Help & FAQ',
        'subtitle': 'Get answers',
        'route': '/help',
        'badge': null,
      },
    ];

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      itemCount: menuItems.length,
      separatorBuilder: (context, index) => SizedBox(height: 0.5.h),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildSophisticatedMenuItem(
          context,
          icon: item['icon'] as String,
          title: item['title'] as String,
          subtitle: item['subtitle'] as String,
          route: item['route'] as String,
          badge: item['badge'],
        );
      },
    );
  }

  Widget _buildSophisticatedMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required String route,
    String? badge,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            Navigator.pushNamed(context, route);
          },
          borderRadius: BorderRadius.circular(3.w),
          splashColor: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.08),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                        AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: icon,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 6.w,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        subtitle,
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Badge and Arrow
                Column(
                  children: [
                    if (badge != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: badge == 'NEW' 
                              ? AppTheme.lightTheme.colorScheme.secondary
                              : AppTheme.lightTheme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(1.5.w),
                        ),
                        child: Text(
                          badge,
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: badge == 'NEW'
                                ? AppTheme.lightTheme.colorScheme.onSecondary
                                : AppTheme.lightTheme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    SizedBox(height: badge != null ? 1.h : 0),
                    CustomIconWidget(
                      iconName: 'chevron_right',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      size: 4.w,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSophisticatedFooter(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Quick Action Buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSophisticatedBottomButton(
                    context,
                    icon: 'nights_stay',
                    label: 'Dark Mode',
                    isToggle: true,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Toggle dark mode
                    },
                  ),
                ),
                Container(
                  width: 1,
                  height: 5.h,
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: _buildSophisticatedBottomButton(
                    context,
                    icon: 'logout',
                    label: 'Logout',
                    isDestructive: true,
                    onTap: () {
                      _showSophisticatedLogoutDialog(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          // App Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'verified',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 3.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Tease v1.0.0',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }

  Widget _buildSophisticatedBottomButton(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isToggle = false,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(2.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isDestructive 
                    ? AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(5.w),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: isDestructive 
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.primary,
                  size: 5.w,
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isDestructive 
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSophisticatedLogoutDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.w),
        ),
        elevation: 12,
        shadowColor: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'logout',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 8.w,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              // Title
              Text(
                'Logout Confirmation',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              // Content
              Text(
                'Are you sure you want to logout? You\'ll need to sign in again to access your account.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        side: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Close drawer
                        // Handle logout logic here
                        _performLogout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightTheme.colorScheme.error,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performLogout(BuildContext context) {
    // Add logout logic here
    // For now, just navigate to splash screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/splash-screen',
      (route) => false,
    );
  }
}