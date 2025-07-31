import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FavoriteRoutesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteRoutes;
  final Function(Map<String, dynamic>)? onRouteTap;
  final Function(Map<String, dynamic>)? onQuickBook;

  const FavoriteRoutesWidget({
    Key? key,
    required this.favoriteRoutes,
    this.onRouteTap,
    this.onQuickBook,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (favoriteRoutes.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'star_border',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'No favorite routes',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Save your frequent routes for quick booking',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Favorite Routes',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: favoriteRoutes.length,
          itemBuilder: (context, index) {
            final route = favoriteRoutes[index];
            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: _buildFavoriteRouteCard(context, route),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFavoriteRouteCard(
      BuildContext context, Map<String, dynamic> route) {
    return GestureDetector(
      onTap: () => onRouteTap?.call(route),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'star',
                  color: AppTheme.secondaryLight,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          route['from'] as String? ?? '',
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      CustomIconWidget(
                        iconName: 'arrow_forward',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 18,
                      ),
                      SizedBox(width: 3.w),
                      Flexible(
                        child: Text(
                          route['to'] as String? ?? '',
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usual Duration',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        route['duration'] as String? ?? '',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Starting Price',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        route['price'] as String? ?? '',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 25.w,
                  child: ElevatedButton(
                    onPressed: () => onQuickBook?.call(route),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryLight,
                      foregroundColor: AppTheme.onSecondaryLight,
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Book',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.onSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
