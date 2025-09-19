import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StudentETAPanel extends StatefulWidget {
  final List<Map<String, dynamic>> students;
  final VoidCallback onClose;

  const StudentETAPanel({
    super.key,
    required this.students,
    required this.onClose,
  });

  @override
  State<StudentETAPanel> createState() => _StudentETAPanelState();
}

class _StudentETAPanelState extends State<StudentETAPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'at_stop':
        return Colors.green;
      case 'approaching':
        return Colors.orange;
      case 'walking':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'at_stop':
        return 'At Stop';
      case 'approaching':
        return 'Approaching';
      case 'walking':
        return 'Walking';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'at_stop':
        return Icons.location_on;
      case 'approaching':
        return Icons.directions_walk;
      case 'walking':
        return Icons.directions_run;
      default:
        return Icons.person;
    }
  }

  void _closePanel() {
    _slideController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sort students by ETA (closest first)
    final sortedStudents = List<Map<String, dynamic>>.from(widget.students);
    sortedStudents
        .sort((a, b) => (a['etaToBus'] as int).compareTo(b['etaToBus'] as int));

    return SlideTransition(
      position: _slideAnimation,
      child: Positioned(
        top: 15.h,
        right: 4.w,
        bottom: 8.h, // Reduced from 20.h to 8.h to prevent bottom overlap
        child: Container(
          width: 80.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(-2, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 6.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student ETAs',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            '${sortedStudents.length} students tracked',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textMediumEmphasisLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _closePanel();
                      },
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 5.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Students list
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(4.w),
                  itemCount: sortedStudents.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 3.h,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                  itemBuilder: (context, index) {
                    final student = sortedStudents[index];
                    final status = student['status'] as String;
                    final statusColor = _getStatusColor(status);
                    final etaToBus = student['etaToBus'] as int;
                    final distance = (student['distanceToBus'] as double);

                    return Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Student info row
                          Row(
                            children: [
                              Container(
                                width: 12.w,
                                height: 12.w,
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getStatusIcon(status),
                                  color: statusColor,
                                  size: 6.w,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student['name'],
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      student['grade'],
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.textMediumEmphasisLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getStatusText(status),
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 2.h),

                          // ETA and distance info
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoChip(
                                  icon: Icons.timer,
                                  label: 'ETA',
                                  value: etaToBus > 0
                                      ? '${etaToBus} min'
                                      : 'Arrived',
                                  color: etaToBus <= 2
                                      ? Colors.green
                                      : etaToBus <= 5
                                          ? Colors.orange
                                          : Colors.blue,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: _buildInfoChip(
                                  icon: Icons.straighten,
                                  label: 'Distance',
                                  value: '${distance.toStringAsFixed(1)} km',
                                  color: Colors.grey[600]!,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 2.h),

                          // Contact info
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.5.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 4.w,
                                  color: AppTheme.textMediumEmphasisLight,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  student['parentPhone'],
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.textMediumEmphasisLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 4.w,
            color: color,
          ),
          SizedBox(width: 1.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                  fontSize: 9.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
