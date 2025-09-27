import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/theme_notifier.dart';

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
        color: ThemeNotifier().isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: ThemeNotifier().isDarkMode
              ? Colors.white.withOpacity(0.2)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeNotifier().isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
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
                  color: const Color(0xFF008B8B),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Center(
                  child: Text(
                    seatNumber,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Passenger for Seat $seatNumber',
                style: GoogleFonts.inter(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          TextFormField(
            controller: _nameControllers[seatId],
            style: GoogleFonts.inter(
              color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
              fontSize: 12.sp,
            ),
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: GoogleFonts.inter(
                color: ThemeNotifier().isDarkMode
                    ? Colors.white70
                    : Colors.black54,
                fontSize: 12.sp,
              ),
              hintText: 'Enter passenger name',
              hintStyle: GoogleFonts.inter(
                color: ThemeNotifier().isDarkMode
                    ? Colors.white60
                    : Colors.grey[500],
                fontSize: 12.sp,
              ),
              prefixIcon: Icon(
                Icons.person,
                color: const Color(0xFF008B8B),
                size: 5.w,
              ),
              filled: true,
              fillColor: ThemeNotifier().isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
                borderSide: BorderSide(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
                borderSide: BorderSide(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
                borderSide: const BorderSide(
                  color: Color(0xFF008B8B),
                  width: 2,
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
                  style: GoogleFonts.inter(
                    color: ThemeNotifier().isDarkMode
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 12.sp,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Age',
                    labelStyle: GoogleFonts.inter(
                      color: ThemeNotifier().isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                      fontSize: 12.sp,
                    ),
                    hintText: 'Age',
                    hintStyle: GoogleFonts.inter(
                      color: ThemeNotifier().isDarkMode
                          ? Colors.white60
                          : Colors.grey[500],
                      fontSize: 12.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.cake,
                      color: const Color(0xFF008B8B),
                      size: 5.w,
                    ),
                    filled: true,
                    fillColor: ThemeNotifier().isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.w),
                      borderSide: BorderSide(
                        color: ThemeNotifier().isDarkMode
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.w),
                      borderSide: BorderSide(
                        color: ThemeNotifier().isDarkMode
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.w),
                      borderSide: const BorderSide(
                        color: Color(0xFF008B8B),
                        width: 2,
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
                    color: ThemeNotifier().isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: ThemeNotifier().isDarkMode
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _genderSelections[seatId],
                      isExpanded: true,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: ThemeNotifier().isDarkMode
                            ? Colors.white70
                            : Colors.grey[600],
                        size: 6.w,
                      ),
                      items: ['Male', 'Female', 'Other'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: GoogleFonts.inter(
                              color: ThemeNotifier().isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 12.sp,
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
        color: ThemeNotifier().isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
        boxShadow: [
          BoxShadow(
            color: ThemeNotifier().isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
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
                color: ThemeNotifier().isDarkMode
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey[400],
                borderRadius: BorderRadius.circular(0.5.w),
              ),
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.assignment_ind,
                color: const Color(0xFF008B8B),
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Passenger Details',
                style: GoogleFonts.inter(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 14.sp,
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
