import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DashboardHeaderWidget extends StatelessWidget {
  final String parentName;
  final int notificationCount;
  final VoidCallback onNotificationTap;

  const DashboardHeaderWidget({
    Key? key,
    required this.parentName,
    required this.notificationCount,
    required this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B4D3E),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row with greeting and notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          parentName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Notification Bell
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 6.w,
                          ),
                          if (notificationCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(1.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  shape: BoxShape.circle,
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 4.w,
                                  minHeight: 4.w,
                                ),
                                child: Text(
                                  notificationCount > 99
                                      ? '99+'
                                      : notificationCount.toString(),
                                  style: TextStyle(
                                    color: const Color(0xFF1B4D3E),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 8.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Quick Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Active Bookings',
                      '3',
                      Icons.directions_bus,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: _buildStatCard(
                      'This Week',
                      '12',
                      Icons.calendar_today,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFFFD700),
                size: 5.w,
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}