import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ModificationOptionsWidget extends StatelessWidget {
  final VoidCallback onChangeSeats;
  final VoidCallback onAddBaggage;
  final VoidCallback onCancelBooking;
  final bool canModify;

  const ModificationOptionsWidget({
    Key? key,
    required this.onChangeSeats,
    required this.onAddBaggage,
    required this.onCancelBooking,
    this.canModify = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Modify Booking',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (!canModify) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.warningLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.warningLight,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Modifications not allowed within 2 hours of departure',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.warningLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 3.h),
          _buildModificationOption(
            icon: 'airline_seat_recline_normal',
            title: 'Change Seats',
            subtitle: 'Select different seats • Free within 24 hours',
            onTap: canModify ? onChangeSeats : null,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          _buildModificationOption(
            icon: 'luggage',
            title: 'Add Baggage',
            subtitle: 'Add extra baggage allowance • \$15 per bag',
            onTap: canModify ? onAddBaggage : null,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          _buildModificationOption(
            icon: 'cancel',
            title: 'Cancel Booking',
            subtitle: 'Cancel your trip • Cancellation charges apply',
            onTap: onCancelBooking,
            color: AppTheme.errorLight,
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modification Policy',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '• Seat changes are free up to 24 hours before departure\n• Baggage can be added anytime before check-in\n• Cancellations: 50% refund if cancelled 24+ hours before\n• No modifications allowed within 2 hours of departure',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModificationOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required Color color,
  }) {
    final bool isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppTheme.lightTheme.colorScheme.surface
              : AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isEnabled ? 0.1 : 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: isEnabled ? color : color.withValues(alpha: 0.5),
                size: 6.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isEnabled
                          ? AppTheme.lightTheme.textTheme.titleSmall?.color
                          : AppTheme.lightTheme.textTheme.titleSmall?.color
                              ?.withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: isEnabled
                          ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: isEnabled
                  ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.5),
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }
}
