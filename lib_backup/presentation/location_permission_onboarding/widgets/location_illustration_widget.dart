import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LocationIllustrationWidget extends StatelessWidget {
  const LocationIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: 25.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Phone illustration background
          Container(
            width: 35.w,
            height: 18.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Location pin icon
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'location_on',
                    color: AppTheme.lightTheme.colorScheme.onSecondary,
                    size: 4.w,
                  ),
                ),
                SizedBox(height: 1.h),
                // Phone screen content
                Container(
                  width: 25.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'BusGo',
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBusStopDot(),
                          _buildBusStopDot(),
                          _buildBusStopDot(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Floating bus stops around phone
          Positioned(
            top: 3.h,
            left: 15.w,
            child: _buildFloatingBusStop('Bus Stop A'),
          ),
          Positioned(
            top: 8.h,
            right: 12.w,
            child: _buildFloatingBusStop('Bus Stop B'),
          ),
          Positioned(
            bottom: 5.h,
            left: 18.w,
            child: _buildFloatingBusStop('Bus Stop C'),
          ),
          // GPS signal waves
          Positioned(
            top: 2.h,
            right: 20.w,
            child: _buildGpsWaves(),
          ),
        ],
      ),
    );
  }

  Widget _buildBusStopDot() {
    return Container(
      width: 1.w,
      height: 1.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.secondary,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildFloatingBusStop(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'directions_bus',
            color: AppTheme.lightTheme.colorScheme.onSecondary,
            size: 3.w,
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSecondary,
              fontSize: 8.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsWaves() {
    return SizedBox(
      width: 8.w,
      height: 8.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer wave
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          // Middle wave
          Container(
            width: 5.w,
            height: 5.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          // Inner wave
          Container(
            width: 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
