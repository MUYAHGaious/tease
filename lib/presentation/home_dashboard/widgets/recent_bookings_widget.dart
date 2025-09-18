import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentBookingsWidget extends StatefulWidget {
  final Function(String) onBookingTap;

  const RecentBookingsWidget({
    super.key,
    required this.onBookingTap,
  });

  @override
  State<RecentBookingsWidget> createState() => _RecentBookingsWidgetState();
}

class _RecentBookingsWidgetState extends State<RecentBookingsWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimations = List.generate(_recentBookings.length, (index) {
      return Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.2,
          0.6 + (index * 0.2),
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    _fadeAnimations = List.generate(_recentBookings.length, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.15,
          0.5 + (index * 0.15),
          curve: Curves.easeOut,
        ),
      ));
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF20B2AA);
      case 'pending':
        return const Color(0xFFFF9800);
      case 'cancelled':
        return const Color(0xFFf44336);
      default:
        return AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimations[index],
          child: SlideTransition(
            position: _slideAnimations[index],
            child: GestureDetector(
              onTap: () => widget.onBookingTap(booking['id']),
              child: Container(
                width: 80.w,
                margin: EdgeInsets.only(right: 4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.shadow
                          .withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CustomImageWidget(
                            imageUrl: booking['image'],
                            width: double.infinity,
                            height: 12.h,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 2.w,
                            right: 2.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 1.w,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(booking['status']),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                booking['status'],
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    booking['route'],
                                    style: AppTheme
                                        .lightTheme.textTheme.titleMedium
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  booking['price'],
                                  style: AppTheme
                                      .lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'calendar_today',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  size: 4.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  booking['date'],
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                CustomIconWidget(
                                  iconName: 'access_time',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  size: 4.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  booking['time'],
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'airline_seat_recline_normal',
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                      size: 4.w,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      'Seat ${booking['seatNumber']}',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  booking['busOperator'],
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Bookings',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => widget.onBookingTap('/trip-history'),
                child: Text(
                  'View All',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 25.h,
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
