import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyBookingsWidget extends StatelessWidget {
  final String bookingType;
  final VoidCallback? onBookNow;

  const EmptyBookingsWidget({
    Key? key,
    required this.bookingType,
    this.onBookNow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(context),
            SizedBox(height: 4.h),
            _buildTitle(context),
            SizedBox(height: 2.h),
            _buildDescription(context),
            SizedBox(height: 4.h),
            if (bookingType == 'upcoming' || bookingType == 'all')
              _buildBookNowButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: const Color(0xFF1A4A47).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: _getIconName(),
          color: const Color(0xFF1A4A47),
          size: 20.w,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      _getTitle(),
      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryLight,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      _getDescription(),
      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
        color: AppTheme.textSecondaryLight,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBookNowButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onBookNow,
        icon: CustomIconWidget(
          iconName: 'add',
          color: const Color(0xFFC8E53F),
          size: 5.w,
        ),
        label: Text(
          'Book Your First Trip',
          style: TextStyle(
            color: const Color(0xFFC8E53F),
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A4A47),
          foregroundColor: const Color(0xFFC8E53F),
          padding: EdgeInsets.symmetric(vertical: 4.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.w),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF1A4A47).withValues(alpha: 0.3),
        ),
      ),
    );
  }

  String _getIconName() {
    switch (bookingType) {
      case 'upcoming':
        return 'schedule';
      case 'completed':
        return 'check_circle_outline';
      case 'cancelled':
        return 'cancel_outlined';
      default:
        return 'directions_bus';
    }
  }

  String _getTitle() {
    switch (bookingType) {
      case 'upcoming':
        return 'No Upcoming Trips';
      case 'completed':
        return 'No Completed Trips';
      case 'cancelled':
        return 'No Cancelled Bookings';
      default:
        return 'No Bookings Yet';
    }
  }

  String _getDescription() {
    switch (bookingType) {
      case 'upcoming':
        return 'You don\'t have any upcoming bus trips. Book your next journey and start exploring!';
      case 'completed':
        return 'Your completed trips will appear here. Once you finish a journey, you can view receipts and rate your experience.';
      case 'cancelled':
        return 'You haven\'t cancelled any bookings. Your cancelled trips would appear here for reference.';
      default:
        return 'Start your journey with BusGo! Book your first bus ticket and enjoy comfortable, reliable travel.';
    }
  }
}