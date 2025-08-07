import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class BottomToolbarWidget extends StatelessWidget {
  final VoidCallback onCompleteStop;
  final VoidCallback onEmergencyContact;
  final bool isOnline;
  final int pendingSync;
  final bool canCompleteStop;

  const BottomToolbarWidget({
    Key? key,
    required this.onCompleteStop,
    required this.onEmergencyContact,
    required this.isOnline,
    required this.pendingSync,
    required this.canCompleteStop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Emergency Contact Button
            _buildEmergencyButton(),
            SizedBox(width: 3.w),
            // Sync Status
            Expanded(
              child: _buildSyncStatus(),
            ),
            SizedBox(width: 3.w),
            // Complete Stop Button
            _buildCompleteStopButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.errorLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorLight.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onLongPress: onEmergencyContact,
          child: Container(
            padding: EdgeInsets.all(3.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'emergency',
                  color: AppTheme.onErrorLight,
                  size: 24,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Emergency',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.onErrorLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Hold',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.onErrorLight.withValues(alpha: 0.8),
                    fontSize: 8.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatus() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: isOnline
            ? AppTheme.successLight.withValues(alpha: 0.1)
            : AppTheme.warningLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline ? AppTheme.successLight : AppTheme.warningLight,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isOnline ? 'cloud_done' : 'cloud_off',
                color: isOnline ? AppTheme.successLight : AppTheme.warningLight,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                isOnline ? 'Data Synced' : 'Offline Mode',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color:
                      isOnline ? AppTheme.successLight : AppTheme.warningLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (!isOnline && pendingSync > 0) ...[
            SizedBox(height: 0.5.h),
            Text(
              '$pendingSync events pending sync',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.warningLight,
              ),
            ),
          ],
          if (isOnline) ...[
            SizedBox(height: 0.5.h),
            Text(
              'All data synchronized',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.successLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompleteStopButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: canCompleteStop
            ? [
                BoxShadow(
                  color: AppTheme.secondaryLight.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: canCompleteStop ? onCompleteStop : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              canCompleteStop ? AppTheme.secondaryLight : AppTheme.neutralLight,
          foregroundColor: canCompleteStop
              ? AppTheme.onSecondaryLight
              : AppTheme.onSurfaceLight.withValues(alpha: 0.6),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: canCompleteStop ? 2 : 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: canCompleteStop
                  ? AppTheme.onSecondaryLight
                  : AppTheme.onSurfaceLight.withValues(alpha: 0.6),
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Complete',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: canCompleteStop
                    ? AppTheme.onSecondaryLight
                    : AppTheme.onSurfaceLight.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Stop',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: canCompleteStop
                    ? AppTheme.onSecondaryLight
                    : AppTheme.onSurfaceLight.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
