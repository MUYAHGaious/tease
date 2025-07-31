import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PermissionBenefitsWidget extends StatelessWidget {
  const PermissionBenefitsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> benefits = [
      {
        'icon': 'my_location',
        'title': 'Auto-detect Locations',
        'description': 'Automatically find your departure and arrival points',
      },
      {
        'icon': 'near_me',
        'title': 'Nearby Bus Stops',
        'description': 'Discover bus stops and routes close to you',
      },
      {
        'icon': 'track_changes',
        'title': 'Real-time Tracking',
        'description': 'Track your bus location and arrival times live',
      },
    ];

    return Container(
      width: 90.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          // Main heading
          Text(
            'Find Buses Near You',
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          // Subtitle
          Text(
            'Allow location access to enhance your bus booking experience with personalized features',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.95),
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          // Benefits list
          Column(
            children: benefits
                .map((benefit) => _buildBenefitItem(
                      iconName: benefit['icon'] as String,
                      title: benefit['title'] as String,
                      description: benefit['description'] as String,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required String iconName,
    required String title,
    required String description,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 12.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.9),
                    height: 1.3,
                    fontWeight: FontWeight.w500,
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
