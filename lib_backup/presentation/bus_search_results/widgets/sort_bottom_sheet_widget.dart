import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SortBottomSheetWidget extends StatelessWidget {
  final String selectedSort;
  final Function(String) onSortSelected;

  const SortBottomSheetWidget({
    super.key,
    required this.selectedSort,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {
        'key': 'price',
        'title': 'Price',
        'subtitle': 'Low to High',
        'icon': 'attach_money'
      },
      {
        'key': 'departure',
        'title': 'Departure Time',
        'subtitle': 'Earliest First',
        'icon': 'schedule'
      },
      {
        'key': 'duration',
        'title': 'Duration',
        'subtitle': 'Shortest First',
        'icon': 'timer'
      },
      {
        'key': 'rating',
        'title': 'Rating',
        'subtitle': 'Highest First',
        'icon': 'star'
      },
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Text(
                'Sort By',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...sortOptions.map((option) => _buildSortOption(
                context,
                option['key'] as String,
                option['title'] as String,
                option['subtitle'] as String,
                option['icon'] as String,
              )),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String key,
    String title,
    String subtitle,
    String icon,
  ) {
    final isSelected = selectedSort == key;

    return InkWell(
      onTap: () {
        onSortSelected(key);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.only(bottom: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.onSecondary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
