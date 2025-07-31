import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PassengerAssignmentWidget extends StatefulWidget {
  final List<Map<String, dynamic>> selectedSeats;
  final Function(int seatId, Map<String, String> passengerInfo)
      onPassengerAssigned;

  const PassengerAssignmentWidget({
    Key? key,
    required this.selectedSeats,
    required this.onPassengerAssigned,
  }) : super(key: key);

  @override
  State<PassengerAssignmentWidget> createState() =>
      _PassengerAssignmentWidgetState();
}

class _PassengerAssignmentWidgetState extends State<PassengerAssignmentWidget> {
  final Map<int, TextEditingController> _nameControllers = {};
  final Map<int, TextEditingController> _ageControllers = {};
  final Map<int, String> _genderSelections = {};

  @override
  void initState() {
    super.initState();
    for (var seat in widget.selectedSeats) {
      final seatId = seat['id'] as int;
      _nameControllers[seatId] = TextEditingController();
      _ageControllers[seatId] = TextEditingController();
      _genderSelections[seatId] = 'Male';
    }
  }

  @override
  void dispose() {
    _nameControllers.values.forEach((controller) => controller.dispose());
    _ageControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Widget _buildPassengerForm(Map<String, dynamic> seat) {
    final seatId = seat['id'] as int;
    final seatNumber = seat['number'] as String;

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Center(
                  child: Text(
                    seatNumber,
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Passenger for Seat $seatNumber',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          TextFormField(
            controller: _nameControllers[seatId],
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter passenger name',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'person',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
            ),
            onChanged: (value) => _updatePassengerInfo(seatId),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _ageControllers[seatId],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    hintText: 'Age',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'cake',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 5.w,
                      ),
                    ),
                  ),
                  onChanged: (value) => _updatePassengerInfo(seatId),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _genderSelections[seatId],
                      isExpanded: true,
                      icon: CustomIconWidget(
                        iconName: 'arrow_drop_down',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 6.w,
                      ),
                      items: ['Male', 'Female', 'Other'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _genderSelections[seatId] = newValue;
                          });
                          _updatePassengerInfo(seatId);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updatePassengerInfo(int seatId) {
    final passengerInfo = {
      'name': _nameControllers[seatId]?.text ?? '',
      'age': _ageControllers[seatId]?.text ?? '',
      'gender': _genderSelections[seatId] ?? 'Male',
    };
    widget.onPassengerAssigned(seatId, passengerInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12.w,
            height: 1.w,
            margin: EdgeInsets.only(bottom: 3.h),
            alignment: Alignment.center,
            child: Container(
              width: 12.w,
              height: 1.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(0.5.w),
              ),
            ),
          ),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'assignment_ind',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Passenger Details',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ...widget.selectedSeats.map((seat) => _buildPassengerForm(seat)),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
