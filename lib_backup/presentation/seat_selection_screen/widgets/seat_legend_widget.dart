import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SeatLegendWidget extends StatelessWidget {
  const SeatLegendWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seat Legend',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(
                color: AppTheme.successLight,
                label: 'Available',
                icon: 'event_seat',
              ),
              _buildLegendItem(
                color: AppTheme.errorLight,
                label: 'Occupied',
                icon: 'event_seat',
              ),
              _buildLegendItem(
                color: AppTheme.secondaryLight,
                label: 'Selected',
                icon: 'event_seat',
              ),
              _buildLegendItem(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                label: 'Unavailable',
                icon: 'event_seat',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String icon,
  }) {
    return Column(
      children: [
        Container(
          width: 8.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}
