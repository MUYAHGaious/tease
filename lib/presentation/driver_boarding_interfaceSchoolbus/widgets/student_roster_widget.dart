import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class StudentRosterWidget extends StatelessWidget {
  final List<Map<String, dynamic>> students;
  final Function(Map<String, dynamic>) onManualCheckIn;
  final String currentStop;

  const StudentRosterWidget({
    Key? key,
    required this.students,
    required this.onManualCheckIn,
    required this.currentStop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expectedStudents = students
        .where((student) =>
            student['pickupStop'] == currentStop ||
            student['dropoffStop'] == currentStop)
        .toList();

    return Container(
      width: 45.w,
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryLight,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(expectedStudents.length),
          Expanded(
            child: expectedStudents.isEmpty
                ? _buildEmptyState()
                : _buildStudentList(expectedStudents),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int totalStudents) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'people',
                color: AppTheme.onPrimaryLight,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Expected Passengers',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.onPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalStudents',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.onSecondaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Stop: $currentStop',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.onPrimaryLight.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'person_off',
            color: AppTheme.neutralLight,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Expected Passengers',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.neutralLight,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'No students scheduled for this stop',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.neutralLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(List<Map<String, dynamic>> expectedStudents) {
    return ListView.separated(
      padding: EdgeInsets.all(2.w),
      itemCount: expectedStudents.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.h),
      itemBuilder: (context, index) {
        final student = expectedStudents[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final status = student['boardingStatus'] as String;
    final isBoarded = status == 'boarded';
    final isAbsent = status == 'absent';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'boarded':
        statusColor = AppTheme.successLight;
        statusIcon = Icons.check_circle;
        statusText = 'Boarded';
        break;
      case 'absent':
        statusColor = AppTheme.neutralLight;
        statusIcon = Icons.cancel;
        statusText = 'Absent';
        break;
      default:
        statusColor = AppTheme.secondaryLight;
        statusIcon = Icons.schedule;
        statusText = 'Pending';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isBoarded ? null : () => onManualCheckIn(student),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                // Profile Photo
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      imageUrl: student['profilePhoto'] as String,
                      width: 12.w,
                      height: 12.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isAbsent ? AppTheme.neutralLight : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'badge',
                            color: AppTheme.neutralLight,
                            size: 12,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'ID: ${student['studentId']}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.neutralLight,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'school',
                            color: AppTheme.neutralLight,
                            size: 12,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              'Grade ${student['grade']} - ${student['class']}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.neutralLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (student['boardingTime'] != null) ...[
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'access_time',
                              color: statusColor,
                              size: 12,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Boarded: ${student['boardingTime']}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Status Indicator
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        statusIcon,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      statusText,
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
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
}
