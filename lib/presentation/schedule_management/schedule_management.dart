import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../../theme/theme_notifier.dart';
import '../../widgets/global_bottom_navigation.dart';
import '../../widgets/global_microphone_button.dart';

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

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

  // Drag & Drop Basket State
  List<Map<String, dynamic>> _basketItems = [];
  bool _isDragging = false;
  bool _showDropArea = false;
  Timer? _dragDelayTimer;

  // Trip Management State
  List<Map<String, dynamic>> _assembledTrips = [];
  Map<String, dynamic>? _currentTrip;
  List<String> _conflicts = [];

  // Trip Slots Management
  List<Map<String, dynamic>> _tripSlots = [];
  int _nextSlotId = 1;

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

  // Helper method to handle delayed drag start with proper delay
  void _handleDelayedDragStart(Map<String, dynamic> data) {
    _dragDelayTimer?.cancel();
    _dragDelayTimer = Timer(Duration(milliseconds: 1000), () {
      // 1 second delay
      setState(() {
        _isDragging = true;
        _showDropArea = true;
      });
      // Provide haptic feedback when drag actually starts
      HapticFeedback.mediumImpact();
    });
  }

  // Helper method to handle long press start (immediate feedback)
  void _handleLongPressStart(Map<String, dynamic> data) {
    // Provide immediate haptic feedback
    HapticFeedback.lightImpact();
    // Start the delay timer
    _handleDelayedDragStart(data);
  }

  // Helper method to handle drag end
  void _handleDragEnd() {
    _dragDelayTimer?.cancel();
    setState(() {
      _isDragging = false;
      _showDropArea = false;
    });
  }

  // Helper method to cancel drag delay
  void _cancelDragDelay() {
    _dragDelayTimer?.cancel();
  }

  @override
  void dispose() {
    _dragDelayTimer?.cancel();
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
      body: Stack(
        children: [
          Container(
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

          // Auto-opening Drop Area
          if (_showDropArea) _buildAutoDropArea(),

          // Basket Icon (Bottom Right)
          _buildBasketIcon(),

          // Microphone Icon (Below Basket)
          GlobalMicrophoneButton(
            bottomOffset:
                40, // Center-based positioning, aligned with basket icon center
            rightOffset: 3.0,
          ),
        ],
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

    return GestureDetector(
      onLongPressStart: (details) => _handleLongPressStart(route),
      onLongPressCancel: _cancelDragDelay,
      child: Draggable<Map<String, dynamic>>(
        data: route,
        onDragStarted: () {
          // This will be called after the delay
        },
        onDragEnd: (details) => _handleDragEnd(),
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 200,
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.route, color: Colors.white, size: 24),
                Text(
                  route['name'],
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${route['distance']} • ${route['duration']}',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        childWhenDragging: Container(
          margin: EdgeInsets.only(bottom: 1.h),
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox.shrink(), // Completely hide the card
        ),
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
                  // Drag handle
                  Icon(
                    Icons.drag_handle,
                    size: 16,
                    color: Colors.grey.withOpacity(0.6),
                  ),
                  SizedBox(width: 1.w),
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
        ),
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
          Text(
            'Driver Status Overview',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
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
          Text(
            'Conductor Status Overview',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
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
      onLongPressStart: (details) => _handleLongPressStart(driver),
      onLongPressCancel: _cancelDragDelay,
      child: _dragDelayTimer?.isActive == true
          ? _buildDriverCardContent(driver, statusColor,
              statusOption) // Show static card during delay
          : Draggable<Map<String, dynamic>>(
              data: driver,
              onDragStarted: () {
                // Only allow drag after delay is complete
                if (_dragDelayTimer?.isActive == true) {
                  return; // Prevent drag if timer is still active
                }
                setState(() {
                  _isDragging = true;
                  _showDropArea = true;
                });
                HapticFeedback.mediumImpact();
              },
              onDragEnd: (details) => _handleDragEnd(),
              feedback: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 200,
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, color: Colors.white, size: 24),
                      Text(
                        driver['name'],
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${driver['license']} • ${driver['experience']}',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              childWhenDragging: Container(
                margin: EdgeInsets.only(bottom: 1.h),
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox.shrink(), // Completely hide the card
              ),
              child: _buildDriverCardContent(driver, statusColor, statusOption),
            ),
    );
  }

  Widget _buildDriverCardContent(Map<String, dynamic> driver, Color statusColor,
      Map<String, dynamic> statusOption) {
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
                // Drag handle
                Icon(
                  Icons.drag_handle,
                  size: 16,
                  color: Colors.grey.withOpacity(0.6),
                ),
                SizedBox(width: 1.w),
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

    return Draggable<Map<String, dynamic>>(
      data: conductor,
      onDragStarted: () {
        setState(() {
          _isDragging = true;
          _showDropArea = true;
        });
      },
      onDragEnd: (details) {
        setState(() {
          _isDragging = false;
          _showDropArea = false;
        });
      },
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.badge, color: Colors.white, size: 24),
              Text(
                conductor['name'],
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${conductor['employeeId']} • ${conductor['experience']}',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox.shrink(), // Completely hide the card
      ),
      child: GestureDetector(
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
                  // Drag handle
                  Icon(
                    Icons.drag_handle,
                    size: 16,
                    color: Colors.grey.withOpacity(0.6),
                  ),
                  SizedBox(width: 1.w),
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

    return Draggable<Map<String, dynamic>>(
      data: bus,
      onDragStarted: () {
        setState(() {
          _isDragging = true;
          _showDropArea = true;
        });
      },
      onDragEnd: (details) {
        setState(() {
          _isDragging = false;
          _showDropArea = false;
        });
      },
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_bus, color: Colors.white, size: 24),
              Text(
                bus['plateNumber'],
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${bus['model']} • 70 seats',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox.shrink(), // Completely hide the card
      ),
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
                // Drag handle
                Icon(
                  Icons.drag_handle,
                  size: 16,
                  color: Colors.grey.withOpacity(0.6),
                ),
                SizedBox(width: 1.w),
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
                  child: _buildBusDetail('Driver', bus['driver'], Icons.person),
                ),
                Expanded(
                  child: _buildBusDetail(
                      'Route', bus['currentRoute'], Icons.route),
                ),
              ],
            ),
            SizedBox(height: 0.5.h),
            Row(
              children: [
                Expanded(
                  child: _buildBusDetail(
                      'Conductor', bus['conductor'], Icons.badge),
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
                    label:
                        Text('Edit', style: GoogleFonts.inter(fontSize: 9.sp)),
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
        child: Stack(
          children: [
            // Original content (blurred/disabled)
            SingleChildScrollView(
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
            // Overlay
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.construction,
                        size: 12.w,
                        color: primaryColor.withOpacity(0.7),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Coming Soon',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Real-Time Control',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'This feature is currently under development.\nReal-time monitoring and emergency controls\nwill be available in a future update.',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: textColor.withOpacity(0.7),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: primaryColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          '🚧 Under Development',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
                  'Download All',
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

  Widget _buildDropZone(String title, IconData icon, String hint) {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => true,
      onAccept: (data) => _handleDrop(data, title),
      builder: (context, candidateData, rejectedData) {
        bool isHighlighted = candidateData.isNotEmpty;

        return Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color:
                isHighlighted ? primaryColor.withOpacity(0.1) : backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHighlighted ? primaryColor : borderColor,
              width: isHighlighted ? 3 : 2,
              style: isHighlighted ? BorderStyle.solid : BorderStyle.none,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: isHighlighted ? primaryColor : Colors.grey,
              ),
              SizedBox(height: 0.5.h),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isHighlighted ? primaryColor : Colors.grey,
                ),
              ),
              SizedBox(height: 0.2.h),
              Text(
                hint,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: isHighlighted
                      ? primaryColor.withOpacity(0.7)
                      : Colors.grey.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleDrop(Map<String, dynamic> data, String dropZoneTitle) {
    String itemType = _getItemType(data);

    // Check if we already have this type of item in any slot
    List<Map<String, dynamic>> existingSlots = [];
    for (var slot in _tripSlots) {
      if (slot['items'].any((item) => _getItemType(item) == itemType)) {
        existingSlots.add(slot);
      }
    }

    if (existingSlots.isNotEmpty) {
      // Show slot selection dialog
      _showSlotSelectionDialog(data, existingSlots, dropZoneTitle);
      return;
    }

    // Check for other conflicts
    List<String> conflicts = _checkConflicts(data);
    if (conflicts.isNotEmpty) {
      _showConflictDialog(conflicts, data);
      return;
    }

    // Add to first available slot or create new slot
    _addToSlot(data, dropZoneTitle);
  }

  String _getItemType(Map<String, dynamic> data) {
    if (data.containsKey('license')) return 'driver';
    if (data.containsKey('employeeId')) return 'conductor';
    if (data.containsKey('plateNumber')) return 'bus';
    if (data.containsKey('name') && data.containsKey('distance'))
      return 'route';
    return 'unknown';
  }

  void _showAssignmentConfirmation(
      Map<String, dynamic> data, String dropZoneTitle) {
    String itemName = data['name'] ?? data['plateNumber'];
    String itemType = _getItemType(data);

    // Show notification instead of dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getItemIcon(itemType), color: Colors.white, size: 20),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$itemName added to trip assembly',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _getItemSubtitle(data, itemType),
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  IconData _getItemIcon(String type) {
    switch (type) {
      case 'driver':
        return Icons.person;
      case 'conductor':
        return Icons.badge;
      case 'bus':
        return Icons.directions_bus;
      case 'route':
        return Icons.route;
      default:
        return Icons.help;
    }
  }

  String _getItemSubtitle(Map<String, dynamic> data, String type) {
    switch (type) {
      case 'driver':
        return '${data['license']} • ${data['experience']}';
      case 'conductor':
        return '${data['employeeId']} • ${data['experience']}';
      case 'bus':
        return '${data['model']} • 70 seats';
      case 'route':
        return '${data['distance']} • ${data['duration']}';
      default:
        return '';
    }
  }

  Widget _buildAutoDropArea() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 120,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.95),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: DragTarget<Map<String, dynamic>>(
          onWillAccept: (data) => true,
          onAccept: (data) => _handleDrop(data, 'Trip Assembly'),
          builder: (context, candidateData, rejectedData) {
            bool isHighlighted = candidateData.isNotEmpty;

            return Container(
              padding: EdgeInsets.all(3.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: isHighlighted ? 48 : 40,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    isHighlighted
                        ? 'Drop here to add to trip'
                        : 'Drop items here to build your trip',
                    style: GoogleFonts.inter(
                      fontSize: isHighlighted ? 14.sp : 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBasketIcon() {
    return Positioned(
      bottom: 100, // Center-based positioning
      right: 3.w,
      child: GestureDetector(
        onTap: () => _showBasketOverlay(),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              if (_tripSlots.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${_tripSlots.length}',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBasketOverlay() {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      isScrollControlled: true, // Allow the sheet to grow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize:
              _tripSlots.isEmpty ? 0.3 : 0.6, // Start smaller if empty
          minChildSize: 0.3, // Minimum height
          maxChildSize: 0.9, // Maximum height (90% of screen)
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(3.w),
              child: Column(
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Title
                  Text(
                    'Trip Slots Management',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Manage your trip slots and assemble trips',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Trip Slots List - Scrollable
                  Expanded(
                    child: _tripSlots.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.schedule_outlined,
                                  size: 64,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'No trip slots created',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: Colors.grey.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  'Drag items from the tabs above to create trip slots',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _tripSlots.length,
                            itemBuilder: (context, index) {
                              final slot = _tripSlots[index];
                              return _buildTripSlotCard(slot, index);
                            },
                          ),
                  ),

                  // Actions - Fixed at bottom
                  if (_tripSlots.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _tripSlots.clear();
                              });
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.clear_all, size: 4.w),
                            label: Text('Clear All Slots',
                                style: GoogleFonts.inter(fontSize: 10.sp)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red),
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _assembleAllTrips();
                            },
                            icon: Icon(Icons.check_circle, size: 4.w),
                            label: Text('Assemble All Trips',
                                style: GoogleFonts.inter(fontSize: 10.sp)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTripSlotCard(Map<String, dynamic> slot, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slot Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.schedule,
                  color: primaryColor,
                  size: 16,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            slot['name'],
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _renameSlot(slot),
                          icon: Icon(Icons.edit, color: primaryColor, size: 16),
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    Text(
                      '${slot['items'].length} items • ${_getSlotCompletionStatus(slot)}',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _tripSlots.removeAt(index);
                  });
                },
                icon: Icon(Icons.delete_outline, color: Colors.red, size: 16),
                constraints: BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Items in Slot
          if (slot['items'].isNotEmpty) ...[
            Wrap(
              spacing: 1.w,
              runSpacing: 0.5.h,
              children: slot['items'].map<Widget>((item) {
                String itemType = _getItemType(item);
                String itemName = item['name'] ?? item['plateNumber'];
                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: _getItemTypeColor(itemType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: _getItemTypeColor(itemType).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getItemIcon(itemType),
                        color: _getItemTypeColor(itemType),
                        size: 12,
                      ),
                      SizedBox(width: 0.5.w),
                      Text(
                        itemName,
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                          color: _getItemTypeColor(itemType),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 1.h),
          ],

          // Slot Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _assembleSlotTrip(slot),
                  icon: Icon(Icons.check_circle_outline, size: 12),
                  label: Text('Assemble Trip',
                      style: GoogleFonts.inter(fontSize: 9.sp)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                    minimumSize: Size(0, 0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getItemTypeColor(String type) {
    switch (type) {
      case 'driver':
        return Colors.blue;
      case 'conductor':
        return Colors.green;
      case 'bus':
        return Colors.orange;
      case 'route':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _renameSlot(Map<String, dynamic> slot) {
    TextEditingController controller =
        TextEditingController(text: slot['name']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            'Rename Trip Slot',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Slot Name',
              hintText: 'Enter a custom name for this trip slot',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: GoogleFonts.inter(fontSize: 10.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  slot['name'] = controller.text.trim().isNotEmpty
                      ? controller.text.trim()
                      : 'Trip Slot ${slot['id']}';
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _assembleSlotTrip(Map<String, dynamic> slot) {
    // Validate slot completeness
    List<String> errors = _validateSlotCompleteness(slot);
    if (errors.isNotEmpty) {
      _showValidationDialog(errors);
      return;
    }

    // Create trip from slot
    Map<String, dynamic> trip = _createTripFromSlot(slot);

    // Add to assembled trips
    setState(() {
      _assembledTrips.add(trip);
      _currentTrip = trip;
    });

    // Show trip result
    _showTripResult(trip);
  }

  void _assembleAllTrips() {
    List<Map<String, dynamic>> validTrips = [];
    List<String> allErrors = [];

    for (var slot in _tripSlots) {
      List<String> errors = _validateSlotCompleteness(slot);
      if (errors.isEmpty) {
        validTrips.add(_createTripFromSlot(slot));
      } else {
        allErrors.addAll(errors.map((error) => '${slot['name']}: $error'));
      }
    }

    if (validTrips.isEmpty) {
      _showValidationDialog(allErrors);
      return;
    }

    // Add all valid trips
    setState(() {
      _assembledTrips.addAll(validTrips);
      _currentTrip = validTrips.first;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Successfully assembled ${validTrips.length} trip${validTrips.length > 1 ? 's' : ''}'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Show trip management
    _showTripManagement();
  }

  List<String> _validateSlotCompleteness(Map<String, dynamic> slot) {
    List<String> errors = [];
    List<String> requiredTypes = ['driver', 'conductor', 'bus', 'route'];
    List<String> presentTypes =
        slot['items'].map<String>((item) => _getItemType(item)).toList();

    for (String type in requiredTypes) {
      if (!presentTypes.contains(type)) {
        errors.add('$type is required');
      }
    }

    return errors;
  }

  Map<String, dynamic> _createTripFromSlot(Map<String, dynamic> slot) {
    var driver =
        slot['items'].firstWhere((item) => _getItemType(item) == 'driver');
    var conductor =
        slot['items'].firstWhere((item) => _getItemType(item) == 'conductor');
    var bus = slot['items'].firstWhere((item) => _getItemType(item) == 'bus');
    var route =
        slot['items'].firstWhere((item) => _getItemType(item) == 'route');

    String tripId =
        'TRP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    return {
      'tripId': tripId,
      'driver': driver,
      'conductor': conductor,
      'bus': bus,
      'route': route,
      'status': 'assembled',
      'createdAt': DateTime.now(),
      'departureTime': _calculateDepartureTime(),
      'estimatedArrival': _calculateArrivalTime(),
      'passengerCapacity': bus['capacity'],
      'estimatedRevenue': _calculateEstimatedRevenue(),
      'slotName': slot['name'],
    };
  }

  void _assembleTrip() {
    if (_basketItems.isEmpty) return;

    // Validate trip completeness
    List<String> validationErrors = _validateTripCompleteness();

    if (validationErrors.isNotEmpty) {
      _showValidationDialog(validationErrors);
      return;
    }

    // Create the trip
    Map<String, dynamic> trip = _createTrip();

    // Add to assembled trips
    setState(() {
      _assembledTrips.add(trip);
      _currentTrip = trip;
      _basketItems.clear();
    });

    // Show trip result
    _showTripResult(trip);
  }

  List<String> _checkConflicts(Map<String, dynamic> newItem) {
    List<String> conflicts = [];
    String itemType = _getItemType(newItem);

    // Check for duplicate items
    for (var existingItem in _basketItems) {
      if (_getItemType(existingItem) == itemType) {
        conflicts.add('${itemType.capitalize()} already added to trip');
        break;
      }
    }

    // Check for schedule conflicts
    if (itemType == 'driver') {
      conflicts.addAll(_checkDriverConflicts(newItem));
    } else if (itemType == 'conductor') {
      conflicts.addAll(_checkConductorConflicts(newItem));
    } else if (itemType == 'bus') {
      conflicts.addAll(_checkBusConflicts(newItem));
    } else if (itemType == 'route') {
      conflicts.addAll(_checkRouteConflicts(newItem));
    }

    // Check for capacity conflicts
    conflicts.addAll(_checkCapacityConflicts(newItem));

    return conflicts;
  }

  List<String> _checkDriverConflicts(Map<String, dynamic> driver) {
    List<String> conflicts = [];

    // Check if driver is already assigned to another trip
    for (var trip in _assembledTrips) {
      if (trip['driver']['id'] == driver['id']) {
        conflicts.add(
            'Driver ${driver['name']} is already assigned to Trip ${trip['tripId']}');
      }
    }

    // Check working hours
    if (driver['status'] == 'on_break') {
      conflicts.add('Driver ${driver['name']} is currently on break');
    } else if (driver['status'] == 'sick_leave') {
      conflicts.add('Driver ${driver['name']} is on sick leave');
    } else if (driver['status'] == 'vacation') {
      conflicts.add('Driver ${driver['name']} is on vacation');
    }

    return conflicts;
  }

  List<String> _checkConductorConflicts(Map<String, dynamic> conductor) {
    List<String> conflicts = [];

    // Check if conductor is already assigned to another trip
    for (var trip in _assembledTrips) {
      if (trip['conductor']['id'] == conductor['id']) {
        conflicts.add(
            'Conductor ${conductor['name']} is already assigned to Trip ${trip['tripId']}');
      }
    }

    // Check availability
    if (conductor['status'] == 'on_break') {
      conflicts.add('Conductor ${conductor['name']} is currently on break');
    } else if (conductor['status'] == 'sick_leave') {
      conflicts.add('Conductor ${conductor['name']} is on sick leave');
    } else if (conductor['status'] == 'vacation') {
      conflicts.add('Conductor ${conductor['name']} is on vacation');
    }

    return conflicts;
  }

  List<String> _checkBusConflicts(Map<String, dynamic> bus) {
    List<String> conflicts = [];

    // Check if bus is already assigned to another trip
    for (var trip in _assembledTrips) {
      if (trip['bus']['id'] == bus['id']) {
        conflicts.add(
            'Bus ${bus['plateNumber']} is already assigned to Trip ${trip['tripId']}');
      }
    }

    // Check bus status
    if (bus['status'] == 'maintenance') {
      conflicts.add('Bus ${bus['plateNumber']} is in maintenance');
    } else if (bus['status'] == 'inactive') {
      conflicts.add('Bus ${bus['plateNumber']} is inactive');
    } else if (bus['status'] == 'suspended') {
      conflicts.add('Bus ${bus['plateNumber']} is suspended');
    }

    return conflicts;
  }

  List<String> _checkRouteConflicts(Map<String, dynamic> route) {
    List<String> conflicts = [];

    // Check if route is already assigned to another trip
    for (var trip in _assembledTrips) {
      if (trip['route'] == route['name']) {
        conflicts.add(
            'Route ${route['name']} is already assigned to Trip ${trip['tripId']}');
      }
    }

    // Check route status
    if (route['status'] == 'inactive') {
      conflicts.add('Route ${route['name']} is inactive');
    } else if (route['status'] == 'maintenance') {
      conflicts.add('Route ${route['name']} is under maintenance');
    } else if (route['status'] == 'suspended') {
      conflicts.add('Route ${route['name']} is suspended');
    }

    return conflicts;
  }

  List<String> _checkCapacityConflicts(Map<String, dynamic> item) {
    List<String> conflicts = [];

    if (_getItemType(item) == 'bus') {
      // Check if bus capacity is sufficient for route
      var route = _basketItems.firstWhere(
        (item) => _getItemType(item) == 'route',
        orElse: () => {},
      );

      if (route.isNotEmpty && route['expectedPassengers'] > item['capacity']) {
        conflicts.add(
            'Bus capacity (${item['capacity']}) insufficient for route (${route['expectedPassengers']} passengers)');
      }
    }

    return conflicts;
  }

  void _showConflictDialog(List<String> conflicts, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 24),
              SizedBox(width: 1.w),
              Text(
                'Assignment Conflict',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cannot add ${item['name'] ?? item['plateNumber']} due to:',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: textColor,
                ),
              ),
              SizedBox(height: 1.h),
              ...conflicts.map((conflict) => Padding(
                    padding: EdgeInsets.only(bottom: 0.5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 16),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            conflict,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );

    // Haptic feedback for conflict
    HapticFeedback.heavyImpact();
  }

  void _showReplacementDialog(Map<String, dynamic> existingItem,
      Map<String, dynamic> newItem, String dropZoneTitle) {
    String itemType = _getItemType(existingItem);
    String existingName = existingItem['name'] ?? existingItem['plateNumber'];
    String newName = newItem['name'] ?? newItem['plateNumber'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            '${itemType.capitalize()} Already Selected',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You already have ${existingName} selected.',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: textColor.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'What would you like to do with ${newName}?',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _replaceItem(existingItem, newItem, dropZoneTitle);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.withOpacity(0.1),
                foregroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              ),
              child: Text(
                'Replace',
                style: GoogleFonts.inter(fontSize: 11.sp),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addAsSeparateTrip(newItem, dropZoneTitle);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor.withOpacity(0.1),
                foregroundColor: primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              ),
              child: Text(
                'Add Separate',
                style: GoogleFonts.inter(fontSize: 11.sp),
              ),
            ),
          ],
        );
      },
    );
  }

  void _replaceItem(Map<String, dynamic> existingItem,
      Map<String, dynamic> newItem, String dropZoneTitle) {
    setState(() {
      // Remove the existing item
      _basketItems.removeWhere((item) => item == existingItem);

      // Add the new item
      _basketItems.add({
        ...newItem,
        'type': _getItemType(newItem),
        'addedAt': DateTime.now(),
        'status': 'pending',
      });
    });

    // Show replacement confirmation
    _showReplacementConfirmation(existingItem, newItem, dropZoneTitle);

    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  void _addAsSeparateTrip(Map<String, dynamic> newItem, String dropZoneTitle) {
    // Check for conflicts
    List<String> conflicts = _checkConflicts(newItem);
    if (conflicts.isNotEmpty) {
      _showConflictDialog(conflicts, newItem);
      return;
    }

    // Add item to basket
    setState(() {
      _basketItems.add({
        ...newItem,
        'type': _getItemType(newItem),
        'addedAt': DateTime.now(),
        'status': 'pending',
        'separateTrip': true, // Mark as separate trip
      });
    });

    // Show assignment confirmation
    _showAssignmentConfirmation(newItem, dropZoneTitle);

    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  void _showReplacementConfirmation(Map<String, dynamic> oldItem,
      Map<String, dynamic> newItem, String dropZoneTitle) {
    String itemType = _getItemType(newItem);
    String oldName = oldItem['name'] ?? oldItem['plateNumber'];
    String newName = newItem['name'] ?? newItem['plateNumber'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getItemIcon(itemType),
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'Replaced $oldName with $newName',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(3.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSlotSelectionDialog(Map<String, dynamic> newItem,
      List<Map<String, dynamic>> existingSlots, String dropZoneTitle) {
    String itemType = _getItemType(newItem);
    String itemName = newItem['name'] ?? newItem['plateNumber'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            'Select Trip Slot',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Where would you like to add $itemName?',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: textColor.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Available Trip Slots:',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              SizedBox(height: 1.h),
              ...existingSlots
                  .map((slot) => Container(
                        margin: EdgeInsets.only(bottom: 1.h),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.schedule,
                              color: primaryColor,
                              size: 16,
                            ),
                          ),
                          title: Text(
                            slot['name'],
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          subtitle: Text(
                            '${slot['items'].length} items • ${_getSlotCompletionStatus(slot)}',
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _addToExistingSlot(slot, newItem, dropZoneTitle);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor.withOpacity(0.1),
                              foregroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              minimumSize: Size(0, 0),
                            ),
                            child: Text(
                              'Add Here',
                              style: GoogleFonts.inter(fontSize: 8.sp),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              SizedBox(height: 1.h),
              Divider(color: borderColor.withOpacity(0.3)),
              SizedBox(height: 1.h),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
                title: Text(
                  'Create New Trip Slot',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                subtitle: Text(
                  'Start a new trip slot',
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _createNewSlot(newItem, dropZoneTitle);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    foregroundColor: Colors.green,
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    minimumSize: Size(0, 0),
                  ),
                  child: Text(
                    'Create',
                    style: GoogleFonts.inter(fontSize: 8.sp),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getSlotCompletionStatus(Map<String, dynamic> slot) {
    List<String> requiredTypes = ['driver', 'conductor', 'bus', 'route'];
    List<String> presentTypes =
        slot['items'].map<String>((item) => _getItemType(item)).toList();

    int completed =
        requiredTypes.where((type) => presentTypes.contains(type)).length;
    return '$completed/${requiredTypes.length} complete';
  }

  void _addToExistingSlot(Map<String, dynamic> slot,
      Map<String, dynamic> newItem, String dropZoneTitle) {
    String itemType = _getItemType(newItem);

    // Check if slot already has this type
    bool hasType = slot['items'].any((item) => _getItemType(item) == itemType);

    if (hasType) {
      // Show replacement dialog for this specific slot
      _showSlotReplacementDialog(slot, newItem, dropZoneTitle);
      return;
    }

    // Check for conflicts
    List<String> conflicts = _checkConflicts(newItem);
    if (conflicts.isNotEmpty) {
      _showConflictDialog(conflicts, newItem);
      return;
    }

    // Add to slot
    setState(() {
      slot['items'].add({
        ...newItem,
        'type': itemType,
        'addedAt': DateTime.now(),
        'status': 'pending',
      });
    });

    _showAssignmentConfirmation(newItem, dropZoneTitle);
    HapticFeedback.mediumImpact();
  }

  void _createNewSlot(Map<String, dynamic> newItem, String dropZoneTitle) {
    String itemType = _getItemType(newItem);

    // Check for conflicts
    List<String> conflicts = _checkConflicts(newItem);
    if (conflicts.isNotEmpty) {
      _showConflictDialog(conflicts, newItem);
      return;
    }

    // Create new slot
    Map<String, dynamic> newSlot = {
      'id': _nextSlotId++,
      'name': 'Trip Slot ${_tripSlots.length + 1}',
      'items': [
        {
          ...newItem,
          'type': itemType,
          'addedAt': DateTime.now(),
          'status': 'pending',
        }
      ],
      'createdAt': DateTime.now(),
      'isEditable': true,
    };

    setState(() {
      _tripSlots.add(newSlot);
    });

    _showAssignmentConfirmation(newItem, dropZoneTitle);
    HapticFeedback.mediumImpact();
  }

  void _addToSlot(Map<String, dynamic> data, String dropZoneTitle) {
    String itemType = _getItemType(data);

    // Check for conflicts
    List<String> conflicts = _checkConflicts(data);
    if (conflicts.isNotEmpty) {
      _showConflictDialog(conflicts, data);
      return;
    }

    if (_tripSlots.isEmpty) {
      // Create first slot
      _createNewSlot(data, dropZoneTitle);
    } else {
      // Add to first available slot
      var firstSlot = _tripSlots.first;
      _addToExistingSlot(firstSlot, data, dropZoneTitle);
    }
  }

  void _showSlotReplacementDialog(Map<String, dynamic> slot,
      Map<String, dynamic> newItem, String dropZoneTitle) {
    String itemType = _getItemType(newItem);
    String newName = newItem['name'] ?? newItem['plateNumber'];

    // Find existing item of same type in slot
    var existingItem =
        slot['items'].firstWhere((item) => _getItemType(item) == itemType);
    String existingName = existingItem['name'] ?? existingItem['plateNumber'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            'Replace in ${slot['name']}',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This slot already has $existingName.',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: textColor.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'What would you like to do with $newName?',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _replaceInSlot(slot, existingItem, newItem, dropZoneTitle);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.withOpacity(0.1),
                foregroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              ),
              child: Text(
                'Replace',
                style: GoogleFonts.inter(fontSize: 11.sp),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createNewSlot(newItem, dropZoneTitle);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor.withOpacity(0.1),
                foregroundColor: primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              ),
              child: Text(
                'New Slot',
                style: GoogleFonts.inter(fontSize: 11.sp),
              ),
            ),
          ],
        );
      },
    );
  }

  void _replaceInSlot(Map<String, dynamic> slot, Map<String, dynamic> oldItem,
      Map<String, dynamic> newItem, String dropZoneTitle) {
    setState(() {
      // Remove old item
      slot['items'].removeWhere((item) => item == oldItem);

      // Add new item
      slot['items'].add({
        ...newItem,
        'type': _getItemType(newItem),
        'addedAt': DateTime.now(),
        'status': 'pending',
      });
    });

    _showReplacementConfirmation(oldItem, newItem, dropZoneTitle);
    HapticFeedback.mediumImpact();
  }

  List<String> _validateTripCompleteness() {
    List<String> errors = [];

    // Group items by type and separate trip status
    Map<String, List<Map<String, dynamic>>> groupedItems = {};
    List<Map<String, dynamic>> separateTrips = [];

    for (var item in _basketItems) {
      String type = _getItemType(item);
      if (item['separateTrip'] == true) {
        separateTrips.add(item);
      } else {
        if (!groupedItems.containsKey(type)) {
          groupedItems[type] = [];
        }
        groupedItems[type]!.add(item);
      }
    }

    // Check main trip completeness
    if (!groupedItems.containsKey('driver')) {
      errors.add('Driver is required');
    }
    if (!groupedItems.containsKey('conductor')) {
      errors.add('Conductor is required');
    }
    if (!groupedItems.containsKey('bus')) {
      errors.add('Bus is required');
    }
    if (!groupedItems.containsKey('route')) {
      errors.add('Route is required');
    }

    // Check for multiple items of same type in main trip
    groupedItems.forEach((type, items) {
      if (items.length > 1) {
        errors.add(
            'Multiple ${type}s selected for main trip. Use "Add Separate" for additional ${type}s.');
      }
    });

    // Validate separate trips
    for (var separateItem in separateTrips) {
      String type = _getItemType(separateItem);
      if (!groupedItems.containsKey(type)) {
        errors.add(
            'Cannot create separate trip for $type without main trip $type');
      }
    }

    // Check compatibility for main trip
    if (groupedItems.containsKey('driver') &&
        groupedItems.containsKey('conductor') &&
        groupedItems.containsKey('bus') &&
        groupedItems.containsKey('route')) {
      var driver = groupedItems['driver']!.first;
      var conductor = groupedItems['conductor']!.first;
      var bus = groupedItems['bus']!.first;
      var route = groupedItems['route']!.first;

      // Check driver-conductor compatibility
      if (driver['currentRoute'] != conductor['currentRoute']) {
        errors.add('Driver and conductor are assigned to different routes');
      }

      // Check bus-driver compatibility
      if (bus['currentRoute'] != driver['currentRoute']) {
        errors.add('Bus and driver are assigned to different routes');
      }
    }

    return errors;
  }

  void _showValidationDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 24),
              SizedBox(width: 1.w),
              Text(
                'Trip Incomplete',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cannot assemble trip. Missing requirements:',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: textColor,
                ),
              ),
              SizedBox(height: 1.h),
              ...errors.map((error) => Padding(
                    padding: EdgeInsets.only(bottom: 0.5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 16),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            error,
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> _createTrip() {
    // Get main trip components (non-separate items)
    var driver = _basketItems.firstWhere((item) =>
        _getItemType(item) == 'driver' && item['separateTrip'] != true);
    var conductor = _basketItems.firstWhere((item) =>
        _getItemType(item) == 'conductor' && item['separateTrip'] != true);
    var bus = _basketItems.firstWhere(
        (item) => _getItemType(item) == 'bus' && item['separateTrip'] != true);
    var route = _basketItems.firstWhere((item) =>
        _getItemType(item) == 'route' && item['separateTrip'] != true);

    String tripId =
        'TRP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    return {
      'tripId': tripId,
      'driver': driver,
      'conductor': conductor,
      'bus': bus,
      'route': route,
      'status': 'assembled',
      'createdAt': DateTime.now(),
      'departureTime': _calculateDepartureTime(),
      'estimatedArrival': _calculateArrivalTime(),
      'passengerCapacity': bus['capacity'],
      'estimatedRevenue': _calculateEstimatedRevenue(),
      'separateTrips': _createSeparateTrips(),
    };
  }

  List<Map<String, dynamic>> _createSeparateTrips() {
    List<Map<String, dynamic>> separateTrips = [];

    // Group separate items by type
    Map<String, List<Map<String, dynamic>>> separateItems = {};
    for (var item in _basketItems) {
      if (item['separateTrip'] == true) {
        String type = _getItemType(item);
        if (!separateItems.containsKey(type)) {
          separateItems[type] = [];
        }
        separateItems[type]!.add(item);
      }
    }

    // Create separate trips for each additional item
    separateItems.forEach((type, items) {
      for (var item in items) {
        // Get the main trip components for this separate trip
        var mainDriver = _basketItems.firstWhere(
            (i) => _getItemType(i) == 'driver' && i['separateTrip'] != true);
        var mainConductor = _basketItems.firstWhere(
            (i) => _getItemType(i) == 'conductor' && i['separateTrip'] != true);
        var mainBus = _basketItems.firstWhere(
            (i) => _getItemType(i) == 'bus' && i['separateTrip'] != true);
        var mainRoute = _basketItems.firstWhere(
            (i) => _getItemType(i) == 'route' && i['separateTrip'] != true);

        // Create separate trip with the additional item
        Map<String, dynamic> separateTrip = {
          'tripId':
              'TRP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}-${type.toUpperCase()}',
          'driver': type == 'driver' ? item : mainDriver,
          'conductor': type == 'conductor' ? item : mainConductor,
          'bus': type == 'bus' ? item : mainBus,
          'route': type == 'route' ? item : mainRoute,
          'status': 'assembled',
          'createdAt': DateTime.now(),
          'departureTime': _calculateDepartureTime(),
          'estimatedArrival': _calculateArrivalTime(),
          'passengerCapacity':
              type == 'bus' ? item['capacity'] : mainBus['capacity'],
          'estimatedRevenue': _calculateEstimatedRevenue(),
          'isSeparateTrip': true,
          'separateItemType': type,
        };

        separateTrips.add(separateTrip);
      }
    });

    return separateTrips;
  }

  String _calculateDepartureTime() {
    // Calculate next available departure time
    DateTime now = DateTime.now();
    DateTime nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    return '${nextHour.hour.toString().padLeft(2, '0')}:00';
  }

  String _calculateArrivalTime() {
    // Calculate arrival time based on route duration
    DateTime now = DateTime.now();
    DateTime arrival = now.add(Duration(hours: 4)); // Default 4 hours
    return '${arrival.hour.toString().padLeft(2, '0')}:${arrival.minute.toString().padLeft(2, '0')}';
  }

  double _calculateEstimatedRevenue() {
    var bus = _basketItems.firstWhere((item) => _getItemType(item) == 'bus');
    int capacity = bus['capacity'];
    double occupancyRate = 0.75; // 75% occupancy
    double ticketPrice = 7500.0; // XAF

    return capacity * occupancyRate * ticketPrice;
  }

  void _showTripResult(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.check_circle,
                            color: Colors.white, size: 4.w),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trip Assembled Successfully!',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'Trip ID: ${trip['tripId']}',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
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
                        // Trip Details
                        _buildTripDetailSection('Trip Details', [
                          {
                            'label': 'Route',
                            'value': trip['route'],
                            'icon': Icons.route
                          },
                          {
                            'label': 'Departure',
                            'value': trip['departureTime'],
                            'icon': Icons.schedule
                          },
                          {
                            'label': 'Arrival',
                            'value': trip['estimatedArrival'],
                            'icon': Icons.schedule
                          },
                          {
                            'label': 'Capacity',
                            'value': '${trip['passengerCapacity']} seats',
                            'icon': Icons.people
                          },
                        ]),

                        SizedBox(height: 2.h),

                        // Team Assignment
                        _buildTripDetailSection('Team Assignment', [
                          {
                            'label': 'Driver',
                            'value': trip['driver']['name'],
                            'icon': Icons.person
                          },
                          {
                            'label': 'Conductor',
                            'value': trip['conductor']['name'],
                            'icon': Icons.badge
                          },
                          {
                            'label': 'Bus',
                            'value': trip['bus']['plateNumber'],
                            'icon': Icons.directions_bus
                          },
                        ]),

                        SizedBox(height: 2.h),

                        // Financial Projection
                        _buildTripDetailSection('Financial Projection', [
                          {
                            'label': 'Estimated Revenue',
                            'value':
                                '${trip['estimatedRevenue'].toStringAsFixed(0)} XAF',
                            'icon': Icons.attach_money
                          },
                          {
                            'label': 'Occupancy Rate',
                            'value': '75%',
                            'icon': Icons.trending_up
                          },
                          {
                            'label': 'Ticket Price',
                            'value': '7,500 XAF',
                            'icon': Icons.confirmation_number
                          },
                        ]),

                        // Separate Trips (if any)
                        if (trip['separateTrips'] != null &&
                            trip['separateTrips'].isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          _buildSeparateTripsSection(trip['separateTrips']),
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
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border(
                        top: BorderSide(color: borderColor.withOpacity(0.2))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showTripManagement();
                          },
                          icon: Icon(Icons.list, size: 3.w),
                          label: Text('View All Trips',
                              style: GoogleFonts.inter(fontSize: 10.sp)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            side: BorderSide(color: borderColor),
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _startTrip(trip);
                          },
                          icon: Icon(Icons.play_arrow, size: 3.w),
                          label: Text('Start Trip',
                              style: GoogleFonts.inter(fontSize: 10.sp)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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

  Widget _buildTripDetailSection(
      String title, List<Map<String, dynamic>> details) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 1.h),
          ...details.map((detail) => Padding(
                padding: EdgeInsets.only(bottom: 0.5.h),
                child: Row(
                  children: [
                    Icon(detail['icon'], color: primaryColor, size: 3.w),
                    SizedBox(width: 1.w),
                    Text(
                      detail['label'],
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    Spacer(),
                    Text(
                      detail['value'],
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSeparateTripsSection(List<Map<String, dynamic>> separateTrips) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_road, color: Colors.blue, size: 16),
              SizedBox(width: 1.w),
              Text(
                'Additional Trips Created',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'You created ${separateTrips.length} additional trip${separateTrips.length > 1 ? 's' : ''} with different components:',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: textColor.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 1.h),
          ...separateTrips
              .map((trip) => Container(
                    margin: EdgeInsets.only(bottom: 1.h),
                    padding: EdgeInsets.all(1.5.w),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.route, size: 14, color: primaryColor),
                            SizedBox(width: 1.w),
                            Text(
                              'Trip ${trip['tripId']}',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.w, vertical: 0.3.h),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                trip['separateItemType']
                                    .toString()
                                    .toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Different ${trip['separateItemType']}: ${trip['separateItemType'] == 'driver' ? trip['driver']['name'] : trip['separateItemType'] == 'conductor' ? trip['conductor']['name'] : trip['separateItemType'] == 'bus' ? trip['bus']['plateNumber'] : trip['route']['name']}',
                          style: GoogleFonts.inter(
                            fontSize: 9.sp,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  void _showTripManagement() {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 70.h,
          padding: EdgeInsets.all(3.w),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),

              // Title
              Text(
                'Trip Management',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              SizedBox(height: 2.h),

              // Trips List
              Expanded(
                child: _assembledTrips.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_bus_outlined,
                              size: 64,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'No trips assembled yet',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                color: Colors.grey.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              'Assemble trips using the drag & drop system',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _assembledTrips.length,
                        itemBuilder: (context, index) {
                          final trip = _assembledTrips[index];
                          return _buildTripCard(trip, index);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip['tripId'],
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      trip['route'],
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trip['status'].toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: Colors.green,
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
                child: _buildTripDetail(
                    'Driver', trip['driver']['name'], Icons.person),
              ),
              Expanded(
                child: _buildTripDetail(
                    'Conductor', trip['conductor']['name'], Icons.badge),
              ),
              Expanded(
                child: _buildTripDetail(
                    'Bus', trip['bus']['plateNumber'], Icons.directions_bus),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _startTrip(trip),
                  icon: Icon(Icons.play_arrow, size: 3.w),
                  label:
                      Text('Start', style: GoogleFonts.inter(fontSize: 9.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editTrip(trip),
                  icon: Icon(Icons.edit, size: 3.w),
                  label: Text('Edit', style: GoogleFonts.inter(fontSize: 9.sp)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(color: borderColor),
                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 3.w, color: textColor.withOpacity(0.6)),
        SizedBox(width: 0.5.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  color: textColor.withOpacity(0.6),
                ),
              ),
              Text(
                value,
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
    );
  }

  void _startTrip(Map<String, dynamic> trip) {
    setState(() {
      trip['status'] = 'active';
      trip['startedAt'] = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trip ${trip['tripId']} started successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editTrip(Map<String, dynamic> trip) {
    // TODO: Implement trip editing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trip editing functionality coming soon')),
    );
  }
}
