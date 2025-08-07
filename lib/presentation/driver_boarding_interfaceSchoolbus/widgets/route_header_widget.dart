import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class RouteHeaderWidget extends StatelessWidget {
  final String routeNumber;
  final int currentCapacity;
  final int maxCapacity;
  final String currentStop;
  final String nextStop;
  final bool isOnline;
  final VoidCallback? onBackTap;
  final bool showBackButton;

  const RouteHeaderWidget({
    Key? key,
    required this.routeNumber,
    required this.currentCapacity,
    required this.maxCapacity,
    required this.currentStop,
    required this.nextStop,
    required this.isOnline,
    this.onBackTap,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final capacityPercentage = (currentCapacity / maxCapacity * 100).round();
    final isNearCapacity = capacityPercentage >= 80;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top row with back button (if enabled)
            if (showBackButton)
              Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBackTap ?? () => Navigator.pop(context),
                      icon: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.onPrimaryLight,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            Row(
              children: [
                // Route Info
                Expanded(
                  flex: 2,
                  child: _buildRouteInfo(),
                ),
                // Capacity Indicator
                Expanded(
                  flex: 1,
                  child: _buildCapacityIndicator(
                      capacityPercentage, isNearCapacity),
                ),
                // Connection Status
                _buildConnectionStatus(),
              ],
            ),
            SizedBox(height: 1.5.h),
            _buildStopInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'directions_bus',
              color: AppTheme.secondaryLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Route $routeNumber',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.onPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Driver Boarding Interface',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.onPrimaryLight.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCapacityIndicator(int percentage, bool isNearCapacity) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.onPrimaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isNearCapacity ? AppTheme.warningLight : AppTheme.secondaryLight,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'people',
                color: isNearCapacity
                    ? AppTheme.warningLight
                    : AppTheme.secondaryLight,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                '$currentCapacity/$maxCapacity',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.onPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.onPrimaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: isNearCapacity
                      ? AppTheme.warningLight
                      : AppTheme.secondaryLight,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            '$percentage% Full',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.onPrimaryLight.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isOnline ? AppTheme.successLight : AppTheme.warningLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 1.w),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopInfo() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.onPrimaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Current Stop
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.secondaryLight,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Current Stop',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.onPrimaryLight.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  currentStop,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.onPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 6.h,
            color: AppTheme.onPrimaryLight.withValues(alpha: 0.3),
            margin: EdgeInsets.symmetric(horizontal: 3.w),
          ),
          // Next Stop
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'arrow_forward',
                      color: AppTheme.onPrimaryLight.withValues(alpha: 0.6),
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Next Stop',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.onPrimaryLight.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  nextStop.isNotEmpty ? nextStop : 'End of Route',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.onPrimaryLight.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
