import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RouteSelectionCard extends StatelessWidget {
  final String title;
  final String? selectedStop;
  final List<String> availableStops;
  final Function(String?) onStopSelected;
  final bool isDropOff;

  const RouteSelectionCard({
    Key? key,
    required this.title,
    required this.selectedStop,
    required this.availableStops,
    required this.onStopSelected,
    this.isDropOff = false,
  }) : super(key: key);

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
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4D3E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isDropOff ? Icons.location_on : Icons.my_location,
                    color: const Color(0xFF1B4D3E),
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF1B4D3E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            // Dropdown
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedStop != null 
                      ? const Color(0xFF1B4D3E).withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedStop,
                  hint: Text(
                    'Select ${isDropOff ? 'drop-off' : 'pickup'} location',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                  isExpanded: true,
                  items: availableStops.map((String stop) {
                    return DropdownMenuItem<String>(
                      value: stop,
                      child: Text(
                        stop,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF1B4D3E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onStopSelected,
                ),
              ),
            ),
            
            if (selectedStop != null) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF4CAF50),
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Selected: $selectedStop',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}