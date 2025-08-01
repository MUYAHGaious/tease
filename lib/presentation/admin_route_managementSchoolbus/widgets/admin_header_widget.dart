import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdminHeaderWidget extends StatelessWidget {
  final String adminName;
  final String systemStatus;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onBackTap;
  final bool showBackButton;

  const AdminHeaderWidget({
    super.key,
    required this.adminName,
    required this.systemStatus,
    this.onMenuTap,
    this.onNotificationTap,
    this.onBackTap,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 6.h, 4.w, 2.h),
      decoration: const BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top row with back/menu and notifications
            Row(
              children: [
                IconButton(
                  onPressed: showBackButton ? (onBackTap ?? () => Navigator.pop(context)) : onMenuTap,
                  icon: CustomIconWidget(
                    iconName: showBackButton ? 'arrow_back' : 'menu',
                    color: AppTheme.onPrimaryLight,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Stack(
                  children: [
                    IconButton(
                      onPressed: onNotificationTap,
                      icon: CustomIconWidget(
                        iconName: 'notifications',
                        color: AppTheme.onPrimaryLight,
                        size: 24,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.secondaryLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Admin info section
            Row(
              children: [
                Container(
                  width: 15.w,
                  height: 7.h,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.onSecondaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onPrimaryLight
                                  .withValues(alpha: 0.8),
                            ),
                      ),
                      Text(
                        adminName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.onPrimaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(systemStatus).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(systemStatus),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(systemStatus),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        systemStatus,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.onPrimaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Quick stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Active Routes',
                    '12',
                    Icons.route,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Buses',
                    '8',
                    Icons.directions_bus,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Drivers',
                    '15',
                    Icons.person,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.onPrimaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.onPrimaryLight.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon.toString().split('.').last,
            color: AppTheme.secondaryLight,
            size: 20,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.onPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onPrimaryLight.withValues(alpha: 0.8),
                ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
      case 'active':
        return AppTheme.successLight;
      case 'maintenance':
      case 'warning':
        return AppTheme.warningLight;
      case 'offline':
      case 'error':
        return AppTheme.errorLight;
      default:
        return AppTheme.secondaryLight;
    }
  }
}
