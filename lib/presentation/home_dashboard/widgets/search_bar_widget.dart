import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

// 2025 Design Constants
const Color primaryColor = Color(0xFF20B2AA);
const double cardBorderRadius = 16.0;

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearchTap;

  const SearchBarWidget({
    super.key,
    required this.onSearchTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;

  final List<String> _recentSearches = [
    'Douala to Yaoundé',
    'Yaoundé to Bamenda',
    'Douala to Bafoussam',
    'Garoua to Maroua',
  ];

  final List<String> _popularRoutes = [
    'Douala → Yaoundé',
    'Yaoundé → Bamenda',
    'Douala → Bafoussam',
    'Garoua → Maroua',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchTap() {
    HapticFeedback.selectionClick();
    widget.onSearchTap('/search-booking');
  }

  // Modern suggestion item with clean design
  Widget _buildSuggestionItem(String text, IconData iconData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          _searchController.text = text;
          _handleSearchTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  iconData,
                  color: primaryColor,
                  size: 4.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: AppTheme.onSurfaceLight,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_outward,
                color: AppTheme.onSurfaceLight.withOpacity(0.4),
                size: 4.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Modern search bar with clean design
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5.w),
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
              onTap: _handleSearchTap,
              borderRadius: BorderRadius.circular(cardBorderRadius),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    // Modern search icon
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
                    // Search text with modern typography
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
                          SizedBox(height: 0.3.h),
                          Text(
                            'Search destinations, routes, and more',
                            style: TextStyle(
                              color: AppTheme.onSurfaceLight.withOpacity(0.6),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Modern arrow icon
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
        ),

        // Modern suggestions dropdown (simplified)
        if (_isExpanded) ...[
          SizedBox(height: 2.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(cardBorderRadius),
              border: Border.all(
                color: AppTheme.onSurfaceLight.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.onSurfaceLight.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent searches section
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
                  child: Text(
                    'Recent Searches',
                    style: TextStyle(
                      color: AppTheme.onSurfaceLight,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...(_recentSearches.take(2).map(
                    (search) => _buildSuggestionItem(search, Icons.history))),

                // Divider
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  height: 1,
                  color: AppTheme.onSurfaceLight.withOpacity(0.1),
                ),

                // Popular routes section
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.h),
                  child: Text(
                    'Popular Routes',
                    style: TextStyle(
                      color: AppTheme.onSurfaceLight,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...(_popularRoutes.take(2).map(
                    (route) => _buildSuggestionItem(route, Icons.trending_up))),

                SizedBox(height: 1.h),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
