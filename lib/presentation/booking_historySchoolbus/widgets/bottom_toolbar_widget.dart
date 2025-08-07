import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BottomToolbarWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onExport;
  final VoidCallback? onCancel;
  final VoidCallback? onClearSelection;

  const BottomToolbarWidget({
    Key? key,
    required this.selectedCount,
    this.onExport,
    this.onCancel,
    this.onClearSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$selectedCount selected',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onClearSelection,
              icon: CustomIconWidget(
                iconName: 'clear',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 16,
              ),
              label: Text(
                'Clear',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontSize: 12.sp,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            if (onExport != null)
              ElevatedButton.icon(
                onPressed: onExport,
                icon: CustomIconWidget(
                  iconName: 'download',
                  color: AppTheme.lightTheme.colorScheme.onSecondary,
                  size: 16,
                ),
                label: Text(
                  'Export',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.onSecondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryLight,
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                ),
              ),
            if (onCancel != null) ...[
              SizedBox(width: 2.w),
              ElevatedButton.icon(
                onPressed: onCancel,
                icon: CustomIconWidget(
                  iconName: 'cancel',
                  color: Colors.white,
                  size: 16,
                ),
                label: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorLight,
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
