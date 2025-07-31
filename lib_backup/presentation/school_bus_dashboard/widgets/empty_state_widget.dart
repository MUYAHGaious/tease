import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onLinkChild;

  const EmptyStateWidget({
    Key? key,
    required this.onLinkChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: const Color(0xFF1B4D3E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15.w),
              ),
              child: Center(
                child: Icon(
                  Icons.family_restroom,
                  size: 15.w,
                  color: const Color(0xFF1B4D3E),
                ),
              ),
            ),
            
            SizedBox(height: 4.h),
            
            // Title
            Text(
              'No Children Linked',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B4D3E),
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 2.h),
            
            // Description
            Text(
              'Start by linking your children to manage their school bus bookings and track their journeys.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 4.h),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: onLinkChild,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4D3E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Link Your First Child',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 3.h),
            
            // Help Text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 4.w,
                  color: Colors.grey[500],
                ),
                SizedBox(width: 2.w),
                Text(
                  'Need help? Contact school administration',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
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