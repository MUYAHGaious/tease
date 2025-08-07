import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PopularRoutesSectionWidget extends StatefulWidget {
  const PopularRoutesSectionWidget({super.key});

  @override
  State<PopularRoutesSectionWidget> createState() =>
      _PopularRoutesSectionWidgetState();
}

class _PopularRoutesSectionWidgetState extends State<PopularRoutesSectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late List<Animation<double>> _scaleAnimations;

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
      'duration': '20-30 min',
      'frequency': 'Every 20 min',
    },
    {
      'route': 'Centre Ville ↔ Emombo',
      'passengers': '650+ daily',
      'rating': 4.7,
      'duration': '40-50 min',
      'frequency': 'Every 25 min',
    },
    {
      'route': 'Mfoundi ↔ Nkol-Eton',
      'passengers': '900+ daily',
      'rating': 4.5,
      'duration': '25-35 min',
      'frequency': 'Every 18 min',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimations = List.generate(
      _popularRoutes.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _scaleController,
          curve: Interval(
            index * 0.1,
            0.4 + (index * 0.1),
            curve: Curves.elasticOut,
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryLight,
                    ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.secondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4.w,
              mainAxisSpacing: 3.h,
              childAspectRatio: 0.85,
            ),
            itemCount: _popularRoutes.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _scaleAnimations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimations[index].value,
                    child: _buildRouteCard(_popularRoutes[index], index),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route, int index) {
    return GestureDetector(
      onTap: () => _handleRouteSelection(route),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.w),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRouteHeader(route),
            SizedBox(height: 2.h),
            _buildRouteStats(route),
            SizedBox(height: 2.h),
            _buildRouteInfo(route),
            const Spacer(),
            _buildBookButton(route),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteHeader(Map<String, dynamic> route) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.secondaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Icon(
            Icons.route,
            color: AppTheme.secondaryLight,
            size: 5.w,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            route['route'],
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
                ),
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteStats(Map<String, dynamic> route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              route['passengers'],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.successLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              'passengers',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralLight,
                  ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                color: AppTheme.secondaryLight,
                size: 3.w,
              ),
              SizedBox(width: 1.w),
              Text(
                route['rating'].toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo(Map<String, dynamic> route) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.access_time, route['duration']),
        SizedBox(height: 1.h),
        _buildInfoRow(Icons.schedule, route['frequency']),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.neutralLight,
          size: 4.w,
        ),
        SizedBox(width: 2.w),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.neutralLight,
              ),
        ),
      ],
    );
  }

  Widget _buildBookButton(Map<String, dynamic> route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox.shrink(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Text(
            'Book',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  void _handleRouteSelection(Map<String, dynamic> route) {
    final routeParts = route['route'].split(' ↔ ');
    Navigator.pushNamed(context, AppRoutes.busBookingForm, arguments: {
      'from': routeParts[0],
      'to': routeParts[1],
      'popular': true,
    });
  }
}
