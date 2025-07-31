import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class JourneyStatusWidget extends StatelessWidget {
  final String currentStatus;
  final DateTime departureTime;
  final DateTime arrivalTime;

  const JourneyStatusWidget({
    Key? key,
    required this.currentStatus,
    required this.departureTime,
    required this.arrivalTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> statuses = [
      'booked',
      'departed',
      'in-transit',
      'completed'
    ];
    final int currentIndex = statuses.indexOf(currentStatus.toLowerCase());

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Journey Status',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(currentStatus).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentStatus.toUpperCase(),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: _getStatusColor(currentStatus),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: List.generate(statuses.length, (index) {
              final isActive = index <= currentIndex;
              final isCompleted = index < currentIndex;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 4.w,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline,
                        shape: BoxShape.circle,
                      ),
                      child: isCompleted
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              size: 2.5.w,
                            )
                          : null,
                    ),
                    if (index < statuses.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isActive
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Departure',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Arrival',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'departed':
        return AppTheme.warningLight;
      case 'in-transit':
        return AppTheme.warningLight;
      case 'completed':
        return AppTheme.successLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }
}
