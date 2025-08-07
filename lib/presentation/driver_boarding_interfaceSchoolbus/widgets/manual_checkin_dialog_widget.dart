import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ManualCheckinDialogWidget extends StatefulWidget {
  final Map<String, dynamic> student;
  final Function(Map<String, dynamic>, String) onConfirm;

  const ManualCheckinDialogWidget({
    Key? key,
    required this.student,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<ManualCheckinDialogWidget> createState() =>
      _ManualCheckinDialogWidgetState();
}

class _ManualCheckinDialogWidgetState extends State<ManualCheckinDialogWidget> {
  String? selectedReason;
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> reasons = [
    {
      'value': 'no_qr_code',
      'label': 'No QR Code Available',
      'icon': 'qr_code_off',
    },
    {
      'value': 'phone_issues',
      'label': 'Phone/Device Issues',
      'icon': 'phone_disabled',
    },
    {
      'value': 'qr_not_working',
      'label': 'QR Code Not Scanning',
      'icon': 'qr_code_scanner',
    },
    {
      'value': 'emergency',
      'label': 'Emergency Boarding',
      'icon': 'emergency',
    },
    {
      'value': 'other',
      'label': 'Other Reason',
      'icon': 'more_horiz',
    },
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 80.w,
        constraints: BoxConstraints(maxHeight: 80.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStudentInfo(),
                    SizedBox(height: 3.h),
                    _buildReasonSelection(),
                    if (selectedReason == 'other') ...[
                      SizedBox(height: 2.h),
                      _buildNotesField(),
                    ],
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'how_to_reg',
            color: AppTheme.onPrimaryLight,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Manual Check-In',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.onPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.onPrimaryLight,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryLight,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: widget.student['profilePhoto'] as String,
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student['name'] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'ID: ${widget.student['studentId']}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralLight,
                  ),
                ),
                Text(
                  'Grade ${widget.student['grade']} - ${widget.student['class']}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason for Manual Check-In',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Please select why QR code scanning is not available',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.neutralLight,
          ),
        ),
        SizedBox(height: 2.h),
        ...reasons.map((reason) => _buildReasonOption(reason)),
      ],
    );
  }

  Widget _buildReasonOption(Map<String, dynamic> reason) {
    final isSelected = selectedReason == reason['value'];

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryLight.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppTheme.primaryLight : AppTheme.dividerLight,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              selectedReason = reason['value'];
            });
          },
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: reason['icon'],
                  color: isSelected
                      ? AppTheme.primaryLight
                      : AppTheme.neutralLight,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    reason['label'],
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.primaryLight
                          : AppTheme.textHighEmphasisLight,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.primaryLight,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Please provide additional details...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Cancel'),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: ElevatedButton(
              onPressed: selectedReason != null ? _handleConfirm : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Check In Student'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleConfirm() {
    if (selectedReason == null) return;

    String reason = selectedReason == 'other'
        ? _notesController.text.trim()
        : reasons.firstWhere((r) => r['value'] == selectedReason)['label'];

    if (selectedReason == 'other' && reason.isEmpty) {
      reason = 'Other reason (no details provided)';
    }

    widget.onConfirm(widget.student, reason);
    Navigator.of(context).pop();
  }
}
