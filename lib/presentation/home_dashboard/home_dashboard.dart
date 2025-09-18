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

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _handleNavigation(String route) {
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, route);
  }

  void _handleBookingTap(String bookingId) {
    HapticFeedback.selectionClick();
    // Skip search flow - go directly to seat selection with pre-filled data
    Navigator.pushNamed(context, '/seat-selection', arguments: {
      'bookingId': bookingId,
      'skipSearch': true,
    });
  }

  void _handleRouteTap(String routeId) {
    HapticFeedback.selectionClick();
    // Skip search flow - go directly to seat selection with route data
    Navigator.pushNamed(context, '/seat-selection', arguments: {
      'routeId': routeId,
      'skipSearch': true,
    });
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Simple white background, no gradients
      ),
    );
  }

  Widget _buildStickyHeader() {
    return AnimatedBuilder(
      animation: _headerOpacityAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[50], // Light background
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: const GreetingHeaderWidget(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      drawer: const CustomMenuDrawer(),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          Column(
            children: [
              _buildStickyHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: AppTheme.primaryLight,
                  backgroundColor: AppTheme.surfaceLight,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 3.h),
                            SearchBarWidget(
                              onSearchTap: _handleNavigation,
                            ),
                            SizedBox(height: 4.h),
                            QuickActionsWidget(
                              onActionTap: _handleNavigation,
                            ),
                            SizedBox(height: 4.h),
                            RecentBookingsWidget(
                              onBookingTap: _handleBookingTap,
                            ),
                            SizedBox(height: 4.h),
                            PopularRoutesWidget(
                              onRouteTap: _handleRouteTap,
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isRefreshing)
            Positioned.fill(
              child: Container(
                color: AppTheme.onSurfaceLight.withValues(alpha: 0.2),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: AppTheme.getGlassmorphismDecoration(
                      backgroundColor: AppTheme.surfaceLight.withValues(alpha: 0.95),
                      borderRadius: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.primaryLight,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Refreshing...',
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurfaceLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: GlobalBottomNavigation(
        initialIndex: 0, // Home tab
      ),
      floatingActionButton: _buildGlassFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildGlassFAB() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF20B2AA), Color(0xFF48CAE4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF20B2AA).withOpacity(0.4), 
            blurRadius: 15, 
            spreadRadius: 0, 
            offset: const Offset(0, 6)
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1), 
            blurRadius: 6, 
            spreadRadius: 0, 
            offset: const Offset(0, 2)
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showVoiceAssistant();
        },
        child: const Icon(
          Icons.mic, 
          color: Colors.white, 
          size: 28,
        ),
      ),
    );
  }

  void _showVoiceAssistant() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF20B2AA), Color(0xFF48CAE4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Voice Assistant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Say "Book a ticket" to get started',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Text(
                'Listening...',
                style: TextStyle(
                  color: Colors.white,
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

      paint.color = AppTheme.primaryLight
          .withValues(alpha: opacity * 0.1);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.scrollOffset != scrollOffset;
  }
}

