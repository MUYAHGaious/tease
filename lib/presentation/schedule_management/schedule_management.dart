import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

import '../../theme/theme_notifier.dart';
import '../../widgets/global_bottom_navigation.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleManagementScreen> createState() =>
      _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentSubTab = 0; // For Driver/Conductor sub-tabs

  // Route status options
  final List<Map<String, dynamic>> _routeStatusOptions = [
    {
      'value': 'active',
      'label': 'Active',
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'value': 'inactive',
      'label': 'Inactive',
      'icon': Icons.pause_circle,
      'color': Colors.orange,
    },
    {
      'value': 'maintenance',
      'label': 'Maintenance',
      'icon': Icons.build,
      'color': Colors.blue,
    },
    {
      'value': 'suspended',
      'label': 'Suspended',
      'icon': Icons.block,
      'color': Colors.red,
    },
  ];

  // Driver status options
  final List<Map<String, dynamic>> _driverStatusOptions = [
    {
      'value': 'on_duty',
      'label': 'On Duty',
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'value': 'off_duty',
      'label': 'Off Duty',
      'icon': Icons.pause_circle,
      'color': Colors.orange,
    },
    {
      'value': 'on_break',
      'label': 'On Break',
      'icon': Icons.coffee,
      'color': Colors.blue,
    },
    {
      'value': 'sick_leave',
      'label': 'Sick Leave',
      'icon': Icons.sick,
      'color': Colors.red,
    },
    {
      'value': 'vacation',
      'label': 'Vacation',
      'icon': Icons.beach_access,
      'color': Colors.purple,
    },
  ];

  // Conductor status options
  final List<Map<String, dynamic>> _conductorStatusOptions = [
    {
      'value': 'on_duty',
      'label': 'On Duty',
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'value': 'off_duty',
      'label': 'Off Duty',
      'icon': Icons.pause_circle,
      'color': Colors.orange,
    },
    {
      'value': 'on_break',
      'label': 'On Break',
      'icon': Icons.coffee,
      'color': Colors.blue,
    },
    {
      'value': 'sick_leave',
      'label': 'Sick Leave',
      'icon': Icons.sick,
      'color': Colors.red,
    },
    {
      'value': 'vacation',
      'label': 'Vacation',
      'icon': Icons.beach_access,
      'color': Colors.purple,
    },
  ];

  // Bus model options
  final List<String> _busModelOptions = [
    'Mercedes Sprinter',
    'Toyota Coaster',
    'Isuzu NPR',
    'Ford Transit',
    'Volkswagen Crafter',
    'Iveco Daily',
    'Fiat Ducato',
    'Renault Master',
  ];

  // Driver options
  final List<String> _driverOptions = [
    'John Doe',
    'Jane Smith',
    'Lisa Davis',
    'Mike Johnson',
    'Sarah Wilson',
    'David Brown',
    'Emma Taylor',
    'James Anderson',
  ];

  // Conductor options
  final List<String> _conductorOptions = [
    'Alice Johnson',
    'Bob Williams',
    'Carol Davis',
    'Daniel Miller',
    'Eva Garcia',
    'Frank Martinez',
    'Grace Rodriguez',
    'Henry Lee',
  ];

  // Route options
  final List<String> _routeOptions = [
    'Douala → Yaoundé',
    'Yaoundé → Bamenda',
    'Douala → Bafoussam',
    'Bamenda → Douala',
    'Yaoundé → Douala',
    'Bafoussam → Yaoundé',
  ];

  // Theme-aware colors using proper theme system
  Color get primaryColor => Theme.of(context).colorScheme.primary;
  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(context).colorScheme.surface;
  Color get textColor => Theme.of(context).colorScheme.onSurface;
  Color get onSurfaceVariantColor =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  Color get borderColor => Theme.of(context).colorScheme.outline;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  int _selectedTab = 0;
  final List<String> _tabs = [
    'Schedule Overview',
    'Route Management',
    'Bus Management',
    'Driver & Conductor',
    'Real-time Control',
    'Performance'
  ];

  // Mock data for comprehensive features
  final List<Map<String, dynamic>> _routes = [
    {
      'id': 'R001',
      'name': 'Douala → Yaoundé',
      'distance': '245 km',
      'duration': '4h 15m',
      'frequency': 'Every 2 hours',
      'stops': ['Douala Central', 'Edea', 'Mbalmayo', 'Yaoundé Central'],
      'status': 'active',
      'buses': 3,
      'drivers': ['John Doe', 'Jane Smith', 'Mike Johnson'],
      'lastUpdated': '2025-01-15 08:30',
    },
    {
      'id': 'R002',
      'name': 'Yaoundé → Bamenda',
      'distance': '365 km',
      'duration': '5h 30m',
      'frequency': 'Daily',
      'stops': ['Yaoundé Central', 'Bafoussam', 'Mbouda', 'Bamenda Central'],
      'status': 'active',
      'buses': 2,
      'drivers': ['Sarah Wilson', 'David Brown'],
      'lastUpdated': '2025-01-15 07:45',
    },
    {
      'id': 'R003',
      'name': 'Douala → Bafoussam',
      'distance': '180 km',
      'duration': '3h 45m',
      'frequency': 'Every 3 hours',
      'stops': ['Douala Central', 'Edea', 'Melong', 'Bafoussam Central'],
      'status': 'maintenance',
      'buses': 1,
      'drivers': ['Lisa Davis'],
      'lastUpdated': '2025-01-14 16:20',
    },
  ];

  final List<Map<String, dynamic>> _drivers = [
    {
      'id': 'D001',
      'name': 'John Doe',
      'license': 'DL-123456',
      'experience': '5 years',
      'status': 'on_duty',
      'currentRoute': 'Douala → Yaoundé',
      'shift': 'Morning (06:00-14:00)',
      'phone': '+237 6 12 34 56 78',
      'rating': 4.8,
      'tripsToday': 2,
      'conductor': 'Alice Johnson',
      'conductorPhone': '+237 6 23 45 67 89',
      'breakTime': '10:00-10:15',
      'overtime': 0,
      'fuelEfficiency': 92,
    },
    {
      'id': 'D002',
      'name': 'Jane Smith',
      'license': 'DL-789012',
      'experience': '3 years',
      'status': 'on_duty',
      'currentRoute': 'Douala → Yaoundé',
      'shift': 'Afternoon (14:00-22:00)',
      'phone': '+237 6 23 45 67 89',
      'rating': 4.6,
      'tripsToday': 1,
      'conductor': 'Bob Williams',
      'conductorPhone': '+237 6 34 56 78 90',
      'breakTime': '16:00-16:15',
      'overtime': 0,
      'fuelEfficiency': 88,
    },
    {
      'id': 'D003',
      'name': 'Mike Johnson',
      'license': 'DL-345678',
      'experience': '7 years',
      'status': 'off_duty',
      'currentRoute': 'Douala → Yaoundé',
      'shift': 'Night (22:00-06:00)',
      'phone': '+237 6 34 56 78 90',
      'rating': 4.9,
      'tripsToday': 0,
      'conductor': 'Carol Davis',
      'conductorPhone': '+237 6 45 67 89 01',
      'breakTime': '02:00-02:15',
      'overtime': 0,
      'fuelEfficiency': 95,
    },
    {
      'id': 'D004',
      'name': 'Sarah Wilson',
      'license': 'DL-901234',
      'experience': '4 years',
      'status': 'on_break',
      'currentRoute': 'Yaoundé → Bamenda',
      'shift': 'Morning (06:00-14:00)',
      'phone': '+237 6 45 67 89 01',
      'rating': 4.7,
      'tripsToday': 1,
      'conductor': 'Daniel Miller',
      'conductorPhone': '+237 6 56 78 90 12',
      'breakTime': '10:00-10:15',
      'overtime': 0,
      'fuelEfficiency': 90,
    },
    {
      'id': 'D005',
      'name': 'David Brown',
      'license': 'DL-567890',
      'experience': '6 years',
      'status': 'sick_leave',
      'currentRoute': 'Bamenda → Douala',
      'shift': 'Afternoon (14:00-22:00)',
      'phone': '+237 6 56 78 90 12',
      'rating': 4.5,
      'tripsToday': 0,
      'conductor': 'Eva Garcia',
      'conductorPhone': '+237 6 67 89 01 23',
      'breakTime': '18:00-18:15',
      'overtime': 0,
      'fuelEfficiency': 87,
    },
  ];

  final List<Map<String, dynamic>> _conductors = [
    {
      'id': 'C001',
      'name': 'Alice Johnson',
      'employeeId': 'EMP-001',
      'experience': '3 years',
      'status': 'on_duty',
      'currentRoute': 'Douala → Yaoundé',
      'shift': 'Morning (06:00-14:00)',
      'phone': '+237 6 23 45 67 89',
      'rating': 4.7,
      'tripsToday': 2,
      'driver': 'John Doe',
      'driverPhone': '+237 6 12 34 56 78',
      'breakTime': '10:00-10:15',
      'overtime': 0,
    },
    {
      'id': 'C002',
      'name': 'Bob Williams',
      'employeeId': 'EMP-002',
      'experience': '2 years',
      'status': 'on_duty',
      'currentRoute': 'Douala → Yaoundé',
      'shift': 'Afternoon (14:00-22:00)',
      'phone': '+237 6 34 56 78 90',
      'rating': 4.5,
      'tripsToday': 1,
      'driver': 'Jane Smith',
      'driverPhone': '+237 6 23 45 67 89',
      'breakTime': '16:00-16:15',
      'overtime': 0,
    },
    {
      'id': 'C003',
      'name': 'Carol Davis',
      'employeeId': 'EMP-003',
      'experience': '4 years',
      'status': 'off_duty',
      'currentRoute': 'Douala → Yaoundé',
      'shift': 'Night (22:00-06:00)',
      'phone': '+237 6 45 67 89 01',
      'rating': 4.8,
      'tripsToday': 0,
      'driver': 'Mike Johnson',
      'driverPhone': '+237 6 34 56 78 90',
      'breakTime': '02:00-02:15',
      'overtime': 0,
    },
    {
      'id': 'C004',
      'name': 'Daniel Miller',
      'employeeId': 'EMP-004',
      'experience': '1 year',
      'status': 'on_break',
      'currentRoute': 'Yaoundé → Bamenda',
      'shift': 'Morning (06:00-14:00)',
      'phone': '+237 6 56 78 90 12',
      'rating': 4.3,
      'tripsToday': 1,
      'driver': 'Sarah Wilson',
      'driverPhone': '+237 6 45 67 89 01',
      'breakTime': '10:00-10:15',
      'overtime': 0,
    },
    {
      'id': 'C005',
      'name': 'Eva Garcia',
      'employeeId': 'EMP-005',
      'experience': '5 years',
      'status': 'vacation',
      'currentRoute': 'Bamenda → Douala',
      'shift': 'Afternoon (14:00-22:00)',
      'phone': '+237 6 67 89 01 23',
      'rating': 4.6,
      'tripsToday': 0,
      'driver': 'David Brown',
      'driverPhone': '+237 6 56 78 90 12',
      'breakTime': '18:00-18:15',
      'overtime': 0,
    },
  ];

  final List<Map<String, dynamic>> _buses = [
    {
      'id': 'B001',
      'plateNumber': 'CM-1234-AB',
      'model': 'Mercedes Sprinter',
      'capacity': 70,
      'status': 'active',
      'currentRoute': 'Douala → Yaoundé',
      'driver': 'John Doe',
      'conductor': 'Alice Johnson',
      'lastMaintenance': '2025-01-10',
      'nextMaintenance': '2025-02-10',
    },
    {
      'id': 'B002',
      'plateNumber': 'CM-5678-CD',
      'model': 'Toyota Coaster',
      'capacity': 70,
      'status': 'active',
      'currentRoute': 'Douala → Yaoundé',
      'driver': 'Jane Smith',
      'conductor': 'Bob Williams',
      'lastMaintenance': '2025-01-08',
      'nextMaintenance': '2025-02-08',
    },
    {
      'id': 'B003',
      'plateNumber': 'CM-9012-EF',
      'model': 'Isuzu NPR',
      'capacity': 70,
      'status': 'maintenance',
      'currentRoute': 'Douala → Bafoussam',
      'driver': 'Lisa Davis',
      'conductor': 'Carol Davis',
      'lastMaintenance': '2025-01-15',
      'nextMaintenance': '2025-02-15',
    },
  ];

  final List<Map<String, dynamic>> _todaySchedule = [
    {
      'id': 'S001',
      'route': 'Douala → Yaoundé',
      'departureTime': '08:30',
      'arrivalTime': '12:45',
      'driver': 'John Doe',
      'bus': 'CM-1234-AB',
      'status': 'On Time',
      'passengers': 22,
      'delay': 0,
    },
    {
      'id': 'S002',
      'route': 'Yaoundé → Bamenda',
      'departureTime': '10:15',
      'arrivalTime': '15:45',
      'driver': 'Sarah Wilson',
      'bus': 'CM-5678-CD',
      'status': 'Delayed',
      'passengers': 18,
      'delay': 15,
    },
    {
      'id': 'S003',
      'route': 'Douala → Bafoussam',
      'departureTime': '14:00',
      'arrivalTime': '17:45',
      'driver': 'Lisa Davis',
      'bus': 'CM-9012-EF',
      'status': 'Cancelled',
      'passengers': 0,
      'delay': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    ThemeNotifier().addListener(_onThemeChanged);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.05),
              backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSegmentedControl(),
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GlobalBottomNavigation(
        initialIndex: 2, // My Tickets tab
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back,
                color: textColor,
                size: 5.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule Management',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  'Manage routes, drivers & schedules',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: onSurfaceVariantColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: onSurfaceVariantColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () => _showNotifications(),
              icon: Icon(
                Icons.notifications,
                color: onSurfaceVariantColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      padding: EdgeInsets.all(0.5.w),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = _selectedTab == index;

            return Container(
              margin: EdgeInsets.only(right: 1.w),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedTab = index;
                  });
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tab,
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      color: isSelected
                          ? Colors.white
                          : textColor.withOpacity(0.7),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildScheduleOverview();
      case 1:
        return _buildRouteManagement();
      case 2:
        return _buildBusManagement();
      case 3:
        return _buildDriverAndConductor();
      case 4:
        return _buildRealTimeControl();
      case 5:
        return _buildPerformanceAnalysis();
      default:
        return _buildScheduleOverview();
    }
  }

  Widget _buildScheduleOverview() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(3.w),
          child: Column(
            children: [
              _buildStatsCards(),
              SizedBox(height: 2.h),
              _buildTodaySchedule(),
              SizedBox(height: 2.h),
              _buildUpcomingSchedules(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Overview',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Active Routes', '3', Icons.route, Colors.blue),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                    'Scheduled Trips', '12', Icons.schedule, Colors.green),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Drivers On Duty', '4', Icons.person, Colors.orange),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard('Delays', '1', Icons.warning, Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(1.5.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 4.w,
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 8.sp,
              color: textColor.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Schedule',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              TextButton(
                onPressed: () => _showScheduleDetails(),
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ..._todaySchedule
              .map((schedule) => _buildScheduleItem(schedule))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> schedule) {
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;

    switch (schedule['status']) {
      case 'On Time':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Delayed':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule['route'],
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${schedule['departureTime']} - ${schedule['arrivalTime']}',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
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
                      schedule['status'],
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildScheduleDetail(
                    'Driver', schedule['driver'], Icons.person),
              ),
              Expanded(
                child: _buildScheduleDetail(
                    'Bus', schedule['bus'], Icons.directions_bus),
              ),
              Expanded(
                child: _buildScheduleDetail(
                    'Passengers', '${schedule['passengers']}', Icons.people),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 3.w,
          color: textColor.withOpacity(0.6),
        ),
        SizedBox(width: 1.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 8.sp,
                  color: textColor.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingSchedules() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Schedules',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              TextButton(
                onPressed: () => _showUpcomingSchedules(),
                child: Text(
                  'Manage',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Tomorrow\'s routes and schedules will be displayed here.',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: textColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteManagement() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(3.w),
          child: Column(
            children: [
              _buildRouteStats(),
              SizedBox(height: 2.h),
              _buildRoutesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteStats() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route Status Overview',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Routes', '${_routes.length}',
                    Icons.route, Colors.purple),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                    'Active',
                    '${_routes.where((r) => r['status'] == 'active').length}',
                    Icons.check_circle,
                    Colors.green),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Inactive',
                    '${_routes.where((r) => r['status'] == 'inactive').length}',
                    Icons.pause_circle,
                    Colors.orange),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                    'Maintenance',
                    '${_routes.where((r) => r['status'] == 'maintenance').length}',
                    Icons.build,
                    Colors.blue),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Suspended',
                    '${_routes.where((r) => r['status'] == 'suspended').length}',
                    Icons.block,
                    Colors.red),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Container(), // Empty space for layout balance
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesList() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Route Definitions',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateRouteDialog(),
                icon: Icon(Icons.add, size: 4.w),
                label: Text(
                  'New Route',
                  style: GoogleFonts.inter(fontSize: 10.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ..._routes.map((route) => _buildRouteCard(route)).toList(),
        ],
      ),
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route) {
    // Get status color from the dropdown options
    String currentStatus = route['status'] ?? 'active';
    Map<String, dynamic> statusOption = _routeStatusOptions.firstWhere(
      (option) => option['value'] == currentStatus,
      orElse: () => _routeStatusOptions.first,
    );
    Color statusColor = statusOption['color'];

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route['name'],
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${route['distance']} • ${route['duration']}',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusOption['label'],
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildRouteDetail(
                    'Distance', route['distance'], Icons.straighten),
              ),
              Expanded(
                child: _buildRouteDetail(
                    'Duration', route['duration'], Icons.schedule),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _editRoute(route),
                  icon: Icon(Icons.edit, size: 3.w),
                  label: Text('Edit Route',
                      style: GoogleFonts.inter(fontSize: 9.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    foregroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildRouteStatusDropdown(route),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 3.w,
          color: textColor.withOpacity(0.6),
        ),
        SizedBox(width: 1.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 8.sp,
                  color: textColor.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverAndConductor() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Sub-tab headers
            Container(
              margin: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: borderColor.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentSubTab = 0),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        decoration: BoxDecoration(
                          color: _currentSubTab == 0
                              ? primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Drivers',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                _currentSubTab == 0 ? Colors.white : textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentSubTab = 1),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        decoration: BoxDecoration(
                          color: _currentSubTab == 1
                              ? primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Conductors',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                _currentSubTab == 1 ? Colors.white : textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Sub-tab content
            Expanded(
              child: _currentSubTab == 0
                  ? _buildDriversTab()
                  : _buildConductorsTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriversTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(3.w),
      child: Column(
        children: [
          _buildDriverStatusOverview(),
          SizedBox(height: 2.h),
          _buildDriversList(),
        ],
      ),
    );
  }

  Widget _buildConductorsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(3.w),
      child: Column(
        children: [
          _buildConductorStatusOverview(),
          SizedBox(height: 2.h),
          _buildConductorsList(),
        ],
      ),
    );
  }

  Widget _buildDriverStatusOverview() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Driver Status Overview',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddDriverSheet(),
                icon: Icon(Icons.person_add, size: 3.w),
                label: Text(
                  'Add Driver',
                  style: GoogleFonts.inter(fontSize: 9.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Drivers', '${_drivers.length}',
                    Icons.person, Colors.blue),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: _buildStatCard(
                    'On Duty',
                    '${_drivers.where((d) => d['status'] == 'on_duty').length}',
                    Icons.check_circle,
                    Colors.green),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Off Duty',
                    '${_drivers.where((d) => d['status'] == 'off_duty').length}',
                    Icons.pause_circle,
                    Colors.orange),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: _buildStatCard(
                    'On Break',
                    '${_drivers.where((d) => d['status'] == 'on_break').length}',
                    Icons.coffee,
                    Colors.blue),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Sick Leave',
                    '${_drivers.where((d) => d['status'] == 'sick_leave').length}',
                    Icons.sick,
                    Colors.red),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: _buildStatCard(
                    'Vacation',
                    '${_drivers.where((d) => d['status'] == 'vacation').length}',
                    Icons.beach_access,
                    Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConductorStatusOverview() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conductor Status Overview',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddConductorSheet(),
                icon: Icon(Icons.badge, size: 3.w),
                label: Text(
                  'Add Conductor',
                  style: GoogleFonts.inter(fontSize: 9.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Conductors',
                    '${_conductors.length}', Icons.badge, Colors.indigo),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: _buildStatCard(
                    'On Duty',
                    '${_conductors.where((c) => c['status'] == 'on_duty').length}',
                    Icons.check_circle,
                    Colors.green),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Off Duty',
                    '${_conductors.where((c) => c['status'] == 'off_duty').length}',
                    Icons.pause_circle,
                    Colors.orange),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: _buildStatCard(
                    'On Break',
                    '${_conductors.where((c) => c['status'] == 'on_break').length}',
                    Icons.coffee,
                    Colors.blue),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Sick Leave',
                    '${_conductors.where((c) => c['status'] == 'sick_leave').length}',
                    Icons.sick,
                    Colors.red),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: _buildStatCard(
                    'Vacation',
                    '${_conductors.where((c) => c['status'] == 'vacation').length}',
                    Icons.beach_access,
                    Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriversList() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Driver Assignments',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          ..._drivers.map((driver) => _buildDriverCard(driver)).toList(),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    // Get status color from the dropdown options
    String currentStatus = driver['status'] ?? 'on_duty';
    Map<String, dynamic> statusOption = _driverStatusOptions.firstWhere(
      (option) => option['value'] == currentStatus,
      orElse: () => _driverStatusOptions.first,
    );
    Color statusColor = statusOption['color'];

    return GestureDetector(
      onTap: () => _showDriverDetailsOverlay(driver),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver['name'],
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${driver['license']} • ${driver['experience']}',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusOption['label'],
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: _buildDriverDetail(
                      'Route', driver['currentRoute'], Icons.route),
                ),
                Expanded(
                  child: _buildDriverDetail(
                      'Shift', driver['shift'], Icons.schedule),
                ),
                Expanded(
                  child: _buildDriverDetail(
                      'Conductor', driver['conductor'], Icons.badge),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _assignDriver(driver),
                    icon: Icon(Icons.assignment_ind, size: 3.w),
                    label: Text('Assign',
                        style: GoogleFonts.inter(fontSize: 9.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      foregroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 0.5.h),
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

  Widget _buildConductorsList() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conductor Assignments',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          ..._conductors
              .map((conductor) => _buildConductorCard(conductor))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildConductorCard(Map<String, dynamic> conductor) {
    // Get status color from the dropdown options
    String currentStatus = conductor['status'] ?? 'on_duty';
    Map<String, dynamic> statusOption = _conductorStatusOptions.firstWhere(
      (option) => option['value'] == currentStatus,
      orElse: () => _conductorStatusOptions.first,
    );
    Color statusColor = statusOption['color'];

    return GestureDetector(
      onTap: () => _showConductorDetailsOverlay(conductor),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conductor['name'],
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${conductor['employeeId']} • ${conductor['experience']}',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusOption['label'],
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: _buildDriverDetail(
                      'Route', conductor['currentRoute'], Icons.route),
                ),
                Expanded(
                  child: _buildDriverDetail(
                      'Shift', conductor['shift'], Icons.schedule),
                ),
                Expanded(
                  child: _buildDriverDetail(
                      'Driver', conductor['driver'], Icons.person),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _assignConductor(conductor),
                    icon: Icon(Icons.assignment_ind, size: 3.w),
                    label: Text('Assign',
                        style: GoogleFonts.inter(fontSize: 9.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      foregroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 0.5.h),
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

  Widget _buildDriverDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 3.w,
          color: textColor.withOpacity(0.6),
        ),
        SizedBox(width: 1.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 8.sp,
                  color: textColor.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusManagement() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(3.w),
          child: Column(
            children: [
              _buildBusStatusOverview(),
              SizedBox(height: 2.h),
              _buildBusesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusStatusOverview() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bus Status Overview',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddBusSheet(),
                icon: Icon(Icons.add, size: 3.w),
                label: Text(
                  'Add Bus',
                  style: GoogleFonts.inter(fontSize: 9.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Buses', '${_buses.length}',
                    Icons.directions_bus, Colors.purple),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: _buildStatCard(
                    'Active',
                    '${_buses.where((b) => b['status'] == 'active').length}',
                    Icons.check_circle,
                    Colors.green),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Inactive',
                    '${_buses.where((b) => b['status'] == 'inactive').length}',
                    Icons.pause_circle,
                    Colors.orange),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: _buildStatCard(
                    'Maintenance',
                    '${_buses.where((b) => b['status'] == 'maintenance').length}',
                    Icons.build,
                    Colors.blue),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Suspended',
                    '${_buses.where((b) => b['status'] == 'suspended').length}',
                    Icons.block,
                    Colors.red),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: _buildStatCard(
                    'Total Capacity', '70', Icons.people, Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusesList() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bus Fleet',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          ..._buses.map((bus) => _buildBusCard(bus)).toList(),
        ],
      ),
    );
  }

  Widget _buildBusCard(Map<String, dynamic> bus) {
    // Get status color from the dropdown options
    String currentStatus = bus['status'] ?? 'active';
    Map<String, dynamic> statusOption = _routeStatusOptions.firstWhere(
      (option) => option['value'] == currentStatus,
      orElse: () => _routeStatusOptions.first,
    );
    Color statusColor = statusOption['color'];

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus['plateNumber'],
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${bus['model']} • 70 seats',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusOption['label'],
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildBusDetail('Driver', bus['driver'], Icons.person),
              ),
              Expanded(
                child:
                    _buildBusDetail('Route', bus['currentRoute'], Icons.route),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            children: [
              Expanded(
                child:
                    _buildBusDetail('Conductor', bus['conductor'], Icons.badge),
              ),
              Expanded(
                child: Container(), // Empty space for alignment
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _editBus(bus),
                  icon: Icon(Icons.edit, size: 3.w),
                  label: Text('Edit', style: GoogleFonts.inter(fontSize: 9.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    foregroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildBusStatusDropdown(bus),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 3.w,
          color: textColor.withOpacity(0.6),
        ),
        SizedBox(width: 1.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 8.sp,
                  color: textColor.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRealTimeControl() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(3.w),
          child: Column(
            children: [
              _buildRealTimeStats(),
              SizedBox(height: 2.h),
              _buildActiveDelays(),
              SizedBox(height: 2.h),
              _buildEmergencyControls(),
              SizedBox(height: 2.h),
              _buildCommunicationCenter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealTimeStats() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real-time Operations',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Active Trips', '8', Icons.directions_bus, Colors.blue),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child:
                    _buildStatCard('Delays', '2', Icons.warning, Colors.orange),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'On Time', '6', Icons.check_circle, Colors.green),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                    'Emergencies', '0', Icons.emergency, Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDelays() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Delays & Issues',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _handleAllDelays(),
                icon: Icon(Icons.refresh, size: 4.w),
                label: Text(
                  'Resolve All',
                  style: GoogleFonts.inter(fontSize: 10.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildDelayItem('Bus CM-5678-CD', 'Yaoundé → Bamenda', '15 min delay',
              'Traffic jam', Colors.orange),
          _buildDelayItem('Bus CM-1234-AB', 'Douala → Yaoundé', '5 min delay',
              'Passenger loading', Colors.amber),
        ],
      ),
    );
  }

  Widget _buildDelayItem(
      String bus, String route, String delay, String reason, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: color,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$bus - $route',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  '$delay • $reason',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _resolveDelay(bus),
            child: Text(
              'Resolve',
              style: GoogleFonts.inter(fontSize: 9.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color.withOpacity(0.1),
              foregroundColor: color,
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyControls() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Controls',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _emergencyStop(),
                  icon: Icon(Icons.stop, size: 4.w),
                  label: Text(
                    'Emergency Stop',
                    style: GoogleFonts.inter(fontSize: 10.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendAlert(),
                  icon: Icon(Icons.notification_important, size: 4.w),
                  label: Text(
                    'Send Alert',
                    style: GoogleFonts.inter(fontSize: 10.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rerouteBus(),
                  icon: Icon(Icons.route, size: 4.w),
                  label: Text(
                    'Reroute Bus',
                    style: GoogleFonts.inter(fontSize: 10.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _contactEmergency(),
                  icon: Icon(Icons.phone, size: 4.w),
                  label: Text(
                    'Call Emergency',
                    style: GoogleFonts.inter(fontSize: 10.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationCenter() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Communication Center',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _broadcastMessage(),
                  icon: Icon(Icons.broadcast_on_home, size: 4.w),
                  label: Text(
                    'Broadcast',
                    style: GoogleFonts.inter(fontSize: 10.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updatePassengers(),
                  icon: Icon(Icons.people, size: 4.w),
                  label: Text(
                    'Update Passengers',
                    style: GoogleFonts.inter(fontSize: 10.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceAnalysis() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(3.w),
          child: Column(
            children: [
              _buildPerformanceStats(),
              SizedBox(height: 2.h),
              _buildPerformanceCharts(),
              SizedBox(height: 2.h),
              _buildPerformanceReports(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceStats() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'On-Time Rate', '85%', Icons.schedule, Colors.green),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                    'Customer Rating', '4.7', Icons.star, Colors.amber),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Fuel Efficiency', '92%',
                    Icons.local_gas_station, Colors.blue),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                    'Maintenance Cost', 'Low', Icons.build, Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCharts() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Charts',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 20.h,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor.withOpacity(0.1),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 8.w,
                    color: primaryColor.withOpacity(0.3),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Performance Charts',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Charts and analytics will be displayed here',
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceReports() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance Reports',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _generateReport(),
                icon: Icon(Icons.download, size: 4.w),
                label: Text(
                  'Generate',
                  style: GoogleFonts.inter(fontSize: 10.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildReportItem(
              'Daily Performance Report', '2025-01-15', Icons.today),
          _buildReportItem(
              'Weekly Route Analysis', '2025-01-08', Icons.calendar_view_week),
          _buildReportItem(
              'Monthly Fleet Report', '2024-12-01', Icons.calendar_month),
        ],
      ),
    );
  }

  Widget _buildReportItem(String title, String date, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 5.w,
            color: primaryColor,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _downloadReport(title),
            icon: Icon(
              Icons.download,
              size: 4.w,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Schedule'),
        content:
            Text('Schedule creation functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Schedule details functionality')),
    );
  }

  void _showUpcomingSchedules() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Upcoming schedules management')),
    );
  }

  void _showCreateRouteDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCreateRouteSheet(),
    );
  }

  Widget _buildCreateRouteSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(3.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create New Route',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: textColor,
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: _buildRouteForm(),
            ),
          ),

          // Bottom buttons
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(
                  color: borderColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      foregroundColor: textColor,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _createRoute(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Create Route',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditRouteSheet(Map<String, dynamic> route) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(3.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Route',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: textColor,
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: _buildEditRouteForm(route),
            ),
          ),

          // Bottom buttons
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(
                  color: borderColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      foregroundColor: textColor,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateRoute(route),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Update Route',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Origin and Destination (these will form the route name)
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Origin',
                hint: 'Select origin',
                icon: Icons.location_on,
                items: [
                  'Douala',
                  'Yaoundé',
                  'Bamenda',
                  'Bafoussam',
                  'Garoua',
                  'Maroua',
                  'Ngaoundéré',
                  'Bertoua'
                ],
                onChanged: (value) => _selectOrigin(value),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildDropdownField(
                label: 'Destination',
                hint: 'Select destination',
                icon: Icons.location_on,
                items: [
                  'Douala',
                  'Yaoundé',
                  'Bamenda',
                  'Bafoussam',
                  'Garoua',
                  'Maroua',
                  'Ngaoundéré',
                  'Bertoua'
                ],
                onChanged: (value) => _selectDestination(value),
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Distance and Duration
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                label: 'Distance',
                hint: 'e.g., 245 km',
                icon: Icons.straighten,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildFormField(
                label: 'Duration',
                hint: 'e.g., 4h 15m',
                icon: Icons.schedule,
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Stop Duration
        _buildFormField(
          label: 'Stop Duration',
          hint: 'e.g., 30 minutes (for eating, restroom, etc.)',
          icon: Icons.timer,
        ),

        SizedBox(height: 2.h),

        // Stops Section
        Text(
          'Route Stops',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: 1.h),

        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              _buildStopItem('Makenene', false),
            ],
          ),
        ),

        SizedBox(height: 3.h),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    String? initialValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: 0.5.h),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor.withOpacity(0.1),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: initialValue,
            hint: Text(
              hint,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: textColor.withOpacity(0.5),
              ),
            ),
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: textColor,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: primaryColor,
                size: 4.w,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(2.w),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: textColor,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: 0.5.h),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor.withOpacity(0.1),
            ),
          ),
          child: TextField(
            maxLines: maxLines,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 11.sp,
                color: textColor.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                icon,
                color: primaryColor,
                size: 4.w,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(2.w),
            ),
          ),
        ),
      ],
    );
  }

  void _selectOrigin(String? value) {
    if (value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected origin: $value')),
      );
    }
  }

  void _selectDestination(String? value) {
    if (value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected destination: $value')),
      );
    }
  }

  Widget _buildStopItem(String stopName, bool isTerminal) {
    return Container(
      margin: EdgeInsets.only(bottom: 0.5.h),
      padding: EdgeInsets.all(1.5.w),
      decoration: BoxDecoration(
        color: isTerminal ? primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isTerminal
              ? primaryColor.withOpacity(0.3)
              : borderColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isTerminal ? Icons.flag : Icons.location_on,
            color: isTerminal ? primaryColor : textColor.withOpacity(0.6),
            size: 3.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              stopName,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: isTerminal ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          if (!isTerminal)
            IconButton(
              onPressed: () => _removeStop(stopName),
              icon: Icon(
                Icons.close,
                color: Colors.red,
                size: 3.w,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRouteTypeChip(String type, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectRouteType(type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          type,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : textColor,
          ),
        ),
      ),
    );
  }

  void _createRoute() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Route created successfully!')),
    );
  }

  Widget _buildEditRouteForm(Map<String, dynamic> route) {
    // Parse route name to get origin and destination
    String routeName = route['name'] ?? '';
    List<String> parts = routeName.split(' → ');
    String origin = parts.length > 0 ? parts[0] : '';
    String destination = parts.length > 1 ? parts[1] : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Origin and Destination (these will form the route name)
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Origin',
                hint: 'Select origin',
                icon: Icons.location_on,
                items: [
                  'Douala',
                  'Yaoundé',
                  'Bamenda',
                  'Bafoussam',
                  'Garoua',
                  'Maroua',
                  'Ngaoundéré',
                  'Bertoua'
                ],
                initialValue: origin,
                onChanged: (value) => _selectOrigin(value),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildDropdownField(
                label: 'Destination',
                hint: 'Select destination',
                icon: Icons.location_on,
                items: [
                  'Douala',
                  'Yaoundé',
                  'Bamenda',
                  'Bafoussam',
                  'Garoua',
                  'Maroua',
                  'Ngaoundéré',
                  'Bertoua'
                ],
                initialValue: destination,
                onChanged: (value) => _selectDestination(value),
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Distance and Duration
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                label: 'Distance',
                hint: route['distance'] ?? 'e.g., 245 km',
                icon: Icons.straighten,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildFormField(
                label: 'Duration',
                hint: route['duration'] ?? 'e.g., 4h 15m',
                icon: Icons.schedule,
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Stop Duration
        _buildFormField(
          label: 'Stop Duration',
          hint: 'e.g., 30 minutes (for eating, restroom, etc.)',
          icon: Icons.timer,
        ),

        SizedBox(height: 2.h),

        // Stops Section
        Text(
          'Route Stops',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: 1.h),

        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              _buildStopItem('Makenene', false),
            ],
          ),
        ),

        SizedBox(height: 3.h),
      ],
    );
  }

  void _updateRoute(Map<String, dynamic> route) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Route "${route['name']}" updated successfully!')),
    );
  }

  void _addStop() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Add stop functionality would be implemented here')),
    );
  }

  void _removeStop(String stopName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removing stop: $stopName')),
    );
  }

  void _selectRouteType(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected route type: $type')),
    );
  }

  void _editRoute(Map<String, dynamic> route) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEditRouteSheet(route),
    );
  }

  void _optimizeRoute(Map<String, dynamic> route) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Optimizing route: ${route['name']}')),
    );
  }

  Widget _buildRouteStatusDropdown(Map<String, dynamic> route) {
    // Get current status or default to 'active'
    String currentStatus = route['status'] ?? 'active';
    Map<String, dynamic> currentStatusOption = _routeStatusOptions.firstWhere(
      (option) => option['value'] == currentStatus,
      orElse: () => _routeStatusOptions.first,
    );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: textColor,
            size: 4.w,
          ),
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            color: textColor,
          ),
          items: _routeStatusOptions.map((Map<String, dynamic> option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Row(
                children: [
                  Icon(
                    option['icon'],
                    color: option['color'],
                    size: 3.w,
                  ),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      option['label'],
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              _updateRouteStatus(route, newValue);
            }
          },
        ),
      ),
    );
  }

  void _updateRouteStatus(Map<String, dynamic> route, String newStatus) {
    setState(() {
      route['status'] = newStatus;
    });

    Map<String, dynamic> statusOption = _routeStatusOptions.firstWhere(
      (option) => option['value'] == newStatus,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Route "${route['name']}" status changed to ${statusOption['label']}',
        ),
        backgroundColor: statusOption['color'],
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _createScheduleForRoute(Map<String, dynamic> route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Schedule'),
        content: Text('Create a new schedule for route: ${route['name']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Opening schedule creation for ${route['name']}')),
              );
            },
            child: Text('Create Schedule'),
          ),
        ],
      ),
    );
  }

  void _showAddDriverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Driver'),
        content: Text(
            'Driver registration functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _assignDriver(Map<String, dynamic> driver) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assigning driver: ${driver['name']}')),
    );
  }

  void _assignConductor(Map<String, dynamic> conductor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assigning conductor: ${conductor['name']}')),
    );
  }

  void _viewDriverDetails(Map<String, dynamic> driver) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for: ${driver['name']}')),
    );
  }

  Widget _buildBusStatusDropdown(Map<String, dynamic> bus) {
    // Get current status or default to 'active'
    String currentStatus = bus['status'] ?? 'active';
    Map<String, dynamic> currentStatusOption = _routeStatusOptions.firstWhere(
      (option) => option['value'] == currentStatus,
      orElse: () => _routeStatusOptions.first,
    );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: textColor,
            size: 4.w,
          ),
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            color: textColor,
          ),
          items: _routeStatusOptions.map((Map<String, dynamic> option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Row(
                children: [
                  Icon(
                    option['icon'],
                    color: option['color'],
                    size: 3.w,
                  ),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      option['label'],
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              _updateBusStatus(bus, newValue);
            }
          },
        ),
      ),
    );
  }

  void _updateBusStatus(Map<String, dynamic> bus, String newStatus) {
    setState(() {
      bus['status'] = newStatus;
    });

    Map<String, dynamic> statusOption = _routeStatusOptions.firstWhere(
      (option) => option['value'] == newStatus,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bus "${bus['plateNumber']}" status changed to ${statusOption['label']}',
        ),
        backgroundColor: statusOption['color'],
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editBus(Map<String, dynamic> bus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEditBusSheet(bus),
    );
  }

  void _showAddBusSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddBusSheet(),
    );
  }

  Widget _buildAddBusSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(3.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Bus',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: textColor,
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: _buildBusForm(),
            ),
          ),

          // Bottom buttons
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(
                  color: borderColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      foregroundColor: textColor,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _createBus(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Add Bus',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plate Number and Model
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                label: 'Plate Number',
                hint: 'e.g., CM-1234-AB',
                icon: Icons.confirmation_number,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildDropdownField(
                label: 'Model',
                hint: 'Select model',
                icon: Icons.directions_bus,
                items: _busModelOptions,
                onChanged: (value) => _selectBusModel(value),
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Capacity and Status
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                label: 'Capacity',
                hint: '70',
                icon: Icons.people,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildDropdownField(
                label: 'Status',
                hint: 'Select status',
                icon: Icons.info,
                items: ['active', 'inactive', 'maintenance', 'suspended'],
                onChanged: (value) => _selectBusStatus(value),
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Driver and Route
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Driver',
                hint: 'Select driver',
                icon: Icons.person,
                items: _driverOptions,
                onChanged: (value) => _selectBusDriver(value),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildDropdownField(
                label: 'Current Route',
                hint: 'Select route',
                icon: Icons.route,
                items: _routeOptions,
                onChanged: (value) => _selectBusRoute(value),
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Conductor
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Conductor',
                hint: 'Select conductor',
                icon: Icons.badge,
                items: _conductorOptions,
                onChanged: (value) => _selectBusConductor(value),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Container(), // Empty space for alignment
            ),
          ],
        ),

        SizedBox(height: 3.h),
      ],
    );
  }

  void _selectBusStatus(String? value) {
    if (value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected bus status: $value')),
      );
    }
  }

  void _createBus() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bus added successfully!')),
    );
  }

  Widget _buildEditBusSheet(Map<String, dynamic> bus) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(3.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Bus',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: textColor,
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: _buildEditBusForm(bus),
            ),
          ),

          // Bottom buttons
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(
                  color: borderColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      foregroundColor: textColor,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateBus(bus),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Update Bus',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditBusForm(Map<String, dynamic> bus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plate Number and Model
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                label: 'Plate Number',
                hint: bus['plateNumber'] ?? 'e.g., CM-1234-AB',
                icon: Icons.confirmation_number,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildDropdownField(
                label: 'Model',
                hint: 'Select model',
                icon: Icons.directions_bus,
                items: _busModelOptions,
                initialValue: bus['model'],
                onChanged: (value) => _selectBusModel(value),
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Capacity and Status
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                label: 'Capacity',
                hint: '70',
                icon: Icons.people,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildDropdownField(
                label: 'Status',
                hint: 'Select status',
                icon: Icons.info,
                items: ['active', 'inactive', 'maintenance', 'suspended'],
                initialValue: bus['status'],
                onChanged: (value) => _selectBusStatus(value),
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Driver and Route
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Driver',
                hint: 'Select driver',
                icon: Icons.person,
                items: _driverOptions,
                initialValue: bus['driver'],
                onChanged: (value) => _selectBusDriver(value),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildDropdownField(
                label: 'Current Route',
                hint: 'Select route',
                icon: Icons.route,
                items: _routeOptions,
                initialValue: bus['currentRoute'],
                onChanged: (value) => _selectBusRoute(value),
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Conductor
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Conductor',
                hint: 'Select conductor',
                icon: Icons.badge,
                items: _conductorOptions,
                initialValue: bus['conductor'],
                onChanged: (value) => _selectBusConductor(value),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Container(), // Empty space for alignment
            ),
          ],
        ),

        SizedBox(height: 3.h),
      ],
    );
  }

  void _selectBusModel(String? value) {
    setState(() {
      // Handle model selection
    });
  }

  void _selectBusDriver(String? value) {
    setState(() {
      // Handle driver selection
    });
  }

  void _selectBusRoute(String? value) {
    setState(() {
      // Handle route selection
    });
  }

  void _selectBusConductor(String? value) {
    setState(() {
      // Handle conductor selection
    });
  }

  void _updateBus(Map<String, dynamic> bus) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Bus "${bus['plateNumber']}" updated successfully!')),
    );
  }

  void _assignBus(Map<String, dynamic> bus) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assigning bus: ${bus['plateNumber']}')),
    );
  }

  void _scheduleMaintenance(Map<String, dynamic> bus) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Scheduling maintenance for: ${bus['plateNumber']}')),
    );
  }

  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generating performance report...')),
    );
  }

  void _downloadReport(String reportName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading: $reportName')),
    );
  }

  // Real-time Control Action Methods
  void _handleAllDelays() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Resolving all delays...')),
    );
  }

  void _resolveDelay(String bus) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Resolving delay for $bus')),
    );
  }

  void _emergencyStop() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency Stop'),
        content: Text(
            'Are you sure you want to initiate emergency stop for all buses?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Emergency stop initiated!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Stop All Buses'),
          ),
        ],
      ),
    );
  }

  void _sendAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sending alert to all drivers and conductors...')),
    );
  }

  void _rerouteBus() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening bus rerouting interface...')),
    );
  }

  void _contactEmergency() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contacting emergency services...')),
    );
  }

  void _broadcastMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening broadcast message interface...')),
    );
  }

  void _updatePassengers() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updating passenger notifications...')),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationItem('Route Delay',
                'Bamenda → Yaoundé is 15 minutes late', Colors.orange),
            _buildNotificationItem(
                'Maintenance Due', 'Bus CM-1234-AB needs service', Colors.blue),
            _buildNotificationItem(
                'Driver Alert', 'John Doe completed his shift', Colors.green),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('All notifications marked as read')),
              );
            },
            child: Text('Mark All Read'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: color,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDriverDetailsOverlay(Map<String, dynamic> driver) {
    // Get current status info
    String currentStatus = driver['status'] ?? 'on_duty';
    Map<String, dynamic> statusOption = _driverStatusOptions.firstWhere(
      (option) => option['value'] == currentStatus,
      orElse: () => _driverStatusOptions.first,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 90.w,
            constraints: BoxConstraints(maxHeight: 80.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            Icon(Icons.person, color: Colors.white, size: 4.w),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver['name'],
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'Driver • ${driver['license']}',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: textColor, size: 4.w),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: statusOption['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: statusOption['color'].withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(statusOption['icon'],
                                  color: statusOption['color'], size: 3.w),
                              SizedBox(width: 1.w),
                              Text(
                                statusOption['label'],
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  color: statusOption['color'],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '${driver['rating']}/5',
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  color: textColor.withOpacity(0.7),
                                ),
                              ),
                              Icon(Icons.star, color: Colors.amber, size: 3.w),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Basic Info Grid
                        _buildInfoGrid([
                          {
                            'label': 'Experience',
                            'value': driver['experience'],
                            'icon': Icons.work
                          },
                          {
                            'label': 'Phone',
                            'value': driver['phone'],
                            'icon': Icons.phone
                          },
                          {
                            'label': 'Trips Today',
                            'value': '${driver['tripsToday']}',
                            'icon': Icons.directions_bus
                          },
                          {
                            'label': 'Passengers',
                            'value': '${driver['passengersServed'] ?? 120}',
                            'icon': Icons.people
                          },
                        ]),

                        SizedBox(height: 2.h),

                        // Current Assignment Section
                        if (currentStatus == 'on_duty') ...[
                          _buildSectionHeader(
                              'Current Assignment', Icons.assignment),
                          SizedBox(height: 1.h),
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: borderColor.withOpacity(0.2)),
                            ),
                            child: Column(
                              children: [
                                _buildAssignmentRow(
                                    'Bus',
                                    'Bus ${driver['busNumber'] ?? 'B001'} (${driver['busModel'] ?? 'Toyota Coaster'})',
                                    Icons.directions_bus),
                                _buildAssignmentRow('Route',
                                    driver['currentRoute'], Icons.route),
                                _buildAssignmentRow(
                                    'Date',
                                    driver['currentDate'] ?? 'January 15, 2025',
                                    Icons.calendar_today),
                                _buildAssignmentRow('Conductor',
                                    driver['conductor'], Icons.badge),
                                _buildAssignmentRow(
                                    'Shift', driver['shift'], Icons.schedule),
                                _buildAssignmentRow(
                                    'Departure',
                                    driver['departureTime'] ?? '08:00 AM',
                                    Icons.schedule),
                                _buildAssignmentRow(
                                    'Arrival',
                                    driver['arrivalTime'] ?? '12:00 PM',
                                    Icons.schedule),
                                _buildAssignmentRow(
                                    'Capacity',
                                    '${driver['currentPassengers'] ?? 45}/${driver['busCapacity'] ?? 70}',
                                    Icons.people),
                                _buildAssignmentRow(
                                    'Next Trip',
                                    driver['nextTrip'] ?? '02:00 PM',
                                    Icons.schedule),
                              ],
                            ),
                          ),
                        ] else ...[
                          _buildSectionHeader('Status Details', Icons.info),
                          SizedBox(height: 1.h),
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: borderColor.withOpacity(0.2)),
                            ),
                            child: Column(
                              children: [
                                if (currentStatus == 'on_break') ...[
                                  _buildAssignmentRow('Break Duration',
                                      '30 minutes', Icons.timer),
                                  _buildAssignmentRow(
                                      'Resume Time',
                                      driver['resumeTime'] ?? '10:30 AM',
                                      Icons.schedule),
                                ],
                                if (currentStatus == 'vacation') ...[
                                  _buildAssignmentRow(
                                      'Vacation End',
                                      driver['vacationEnd'] ?? 'Jan 15, 2025',
                                      Icons.calendar_today),
                                ],
                                if (currentStatus == 'sick_leave') ...[
                                  _buildAssignmentRow(
                                      'Expected Return',
                                      driver['expectedReturn'] ??
                                          'Jan 10, 2025',
                                      Icons.healing),
                                ],
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 2.h),

                        // Trip Information Section
                        if (currentStatus == 'on_duty') ...[
                          _buildSectionHeader(
                              'Next Trip Information', Icons.schedule),
                          SizedBox(height: 1.h),
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: borderColor.withOpacity(0.2)),
                            ),
                            child: Column(
                              children: [
                                _buildAssignmentRow(
                                    'Bus',
                                    'Bus ${driver['nextBusNumber'] ?? 'B002'} (${driver['nextBusModel'] ?? 'Toyota Coaster'})',
                                    Icons.directions_bus),
                                _buildAssignmentRow(
                                    'Next Route',
                                    driver['nextRoute'] ?? 'Yaoundé → Douala',
                                    Icons.route),
                                _buildAssignmentRow(
                                    'Date',
                                    driver['nextDate'] ?? 'January 15, 2025',
                                    Icons.calendar_today),
                                _buildAssignmentRow(
                                    'Shift',
                                    driver['nextShift'] ??
                                        'Afternoon (14:00-22:00)',
                                    Icons.schedule),
                                _buildAssignmentRow(
                                    'Departure Time',
                                    driver['nextDeparture'] ?? '02:00 PM',
                                    Icons.schedule),
                                _buildAssignmentRow(
                                    'Expected Arrival',
                                    driver['nextArrival'] ?? '06:00 PM',
                                    Icons.schedule),
                                _buildAssignmentRow(
                                    'Conductor',
                                    driver['nextConductor'] ?? 'Sarah Wilson',
                                    Icons.badge),
                                _buildAssignmentRow(
                                    'Available Seats',
                                    '${driver['nextAvailableSeats'] ?? 25}/70',
                                    Icons.people),
                              ],
                            ),
                          ),
                        ] else ...[
                          _buildSectionHeader(
                              'Trip History & Schedule', Icons.history),
                          SizedBox(height: 1.h),
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: borderColor.withOpacity(0.2)),
                            ),
                            child: Column(
                              children: [
                                // Previous Trip Info
                                if (driver['lastTrip'] != null) ...[
                                  Row(
                                    children: [
                                      Icon(Icons.history,
                                          color: primaryColor, size: 3.w),
                                      SizedBox(width: 1.w),
                                      Text(
                                        'Last Trip',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 0.5.h),
                                  _buildAssignmentRow(
                                      'Route',
                                      driver['lastTrip']['route'] ??
                                          'Douala → Yaoundé',
                                      Icons.route),
                                  _buildAssignmentRow(
                                      'Completed',
                                      driver['lastTrip']['completed'] ??
                                          '12:00 PM',
                                      Icons.check_circle),
                                  _buildAssignmentRow(
                                      'Passengers',
                                      '${driver['lastTrip']['passengers'] ?? 65}',
                                      Icons.people),
                                  SizedBox(height: 1.h),
                                ],
                                // Next Trip Info
                                if (driver['nextTrip'] != null) ...[
                                  Row(
                                    children: [
                                      Icon(Icons.schedule,
                                          color: primaryColor, size: 3.w),
                                      SizedBox(width: 1.w),
                                      Text(
                                        'Next Trip',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 0.5.h),
                                  _buildAssignmentRow(
                                      'Route',
                                      driver['nextTrip']['route'] ??
                                          'Yaoundé → Douala',
                                      Icons.route),
                                  _buildAssignmentRow(
                                      'Scheduled Time',
                                      driver['nextTrip']['time'] ?? '02:00 PM',
                                      Icons.schedule),
                                  _buildAssignmentRow(
                                      'Bus',
                                      'Bus ${driver['nextTrip']['bus'] ?? 'B002'}',
                                      Icons.directions_bus),
                                ] else ...[
                                  Row(
                                    children: [
                                      Icon(Icons.info,
                                          color: Colors.orange, size: 3.w),
                                      SizedBox(width: 1.w),
                                      Text(
                                        'No upcoming trips scheduled',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.sp,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Footer Actions
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    border: Border(
                        top: BorderSide(color: borderColor.withOpacity(0.2))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _assignDriver(driver);
                          },
                          icon: Icon(Icons.assignment_ind, size: 3.w),
                          label: Text('Assign Driver',
                              style: GoogleFonts.inter(fontSize: 10.sp)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            side: BorderSide(color: borderColor),
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Close',
                              style: GoogleFonts.inter(fontSize: 10.sp)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConductorDetailsOverlay(Map<String, dynamic> conductor) {
    // Get current status info
    String currentStatus = conductor['status'] ?? 'on_duty';
    Map<String, dynamic> statusOption = _conductorStatusOptions.firstWhere(
      (option) => option['value'] == currentStatus,
      orElse: () => _conductorStatusOptions.first,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Conductor Details',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: textColor),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),

                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: statusOption['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: statusOption['color'].withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusOption['icon'],
                          color: statusOption['color'], size: 4.w),
                      SizedBox(width: 1.w),
                      Text(
                        statusOption['label'],
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: statusOption['color'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),

                // Basic Info
                _buildDetailRow('Name', conductor['name'], Icons.person),
                _buildDetailRow(
                    'Employee ID', conductor['employeeId'], Icons.badge),
                _buildDetailRow(
                    'Experience', conductor['experience'], Icons.work),
                _buildDetailRow('Phone', conductor['phone'], Icons.phone),
                _buildDetailRow(
                    'Rating', '${conductor['rating']}/5', Icons.star),

                SizedBox(height: 1.h),
                Divider(color: borderColor.withOpacity(0.3)),
                SizedBox(height: 1.h),

                // Current Assignment Details
                Text(
                  'Current Assignment',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 1.h),

                if (currentStatus == 'on_duty') ...[
                  _buildDetailRow(
                      'Bus',
                      'Bus ${conductor['busNumber']} (${conductor['busModel']})',
                      Icons.directions_bus),
                  _buildDetailRow(
                      'Route', conductor['currentRoute'], Icons.route),
                  _buildDetailRow('Driver', conductor['driver'], Icons.person),
                  _buildDetailRow('Shift', conductor['shift'], Icons.schedule),
                  _buildDetailRow('Departure Time',
                      conductor['departureTime'] ?? '08:00 AM', Icons.schedule),
                  _buildDetailRow('Arrival Time',
                      conductor['arrivalTime'] ?? '12:00 PM', Icons.schedule),
                  _buildDetailRow(
                      'Bus Capacity',
                      '${conductor['currentPassengers'] ?? 45}/${conductor['busCapacity'] ?? 70}',
                      Icons.people),
                  _buildDetailRow('Next Trip',
                      conductor['nextTrip'] ?? '02:00 PM', Icons.schedule),
                ] else ...[
                  _buildDetailRow(
                      'Status', statusOption['label'], statusOption['icon']),
                  if (currentStatus == 'on_break') ...[
                    _buildDetailRow(
                        'Break Duration', '30 minutes', Icons.timer),
                    _buildDetailRow('Resume Time',
                        conductor['resumeTime'] ?? '10:30 AM', Icons.schedule),
                  ],
                  if (currentStatus == 'vacation') ...[
                    _buildDetailRow(
                        'Vacation End',
                        conductor['vacationEnd'] ?? 'Jan 15, 2025',
                        Icons.calendar_today),
                  ],
                  if (currentStatus == 'sick_leave') ...[
                    _buildDetailRow(
                        'Expected Return',
                        conductor['expectedReturn'] ?? 'Jan 10, 2025',
                        Icons.healing),
                  ],
                ],

                SizedBox(height: 1.h),
                Divider(color: borderColor.withOpacity(0.3)),
                SizedBox(height: 1.h),

                // Trip Statistics
                Text(
                  'Today\'s Statistics',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 1.h),
                _buildDetailRow('Trips Completed', '${conductor['tripsToday']}',
                    Icons.directions_bus),
                _buildDetailRow(
                    'Tickets Sold',
                    '${conductor['ticketsSold'] ?? 85}',
                    Icons.confirmation_number),
                _buildDetailRow(
                    'Revenue Collected',
                    '${conductor['revenueCollected'] ?? 425000} XAF',
                    Icons.attach_money),

                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _assignConductor(conductor);
                        },
                        icon: Icon(Icons.assignment_ind, size: 4.w),
                        label: Text('Assign'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: backgroundColor,
                          foregroundColor: textColor,
                          side: BorderSide(color: borderColor),
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                        ),
                        child: Text('Close'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 1.h,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: EdgeInsets.all(1.5.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(item['icon'], color: primaryColor, size: 3.w),
              SizedBox(width: 1.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['label'],
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      item['value'],
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 3.w),
        SizedBox(width: 1.w),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 3.w),
          SizedBox(width: 1.w),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 3.w),
          SizedBox(width: 1.w),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Icon(icon, size: 4.w, color: primaryColor),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editDriver(Map<String, dynamic> driver) {
    // TODO: Implement edit driver functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit driver: ${driver['name']}')),
    );
  }

  void _editConductor(Map<String, dynamic> conductor) {
    // TODO: Implement edit conductor functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit conductor: ${conductor['name']}')),
    );
  }

  void _showAddDriverSheet() {
    // TODO: Implement add driver sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add Driver functionality')),
    );
  }

  void _showAddConductorSheet() {
    // TODO: Implement add conductor sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add Conductor functionality')),
    );
  }
}
