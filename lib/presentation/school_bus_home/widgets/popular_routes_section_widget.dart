import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/theme_notifier.dart';
import '../../../core/app_export.dart';

class PopularRoutesSectionWidget extends StatefulWidget {
  const PopularRoutesSectionWidget({super.key});

  @override
  State<PopularRoutesSectionWidget> createState() =>
      _PopularRoutesSectionWidgetState();
}

class _PopularRoutesSectionWidgetState extends State<PopularRoutesSectionWidget> {
  // Theme-aware colors that prevent glitching
  Color get primaryColor => const Color(0xFF008B8B);
  Color get backgroundColor => ThemeNotifier().isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get textColor => ThemeNotifier().isDarkMode ? Colors.white : Colors.black87;
  Color get surfaceColor => ThemeNotifier().isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get onSurfaceColor => ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54;

  final List<Map<String, dynamic>> _popularRoutes = [
    {
      'route': 'Bastos ↔ Nsimeyong',
      'passengers': '1.2k+ daily',
      'rating': 4.8,
      'duration': '35-45 min',
      'frequency': 'Every 15 min',
    },
    {
      'route': 'Université de Yaoundé ↔ Etoudi',
      'passengers': '850+ daily',
      'rating': 4.6,
      'duration': '40-50 min',
      'frequency': 'Every 20 min',
    },
    {
      'route': 'Mfoundi ↔ Mendong',
      'passengers': '950+ daily',
      'rating': 4.7,
      'duration': '30-40 min',
      'frequency': 'Every 12 min',
    },
  ];

  @override
  void initState() {
    super.initState();
    ThemeNotifier().addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Routes',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: onSurfaceColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 24.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            itemCount: _popularRoutes.length,
            itemBuilder: (context, index) {
              return _buildRouteCard(_popularRoutes[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route, int index) {
    return Container(
      width: 75.w,
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Icon(
                  Icons.route,
                  color: primaryColor,
                  size: 4.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route['route'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      route['passengers'],
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: onSurfaceColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              _buildInfoChip(Icons.star, route['rating'].toString(), primaryColor.withOpacity(0.1)),
              SizedBox(width: 2.w),
              _buildInfoChip(Icons.access_time, route['duration'], Colors.orange.withOpacity(0.1)),
            ],
          ),
          SizedBox(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                route['frequency'],
                style: TextStyle(
                  fontSize: 11.sp,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 1.h,
                ),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Text(
                  'Book Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color backgroundColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 3.5.w, color: primaryColor),
          SizedBox(width: 1.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}