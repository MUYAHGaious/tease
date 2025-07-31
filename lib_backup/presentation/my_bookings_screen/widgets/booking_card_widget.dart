import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BookingCardWidget extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onViewTicket;
  final VoidCallback? onModify;
  final VoidCallback? onCancel;
  final VoidCallback? onShare;
  final VoidCallback? onDownloadReceipt;
  final VoidCallback? onRebook;
  final VoidCallback? onRate;

  const BookingCardWidget({
    Key? key,
    required this.booking,
    this.onViewTicket,
    this.onModify,
    this.onCancel,
    this.onShare,
    this.onDownloadReceipt,
    this.onRebook,
    this.onRate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String status = booking['status'] as String;
    final Color borderColor = _getStatusColor(status);
    final bool isUpcoming = status == 'confirmed' || status == 'pending';
    final bool isCompleted = status == 'completed';

    return Dismissible(
      key: Key(booking['id'].toString()),
      background: _buildSwipeBackground(context, isLeft: true),
      secondaryBackground: _buildSwipeBackground(context, isLeft: false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          if (isUpcoming) {
            onModify?.call();
          } else if (isCompleted) {
            onDownloadReceipt?.call();
          }
        } else {
          if (isUpcoming) {
            onShare?.call();
          } else if (isCompleted) {
            onRate?.call();
          }
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: borderColor,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 2.h),
              _buildRouteInfo(context),
              SizedBox(height: 2.h),
              _buildBookingDetails(context),
              if (isUpcoming) ...[
                SizedBox(height: 2.h),
                _buildViewTicketButton(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    final bool isUpcoming =
        booking['status'] == 'confirmed' || booking['status'] == 'pending';
    final bool isCompleted = booking['status'] == 'completed';

    String text;
    IconData icon;
    Color color;

    if (isLeft) {
      if (isUpcoming) {
        text = 'Modify';
        icon = Icons.edit;
        color = AppTheme.warningLight;
      } else if (isCompleted) {
        text = 'Receipt';
        icon = Icons.download;
        color = AppTheme.primaryLight;
      } else {
        text = 'Action';
        icon = Icons.info;
        color = AppTheme.textSecondaryLight;
      }
    } else {
      if (isUpcoming) {
        text = 'Share';
        icon = Icons.share;
        color = AppTheme.primaryLight;
      } else if (isCompleted) {
        text = 'Rate';
        icon = Icons.star;
        color = AppTheme.secondaryLight;
      } else {
        text = 'Action';
        icon = Icons.info;
        color = AppTheme.textSecondaryLight;
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 6.w),
              SizedBox(height: 0.5.h),
              Text(
                text,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: _getStatusColor(booking['status']).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            booking['status'].toString().toUpperCase(),
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: _getStatusColor(booking['status']),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          booking['bookingReference'] as String,
          style: AppTheme.getMonospaceStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking['fromCity'] as String,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Text(
                booking['departureTime'] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: [
              CustomIconWidget(
                iconName: 'arrow_forward',
                color: AppTheme.primaryLight,
                size: 5.w,
              ),
              SizedBox(height: 0.5.h),
              Text(
                booking['duration'] as String,
                style: AppTheme.lightTheme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                booking['toCity'] as String,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
              SizedBox(height: 0.5.h),
              Text(
                booking['arrivalTime'] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall,
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetails(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date',
              style: AppTheme.lightTheme.textTheme.labelSmall,
            ),
            Text(
              booking['travelDate'] as String,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Seats',
              style: AppTheme.lightTheme.textTheme.labelSmall,
            ),
            Text(
              (booking['seatNumbers'] as List).join(', '),
              style: AppTheme.getMonospaceStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Total',
              style: AppTheme.lightTheme.textTheme.labelSmall,
            ),
            Text(
              booking['totalAmount'] as String,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewTicketButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onViewTicket,
        icon: CustomIconWidget(
          iconName: 'qr_code',
          color: const Color(0xFFC8E53F),
          size: 4.w,
        ),
        label: Text(
          'View Ticket',
          style: TextStyle(
            color: const Color(0xFFC8E53F),
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A4A47),
          foregroundColor: const Color(0xFFC8E53F),
          padding: EdgeInsets.symmetric(vertical: 3.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.w),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF1A4A47).withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppTheme.successLight;
      case 'pending':
        return AppTheme.warningLight;
      case 'cancelled':
        return AppTheme.errorLight;
      case 'completed':
        return AppTheme.primaryLight;
      default:
        return AppTheme.textSecondaryLight;
    }
  }
}
