import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BookingDetailsCard extends StatelessWidget {
  final String tripDate;
  final String pickupLocation;
  final String dropoffLocation;
  final String busNumber;

  const BookingDetailsCard({
    Key? key,
    required this.tripDate,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.busNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondaryLight,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.secondaryLight,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 2.h),
          _buildDetailRow(
            context,
            'Date',
            tripDate,
            CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.secondaryLight,
              size: 20,
            ),
          ),
          SizedBox(height: 1.5.h),
          _buildDetailRow(
            context,
            'Pickup',
            pickupLocation,
            CustomIconWidget(
              iconName: 'location_on',
              color: AppTheme.secondaryLight,
              size: 20,
            ),
          ),
          SizedBox(height: 1.5.h),
          _buildDetailRow(
            context,
            'Drop-off',
            dropoffLocation,
            CustomIconWidget(
              iconName: 'flag',
              color: AppTheme.secondaryLight,
              size: 20,
            ),
          ),
          SizedBox(height: 1.5.h),
          _buildDetailRow(
            context,
            'Bus',
            busNumber,
            CustomIconWidget(
              iconName: 'directions_bus',
              color: AppTheme.secondaryLight,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, Widget icon) {
    return Row(
      children: [
        icon,
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
