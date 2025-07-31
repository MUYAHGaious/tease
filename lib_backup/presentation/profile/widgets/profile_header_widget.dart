import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;

  const ProfileHeaderWidget({
    super.key,
    required this.onNotificationTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
          ),

          SizedBox(width: 2.w),

          // Tease Logo and Title
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'directions_bus',
              color: AppTheme.lightTheme.colorScheme.onSecondary,
              size: 20,
            ),
          ),

          SizedBox(width: 3.w),

          Text(
            'Tease',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),

          const Spacer(),

          // Notification Button
          Stack(
            children: [
              IconButton(
                onPressed: onNotificationTap,
                icon: CustomIconWidget(
                  iconName: 'notifications',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          // Settings Button
          IconButton(
            onPressed: onSettingsTap,
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
