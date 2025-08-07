import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BookingDetailWidget extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onClose;

  const BookingDetailWidget({
    Key? key,
    required this.booking,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final route = booking['route'] as String? ?? 'Unknown Route';
    final date = booking['date'] as DateTime? ?? DateTime.now();
    final pickupTime = booking['pickupTime'] as String? ?? '--:--';
    final dropoffTime = booking['dropoffTime'] as String? ?? '--:--';
    final driverName = booking['driverName'] as String? ?? 'Not Assigned';
    final boardingTime = booking['boardingTime'] as String? ?? 'Not Boarded';
    final pickupStop = booking['pickupStop'] as String? ?? 'Unknown Stop';
    final dropoffStop = booking['dropoffStop'] as String? ?? 'Unknown Stop';
    final busNumber = booking['busNumber'] as String? ?? 'N/A';
    final status = booking['status'] as String? ?? 'Unknown';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Booking Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    context,
                    'Route',
                    route,
                    Icons.directions_bus,
                  ),
                  _buildDetailRow(
                    context,
                    'Date',
                    '${date.day}/${date.month}/${date.year}',
                    Icons.calendar_today,
                  ),
                  _buildDetailRow(
                    context,
                    'Pickup Time',
                    pickupTime,
                    Icons.schedule,
                  ),
                  _buildDetailRow(
                    context,
                    'Drop-off Time',
                    dropoffTime,
                    Icons.schedule,
                  ),
                  _buildDetailRow(
                    context,
                    'Pickup Stop',
                    pickupStop,
                    Icons.location_on,
                  ),
                  _buildDetailRow(
                    context,
                    'Drop-off Stop',
                    dropoffStop,
                    Icons.location_on,
                  ),
                  _buildDetailRow(
                    context,
                    'Bus Number',
                    busNumber,
                    Icons.directions_bus,
                  ),
                  _buildDetailRow(
                    context,
                    'Driver',
                    driverName,
                    Icons.person,
                  ),
                  _buildDetailRow(
                    context,
                    'Status',
                    status,
                    Icons.info,
                    valueColor: _getStatusColor(status),
                  ),
                  if (boardingTime != 'Not Boarded')
                    _buildDetailRow(
                      context,
                      'Boarding Time',
                      boardingTime,
                      Icons.check_circle,
                      valueColor: AppTheme.successLight,
                    ),
                  SizedBox(height: 3.h),
                  if (status == 'Confirmed' || status == 'Completed')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/qr-code-display');
                        },
                        icon: CustomIconWidget(
                          iconName: 'qr_code',
                          color: AppTheme.lightTheme.colorScheme.onSecondary,
                          size: 20,
                        ),
                        label: Text(
                          'View QR Code',
                          style: TextStyle(
                            color: AppTheme.lightTheme.colorScheme.onSecondary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryLight,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon.toString().split('.').last,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: valueColor ??
                            AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppTheme.secondaryLight;
      case 'completed':
        return AppTheme.successLight;
      case 'cancelled':
        return AppTheme.errorLight;
      case 'no-show':
        return AppTheme.warningLight;
      default:
        return AppTheme.neutralLight;
    }
  }
}
