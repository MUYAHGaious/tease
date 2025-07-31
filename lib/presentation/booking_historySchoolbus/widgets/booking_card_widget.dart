import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BookingCardWidget extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onTap;
  final VoidCallback? onRateTrip;
  final VoidCallback? onBookAgain;
  final bool isSelected;
  final VoidCallback? onLongPress;

  const BookingCardWidget({
    Key? key,
    required this.booking,
    this.onTap,
    this.onRateTrip,
    this.onBookAgain,
    this.isSelected = false,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] as String? ?? 'Unknown';
    final route = booking['route'] as String? ?? 'Unknown Route';
    final date = booking['date'] as DateTime? ?? DateTime.now();
    final pickupTime = booking['pickupTime'] as String? ?? '--:--';
    final dropoffTime = booking['dropoffTime'] as String? ?? '--:--';
    final bookingRef = booking['bookingRef'] as String? ?? 'N/A';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Dismissible(
        key: Key(bookingRef),
        background: _buildSwipeBackground(true),
        secondaryBackground: _buildSwipeBackground(false),
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd &&
              status == 'Completed') {
            onRateTrip?.call();
          } else if (direction == DismissDirection.endToStart) {
            onBookAgain?.call();
          }
        },
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd &&
              status != 'Completed') {
            return false;
          }
          return true;
        },
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppTheme.secondaryLight, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              route,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'schedule',
                                  color: AppTheme.secondaryLight,
                                  size: 16,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Pickup: $pickupTime',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'location_on',
                                  color: AppTheme.secondaryLight,
                                  size: 16,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Drop-off: $dropoffTime',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (status == 'Confirmed' || status == 'Completed')
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/qr-code-display');
                          },
                          icon: CustomIconWidget(
                            iconName: 'qr_code',
                            color: AppTheme.lightTheme.colorScheme.onSecondary,
                            size: 16,
                          ),
                          label: Text(
                            'QR Code',
                            style: TextStyle(
                              color:
                                  AppTheme.lightTheme.colorScheme.onSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryLight,
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            minimumSize: Size(0, 4.h),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'confirmation_number',
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 14,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Ref: $bookingRef',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 10.sp,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'confirmed':
        badgeColor = AppTheme.secondaryLight;
        textColor = AppTheme.lightTheme.colorScheme.onSecondary;
        break;
      case 'completed':
        badgeColor = AppTheme.successLight;
        textColor = Colors.white;
        break;
      case 'cancelled':
        badgeColor = AppTheme.errorLight;
        textColor = Colors.white;
        break;
      case 'no-show':
        badgeColor = AppTheme.warningLight;
        textColor = Colors.white;
        break;
      default:
        badgeColor = AppTheme.neutralLight;
        textColor = Colors.white;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(bool isLeft) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft ? AppTheme.successLight : AppTheme.secondaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: isLeft ? 'star' : 'refresh',
            color: Colors.white,
            size: 24,
          ),
          SizedBox(height: 0.5.h),
          Text(
            isLeft ? 'Rate Trip' : 'Book Again',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
