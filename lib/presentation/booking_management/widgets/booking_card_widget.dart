import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class BookingCardWidget extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onViewDetails;
  final VoidCallback onEditBooking;
  final VoidCallback onPrintBooking;
  final VoidCallback onCancelBooking;

  const BookingCardWidget({
    Key? key,
    required this.booking,
    required this.onViewDetails,
    required this.onEditBooking,
    required this.onPrintBooking,
    required this.onCancelBooking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Theme-aware colors following your pattern
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariantColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final shadowColor = Theme.of(context).colorScheme.shadow;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onViewDetails();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with booking ID and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking ID: ${booking['bookingId']}',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking['status']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking['status'].toString().toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                // Passenger info
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        booking['passengerName'],
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                // Route info
                Row(
                  children: [
                    Icon(
                      Icons.route,
                      color: primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        '${booking['fromCity']} → ${booking['toCity']}',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                // Travel details
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      booking['travelDate'],
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.access_time,
                      color: primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      booking['departureTime'],
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                // Price and actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking['price'],
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    Row(
                      children: [
                        _buildActionButton(
                          context: context,
                          icon: Icons.visibility,
                          onTap: onViewDetails,
                        ),
                        SizedBox(width: 2.w),
                        _buildActionButton(
                          context: context,
                          icon: Icons.edit,
                          onTap: onEditBooking,
                        ),
                        SizedBox(width: 2.w),
                        _buildActionButton(
                          context: context,
                          icon: Icons.print,
                          onTap: onPrintBooking,
                        ),
                        SizedBox(width: 2.w),
                        _buildActionButton(
                          context: context,
                          icon: Icons.cancel,
                          onTap: onCancelBooking,
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: isDestructive 
              ? Colors.red.withOpacity(0.1)
              : primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : primaryColor,
          size: 16,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
