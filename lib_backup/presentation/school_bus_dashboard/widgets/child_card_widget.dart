import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChildCardWidget extends StatelessWidget {
  final Map<String, dynamic> childData;
  final VoidCallback onTap;
  final VoidCallback onBookTrip;
  final VoidCallback onViewQR;
  final VoidCallback onCancelBooking;
  final VoidCallback onEditProfile;
  final VoidCallback onBookingHistory;
  final VoidCallback onNotificationSettings;

  const ChildCardWidget({
    Key? key,
    required this.childData,
    required this.onTap,
    required this.onBookTrip,
    required this.onViewQR,
    required this.onCancelBooking,
    required this.onEditProfile,
    required this.onBookingHistory,
    required this.onNotificationSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasActiveBooking = childData['hasActiveBooking'] ?? false;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                // Child Info Row
                Row(
                  children: [
                    // Profile Photo
                    Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFF4D03F)],
                        ),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Center(
                        child: Text(
                          childData['name']?.substring(0, 1) ?? 'C',
                          style: TextStyle(
                            color: const Color(0xFF1B4D3E),
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 3.w),
                    
                    // Child Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            childData['name'] ?? 'Child Name',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1B4D3E),
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Grade ${childData['grade'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'ID: ${childData['studentId'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status Indicator
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: hasActiveBooking 
                            ? const Color(0xFF4CAF50).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hasActiveBooking ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: hasActiveBooking 
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 2.h),
                
                // Booking Status
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: hasActiveBooking 
                        ? const Color(0xFF1B4D3E).withOpacity(0.05)
                        : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasActiveBooking 
                          ? const Color(0xFF1B4D3E).withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            hasActiveBooking ? Icons.directions_bus : Icons.bus_alert,
                            color: hasActiveBooking 
                                ? const Color(0xFF1B4D3E)
                                : Colors.grey[600],
                            size: 4.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            childData['bookingStatus'] ?? 'No Active Booking',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: hasActiveBooking 
                                  ? const Color(0xFF1B4D3E)
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (childData['nextTrip'] != null) ...[
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: const Color(0xFFFFD700),
                              size: 3.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              childData['nextTrip'],
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                SizedBox(height: 2.h),
                
                // Action Buttons
                Row(
                  children: [
                    if (hasActiveBooking) ...[
                      Expanded(
                        child: _buildActionButton(
                          'View QR',
                          Icons.qr_code,
                          const Color(0xFF1B4D3E),
                          onViewQR,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: _buildActionButton(
                          'Cancel',
                          Icons.cancel,
                          const Color(0xFFF44336),
                          onCancelBooking,
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: _buildActionButton(
                          'Book Trip',
                          Icons.add,
                          const Color(0xFF4CAF50),
                          onBookTrip,
                        ),
                      ),
                    ],
                    SizedBox(width: 2.w),
                    Expanded(
                      child: _buildActionButton(
                        'History',
                        Icons.history,
                        Colors.grey[600]!,
                        onBookingHistory,
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

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 4.w,
              ),
              SizedBox(width: 1.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}