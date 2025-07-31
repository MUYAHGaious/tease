import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentTripsSectionWidget extends StatefulWidget {
  const RecentTripsSectionWidget({super.key});

  @override
  State<RecentTripsSectionWidget> createState() =>
      _RecentTripsSectionWidgetState();
}

class _RecentTripsSectionWidgetState extends State<RecentTripsSectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _recentTrips = [
    {
      'route': 'Downtown → Airport',
      'date': 'Today, 2:30 PM',
      'status': 'Completed',
      'busNumber': 'SB-1432',
    },
    {
      'route': 'University → Mall',
      'date': 'Yesterday, 11:15 AM',
      'status': 'Completed',
      'busNumber': 'SB-2156',
    },
    {
      'route': 'Business District → Home',
      'date': '2 days ago, 6:45 PM',
      'status': 'Cancelled',
      'busNumber': 'SB-3298',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Trips',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryLight,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.bookingHistory);
                  },
                  child: Text(
                    'View All',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.secondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              children: _recentTrips.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> trip = entry.value;
                return _buildTripCard(trip, index);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      margin: EdgeInsets.only(bottom: 2.h),
      child: Dismissible(
        key: Key('trip_$index'),
        direction: DismissDirection.endToStart,
        background: _buildDismissBackground(),
        onDismissed: (direction) => _handleRebook(trip),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryLight.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildTripIcon(trip['status']),
              SizedBox(width: 4.w),
              Expanded(child: _buildTripDetails(trip)),
              _buildTripActions(trip),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripIcon(String status) {
    Color iconColor;
    IconData iconData;

    switch (status) {
      case 'Completed':
        iconColor = AppTheme.successLight;
        iconData = Icons.check_circle;
        break;
      case 'Cancelled':
        iconColor = AppTheme.errorLight;
        iconData = Icons.cancel;
        break;
      default:
        iconColor = AppTheme.warningLight;
        iconData = Icons.schedule;
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 6.w,
      ),
    );
  }

  Widget _buildTripDetails(Map<String, dynamic> trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trip['route'],
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLight,
              ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          trip['date'],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.neutralLight,
              ),
        ),
        SizedBox(height: 0.5.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: _getStatusColor(trip['status']).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(1.w),
              ),
              child: Text(
                trip['status'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(trip['status']),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              'Bus: ${trip['busNumber']}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralLight,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripActions(Map<String, dynamic> trip) {
    return Column(
      children: [
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: () => _handleRebook(trip),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Text(
              'Rebook',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryLight,
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.refresh,
            color: AppTheme.onSecondaryLight,
            size: 6.w,
          ),
          SizedBox(width: 2.w),
          Text(
            'Rebook',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.onSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.successLight;
      case 'Cancelled':
        return AppTheme.errorLight;
      default:
        return AppTheme.warningLight;
    }
  }

  void _handleRebook(Map<String, dynamic> trip) {
    final routeParts = trip['route'].split(' → ');
    Navigator.pushNamed(context, AppRoutes.busBookingForm, arguments: {
      'from': routeParts[0],
      'to': routeParts[1],
      'rebook': true,
    });
  }
}
