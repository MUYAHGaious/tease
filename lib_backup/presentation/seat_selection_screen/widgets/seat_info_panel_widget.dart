import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SeatInfoPanelWidget extends StatelessWidget {
  final String? selectedSeat;
  final Map<String, dynamic>? seatInfo;

  const SeatInfoPanelWidget({
    Key? key,
    this.selectedSeat,
    this.seatInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedSeat == null || seatInfo == null) {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'info_outline',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(
              'Tap a seat for details',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'event_seat',
                  color: AppTheme.lightTheme.colorScheme.onSecondary,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Seat $selectedSeat',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            icon: 'attach_money',
            label: 'Price',
            value:
                '\$${(seatInfo!['price'] as double? ?? 45.0).toStringAsFixed(2)}',
          ),
          SizedBox(height: 1.h),
          if (seatInfo!['isWindow'] as bool? ?? false)
            _buildInfoRow(
              icon: 'window',
              label: 'Position',
              value: 'Window Seat',
              valueColor: AppTheme.successLight,
            ),
          if (seatInfo!['isAisle'] as bool? ?? false)
            _buildInfoRow(
              icon: 'airline_seat_recline_normal',
              label: 'Position',
              value: 'Aisle Seat',
              valueColor: AppTheme.successLight,
            ),
          if (seatInfo!['extraLegroom'] as bool? ?? false) ...[
            SizedBox(height: 1.h),
            _buildInfoRow(
              icon: 'accessibility',
              label: 'Feature',
              value: 'Extra Legroom',
              valueColor: AppTheme.successLight,
            ),
          ],
          if (seatInfo!['nearRestroom'] as bool? ?? false) ...[
            SizedBox(height: 1.h),
            _buildInfoRow(
              icon: 'wc',
              label: 'Location',
              value: 'Near Restroom',
              valueColor: AppTheme.warningLight,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 16,
        ),
        SizedBox(width: 2.w),
        Text(
          '$label: ',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
