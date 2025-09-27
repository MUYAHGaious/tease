import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../theme/theme_notifier.dart';
import '../../core/app_export.dart';
import './widgets/search_section_widget.dart';
import './widgets/popular_routes_section_widget.dart';
import './widgets/quick_access_tiles_widget.dart';

// 2025 Design Constants - Using Theme System
// Colors are now theme-aware and will automatically switch between light/dark modes

class PremiumHomeScreen extends StatefulWidget {
  const PremiumHomeScreen({super.key});

  @override
  State<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends State<PremiumHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  // Theme-aware colors that prevent glitching
  Color get primaryColor => const Color(0xFF008B8B);
  Color get backgroundColor => ThemeNotifier().isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get textColor => ThemeNotifier().isDarkMode ? Colors.white : Colors.black87;
  Color get surfaceColor => ThemeNotifier().isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get onSurfaceColor => ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54;

  static Future<void> _refreshData() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  void initState() {
    super.initState();
    ThemeNotifier().addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: primaryColor,
        backgroundColor: surfaceColor,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 28.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryColor,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.9),
              ],
            ),
          ),
          child: _buildHeader(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            SizedBox(height: 3.h),
            _buildWelcomeSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Icon(
              Icons.arrow_back,
              color: surfaceColor,
              size: 6.w,
            ),
          ),
        ),
        Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    color: surfaceColor,
                    size: 6.w,
                  ),
                ),
                Positioned(
                  right: 1.w,
                  top: 1.w,
                  child: Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 3.w),
            CircleAvatar(
              radius: 5.w,
              backgroundColor: primaryColor,
              child: Icon(
                Icons.person,
                color: surfaceColor,
                size: 6.w,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 24.sp,
            color: surfaceColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Book your perfect journey today',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.w),
          topRight: Radius.circular(8.w),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 3.h),
          const SearchSectionWidget(),
          SizedBox(height: 3.h),
          _buildQuickBookSection(),
          SizedBox(height: 3.h),
          _buildRecentTripsSection(),
          SizedBox(height: 3.h),
          const PopularRoutesSectionWidget(),
          SizedBox(height: 3.h),
          _buildSpecialOffersSection(),
          SizedBox(height: 3.h),
          const QuickAccessTilesWidget(),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  Widget _buildQuickBookSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(5.w),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Icon(
                Icons.flash_on,
                color: primaryColor,
                size: 7.w,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Book',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Fast booking for frequent routes',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: onSurfaceColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: primaryColor,
                size: 4.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTripsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Trips',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 2.5.h),
          Container(
            height: 16.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                final trips = [
                  'University Campus → Downtown',
                  'Airport → Shopping Mall',
                  'Business District → University',
                ];
                return Container(
                  width: 72.w,
                  margin: EdgeInsets.only(right: 4.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(4.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trips[index],
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Last trip: ${index + 1} days ago',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: onSurfaceColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(3.w),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            'Book Again',
                            style: TextStyle(
                              color: surfaceColor,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOffersSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Offers',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 2.5.h),
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.85),
                  primaryColor.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(5.w),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '20% OFF',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: surfaceColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Weekend Special\nValid until Sunday',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(3.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Claim Now',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
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
}