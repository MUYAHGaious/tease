import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SelectedSeatsSummaryWidget extends StatelessWidget {
  final List<String> selectedSeats;
  final double pricePerSeat;
  final String currency;
  final VoidCallback onContinue;

  const SelectedSeatsSummaryWidget({
    Key? key,
    required this.selectedSeats,
    required this.pricePerSeat,
    required this.currency,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalPrice = selectedSeats.length * pricePerSeat;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            if (selectedSeats.isNotEmpty) ...[
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'event_seat',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Selected Seats',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A4A47),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A4A47).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF1A4A47).withValues(alpha: 0.2),
                  ),
                ),
                child: Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: selectedSeats
                      .map((seat) => Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC8E53F),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              seat,
                              style: AppTheme.lightTheme.textTheme.labelMedium
                                  ?.copyWith(
                                color: const Color(0xFF1A4A47),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${selectedSeats.length} seat${selectedSeats.length > 1 ? 's' : ''} × $currency ${pricePerSeat.toStringAsFixed(0)}',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Total: $currency ${totalPrice.toStringAsFixed(0)}',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A4A47),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC8E53F),
                      foregroundColor: const Color(0xFF1A4A47),
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continue',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: const Color(0xFF1A4A47),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        CustomIconWidget(
                          iconName: 'arrow_forward',
                          color: const Color(0xFF1A4A47),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Column(
                children: [
                  CustomIconWidget(
                    iconName: 'event_seat',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 40,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Select seats to continue',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Tap on available seats to select them',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
