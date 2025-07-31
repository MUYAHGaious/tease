import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BookingSummaryWidget extends StatelessWidget {
  final int totalActiveTrips;
  final List<Map<String, dynamic>> upcomingSchedule;

  const BookingSummaryWidget({
    Key? key,
    required this.totalActiveTrips,
    required this.upcomingSchedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4D3E), Color(0xFF2D5A47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4D3E).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.schedule,
                  color: const Color(0xFFFFD700),
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Schedule',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$totalActiveTrips active trips',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 3.h),
          
          // Upcoming trips
          if (upcomingSchedule.isNotEmpty) ...[
            ...upcomingSchedule.take(3).map((trip) => _buildTripItem(trip)),
          ] else ...[
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withOpacity(0.7),
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'No upcoming trips scheduled',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripItem(Map<String, dynamic> trip) {
    final isConfirmed = trip['status'] == 'confirmed';
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConfirmed 
              ? const Color(0xFFFFD700).withOpacity(0.3)
              : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Time
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trip['time'] ?? '',
              style: TextStyle(
                color: const Color(0xFFFFD700),
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          
          SizedBox(width: 3.w),
          
          // Trip Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip['childName'] ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  trip['route'] ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: isConfirmed 
                  ? const Color(0xFF4CAF50).withOpacity(0.2)
                  : const Color(0xFFFF9800).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isConfirmed ? 'Ready' : 'Pending',
              style: TextStyle(
                color: isConfirmed 
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800),
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}