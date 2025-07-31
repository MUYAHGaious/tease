import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final int? count;
  final VoidCallback onRemove;

  const FilterChipWidget({
    super.key,
    required this.label,
    this.count,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 2.w),
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (count != null) ...[
              SizedBox(width: 1.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
        deleteIcon: CustomIconWidget(
          iconName: 'close',
          color: AppTheme.lightTheme.colorScheme.secondary,
          size: 16,
        ),
        onDeleted: onRemove,
        backgroundColor:
            AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
        side: BorderSide(
          color:
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
