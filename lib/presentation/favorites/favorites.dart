import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/theme_notifier.dart';
import '../../widgets/global_bottom_navigation.dart';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> with TickerProviderStateMixin {
  // Theme-aware colors
  Color get primaryColor => const Color(0xFF008B8B);
  Color get backgroundColor =>
      ThemeNotifier().isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get surfaceColor =>
      ThemeNotifier().isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get textColor =>
      ThemeNotifier().isDarkMode ? Colors.white : Colors.black87;
  Color get onSurfaceVariantColor =>
      ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54;
  Color get borderColor => ThemeNotifier().isDarkMode
      ? Colors.white.withOpacity(0.2)
      : Colors.grey.withOpacity(0.3);
  int _selectedSegment = 0;
  String _searchQuery = '';
  bool _isRefreshing = false;

  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // Mock favorites data
  final List<Map<String, dynamic>> _allFavorites = [
    {
      "id": "FAV001",
      "type": "route",
      "title": "Douala → Yaoundé",
      "subtitle": "Popular route • 4h journey",
      "operator": "Tease Express",
      "price": "From 22,500 XAF",
      "rating": 4.8,
      "frequency": "Every 2 hours",
      "icon": Icons.route,
      "color": Color(0xFF1a4d3a),
    },
    {
      "id": "FAV002",
      "type": "operator",
      "title": "Cameroon Express",
      "subtitle": "Premium bus operator",
      "operator": "Cameroon Express",
      "price": "Average: 35,000 XAF",
      "rating": 4.6,
      "frequency": "20+ routes",
      "icon": Icons.directions_bus,
      "color": Color(0xFF2d5a3d),
    },
    {
      "id": "FAV003",
      "type": "route",
      "title": "Yaoundé → Bamenda",
      "subtitle": "Scenic mountain route • 5h journey",
      "operator": "Mountain Express",
      "price": "From 37,500 XAF",
      "rating": 4.7,
      "frequency": "Daily departures",
      "icon": Icons.route,
      "color": Color(0xFF4a7c59),
    },
    {
      "id": "FAV004",
      "type": "destination",
      "title": "Bafoussam",
      "subtitle": "Cultural city in the highlands",
      "operator": "Multiple operators",
      "price": "From 18,000 XAF",
      "rating": 4.4,
      "frequency": "15+ daily trips",
      "icon": Icons.location_city,
      "color": Color(0xFF0d2921),
    },
  ];

  @override
  void initState() {
    super.initState();
    ThemeNotifier().addListener(_onThemeChanged);
    _initializeAnimations();
    _startAnimations();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    _fadeAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideAnimationController.forward();
    });
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isRefreshing = false);
  }

  List<Map<String, dynamic>> get _filteredFavorites {
    var filtered = _allFavorites;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              item['title']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              item['subtitle']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedSegment == 1) {
      filtered = filtered.where((item) => item['type'] == 'route').toList();
    } else if (_selectedSegment == 2) {
      filtered = filtered.where((item) => item['type'] == 'operator').toList();
    }

    return filtered;
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.05),
            Colors.white,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: textColor,
                      size: 6.w,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Favorites',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '${_filteredFavorites.length} saved items',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildSearchBar(),
            SizedBox(height: 2.h),
            _buildSegmentedControl(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search favorites...',
          hintStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            color: textColor.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: textColor.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          _buildSegmentButton('All', 0),
          _buildSegmentButton('Routes', 1),
          _buildSegmentButton('Operators', 2),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String title, int index) {
    final isSelected = _selectedSegment == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedSegment = index);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: isSelected ? Colors.white : textColor.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> favorite) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            // Handle favorite tap
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: (favorite['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        favorite['icon'],
                        color: favorite['color'],
                        size: 6.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            favorite['title'],
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            favorite['subtitle'],
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        // Remove from favorites
                      },
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red[600],
                          size: 5.w,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            favorite['price'],
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rating',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber[600],
                                size: 4.w,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                '${favorite['rating']}',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Frequency',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            favorite['frequency'],
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              color: primaryColor,
              size: 15.w,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'No favorites yet',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Start exploring routes and operators\nto add them to your favorites',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: textColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildHeader(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: primaryColor,
              child: _filteredFavorites.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: 60.h,
                        child: _buildEmptyState(),
                      ),
                    )
                  : SlideTransition(
                      position: _slideAnimation,
                      child: ListView.builder(
                        padding: EdgeInsets.all(4.w),
                        itemCount: _filteredFavorites.length,
                        itemBuilder: (context, index) {
                          return _buildFavoriteCard(_filteredFavorites[index]);
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlobalBottomNavigation(
        initialIndex: 3, // Favorites tab
      ),
    );
  }
}
