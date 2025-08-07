import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/animated_header_widget.dart';
import './widgets/popular_routes_section_widget.dart';
import './widgets/quick_access_tiles_widget.dart';
import './widgets/quick_book_section_widget.dart';
import './widgets/recent_trips_section_widget.dart';
import './widgets/search_section_widget.dart';
import './widgets/special_offers_section_widget.dart';

class PremiumHomeScreen extends StatefulWidget {
  const PremiumHomeScreen({super.key});

  @override
  State<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends State<PremiumHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scrollController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scrollAnimation;
  final ScrollController _pageScrollController = ScrollController();
  final RefreshIndicator _refreshIndicator = const RefreshIndicator(
    onRefresh: _refreshData,
    child: SizedBox.shrink(),
  );

  static Future<void> _refreshData() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scrollController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scrollAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scrollController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _scrollController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryLight,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: _buildContent(),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.secondaryLight,
      backgroundColor: AppTheme.primaryLight,
      child: CustomScrollView(
        controller: _pageScrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _scrollAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _scrollAnimation.value)),
                  child: Opacity(
                    opacity: _scrollAnimation.value,
                    child: _buildMainContent(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 25.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryLight,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryLight,
                const Color(0xFF2D5A47),
              ],
            ),
          ),
          child: const AnimatedHeaderWidget(),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.w),
          topRight: Radius.circular(6.w),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 3.h),
          const SearchSectionWidget(),
          SizedBox(height: 3.h),
          const QuickBookSectionWidget(),
          SizedBox(height: 3.h),
          const RecentTripsSectionWidget(),
          SizedBox(height: 3.h),
          const PopularRoutesSectionWidget(),
          SizedBox(height: 3.h),
          const SpecialOffersSectionWidget(),
          SizedBox(height: 3.h),
          const QuickAccessTilesWidget(),
          SizedBox(height: 5.h),
        ],
      ),
    );
  }
}
