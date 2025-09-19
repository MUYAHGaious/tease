import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/booking_summary_widget.dart';
import './widgets/child_card_widget.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/empty_state_widget.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({Key? key}) : super(key: key);

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Mock data for parent dashboard
  final Map<String, dynamic> parentData = {
    "name": "Sarah Johnson",
    "email": "sarah.johnson@email.com",
    "phone": "+237 6 12 34 56 78",
    "notificationCount": 3,
  };

  final List<Map<String, dynamic>> childrenData = [
    {
      "id": 1,
      "name": "Emma Johnson",
      "grade": "5th",
      "profilePhoto":
          "https://images.unsplash.com/photo-1544005313-94ddf0286df2?fm=jpg&q=60&w=300&ixlib=rb-4.0.3",
      "hasActiveBooking": true,
      "bookingStatus": "Bus #12 - Morning Route",
      "nextTrip": "Tomorrow 7:30 AM",
      "studentId": "STU001",
    },
    {
      "id": 2,
      "name": "Liam Johnson",
      "grade": "3rd",
      "profilePhoto":
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?fm=jpg&q=60&w=300&ixlib=rb-4.0.3",
      "hasActiveBooking": false,
      "bookingStatus": "No Active Booking",
      "nextTrip": null,
      "studentId": "STU002",
    },
    {
      "id": 3,
      "name": "Sophia Johnson",
      "grade": "8th",
      "profilePhoto":
          "https://images.unsplash.com/photo-1494790108755-2616b612b786?fm=jpg&q=60&w=300&ixlib=rb-4.0.3",
      "hasActiveBooking": true,
      "bookingStatus": "Bus #8 - Afternoon Route",
      "nextTrip": "Today 3:15 PM",
      "studentId": "STU003",
    },
  ];

  final List<Map<String, dynamic>> upcomingSchedule = [
    {
      "childName": "Emma Johnson",
      "time": "7:30 AM",
      "route": "Morning Route - Bus #12",
      "status": "confirmed",
      "date": "2025-07-28",
    },
    {
      "childName": "Sophia Johnson",
      "time": "3:15 PM",
      "route": "Afternoon Route - Bus #8",
      "status": "confirmed",
      "date": "2025-07-27",
    },
    {
      "childName": "Emma Johnson",
      "time": "7:30 AM",
      "route": "Morning Route - Bus #12",
      "status": "pending",
      "date": "2025-07-29",
    },
  ];

  final List<Map<String, dynamic>> notifications = [
    {
      "id": 1,
      "title": "Booking Confirmed",
      "message": "Emma's morning trip for tomorrow has been confirmed.",
      "timestamp": "2 hours ago",
      "type": "booking",
      "isRead": false,
    },
    {
      "id": 2,
      "title": "Route Update",
      "message": "Bus #8 afternoon route has a 10-minute delay today.",
      "timestamp": "4 hours ago",
      "type": "route",
      "isRead": false,
    },
    {
      "id": 3,
      "title": "Payment Reminder",
      "message": "Monthly transportation fee is due in 3 days.",
      "timestamp": "1 day ago",
      "type": "payment",
      "isRead": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Parent Dashboard',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header
          DashboardHeaderWidget(
            parentName: parentData['name'] ?? 'Parent',
            notificationCount: parentData['notificationCount'] ?? 0,
            onNotificationTap: _handleNotificationTap,
          ),

          // Tab Bar
          Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Children'),
                Tab(text: 'Bookings'),
                Tab(text: 'Notifications'),
                Tab(text: 'Profile'),
              ],
              labelColor: AppTheme.lightTheme.colorScheme.primary,
              unselectedLabelColor:
                  AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              indicatorColor: AppTheme.lightTheme.colorScheme.secondary,
              indicatorWeight: 3,
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChildrenTab(),
                _buildBookingsTab(),
                _buildNotificationsTab(),
                _buildProfileTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _handleAddChild,
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
              icon: CustomIconWidget(
                iconName: 'person_add',
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                size: 5.w,
              ),
              label: Text(
                'Add Child',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildChildrenTab() {
    if (childrenData.isEmpty) {
      return EmptyStateWidget(
        onLinkChild: _handleAddChild,
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.lightTheme.colorScheme.secondary,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              itemCount: childrenData.length,
              itemBuilder: (context, index) {
                final child = childrenData[index];
                return ChildCardWidget(
                  childData: child,
                  onTap: () => _handleChildTap(child),
                  onBookTrip: () => _handleBookTrip(child),
                  onViewQR: () => _handleViewQR(child),
                  onCancelBooking: () => _handleCancelBooking(child),
                  onEditProfile: () => _handleEditProfile(child),
                  onBookingHistory: () => _handleBookingHistory(child),
                  onNotificationSettings: () =>
                      _handleNotificationSettings(child),
                );
              },
            ),
          ),

          // Booking Summary
          BookingSummaryWidget(
            totalActiveTrips: childrenData
                .where((child) => child['hasActiveBooking'] == true)
                .length,
            upcomingSchedule: upcomingSchedule,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTab() {
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        Text(
          'All Family Bookings',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        ...upcomingSchedule.map((booking) => _buildBookingCard(booking)),
      ],
    );
  }

  Widget _buildNotificationsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        // Profile Header
        Container(
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 12.w,
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                child: Text(
                  parentData['name']?.substring(0, 1) ?? 'P',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                parentData['name'] ?? 'Parent Name',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                parentData['email'] ?? 'email@example.com',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // Profile Options
        _buildProfileOption('Account Settings', 'settings', () {}),
        _buildProfileOption('Payment Methods', 'payment', () {}),
        _buildProfileOption('Notification Preferences', 'notifications', () {}),
        _buildProfileOption('Help & Support', 'help_outline', () {}),
        _buildProfileOption('Privacy Policy', 'privacy_tip', () {}),
        _buildProfileOption('Sign Out', 'logout', () {}),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking['childName'] ?? 'Unknown Child',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: booking['status'] == 'confirmed'
                      ? AppTheme.lightTheme.colorScheme.tertiary
                          .withValues(alpha: 0.2)
                      : AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking['status'] == 'confirmed' ? 'Confirmed' : 'Pending',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: booking['status'] == 'confirmed'
                        ? AppTheme.lightTheme.colorScheme.tertiary
                        : AppTheme.lightTheme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                booking['time'] ?? 'No time',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'directions_bus',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  booking['route'] ?? 'No route',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: notification['isRead'] == false
            ? Border.all(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.3),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: _getNotificationColor(notification['type'])
                  .withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: _getNotificationIcon(notification['type']),
              color: _getNotificationColor(notification['type']),
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'] ?? 'Notification',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  notification['message'] ?? 'No message',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Text(
                  notification['timestamp'] ?? 'Unknown time',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (notification['isRead'] == false)
            Container(
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
      String title, String iconName, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: ListTile(
        leading: CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 6.w,
        ),
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.bodyLarge,
        ),
        trailing: CustomIconWidget(
          iconName: 'chevron_right',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 5.w,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: AppTheme.lightTheme.colorScheme.surface,
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'booking':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'route':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'payment':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getNotificationIcon(String type) {
    switch (type) {
      case 'booking':
        return 'check_circle';
      case 'route':
        return 'directions_bus';
      case 'payment':
        return 'payment';
      default:
        return 'notifications';
    }
  }

  // Event Handlers
  void _handleNotificationTap() {
    _tabController.animateTo(2);
  }

  void _handleChildTap(Map<String, dynamic> child) {
    Navigator.pushNamed(context, '/bus-booking-form', arguments: child);
  }

  void _handleBookTrip(Map<String, dynamic> child) {
    Navigator.pushNamed(context, '/bus-booking-form', arguments: child);
  }

  void _handleViewQR(Map<String, dynamic> child) {
    Navigator.pushNamed(context, '/qr-code-display', arguments: child);
  }

  void _handleCancelBooking(Map<String, dynamic> child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
            'Are you sure you want to cancel ${child['name']}\'s booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle cancellation logic
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleEditProfile(Map<String, dynamic> child) {
    // Navigate to edit profile screen
  }

  void _handleBookingHistory(Map<String, dynamic> child) {
    Navigator.pushNamed(context, '/booking-history', arguments: child);
  }

  void _handleNotificationSettings(Map<String, dynamic> child) {
    // Navigate to notification settings
  }

  void _handleAddChild() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Child'),
        content: const Text(
            'You will be redirected to the child linking process. Please have your child\'s student ID ready.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to child linking process
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }
}
