import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/global_bottom_navigation.dart';
import './widgets/custom_menu_drawer.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/popular_routes_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_bookings_widget.dart';
import './widgets/search_bar_widget.dart';

// 2025 Design Constants
const double cardElevation = 2.0;
const double cardBorderRadius = 16.0;
const double sectionSpacing = 24.0;
const double gridSpacing = 16.0;
const Color primaryColor = Color(0xFF20B2AA);

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late AnimationController _scrollAnimationController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _headerOpacityAnimation;

  final ScrollController _scrollController = ScrollController();
  int _currentBottomNavIndex = 0;
  bool _isRefreshing = false;

  // 2025 Contextual Data - Smart content based on time and user behavior
  List<Map<String, dynamic>> _contextualCards = [];
  List<Map<String, dynamic>> _smartQuickActions = [];
  String _timeBasedGreeting = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadContextualContent();
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

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.linear,
    ));

    _headerOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _scrollAnimationController,
      curve: Curves.easeOut,
    ));

    _backgroundAnimationController.repeat();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final scrollPercentage = (scrollOffset / maxScroll).clamp(0.0, 1.0);

    _scrollAnimationController.value = scrollPercentage;
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _scrollAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0: // Home
        // Already on home, maybe scroll to top
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        break;
      case 1: // Favorites
        Navigator.pushNamed(context, '/favorites');
        break;
      case 2: // Tickets
        Navigator.pushNamed(context, '/my-tickets');
        break;
      case 3: // Profile
        Navigator.pushNamed(context, '/profile-settings');
        break;
    }
  }

  void _showCustomMenu() {
    Scaffold.of(context).openDrawer();
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

  // 2025 Modern Dashboard Layout
  Widget _buildModernDashboard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 3.h),

          // Modern Search Bar
          _buildModernSearchBar(),

          SizedBox(height: sectionSpacing),

          // Contextual Greeting
          _buildContextualGreeting(),

          SizedBox(height: sectionSpacing),

          // Smart Quick Actions Grid
          _buildSmartQuickActions(),

          SizedBox(height: sectionSpacing),

          // Contextual Cards Section
          _buildContextualCardsSection(),

          SizedBox(height: 10.h), // Bottom padding for FAB
        ],
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(
          color: AppTheme.onSurfaceLight.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.onSurfaceLight.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNavigation('/search-booking'),
          borderRadius: BorderRadius.circular(cardBorderRadius),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.search,
                    color: primaryColor,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Where are you going?',
                        style: TextStyle(
                          color: AppTheme.onSurfaceLight,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Search destinations, routes, and more',
                        style: TextStyle(
                          color: AppTheme.onSurfaceLight.withOpacity(0.6),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: AppTheme.onSurfaceLight.withOpacity(0.4),
                  size: 5.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContextualGreeting() {
    return Container(
      padding: EdgeInsets.all(4.w),
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Ready to travel today?',
                  style: TextStyle(
                    color: AppTheme.onSurfaceLight.withOpacity(0.7),
                    fontSize: 12.sp,
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
            style: TextStyle(
              color: AppTheme.onSurfaceLight,
              fontSize: 18.sp,
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
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(
          color: AppTheme.onSurfaceLight.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.onSurfaceLight.withOpacity(0.05),
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
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: action['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    action['icon'],
                    color: action['color'],
                    size: 6.w,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  action['title'],
                  style: TextStyle(
                    color: AppTheme.onSurfaceLight,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  action['subtitle'],
                  style: TextStyle(
                    color: AppTheme.onSurfaceLight.withOpacity(0.6),
                    fontSize: 10.sp,
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
            style: TextStyle(
              color: AppTheme.onSurfaceLight,
              fontSize: 18.sp,
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
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(
          color: card['color'].withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: card['color'].withOpacity(0.1),
            blurRadius: 8,
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
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: card['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    card['icon'],
                    color: card['color'],
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card['title'],
                        style: TextStyle(
                          color: AppTheme.onSurfaceLight,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        card['subtitle'],
                        style: TextStyle(
                          color: AppTheme.onSurfaceLight.withOpacity(0.7),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: card['color'],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    card['action'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
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
        color: AppTheme.onSurfaceLight.withOpacity(0.1),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.onSurfaceLight.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.onSurfaceLight.withOpacity(0.1),
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
                    color: AppTheme.onSurfaceLight,
                    fontSize: 12.sp,
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
      // Skip search flow - go directly to seat selection with pre-filled data
      Navigator.pushNamed(context, '/seat-selection', arguments: {
        'bookingId': bookingId,
        'skipSearch': true,
      });
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

  // 2025 Clean Background - No animations, just clean solid color
  Widget _buildCleanBackground() {
    return Container(
      color: AppTheme.backgroundLight,
    );
  }

  // Modern 2025 Header with clean design
  Widget _buildModernHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.onSurfaceLight.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: const GreetingHeaderWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      drawer: const CustomMenuDrawer(),
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
                  backgroundColor: AppTheme.surfaceLight,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 1.h), // Reduced from 3.h to 1.h

                            // Original Search Bar Widget with modern styling
                            SearchBarWidget(
                              onSearchTap: _handleNavigation,
                            ),

                            SizedBox(height: 1.h), // Reduced from 2.h to 1.h

                            // Original Quick Actions Widget with modern styling
                            QuickActionsWidget(
                              onActionTap: _handleNavigation,
                            ),

                            SizedBox(height: 1.h), // Reduced from 2.h to 1.h

                            // Original Recent Bookings Widget with modern styling
                            RecentBookingsWidget(
                              onBookingTap: _handleBookingTap,
                            ),

                            SizedBox(height: 1.h), // Reduced from 2.h to 1.h

                            // Original Popular Routes Widget with modern styling
                            PopularRoutesWidget(
                              onRouteTap: _handleRouteTap,
                            ),

                            SizedBox(height: 3.h), // Reduced from 8.h to 3.h
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
        ],
      ),
      bottomNavigationBar: GlobalBottomNavigation(
        initialIndex: 0, // Home tab
      ),
      floatingActionButton: _buildModernFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // 2025 Clean FAB - No gradients, solid color
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
          color: AppTheme.surfaceLight,
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
                color: AppTheme.onSurfaceLight,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Say "Book a ticket" to get started',
              style: TextStyle(
                color: AppTheme.onSurfaceLight.withOpacity(0.7),
                fontSize: 16,
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
                  fontSize: 18,
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
