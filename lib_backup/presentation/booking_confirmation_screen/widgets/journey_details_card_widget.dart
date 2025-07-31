import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class JourneyDetailsCardWidget extends StatelessWidget {
  final Map<String, dynamic> bookingDetails;

  const JourneyDetailsCardWidget({
    super.key,
    required this.bookingDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
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
            _buildSectionHeader('Journey Details'),
            SizedBox(height: 2.h),
            _buildRouteInfo(),
            SizedBox(height: 2.h),
            _buildDivider(),
            SizedBox(height: 2.h),
            _buildBusInfo(),
            SizedBox(height: 2.h),
            _buildDivider(),
            SizedBox(height: 2.h),
            _buildPassengerInfo(),
            SizedBox(height: 2.h),
            _buildDivider(),
            SizedBox(height: 2.h),
            _buildPaymentInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRouteInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('From', bookingDetails['fromCity'] as String),
              SizedBox(height: 1.h),
              _buildInfoRow('To', bookingDetails['toCity'] as String),
              SizedBox(height: 1.h),
              _buildInfoRow('Date', bookingDetails['travelDate'] as String),
              SizedBox(height: 1.h),
              _buildInfoRow(
                  'Departure', bookingDetails['departureTime'] as String),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primaryContainer
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: 'directions_bus',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 8.w,
          ),
        ),
      ],
    );
  }

  Widget _buildBusInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Bus Number', bookingDetails['busNumber'] as String),
        SizedBox(height: 1.h),
        _buildInfoRow('Bus Type', bookingDetails['busType'] as String),
        SizedBox(height: 1.h),
        _buildInfoRow(
            'Seat Numbers', (bookingDetails['seatNumbers'] as List).join(', ')),
      ],
    );
  }

  Widget _buildPassengerInfo() {
    final passengers =
        bookingDetails['passengers'] as List<Map<String, dynamic>>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passenger Details',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 1.h),
        ...passengers.map((passenger) => Padding(
              padding: EdgeInsets.only(bottom: 0.5.h),
              child: _buildInfoRow(
                'Passenger ${passengers.indexOf(passenger) + 1}',
                '${passenger['name']} (${passenger['age']} years, ${passenger['gender']})',
              ),
            )),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPaymentRow('Base Fare', bookingDetails['baseFare'] as String),
          if (bookingDetails['taxes'] != null) ...[
            SizedBox(height: 0.5.h),
            _buildPaymentRow('Taxes & Fees', bookingDetails['taxes'] as String),
          ],
          if (bookingDetails['addOns'] != null) ...[
            SizedBox(height: 0.5.h),
            _buildPaymentRow('Add-ons', bookingDetails['addOns'] as String),
          ],
          SizedBox(height: 1.h),
          Container(
            height: 1,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          SizedBox(height: 1.h),
          _buildPaymentRow(
            'Total Amount Paid',
            bookingDetails['totalAmount'] as String,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 25.w,
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
    );
  }
}
