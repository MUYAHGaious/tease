import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/bottom_navigation_widget.dart';
import './widgets/floating_action_widget.dart';
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

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    final routes = [
      '/home-dashboard',
      '/search-booking',
      '/my-tickets',
      '/profile'
    ];
    if (index < routes.length && routes[index] != '/home-dashboard') {
      _handleNavigation(routes[index]);
    }
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.lightTheme.colorScheme.surface,
                AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.95),
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
              ],
              stops: [
                0.0,
                0.6 + (_backgroundAnimation.value * 0.2),
                1.0,
              ],
            ),
          ),
          child: CustomPaint(
            painter: ParticlesPainter(
              animationValue: _backgroundAnimation.value,
              scrollOffset:
                  _scrollController.hasClients ? _scrollController.offset : 0.0,
            ),
            child: Container(),
          ),
        );
      },
    );
  }

  Widget _buildStickyHeader() {
    return AnimatedBuilder(
      animation: _headerOpacityAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface.withValues(
              alpha: 0.9 + (0.1 * (1 - _headerOpacityAnimation.value)),
            ),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.1 * (1 - _headerOpacityAnimation.value),
                ),
                width: 1,
              ),
            ),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10 * (1 - _headerOpacityAnimation.value),
                sigmaY: 10 * (1 - _headerOpacityAnimation.value),
              ),
              child: SafeArea(
                bottom: false,
                child: Opacity(
                  opacity: _headerOpacityAnimation.value,
                  child: const GreetingHeaderWidget(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          Column(
            children: [
              _buildStickyHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  backgroundColor: AppTheme.lightTheme.colorScheme.surface,
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
                              onBookingTap: _handleNavigation,
                            ),
                            SizedBox(height: 4.h),
                            PopularRoutesWidget(
                              onRouteTap: _handleNavigation,
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
                color: Colors.black.withValues(alpha: 0.1),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.shadow
                              .withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Refreshing...',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
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
      floatingActionButton: FloatingActionWidget(
        onActionTap: _handleNavigation,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentBottomNavIndex,
        onTap: _handleBottomNavTap,
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
      ..color = AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
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

      paint.color = AppTheme.lightTheme.colorScheme.primary
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
