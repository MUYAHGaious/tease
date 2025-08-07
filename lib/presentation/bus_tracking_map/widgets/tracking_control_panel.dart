import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TrackingControlPanel extends StatelessWidget {
  final bool isTracking;
  final bool showStudentMarkers;
  final Map<String, Map<String, dynamic>> buses;
  final String selectedBusId;
  final VoidCallback onTrackingToggle;
  final VoidCallback onStudentMarkersToggle;
  final Function(String) onBusSelected;

  const TrackingControlPanel({
    super.key,
    required this.isTracking,
    required this.showStudentMarkers,
    required this.buses,
    required this.selectedBusId,
    required this.onTrackingToggle,
    required this.onStudentMarkersToggle,
    required this.onBusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 15.h,
      left: 4.w,
      child: Column(
        children: [
          // Tracking controls container
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tracking toggle
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTrackingToggle();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isTracking
                          ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isTracking
                            ? AppTheme.lightTheme.colorScheme.primary
                            : Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isTracking ? Icons.pause : Icons.play_arrow,
                          color: isTracking
                              ? AppTheme.lightTheme.colorScheme.primary
                              : Colors.grey[600],
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          isTracking ? 'Tracking' : 'Start',
                          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                            color: isTracking
                                ? AppTheme.lightTheme.colorScheme.primary
                                : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // Student markers toggle
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onStudentMarkersToggle();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: showStudentMarkers
                          ? AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: showStudentMarkers
                            ? AppTheme.lightTheme.colorScheme.secondary
                            : Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          showStudentMarkers ? Icons.visibility : Icons.visibility_off,
                          color: showStudentMarkers
                              ? AppTheme.lightTheme.colorScheme.secondary
                              : Colors.grey[600],
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Students',
                          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                            color: showStudentMarkers
                                ? AppTheme.lightTheme.colorScheme.secondary
                                : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Bus selector
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Bus',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                ...buses.entries.map((entry) {
                  final bus = entry.value;
                  final isSelected = selectedBusId == bus['id'];
                  
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onBusSelected(bus['id']);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 1.h),
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : Colors.grey.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_bus,
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : Colors.grey[600],
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bus['name'],
                                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                  color: isSelected
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${bus['currentStudents']}/${bus['capacity']}',
                                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textMediumEmphasisLight,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}