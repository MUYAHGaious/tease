import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../core/app_state.dart';
import '../../../models/user_model.dart';
import '../../../services/onboarding_cache_service.dart';

// 2025 Design Constants - No gradients, solid colors only
const Color primaryColor = Color(0xFF20B2AA);
const double maxDrawerWidth = 280.0; // Material Design 3 spec
const double cardElevation = 2.0;
const double sectionSpacing = 24.0;

class CustomMenuDrawer extends StatefulWidget {
  const CustomMenuDrawer({super.key});

  @override
  State<CustomMenuDrawer> createState() => _CustomMenuDrawerState();
}

class _CustomMenuDrawerState extends State<CustomMenuDrawer>
    with TickerProviderStateMixin {

  List<Map<String, dynamic>> _availableMenuItems = [];
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserAndMenuItems();
  }

  void _loadUserAndMenuItems() {
    _currentUser = AppState().currentUser;
    _availableMenuItems = _getMenuItemsForUser(_currentUser);
    setState(() {});
  }

  List<Map<String, dynamic>> _getMenuItemsForUser(UserModel? user) {
    List<Map<String, dynamic>> items = [
      // Core features available to all users
      {
        'icon': Icons.search,
        'title': 'Search & Book Tickets',
        'route': '/search-booking',
        'requiresAuth': false,
        'category': 'core',
      },
      {
        'icon': Icons.confirmation_num,
        'title': 'My Tickets',
        'route': '/my-tickets',
        'requiresAuth': true,
        'category': 'core',
      },
      {
        'icon': Icons.wallet,
        'title': 'Wallet & Profile',
        'route': '/profile-settings',
        'requiresAuth': true,
        'category': 'core',
      },
      {
        'icon': Icons.local_offer,
        'title': 'Special Offers',
        'route': '/booking-confirmation',
        'requiresAuth': false,
        'category': 'core',
      },
    ];

    // Smart feature access based on roles
    if (user != null) {
      // School/University features
      if (user.isUniversityAffiliated || user.affiliations.contains('ict_university')) {
        items.add({
          'icon': Icons.school,
          'title': 'School Bus Services',
          'route': '/school-bus-home',
          'requiresAuth': true,
          'category': 'university',
          'badge': 'ICT University',
        });
      } else {
        // On-demand access to school bus features
        items.add({
          'icon': Icons.school_outlined,
          'title': 'Access School Bus',
          'onTap': () => _handleSchoolBusAccess(),
          'requiresAuth': true,
          'category': 'ondemand',
          'badge': 'Verify Access',
        });
      }

      // Agency/Professional features
      if (user.isScheduleManager) {
        items.add({
          'icon': Icons.admin_panel_settings,
          'title': 'Schedule Manager',
          'route': '/admin-dashboard',
          'requiresAuth': true,
          'category': 'management',
          'badge': 'Manager',
        });
      }

      if (user.isDriver) {
        items.add({
          'icon': Icons.directions_bus,
          'title': 'Driver Dashboard',
          'route': '/driver-boarding-interface',
          'requiresAuth': true,
          'category': 'operations',
          'badge': 'Driver',
        });
      }

      if (user.isConductor) {
        items.add({
          'icon': Icons.confirmation_number,
          'title': 'Conductor Interface',
          'route': '/conductor-dashboard',
          'requiresAuth': true,
          'category': 'operations',
          'badge': 'Conductor',
        });
      }

      if (user.isBookingClerk) {
        items.add({
          'icon': Icons.book,
          'title': 'Booking Management',
          'route': '/booking-clerk-dashboard',
          'requiresAuth': true,
          'category': 'operations',
          'badge': 'Clerk',
        });
      }

      // Agency access for non-affiliated users
      if (!user.affiliations.contains('agency') && 
          !user.isScheduleManager && !user.isDriver && !user.isConductor && !user.isBookingClerk) {
        items.add({
          'icon': Icons.business_outlined,
          'title': 'Join as Agency Staff',
          'onTap': () => _handleAgencyAccess(),
          'requiresAuth': true,
          'category': 'ondemand',
          'badge': 'Apply Now',
        });
      }
    }

    return items;
  }

  Future<void> _handleSchoolBusAccess() async {
    Navigator.pop(context); // Close drawer
    
    // Check if user has cached university onboarding progress
    final cachedProgress = await OnboardingCacheService.getProgress('school_bus_onboarding');
    
    if (cachedProgress != null && cachedProgress.isValid) {
      // Resume from cache
      Navigator.pushNamed(
        context,
        '/progressive-onboarding',
        arguments: {
          'sessionType': 'school_bus_onboarding',
          'resumeFrom': cachedProgress.currentStep,
          'cachedData': cachedProgress.collectedData,
        },
      );
    } else {
      // Start fresh onboarding
      Navigator.pushNamed(
        context,
        '/progressive-onboarding',
        arguments: {
          'sessionType': 'school_bus_onboarding',
        },
      );
    }
  }

  Future<void> _handleAgencyAccess() async {
    Navigator.pop(context); // Close drawer
    
    // Check if user has cached agency onboarding progress
    final cachedProgress = await OnboardingCacheService.getProgress('agency');
    
    if (cachedProgress != null && cachedProgress.isValid) {
      // Resume from cache
      Navigator.pushNamed(
        context,
        '/progressive-onboarding',
        arguments: {
          'sessionType': 'agency',
          'resumeFrom': cachedProgress.currentStep,
          'cachedData': cachedProgress.collectedData,
        },
      );
    } else {
      // Start fresh onboarding
      Navigator.pushNamed(
        context,
        '/progressive-onboarding',
        arguments: {
          'sessionType': 'agency',
        },
      );
    }
  }

  void _handleMenuItemTap(Map<String, dynamic> item) {
    HapticFeedback.selectionClick();
    Navigator.pop(context);
    
    if (item.containsKey('onTap')) {
      item['onTap']();
    } else if (item.containsKey('route')) {
      Navigator.pushNamed(context, item['route']);
    }
  }

  Widget _glassDrawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxDrawerWidth, // Material Design 3 spec
      child: Drawer(
        child: Container(
          color: AppTheme.backgroundLight,
          child: SafeArea(
            child: Column(
              children: [
                // Modern Header with clean design
                _buildModernHeader(),

                // Categorized Menu Items with better organization
                Expanded(
                  child: _buildCategorizedMenu(),
                ),

                // Clean Bottom Actions
                _buildCleanBottomActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modern 2025 Header Design - Clean and minimal
  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 3.h),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Clean avatar design
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 6.w,
            ),
          ),
          SizedBox(width: 3.w),
          // User info with clean typography
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser?.name ?? 'Guest User',
                  style: TextStyle(
                    color: AppTheme.onSurfaceLight,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.3.h),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getUserStatusText(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // This method is now replaced by _buildModernMenuItem

  // Modern 2025 color system - simplified and consistent
  Color _getModernIconBg(Map<String, dynamic> item) {
    switch (item['category']) {
      case 'ondemand':
        return primaryColor.withOpacity(0.15);
      case 'university':
        return Colors.blue.withOpacity(0.1);
      case 'management':
        return Colors.purple.withOpacity(0.1);
      case 'operations':
        return Colors.green.withOpacity(0.1);
      default:
        return primaryColor.withOpacity(0.1);
    }
  }

  Color _getModernIconColor(Map<String, dynamic> item) {
    switch (item['category']) {
      case 'ondemand':
        return primaryColor;
      case 'university':
        return Colors.blue.shade600;
      case 'management':
        return Colors.purple.shade600;
      case 'operations':
        return Colors.green.shade600;
      default:
        return primaryColor;
    }
  }

  Color _getModernBadgeColor(Map<String, dynamic> item) {
    return _getModernIconColor(item);
  }

  String _getUserStatusText() {
    if (_currentUser == null) return 'Guest User';
    
    List<String> roles = [];
    if (_currentUser!.isUniversityAffiliated) roles.add('ICT University');
    if (_currentUser!.isScheduleManager) roles.add('Manager');
    if (_currentUser!.isDriver) roles.add('Driver');
    if (_currentUser!.isConductor) roles.add('Conductor');
    if (_currentUser!.isBookingClerk) roles.add('Clerk');
    
    if (roles.isEmpty) return 'Standard User';
    return roles.join(' • ');
  }

  // 2025 Categorized Menu System
  Widget _buildCategorizedMenu() {
    final categories = _organizeByCategoryModern();

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildMenuSection(
          category['title'],
          category['items'],
          category['icon'],
        );
      },
    );
  }

  // Organize menu items by category with modern approach
  List<Map<String, dynamic>> _organizeByCategoryModern() {
    final categorizedMenu = <String, List<Map<String, dynamic>>>{};

    // Group items by category
    for (final item in _availableMenuItems) {
      final category = item['category'] ?? 'core';
      categorizedMenu.putIfAbsent(category, () => []);
      categorizedMenu[category]!.add(item);
    }

    // Create sections with proper ordering and icons
    final sections = <Map<String, dynamic>>[];

    if (categorizedMenu.containsKey('core')) {
      sections.add({
        'title': 'Main Services',
        'icon': Icons.stars,
        'items': categorizedMenu['core']!,
      });
    }

    if (categorizedMenu.containsKey('university')) {
      sections.add({
        'title': 'University Services',
        'icon': Icons.school,
        'items': categorizedMenu['university']!,
      });
    }

    if (categorizedMenu.containsKey('management') ||
        categorizedMenu.containsKey('operations')) {
      final workItems = [
        ...categorizedMenu['management'] ?? [],
        ...categorizedMenu['operations'] ?? [],
      ];
      if (workItems.isNotEmpty) {
        sections.add({
          'title': 'Work Tools',
          'icon': Icons.work,
          'items': workItems,
        });
      }
    }

    if (categorizedMenu.containsKey('ondemand')) {
      sections.add({
        'title': 'Get Access',
        'icon': Icons.lock_open,
        'items': categorizedMenu['ondemand']!,
      });
    }

    return sections;
  }

  // Build modern menu section with clean design
  Widget _buildMenuSection(String title, List<Map<String, dynamic>> items, IconData sectionIcon) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with modern design
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: Row(
            children: [
              Icon(
                sectionIcon,
                color: primaryColor.withOpacity(0.7),
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.onSurfaceLight.withOpacity(0.7),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  margin: EdgeInsets.only(left: 3.w),
                  color: primaryColor.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),

        // Section Items
        ...items.map((item) => _buildModernMenuItem(item)).toList(),

        SizedBox(height: 2.h), // Section spacing
      ],
    );
  }

  // Modern menu item design following 2025 patterns
  Widget _buildModernMenuItem(Map<String, dynamic> item) {
    final isSpecial = item['category'] == 'ondemand';

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleMenuItemTap(item),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: isSpecial
                  ? primaryColor.withOpacity(0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSpecial ? Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 1,
              ) : null,
            ),
            child: Row(
              children: [
                // Icon with modern styling
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: _getModernIconBg(item),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item['icon'],
                    color: _getModernIconColor(item),
                    size: 5.w,
                  ),
                ),

                SizedBox(width: 3.w),

                // Title and badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: TextStyle(
                          color: AppTheme.onSurfaceLight,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.containsKey('badge')) ..[
                        SizedBox(height: 0.3.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
                          decoration: BoxDecoration(
                            color: _getModernBadgeColor(item),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['badge'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow with proper sizing
                Icon(
                  isSpecial ? Icons.arrow_forward : Icons.arrow_forward_ios,
                  color: AppTheme.onSurfaceLight.withOpacity(0.4),
                  size: isSpecial ? 4.5.w : 3.5.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Clean bottom actions following 2025 patterns
  Widget _buildCleanBottomActions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.onSurfaceLight.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Settings Access
          _buildBottomActionItem(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile-settings');
            },
          ),

          SizedBox(height: 1.h),

          // Help & Support
          _buildBottomActionItem(
            icon: Icons.help_outline,
            label: 'Help & Support',
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
              // TODO: Navigate to help screen
            },
          ),

          SizedBox(height: 2.h),

          // Logout with emphasis
          _buildBottomActionItem(
            icon: Icons.logout,
            label: 'Sign Out',
            isDestructive: true,
            onTap: () {
              HapticFeedback.selectionClick();
              _showLogoutConfirmation();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red.shade600 : AppTheme.onSurfaceLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          child: Row(
            children: [
              Icon(
                icon,
                color: color.withOpacity(0.8),
                size: 4.5.w,
              ),
              SizedBox(width: 3.w),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sign Out',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontSize: 12.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.onSurfaceLight.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close drawer
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/splash-screen',
                (route) => false,
              );
            },
            child: Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}