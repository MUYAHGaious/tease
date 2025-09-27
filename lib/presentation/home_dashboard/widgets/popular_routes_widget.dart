import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

// 2025 Design Constants
const Color primaryColor = Color(0xFF008B8B);
const double cardBorderRadius = 16.0;

class PopularRoutesWidget extends StatefulWidget {
  final Function(String) onRouteTap;

  const PopularRoutesWidget({
    super.key,
    required this.onRouteTap,
  });

  @override
  State<PopularRoutesWidget> createState() => _PopularRoutesWidgetState();
}

class _PopularRoutesWidgetState extends State<PopularRoutesWidget> {
  bool _isLoading = true;

  final List<Map<String, dynamic>> _popularRoutes = [
    {
      'id': 'PR001',
      'from': 'Douala',
      'to': 'Yaoundé',
      'duration': '4h 30m',
      'price': '6,500 XAF',
      'frequency': '12 buses/day',
      'rating': 4.8,
      'image':
          'https://images.unsplash.com/photo-1485738422979-f5c462d49f74?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'discount': '15% OFF',
    },
    {
      'id': 'PR002',
      'from': 'Yaoundé',
      'to': 'Bamenda',
      'duration': '6h 15m',
      'price': '8,000 XAF',
      'frequency': '8 buses/day',
      'rating': 4.6,
      'image':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'discount': null,
    },
    {
      'id': 'PR003',
      'from': 'Douala',
      'to': 'Bafoussam',
      'duration': '5h 45m',
      'price': '5,500 XAF',
      'frequency': '6 buses/day',
      'rating': 4.7,
      'image':
          'https://images.unsplash.com/photo-1494522358652-f30e61a60313?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'discount': '20% OFF',
    },
    {
      'id': 'PR004',
      'from': 'Garoua',
      'to': 'Maroua',
      'duration': '3h 20m',
      'price': '7,200 XAF',
      'frequency': '10 buses/day',
      'rating': 4.5,
      'image':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'discount': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() async {
    // Simplified loading - no complex animations
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Modern skeleton loader - clean and simple
  Widget _buildSkeletonItem() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60.w,
                  height: 2.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  width: 40.w,
                  height: 1.5.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 15.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  // Modern 2025 route card - clean design with consistent styling
  Widget _buildRouteItem(Map<String, dynamic> route, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onRouteTap(route['id']);
          },
          borderRadius: BorderRadius.circular(cardBorderRadius),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                // Route image with modern styling
                Stack(
                  children: [
                    Container(
                      width: 15.w,
                      height: 15.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: CustomImageWidget(
                          imageUrl: route['image'],
                          width: 15.w,
                          height: 15.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Modern discount badge
                    if (route['discount'] != null)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 1.5.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            route['discount'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 8.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 4.w),

                // Route details with modern typography
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route and rating row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${route['from']} → ${route['to']}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.3.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB300).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: const Color(0xFFFFB300),
                                  size: 3.w,
                                ),
                                SizedBox(width: 0.5.w),
                                Text(
                                  route['rating'].toString(),
                                  style: TextStyle(
                                    color: const Color(0xFFFFB300),
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),

                      // Details row with modern icons - fixed overflow
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            size: 3.5.w,
                          ),
                          SizedBox(width: 1.w),
                          Flexible(
                            child: Text(
                              route['duration'],
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.directions_bus,
                            color: primaryColor.withOpacity(0.7),
                            size: 3.5.w,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              route['frequency'],
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Modern price display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      route['price'],
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      'per person',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w400,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Routes',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onRouteTap('/all-routes');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Icon(
                          Icons.arrow_forward,
                          color: primaryColor,
                          size: 4.w,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        if (_isLoading)
          ...List.generate(3, (index) => _buildSkeletonItem())
        else
          ...(_popularRoutes.map((route) =>
              _buildRouteItem(route, _popularRoutes.indexOf(route)))),
      ],
    );
  }
}
