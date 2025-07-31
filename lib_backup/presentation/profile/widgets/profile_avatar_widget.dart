import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onEditProfile;

  const ProfileAvatarWidget({
    super.key,
    required this.userData,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with Edit Button
          Stack(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: userData["avatarUrl"] as String,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme
                          .lightTheme.colorScheme.surfaceContainerHighest,
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 10.w,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme
                          .lightTheme.colorScheme.surfaceContainerHighest,
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 10.w,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEditProfile,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'edit',
                      color: AppTheme.lightTheme.colorScheme.onSecondary,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // User Name
          Text(
            userData["name"] as String,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 0.5.h),

          // User Email
          Text(
            userData["email"] as String,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 1.h),

          // Membership Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'star',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  '${userData["membershipType"]} Member',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            height: 5.h,
            child: OutlinedButton(
              onPressed: onEditProfile,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Edit Profile',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
