import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../school_bus_dashboard/widgets/ict_university_nav.dart';
import '../school_bus_dashboard/controllers/ict_navigation_controller.dart';

class SchoolBusBookingHistory extends StatelessWidget {
  const SchoolBusBookingHistory({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> _bookingHistory = const [
    {
      'id': 'SB001',
      'date': 'Jul 27, 2025',
      'time': '7:30 AM',
      'route': 'Main Campus Route',
      'status': 'completed',
      'child': 'Emma Johnson',
    },
    {
      'id': 'SB002',
      'date': 'Jul 26, 2025',
      'time': '3:15 PM',
      'route': 'Main Campus Route',
      'status': 'completed',
      'child': 'Emma Johnson',
    },
    {
      'id': 'SB003',
      'date': 'Jul 25, 2025',
      'time': '7:30 AM',
      'route': 'Main Campus Route',
      'status': 'cancelled',
      'child': 'Emma Johnson',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final ICTNavigationController navController = ICTNavigationController();
    return Scaffold(
      backgroundColor: const Color(0xFF1B4D3E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4D3E),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 6.w,
          ),
        ),
        title: Column(
          children: [
            Text(
              'ICT Travel History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Past Campus Trips',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(4.w),
          itemCount: _bookingHistory.length,
          itemBuilder: (context, index) {
            final booking = _bookingHistory[index];
            return _buildBookingCard(booking);
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: ICTUniversityNav(
          currentIndex: 3, // History tab
          onTap: (index) {
            navController.updateIndex(3);
            navController.navigateToIndex(context, index);
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'completed':
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = const Color(0xFFF44336);
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = const Color(0xFFFF9800);
        statusIcon = Icons.schedule;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking ${booking['id']}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B4D3E),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: 3.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            // Child name
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.grey[600],
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  booking['child'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B4D3E),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 1.h),
            
            // Date and time
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey[600],
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  '${booking['date']} at ${booking['time']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 1.h),
            
            // Route
            Row(
              children: [
                Icon(
                  Icons.directions_bus,
                  color: Colors.grey[600],
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    booking['route'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}