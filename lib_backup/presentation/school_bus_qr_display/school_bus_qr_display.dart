import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../school_bus_dashboard/widgets/ict_university_nav.dart';
import '../school_bus_dashboard/controllers/ict_navigation_controller.dart';

class SchoolBusQrDisplay extends StatelessWidget {
  const SchoolBusQrDisplay({Key? key}) : super(key: key);

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
              'ICT Digital Pass',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Your Active Ticket',
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
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              children: [
                // Success Icon
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      color: const Color(0xFF4CAF50),
                      size: 12.w,
                    ),
                  ),
                ),
                
                SizedBox(height: 3.h),
                
                // Success Message
                Text(
                  'Booking Confirmed!',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B4D3E),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 1.h),
                
                Text(
                  'Your school bus ticket has been booked successfully',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 4.h),
                
                // QR Code Card
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // QR Code Placeholder
                      Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code,
                              size: 20.w,
                              color: const Color(0xFF1B4D3E),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'QR CODE',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 3.h),
                      
                      // Booking Details
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B4D3E).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Booking ID', 'SB${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'),
                            SizedBox(height: 1.h),
                            _buildDetailRow('Date', 'Tomorrow, Jul 28'),
                            SizedBox(height: 1.h),
                            _buildDetailRow('Time', '7:30 AM'),
                            SizedBox(height: 1.h),
                            _buildDetailRow('Route', 'Main Campus Route'),
                            SizedBox(height: 1.h),
                            _buildDetailRow('Seat', '3A'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          side: BorderSide(
                            color: const Color(0xFF1B4D3E),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Share',
                          style: TextStyle(
                            color: const Color(0xFF1B4D3E),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.schoolBusDashboard,
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B4D3E),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Back to Dashboard',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: ICTUniversityNav(
          currentIndex: 2, // My Ticket tab
          onTap: (index) {
            navController.updateIndex(2);
            navController.navigateToIndex(context, index);
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF1B4D3E),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}