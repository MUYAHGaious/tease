import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TimePreferenceCard extends StatelessWidget {
  final String? selectedTime;
  final Function(String?) onTimeSelected;

  const TimePreferenceCard({
    Key? key,
    required this.selectedTime,
    required this.onTimeSelected,
  }) : super(key: key);

  final List<String> _timeOptions = const [
    '7:00 AM - Morning',
    '8:00 AM - Morning',
    '3:00 PM - Afternoon',
    '4:00 PM - Afternoon',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4D3E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: const Color(0xFF1B4D3E),
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Time Preference',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF1B4D3E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            Column(
              children: _timeOptions.map((time) {
                final isSelected = selectedTime == time;
                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onTimeSelected(time),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF1B4D3E).withOpacity(0.1)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF1B4D3E)
                                : Colors.grey.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 5.w,
                              height: 5.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected 
                                      ? const Color(0xFF1B4D3E)
                                      : Colors.grey,
                                  width: 2,
                                ),
                                color: isSelected 
                                    ? const Color(0xFF1B4D3E)
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 2.w,
                                        height: 2.w,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isSelected 
                                    ? const Color(0xFF1B4D3E)
                                    : Colors.grey[700],
                                fontWeight: isSelected 
                                    ? FontWeight.w600 
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}