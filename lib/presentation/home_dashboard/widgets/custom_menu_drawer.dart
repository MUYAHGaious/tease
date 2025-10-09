import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/theme_notifier.dart';
import '../../../core/app_state.dart';
import '../../../models/user_model.dart';

// 2025 Design Constants - No gradients, solid colors only
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
  String _userAffiliation = 'regular';
  String _userRole = 'passenger';
  String _affiliationTitle = 'Public Transport';

  // Theme-aware colors using proper theme system
  Color get primaryColor => Theme.of(context).colorScheme.primary;
  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get textColor => Theme.of(context).colorScheme.onSurface;
  Color get surfaceColor => Theme.of(context).colorScheme.surface;
  Color get onSurfaceColor => Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  void initState() {
    super.initState();
    ThemeNotifier().addListener(_onThemeChanged);
    _loadUserAndMenuItems();
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _loadUserAndMenuItems() async {
    // Load user selections from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _userAffiliation = prefs.getString('user_affiliation') ?? 'regular';
    _userRole = prefs.getString('user_role') ?? 'passenger';
    _affiliationTitle =
        prefs.getString('user_affiliation_title') ?? 'Public Transport';

    _currentUser = AppState().currentUser;
    _availableMenuItems = _getMenuItemsForAffiliation();
    setState(() {});
  }

  List<Map<String, dynamic>> _getMenuItemsForUser(UserModel? user) {
    List<Map<String, dynamic>> items = [
      // Core Booking Features
      {
        'icon': Icons.search,
        'title': 'Search & Book Tickets',
        'route': '/search-booking',
        'requiresAuth': false,
        'category': 'booking',
      },
      {
        'icon': Icons.event_seat,
        'title': 'Seat Selection',
        'route': '/seat-selection',
        'requiresAuth': false,
        'category': 'booking',
      },
      {
        'icon': Icons.person_add,
        'title': 'Passenger Details',
        'route': '/passenger-details',
        'requiresAuth': false,
        'category': 'booking',
      },
      {
        'icon': Icons.payment,
        'title': 'Payment Gateway',
        'route': '/payment-gateway',
        'requiresAuth': false,
        'category': 'booking',
      },
      {
        'icon': Icons.check_circle,
        'title': 'Booking Confirmation',
        'route': '/payment-gateway',
        'requiresAuth': false,
        'category': 'booking',
      },

      // My Tickets & Travel
      {
        'icon': Icons.confirmation_num,
        'title': 'My Tickets',
        'route': '/my-tickets',
        'requiresAuth': true,
        'category': 'travel',
      },
      {
        'icon': Icons.qr_code,
        'title': 'QR Code Display',
        'route': '/qr-code-display',
        'requiresAuth': true,
        'category': 'travel',
      },
      {
        'icon': Icons.location_on,
        'title': 'Bus Tracking Map',
        'route': '/bus-tracking-map',
        'requiresAuth': false,
        'category': 'travel',
      },
      {
        'icon': Icons.favorite,
        'title': 'Favorites',
        'route': '/favorites',
        'requiresAuth': true,
        'category': 'travel',
      },

      // Account & Settings
      // Upgrade/change role entry
      {
        'icon': Icons.swap_horiz,
        'title': _userAffiliation == 'regular'
            ? 'Upgrade Role'
            : 'Change Role / Affiliation',
        'category': 'account',
        'onTap': () {
          _showUpgradeRoleSheet();
        },
      },
      {
        'icon': Icons.mic,
        'title': 'Voice AI Assistant',
        'route': '/voice-ai',
        'requiresAuth': false,
        'category': 'account',
      },
    ];

    // Smart feature access based on roles
    if (user != null) {
      // School/University features
      if (user.isUniversityAffiliated || user.canAccessSchoolBus) {
        items.addAll([
          {
            'icon': Icons.school,
            'title': 'University Services',
            'route': '/school-bus-home',
            'requiresAuth': true,
            'category': 'university',
            'badge': 'ICT University',
          },
          {
            'icon': Icons.directions_bus,
            'title': 'Campus Shuttle Booking',
            'route': '/bus-booking-form',
            'requiresAuth': true,
            'category': 'university',
          },
          {
            'icon': Icons.history,
            'title': 'School Bus History',
            'route': '/booking-history',
            'requiresAuth': true,
            'category': 'university',
          },
          {
            'icon': Icons.qr_code_scanner,
            'title': 'School Bus QR Code',
            'route': '/qr-code-display',
            'requiresAuth': true,
            'category': 'university',
          },
        ]);
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
        items.addAll([
          {
            'icon': Icons.admin_panel_settings,
            'title': 'Admin Route Management',
            'route': '/admin-route-management',
            'requiresAuth': true,
            'category': 'management',
            'badge': 'Manager',
          },
          {
            'icon': Icons.edit_calendar,
            'title': 'Schedule Manager',
            'route': AppRoutes.scheduleManagement,
            'requiresAuth': true,
            'category': 'management',
            'badge': 'Manager',
          },
        ]);
      }

      if (user.isDriver) {
        items.addAll([
          {
            'icon': Icons.directions_bus,
            'title': 'Driver Boarding Interface',
            'route': '/driver-boarding-interface',
            'requiresAuth': true,
            'category': 'operations',
            'badge': 'Driver',
          },
          {
            'icon': Icons.qr_code_scanner,
            'title': 'Scan Passenger QR',
            'route': '/driver-boarding-interface',
            'requiresAuth': true,
            'category': 'operations',
            'badge': 'Driver',
          },
        ]);
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

      // Parent Dashboard for school bus
      if (user.canAccessSchoolBus) {
        items.add({
          'icon': Icons.family_restroom,
          'title': 'Parent Dashboard',
          'route': '/parent-dashboard',
          'requiresAuth': true,
          'category': 'university',
          'badge': 'Parent',
        });
      }

      // Agency access for non-affiliated users
      if (!user.affiliations.contains('agency') &&
          !user.isScheduleManager &&
          !user.isDriver &&
          !user.isConductor &&
          !user.isBookingClerk) {
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

  // New method that uses affiliation data from SharedPreferences
  void _showUpgradeRoleSheet() {
    HapticFeedback.selectionClick();
    Navigator.pop(context); // Close drawer
    Future.delayed(const Duration(milliseconds: 150), () {
      final rootNav = Navigator.of(context, rootNavigator: true);
      showModalBottomSheet(
        context: rootNav.context,
        useRootNavigator: true,
        backgroundColor: surfaceColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) {
          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade or Change Role',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                  ),
                  SizedBox(height: 1.h),
                  ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text('Affiliated with the University'),
                    subtitle: const Text('Choose role, then confirm PIN'),
                    onTap: () {
                      final nav = Navigator.of(ctx, rootNavigator: true);
                      Navigator.pop(ctx);
                      Future.microtask(() {
                        nav.pushReplacementNamed(
                          '/affiliation-selection',
                          arguments: {
                            'affiliation': 'ict_university',
                            'step': 1,
                          },
                        );
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.business),
                    title: const Text('With a Transport Agency'),
                    subtitle: const Text('Pick agency → role → PIN'),
                    onTap: () {
                      final nav = Navigator.of(ctx, rootNavigator: true);
                      Navigator.pop(ctx);
                      Future.microtask(() {
                        nav.pushReplacementNamed(
                          '/affiliation-selection',
                          arguments: {
                            'affiliation': 'agency',
                            'step': 1,
                          },
                        );
                      });
                    },
                  ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  List<Map<String, dynamic>> _getMenuItemsForAffiliation() {
    List<Map<String, dynamic>> items = [
      // Core Booking Features (always available)
      {
        'icon': Icons.search,
        'title': 'Search & Book Tickets',
        'route': '/search-booking',
        'requiresAuth': false,
        'category': 'booking',
      },
      {
        'icon': Icons.confirmation_num,
        'title': 'My Tickets',
        'route': '/my-tickets',
        'requiresAuth': true,
        'category': 'travel',
      },
      {
        'icon': Icons.location_on,
        'title': 'Bus Tracking Map',
        'route': '/bus-tracking-map',
        'requiresAuth': false,
        'category': 'travel',
      },
    ];

    // Add features based on affiliation
    if (_userAffiliation == 'ict_university') {
      items.addAll([
        {
          'icon': Icons.school,
          'title': 'University Services',
          'route': '/school-bus-home',
          'requiresAuth': true,
          'category': 'university',
          'badge': 'ICT University',
        },
        {
          'icon': Icons.directions_bus,
          'title': 'Campus Shuttle',
          'route': '/bus-booking-form-schoolbus',
          'requiresAuth': true,
          'category': 'university',
        },
      ]);

      // Role-specific features
      if (_userRole == 'bus_driver' || _userRole == 'bus_coordinator') {
        items.add({
          'icon': Icons.admin_panel_settings,
          'title': 'Bus Management',
          'route': '/bus-management',
          'requiresAuth': true,
          'category': 'management',
        });
      }
    }

    if (_userAffiliation == 'agency') {
      items.addAll([
        {
          'icon': Icons.business,
          'title': 'Agency Dashboard',
          'route': '/agency-dashboard',
          'requiresAuth': true,
          'category': 'agency',
        },
        {
          'icon': Icons.schedule,
          'title': 'Route Management',
          'route': '/route-management',
          'requiresAuth': true,
          'category': 'agency',
        },
      ]);

      // Agency role-specific features
      if (_userRole == 'schedule_manager') {
        items.add({
          'icon': Icons.edit_calendar,
          'title': 'Schedule Manager',
          'route': AppRoutes.scheduleManagement,
          'requiresAuth': true,
          'category': 'management',
        });
      }

      if (_userRole == 'booking_clerk') {
        items.add({
          'icon': Icons.receipt_long,
          'title': 'Booking Management',
          'route': '/booking-management',
          'requiresAuth': true,
          'category': 'management',
        });
      }
    }

    // Account and Support items
    items.addAll([
      {
        'icon': Icons.swap_horiz,
        'title': _userAffiliation == 'regular'
            ? 'Upgrade Role'
            : 'Change Role / Affiliation',
        'category': 'account',
        'onTap': () {
          _showUpgradeRoleSheet();
        },
      },
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'route': '/profile-settings',
        'requiresAuth': true,
        'category': 'account',
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help & Support',
        'category': 'account',
        'onTap': () {
          HapticFeedback.selectionClick();
          Navigator.pop(context);
          // TODO: Navigate to help screen
        },
      },
    ]);

    return items;
  }

  Future<void> _toggleTheme() async {
    await ThemeNotifier().toggleTheme();

    // Trigger haptic feedback
    HapticFeedback.lightImpact();

    // Refresh the menu items to update the icon
    _availableMenuItems = _getMenuItemsForAffiliation();
    setState(() {});
  }

  Future<void> _handleSchoolBusAccess() async {
    Navigator.pop(context); // Close drawer
    Navigator.pushNamed(context, '/school-bus-home');
  }

  Future<void> _handleAgencyAccess() async {
    Navigator.pop(context); // Close drawer
    Navigator.pushNamed(context, '/home-dashboard');
  }

  void _handleMenuItemTap(Map<String, dynamic> item) {
    HapticFeedback.selectionClick();

    // Handle special actions
    if (item.containsKey('action')) {
      if (item['action'] == 'toggle_theme') {
        _toggleTheme();
        return; // Don't close drawer for theme toggle
      }
    }

    // Use root navigator to avoid using a disposed drawer context
    final nav = Navigator.of(context, rootNavigator: true);
    Navigator.pop(context);

    if (item.containsKey('onTap')) {
      // Defer to ensure drawer is closed before running callbacks
      Future.microtask(() => item['onTap']());
    } else if (item.containsKey('route')) {
      final route = item['route'];
      Future.microtask(() => nav.pushNamed(route));
    }
  }

  Widget _glassDrawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500)),
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
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.9),
                border: Border(
                  right: BorderSide(
                    color: primaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(8, 0),
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                    spreadRadius: 1,
                  ),
                ],
              ),
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
                    color: textColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.3.h),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getUserStatusText(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7.5.sp,
                      fontWeight: FontWeight.w600,
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
      case 'booking':
        return primaryColor.withOpacity(0.1);
      case 'travel':
        return Colors.orange.withOpacity(0.1);
      case 'university':
        return Colors.blue.withOpacity(0.1);
      case 'management':
        return Colors.purple.withOpacity(0.1);
      case 'operations':
        return Colors.green.withOpacity(0.1);
      case 'account':
        return Colors.grey.withOpacity(0.1);
      case 'ondemand':
        return primaryColor.withOpacity(0.15);
      default:
        return primaryColor.withOpacity(0.1);
    }
  }

  Color _getModernIconColor(Map<String, dynamic> item) {
    switch (item['category']) {
      case 'booking':
        return primaryColor;
      case 'travel':
        return Colors.orange.shade600;
      case 'university':
        return Colors.blue.shade600;
      case 'management':
        return Colors.purple.shade600;
      case 'operations':
        return Colors.green.shade600;
      case 'account':
        return Colors.grey.shade600;
      case 'ondemand':
        return primaryColor;
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
          category['title'] as String,
          List<Map<String, dynamic>>.from(category['items']),
          category['icon'] as IconData,
        );
      },
    );
  }

  // Organize menu items by category with modern approach
  List<Map<String, dynamic>> _organizeByCategoryModern() {
    final categorizedMenu = <String, List<Map<String, dynamic>>>{};

    // Group items by category
    for (final item in _availableMenuItems) {
      final category = item['category'] ?? 'booking';
      categorizedMenu.putIfAbsent(category, () => []);
      categorizedMenu[category]!.add(item);
    }

    // Create sections with proper ordering and icons
    final sections = <Map<String, dynamic>>[];

    if (categorizedMenu.containsKey('booking')) {
      sections.add({
        'title': 'Book & Pay',
        'icon': Icons.credit_card,
        'items': categorizedMenu['booking']!,
      });
    }

    if (categorizedMenu.containsKey('travel')) {
      sections.add({
        'title': 'My Travel',
        'icon': Icons.luggage,
        'items': categorizedMenu['travel']!,
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

    if (categorizedMenu.containsKey('account')) {
      sections.add({
        'title': 'Account & Support',
        'icon': Icons.account_circle,
        'items': categorizedMenu['account']!,
      });
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
  Widget _buildMenuSection(
      String title, List<Map<String, dynamic>> items, IconData sectionIcon) {
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
                  color: onSurfaceColor.withOpacity(0.7),
                  fontSize: 10.sp,
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
              border: isSpecial
                  ? Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Icon with modern styling
                Container(
                  width: 9.w,
                  height: 9.w,
                  decoration: BoxDecoration(
                    color: _getModernIconBg(item),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item['icon'],
                    color: _getModernIconColor(item),
                    size: 4.2.w,
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
                          color: textColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.containsKey('badge')) ...[
                        SizedBox(height: 0.3.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.2.h),
                          decoration: BoxDecoration(
                            color: _getModernBadgeColor(item),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['badge'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 6.sp,
                              fontWeight: FontWeight.w600,
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
                  color: onSurfaceColor.withOpacity(0.4),
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
            color: onSurfaceColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 2.h),

          // Theme toggle and Logout section
          Row(
            children: [
              // Theme toggle button
              Expanded(
                flex: 1,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
                  child: IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return RotationTransition(
                          turns: Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(animation),
                          child:
                              FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: Icon(
                        ThemeNotifier().isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        key: ValueKey(ThemeNotifier().isDarkMode),
                        color: onSurfaceColor.withOpacity(0.8),
                        size: 4.5.w,
                      ),
                    ),
                    onPressed: _toggleTheme,
                  ),
                ),
              ),
              // Logout button
              Expanded(
                flex: 3,
                child: _buildBottomActionItem(
                  icon: Icons.logout,
                  label: 'Sign Out',
                  isDestructive: true,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showLogoutConfirmation();
                  },
                ),
              ),
            ],
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
    final color = isDestructive ? Colors.red.shade600 : textColor;

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
                  fontSize: 10.sp,
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
            fontSize: 14.sp,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontSize: 10.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: onSurfaceColor.withOpacity(0.7),
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
