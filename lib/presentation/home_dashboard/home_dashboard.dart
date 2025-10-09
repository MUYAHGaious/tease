import 'dart:ui';
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../core/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/global_bottom_navigation.dart';
import '../../widgets/global_microphone_button.dart';
import './widgets/custom_menu_drawer.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/popular_routes_widget.dart';
import './widgets/recent_bookings_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/role_based_quick_actions_widget.dart';
import '../../theme/theme_notifier.dart';

// 2025 Design Constants
const double cardElevation = 2.0;
const double cardBorderRadius = 16.0;
const double sectionSpacing = 16.0;
const double gridSpacing = 12.0;

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _backgroundAnimationController;
  late AnimationController _scrollAnimationController;

  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  Timer? _themeCheckTimer;
  String _userRole = 'passenger';
  bool get _canScan =>
      _userRole == 'bus_driver' || _userRole == 'bus_conductor';

  // Theme-aware colors that prevent glitching
  Color get primaryColor => const Color(0xFF008B8B);
  Color get backgroundColor =>
      ThemeNotifier().isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get textColor =>
      ThemeNotifier().isDarkMode ? Colors.white : Colors.black87;
  Color get surfaceColor =>
      ThemeNotifier().isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get onSurfaceColor =>
      ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54;
  Color get borderColor =>
      ThemeNotifier().isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
  Color get shadowColor =>
      ThemeNotifier().isDarkMode ? Colors.black : Colors.grey;
  Color get onSurfaceVariantColor =>
      ThemeNotifier().isDarkMode ? Colors.white60 : Colors.black45;

  // 2025 Contextual Data - Smart content based on time and user behavior
  List<Map<String, dynamic>> _contextualCards = [];
  List<Map<String, dynamic>> _smartQuickActions = [];
  String _timeBasedGreeting = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadContextualContent();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String role = prefs.getString('user_role') ?? 'passenger';
      // Fallback to AppState user flags if available
      try {
        final user = AppState().currentUser;
        if (user != null) {
          if (user.isDriver) role = 'bus_driver';
          if (user.isConductor) role = 'bus_conductor';
        }
      } catch (_) {}
      if (mounted) {
        setState(() {
          _userRole = role;
        });
      }
    } catch (_) {}
  }

  void _loadContextualContent() {
    setState(() {
      _contextualCards = _generateContextualCards();
      _smartQuickActions = _generateSmartQuickActions();
      _timeBasedGreeting = _getTimeBasedGreeting();
    });
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  List<Map<String, dynamic>> _generateContextualCards() {
    final hour = DateTime.now().hour;
    final isWeekend =
        [DateTime.saturday, DateTime.sunday].contains(DateTime.now().weekday);

    List<Map<String, dynamic>> cards = [];

    // Morning commute card
    if (hour >= 6 && hour <= 10 && !isWeekend) {
      cards.add({
        'type': 'commute',
        'title': 'Your Morning Commute',
        'subtitle': 'Book your regular route',
        'action': 'Book Now',
        'icon': Icons.wb_sunny,
        'color': Colors.orange,
        'priority': 1,
      });
    }

    // Evening return card
    if (hour >= 16 && hour <= 20 && !isWeekend) {
      cards.add({
        'type': 'return',
        'title': 'Time to Head Home',
        'subtitle': 'Return journey available',
        'action': 'Book Return',
        'icon': Icons.home,
        'color': Colors.blue,
        'priority': 1,
      });
    }

    // Weekend travel suggestions
    if (isWeekend) {
      cards.add({
        'type': 'leisure',
        'title': 'Weekend Getaway',
        'subtitle': 'Explore new destinations',
        'action': 'Discover',
        'icon': Icons.explore,
        'color': Colors.green,
        'priority': 1,
      });
    }

    // Always show recent activity
    cards.add({
      'type': 'recent',
      'title': 'Recent Bookings',
      'subtitle': 'View your travel history',
      'action': 'View All',
      'icon': Icons.history,
      'color': primaryColor,
      'priority': 2,
    });

    // Popular routes
    cards.add({
      'type': 'popular',
      'title': 'Popular Routes',
      'subtitle': 'Trending destinations',
      'action': 'Explore',
      'icon': Icons.trending_up,
      'color': Colors.purple,
      'priority': 2,
    });

    // Sort by priority and time relevance
    cards.sort((a, b) => a['priority'].compareTo(b['priority']));

    return cards;
  }

  List<Map<String, dynamic>> _generateSmartQuickActions() {
    return [
      {
        'title': 'Quick Book',
        'subtitle': 'Fast booking',
        'icon': Icons.flash_on,
        'color': Colors.orange,
        'route': '/search-booking',
      },
      {
        'title': 'My Tickets',
        'subtitle': 'Active trips',
        'icon': Icons.confirmation_num,
        'color': primaryColor,
        'route': '/my-tickets',
      },
      {
        'title': 'Favorites',
        'subtitle': 'Saved routes',
        'icon': Icons.favorite,
        'color': Colors.red,
        'route': '/favorites',
      },
      {
        'title': 'QR Code',
        'subtitle': 'Mobile ticket',
        'icon': Icons.qr_code,
        'color': Colors.blue,
        'route': '/qr-code-display',
      },
    ];
  }

  @override
  void initState() {
    super.initState();

    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _scrollAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundAnimationController.repeat();

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);
    ThemeNotifier().addListener(_onThemeChanged);
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final scrollPercentage = (scrollOffset / maxScroll).clamp(0.0, 1.0);

    _scrollAnimationController.value = scrollPercentage;
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh content when app is resumed
      _loadContextualContent();
    }
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    _backgroundAnimationController.dispose();
    _scrollAnimationController.dispose();
    _scrollController.dispose();
    _themeCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.mediumImpact();

    // Reload contextual content on refresh
    _loadContextualContent();
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
      HapticFeedback.lightImpact();
    }
  }

  Widget _buildContextualGreeting() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getGreetingIcon(),
              color: Colors.white,
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _timeBasedGreeting,
                  style: TextStyle(
                    color: AppTheme.onSurfaceLight,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Ready to travel today?',
                  style: TextStyle(
                    color: AppTheme.onSurfaceLight.withOpacity(0.7),
                    fontSize: 8.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny;
    if (hour < 17) return Icons.wb_sunny_outlined;
    return Icons.nights_stay;
  }

  Widget _buildSmartQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: onSurfaceColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        SizedBox(height: 2.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: gridSpacing,
            mainAxisSpacing: gridSpacing,
          ),
          itemCount: _smartQuickActions.length,
          itemBuilder: (context, index) {
            return _buildQuickActionCard(_smartQuickActions[index]);
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(Map<String, dynamic> action) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(
          color: onSurfaceColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: onSurfaceColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNavigation(action['route']),
          borderRadius: BorderRadius.circular(cardBorderRadius),
          child: Padding(
            padding: EdgeInsets.all(2.5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(1.8.w),
                  decoration: BoxDecoration(
                    color: action['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    action['icon'],
                    color: action['color'],
                    size: 5.2.w,
                  ),
                ),
                SizedBox(height: 1.2.h),
                Text(
                  action['title'],
                  style: TextStyle(
                    color: onSurfaceColor,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  action['subtitle'],
                  style: TextStyle(
                    color: onSurfaceColor.withOpacity(0.6),
                    fontSize: 8.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContextualCardsSection() {
    if (_contextualCards.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            'For You',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.onSurfaceLight,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        SizedBox(height: 2.h),
        ..._contextualCards.map((card) => _buildContextualCard(card)).toList(),
      ],
    );
  }

  Widget _buildContextualCard(Map<String, dynamic> card) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.2.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(
          color: card['color'].withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: card['color'].withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleContextualCardTap(card),
          borderRadius: BorderRadius.circular(cardBorderRadius),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.4.w),
                  decoration: BoxDecoration(
                    color: card['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    card['icon'],
                    color: card['color'],
                    size: 5.4.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card['title'],
                        style: TextStyle(
                          color: AppTheme.onSurfaceLight,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.4.h),
                      Text(
                        card['subtitle'],
                        style: TextStyle(
                          color: AppTheme.onSurfaceLight.withOpacity(0.7),
                          fontSize: 8.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.6.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: card['color'],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    card['action'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleContextualCardTap(Map<String, dynamic> card) {
    HapticFeedback.selectionClick();
    switch (card['type']) {
      case 'commute':
      case 'return':
      case 'leisure':
        _handleNavigation('/search-booking');
        break;
      case 'recent':
        _handleNavigation('/my-tickets');
        break;
      case 'popular':
        _handleNavigation('/popular-routes');
        break;
    }
  }

  Widget _buildModernLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: onSurfaceColor.withOpacity(0.1),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: onSurfaceColor.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: onSurfaceColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 3,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Refreshing...',
                  style: TextStyle(
                    color: onSurfaceColor,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(String route) {
    try {
      HapticFeedback.selectionClick();
      Navigator.pushNamed(context, route);
    } catch (e) {
      debugPrint('Navigation error for route $route: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigation error: $route'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleBookingTap(String bookingId) {
    try {
      HapticFeedback.selectionClick();

      // If it's a route string (like '/my-tickets'), navigate directly
      if (bookingId.startsWith('/')) {
        Navigator.pushNamed(context, bookingId);
        return;
      }

      // Otherwise, navigate to My Tickets screen to view booking details
      Navigator.pushNamed(context, '/my-tickets');
    } catch (e) {
      debugPrint('Booking navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open booking details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleRouteTap(String routeId) {
    try {
      HapticFeedback.selectionClick();
      // Skip search flow - go directly to seat selection with route data
      Navigator.pushNamed(context, '/seat-selection', arguments: {
        'routeId': routeId,
        'skipSearch': true,
      });
    } catch (e) {
      debugPrint('Route navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open route details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 2025 Gradient Background matching booking management screen
  Widget _buildCleanBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withOpacity(0.05),
            backgroundColor,
          ],
        ),
      ),
    );
  }

  // Modern 2025 Header with role-based greeting
  Widget _buildModernHeader() {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: onSurfaceColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: AppState(),
          builder: (context, child) {
            return const GreetingHeaderWidget();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      duration:
          const Duration(milliseconds: 600), // Smoother, longer transition
      curve: Curves.easeInOutCubic, // More natural cubic curve
      data:
          ThemeNotifier().isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      onEnd: () {
        // Optional: Trigger haptic feedback when transition completes
        HapticFeedback.lightImpact();
      },
      child: Stack(
        children: [
          Builder(
            builder: (context) => Scaffold(
              backgroundColor: backgroundColor,
              drawer: const CustomMenuDrawer(),
              onDrawerChanged: (isOpened) {
                if (!isOpened) {
                  // Drawer was closed - theme changes handled by ThemeNotifier
                }
              },
              body: Stack(
                children: [
                  _buildCleanBackground(),
                  Column(
                    children: [
                      _buildModernHeader(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _handleRefresh,
                          color: primaryColor,
                          backgroundColor: surfaceColor,
                          child: CustomScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 1.h), // Reduced from 3.h to 1.h

                                    // Original Search Bar Widget with modern styling
                                    SearchBarWidget(
                                      onSearchTap: _handleNavigation,
                                    ),

                                    SizedBox(
                                        height:
                                            0.5.h), // Further reduced spacing

                                    // Role-based Quick Actions Widget
                                    RoleBasedQuickActionsWidget(
                                      onActionTap: _handleNavigation,
                                    ),

                                    SizedBox(
                                        height: 1.h), // Reduced from 2.h to 1.h

                                    // Original Recent Bookings Widget with modern styling
                                    RecentBookingsWidget(
                                      onBookingTap: _handleBookingTap,
                                    ),

                                    SizedBox(
                                        height: 1.h), // Reduced from 2.h to 1.h

                                    // Original Popular Routes Widget with modern styling
                                    PopularRoutesWidget(
                                      onRouteTap: _handleRouteTap,
                                    ),

                                    SizedBox(
                                        height: 3.h), // Reduced from 8.h to 3.h
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isRefreshing) _buildModernLoadingOverlay(),

                  if (_canScan) _buildScanOverlayButton(),

                  // Development role switcher removed for clean UI
                ],
              ),
              bottomNavigationBar: GlobalBottomNavigation(
                initialIndex: 0, // Home tab
              ),
              floatingActionButton: null, // Remove the floating action button
              floatingActionButtonLocation: null,
            ),
          ),
          // Add microphone icon positioned in bottom right
          GlobalMicrophoneButton(
            onPressed: () => _showModernVoiceAssistant(),
            bottomOffset:
                70, // Center-based positioning, aligned with other screens
            rightOffset: 3.0,
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlayButton() {
    return Positioned(
      right: 16,
      bottom: kBottomNavigationBarHeight + 24,
      child: Semantics(
        label: 'Open QR scanner',
        button: true,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.pushNamed(context, '/driver-boarding-interface');
          },
          child: Container(
            padding: EdgeInsets.all(3.6.w),
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFAB() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showModernVoiceAssistant();
        },
        child: const Icon(
          Icons.mic,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _showModernVoiceAssistant() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(
            color: primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Voice Assistant',
              style: TextStyle(
                color: onSurfaceColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Say "Book a ticket" to get started',
              style: TextStyle(
                color: onSurfaceColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Listening...',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final double animationValue;
  final double scrollOffset;

  ParticlesPainter({
    required this.animationValue,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryLight.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final particleCount = 15;
    final scrollFactor = scrollOffset * 0.001;

    for (int i = 0; i < particleCount; i++) {
      final progress = (animationValue + (i / particleCount)) % 1.0;
      final x = (size.width * 0.1) +
          (size.width * 0.8 * ((i * 0.7 + progress + scrollFactor) % 1.0));
      final y = (size.height * 0.1) +
          (size.height *
              0.8 *
              ((i * 0.3 + progress * 0.5 + scrollFactor) % 1.0));

      final radius = 2.0 + (4.0 * ((i % 3) / 2.0));
      final opacity = 0.3 + (0.4 * (1.0 - progress));

      paint.color = AppTheme.primaryLight.withValues(alpha: opacity * 0.1);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.scrollOffset != scrollOffset;
  }
}
