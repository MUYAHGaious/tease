import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime? departureDate;
  final DateTime? returnDate;
  final bool isRoundTrip;
  final Function(DateTime, bool) onDateSelected;

  const DatePickerWidget({
    super.key,
    required this.departureDate,
    required this.returnDate,
    required this.isRoundTrip,
    required this.onDateSelected,
  });

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    HapticFeedback.selectionClick();
    final DateTime now = DateTime.now();
    final DateTime initialDate = isDeparture 
        ? (departureDate ?? now)
        : (returnDate ?? departureDate ?? now);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.lightTheme.colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked, isDeparture);
    }
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required bool isDeparture,
    required BuildContext context,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectDate(context, isDeparture),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(4.w, 3.w, 4.w, 1.w),
                child: Text(
                  label,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date != null
                                ? DateFormat('MMM dd').format(date)
                                : 'Select date',
                            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: date != null 
                                  ? AppTheme.lightTheme.colorScheme.onSurface
                                  : AppTheme.textMediumEmphasisLight,
                            ),
                          ),
                          if (date != null)
                            Text(
                              DateFormat('EEEE').format(date),
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textMediumEmphasisLight,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Travel Dates',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            _buildDateField(
              label: 'DEPARTURE',
              date: departureDate,
              isDeparture: true,
              context: context,
            ),
            if (isRoundTrip) ...[
              SizedBox(width: 3.w),
              _buildDateField(
                label: 'RETURN',
                date: returnDate,
                isDeparture: false,
                context: context,
              ),
            ],
          ],
        ),
      ],
    );
  }
}