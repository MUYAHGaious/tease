import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

// 2025 Design Constants
const Color primaryColor = Color(0xFF008B8B);
const double cardBorderRadius = 16.0;

class RecentBookingsWidget extends StatefulWidget {
  final Function(String) onBookingTap;

  const RecentBookingsWidget({
    super.key,
    required this.onBookingTap,
  });

  @override
  State<RecentBookingsWidget> createState() => _RecentBookingsWidgetState();
}

class _RecentBookingsWidgetState extends State<RecentBookingsWidget> {
  final List<Map<String, dynamic>> _recentBookings = [
    {
      'id': 'BF001',
      'route': 'Douala → Yaoundé',
      'date': '2025-07-30',
      'time': '09:30 AM',
      'status': 'Confirmed',
      'seatNumber': 'A12',
      'busOperator': 'Express Lines',
      'price': '6,500 XAF',
      'image':
          'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
    },
    {
      'id': 'BF002',
      'route': 'Yaoundé → Bamenda',
      'date': '2025-08-02',
      'time': '02:15 PM',
      'status': 'Pending',
      'seatNumber': 'B08',
      'busOperator': 'Central Voyages',
      'price': '8,000 XAF',
      'image':
          'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
    },
    {
      'id': 'BF003',
      'route': 'Douala → Bafoussam',
      'date': '2025-08-05',
      'time': '11:45 AM',
      'status': 'Confirmed',
      'seatNumber': 'C15',
      'busOperator': 'Guaranty Express',
      'price': '5,500 XAF',
      'image':
          'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  // Modern status colors - consistent with design system
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }

  // Modern 2025 booking card - clean design
  Widget _buildBookingCard(Map<String, dynamic> booking, int index) {
    return Container(
      width: 80.w,
      margin: EdgeInsets.only(right: 4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onBookingTap(booking['id']);
          },
          borderRadius: BorderRadius.circular(cardBorderRadius),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cardBorderRadius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern image with status badge
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 10.h, // Reduced image height
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.1),
                      ),
                      child: CustomImageWidget(
                        imageUrl: booking['image'],
                        width: double.infinity,
                        height: 10.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Modern status badge
                    Positioned(
                      top: 3.w,
                      right: 3.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.5.w,
                          vertical: 0.8.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking['status']),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor(booking['status'])
                                  .withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          booking['status'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Compact card content to prevent overflow
                Padding(
                  padding: EdgeInsets.all(3.w), // Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Prevent overflow
                    children: [
                      // Route and price row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              booking['route'],
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 13.sp, // Slightly smaller
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            booking['price'],
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h), // Reduced spacing

                      // Date and time row with compact design
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            size: 3.w, // Smaller icons
                          ),
                          SizedBox(width: 0.5.w),
                          Expanded(
                            child: Text(
                              '${booking['date']} • ${booking['time']}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                                fontSize: 9.sp, // Smaller text
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.8.h), // Reduced spacing

                      // Compact seat and operator row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 1.5.w,
                              vertical: 0.3.h,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.airline_seat_recline_normal,
                                  color: primaryColor,
                                  size: 2.5.w,
                                ),
                                SizedBox(width: 0.5.w),
                                Text(
                                  booking['seatNumber'],
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Text(
                              booking['busOperator'],
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                                fontSize: 8.sp, // Smaller text
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Bookings',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onBookingTap('/my-tickets');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Icon(
                          Icons.arrow_forward,
                          color: primaryColor,
                          size: 4.w,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 25.h, // Optimized height
          child: ListView.builder(
            padding: EdgeInsets.only(left: 5.w),
            scrollDirection: Axis.horizontal,
            itemCount: _recentBookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(_recentBookings[index], index);
            },
          ),
        ),
      ],
    );
  }
}
