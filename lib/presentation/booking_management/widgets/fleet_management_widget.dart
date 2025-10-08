import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bus_detail_sheet.dart';

class FleetManagementWidget extends StatefulWidget {
  const FleetManagementWidget({Key? key}) : super(key: key);

  @override
  State<FleetManagementWidget> createState() => _FleetManagementWidgetState();
}

class _FleetManagementWidgetState extends State<FleetManagementWidget>
    with TickerProviderStateMixin {
  // Theme-aware colors following the design standards
  Color get primaryColor => Theme.of(context).colorScheme.primary;
  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(context).colorScheme.surface;
  Color get textColor => Theme.of(context).colorScheme.onSurface;
  Color get onSurfaceVariantColor =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  Color get shadowColor => Theme.of(context).colorScheme.shadow;
  Color get borderColor => Theme.of(context).colorScheme.outline;

  // Tab management for fleet sections
  int _selectedFleetTab = 0;
  final List<String> _fleetTabs = ['Routes', 'Buses', 'Seats'];

  // Filter state
  String _searchQuery = '';
  Map<String, dynamic> _filters = {
    'city': 'All',
    'branch': 'All',
    'status': 'All',
    'route': 'All',
    'capacity': 'All',
    'driver': 'All',
    'maintenance': 'All',
  };

  // Animation controllers
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // Mock data for routes
  final List<Map<String, dynamic>> _routes = [
    {
      'id': 'R001',
      'name': 'Douala → Yaoundé',
      'distance': '250 km',
      'duration': '4h 30m',
      'price': '7,500 XAF',
      'status': 'Active',
      'city': 'Douala',
      'branch': 'Ntarinkon',
      'tripsPerDay': 8,
      'popularity': 'High',
      'hasAvailableBuses': true,
      'availableBuses': 3
    },
    {
      'id': 'R002',
      'name': 'Yaoundé → Bamenda',
      'distance': '350 km',
      'duration': '6h 15m',
      'price': '8,000 XAF',
      'status': 'Active',
      'city': 'Yaoundé',
      'branch': 'Mfoundi',
      'tripsPerDay': 6,
      'popularity': 'Medium',
      'hasAvailableBuses': true,
      'availableBuses': 2
    },
    {
      'id': 'R003',
      'name': 'Douala → Bafoussam',
      'distance': '280 km',
      'duration': '5h 00m',
      'price': '7,000 XAF',
      'status': 'Active',
      'city': 'Douala',
      'branch': 'Sonac Street',
      'tripsPerDay': 5,
      'popularity': 'Medium',
      'hasAvailableBuses': false,
      'availableBuses': 0
    },
    {
      'id': 'R004',
      'name': 'Garoua → Maroua',
      'distance': '180 km',
      'duration': '3h 45m',
      'price': '6,500 XAF',
      'status': 'Active',
      'city': 'Garoua',
      'branch': 'Central',
      'tripsPerDay': 4,
      'popularity': 'Low',
      'hasAvailableBuses': true,
      'availableBuses': 1
    },
    {
      'id': 'R005',
      'name': 'Bamenda → Yaoundé',
      'distance': '350 km',
      'duration': '6h 15m',
      'price': '8,000 XAF',
      'status': 'Maintenance',
      'city': 'Bamenda',
      'branch': 'Commercial',
      'tripsPerDay': 0,
      'popularity': 'Medium',
      'hasAvailableBuses': false,
      'availableBuses': 0
    },
    {
      'id': 'R006',
      'name': 'Limbe → Douala',
      'distance': '80 km',
      'duration': '1h 30m',
      'price': '6,500 XAF',
      'status': 'Active',
      'city': 'Limbe',
      'branch': 'Down Beach',
      'tripsPerDay': 12,
      'popularity': 'High',
      'hasAvailableBuses': true,
      'availableBuses': 4
    },
    {
      'id': 'R007',
      'name': 'Bafoussam → Douala',
      'distance': '280 km',
      'duration': '5h 00m',
      'price': '7,000 XAF',
      'status': 'Active',
      'city': 'Bafoussam',
      'branch': 'Commercial',
      'tripsPerDay': 6,
      'popularity': 'Medium',
      'hasAvailableBuses': true,
      'availableBuses': 2
    },
  ];

  // Mock data for buses
  final List<Map<String, dynamic>> _buses = [
    {
      'id': 'B001',
      'plateNumber': 'CM-001-AB',
      'model': 'Mercedes-Benz Sprinter',
      'capacity': 70,
      'availableSeats': 23,
      'status': 'Active',
      'statusFlag': 'Available',
      'lastMaintenance': '2025-01-15',
      'nextMaintenance': '2025-04-15',
      'driver': 'Jean Mballa',
      'conductor': 'Marie Nguema',
      'route': 'Douala → Yaoundé',
      'city': 'Douala',
      'branch': 'Ntarinkon',
      'fuelLevel': '85%',
      'mileage': '125,000 km',
      'year': '2020',
      'insuranceExpiry': '2025-12-31',
      'registrationDate': '2020-03-15'
    },
    {
      'id': 'B002',
      'plateNumber': 'CM-002-CD',
      'model': 'Toyota Coaster',
      'capacity': 70,
      'availableSeats': 45,
      'status': 'Active',
      'statusFlag': 'Available',
      'lastMaintenance': '2025-01-10',
      'nextMaintenance': '2025-04-10',
      'driver': 'Marie Nguema',
      'conductor': 'Paul Essomba',
      'route': 'Yaoundé → Bamenda',
      'city': 'Yaoundé',
      'branch': 'Mfoundi',
      'fuelLevel': '92%',
      'mileage': '98,500 km',
      'year': '2021',
      'insuranceExpiry': '2025-11-30',
      'registrationDate': '2021-01-20'
    },
    {
      'id': 'B003',
      'plateNumber': 'CM-003-EF',
      'model': 'Ford Transit',
      'capacity': 70,
      'availableSeats': 0,
      'status': 'Maintenance',
      'statusFlag': 'Full',
      'lastMaintenance': '2025-01-20',
      'nextMaintenance': '2025-04-20',
      'driver': 'Paul Essomba',
      'conductor': 'Grace Mvondo',
      'route': 'Douala → Bafoussam',
      'city': 'Douala',
      'branch': 'Sonac Street',
      'fuelLevel': '15%',
      'mileage': '156,000 km',
      'year': '2019',
      'insuranceExpiry': '2025-10-15',
      'registrationDate': '2019-08-10'
    },
    {
      'id': 'B004',
      'plateNumber': 'CM-004-GH',
      'model': 'Mercedes-Benz Sprinter',
      'capacity': 70,
      'availableSeats': 67,
      'status': 'Active',
      'statusFlag': 'Almost Empty',
      'lastMaintenance': '2025-01-12',
      'nextMaintenance': '2025-04-12',
      'driver': 'Grace Mvondo',
      'conductor': 'David Nkeng',
      'route': 'Garoua → Maroua',
      'city': 'Garoua',
      'branch': 'Central',
      'fuelLevel': '78%',
      'mileage': '89,200 km',
      'year': '2022',
      'insuranceExpiry': '2025-01-15',
      'registrationDate': '2022-05-08'
    },
    {
      'id': 'B005',
      'plateNumber': 'CM-005-IJ',
      'model': 'Toyota Coaster',
      'capacity': 70,
      'availableSeats': 70,
      'status': 'Inactive',
      'statusFlag': 'Empty',
      'lastMaintenance': '2024-12-15',
      'nextMaintenance': '2025-03-15',
      'driver': 'David Nkeng',
      'conductor': 'Jean Mballa',
      'route': 'Bamenda → Yaoundé',
      'city': 'Bamenda',
      'branch': 'Upstation',
      'fuelLevel': '0%',
      'mileage': '203,500 km',
      'year': '2018',
      'insuranceExpiry': '2025-09-30',
      'registrationDate': '2018-11-25'
    },
    {
      'id': 'B006',
      'plateNumber': 'CM-006-KL',
      'model': 'Mercedes-Benz Sprinter',
      'capacity': 70,
      'availableSeats': 5,
      'status': 'Active',
      'statusFlag': 'Almost Full',
      'lastMaintenance': '2025-01-18',
      'nextMaintenance': '2025-04-18',
      'driver': 'Sarah Mvondo',
      'conductor': 'Peter Nguema',
      'route': 'Douala → Limbe',
      'city': 'Douala',
      'branch': 'Sonac Street',
      'fuelLevel': '95%',
      'mileage': '67,300 km',
      'year': '2023',
      'insuranceExpiry': '2025-03-20',
      'registrationDate': '2023-02-14'
    },
    {
      'id': 'B006',
      'plateNumber': 'CM-006-GH',
      'model': 'Mercedes-Benz Sprinter',
      'capacity': 70,
      'availableSeats': 15,
      'status': 'Active',
      'statusFlag': 'Available',
      'lastMaintenance': '2025-01-25',
      'nextMaintenance': '2025-04-25',
      'driver': 'Grace Mvondo',
      'conductor': 'David Nkeng',
      'route': 'Limbe → Douala',
      'city': 'Limbe',
      'branch': 'Down Beach',
      'fuelLevel': '78%',
      'mileage': '95,000 km',
      'year': '2021',
      'insuranceExpiry': '2025-10-15',
      'registrationDate': '2021-05-10'
    },
    {
      'id': 'B007',
      'plateNumber': 'CM-007-IJ',
      'model': 'Toyota Coaster',
      'capacity': 70,
      'availableSeats': 8,
      'status': 'Active',
      'statusFlag': 'Almost Full',
      'lastMaintenance': '2025-01-30',
      'nextMaintenance': '2025-04-30',
      'driver': 'Sarah Mvondo',
      'conductor': 'Peter Nguema',
      'route': 'Bafoussam → Douala',
      'city': 'Bafoussam',
      'branch': 'Commercial',
      'fuelLevel': '88%',
      'mileage': '110,000 km',
      'year': '2020',
      'insuranceExpiry': '2025-09-20',
      'registrationDate': '2020-08-15'
    },
  ];

  // Mock data for seats
  final List<Map<String, dynamic>> _seats = [
    {
      'id': 'S001',
      'seatNumber': 'A1',
      'busId': 'B001',
      'type': 'Window',
      'status': 'Available',
      'price': '7,500 XAF',
      'route': 'Douala → Yaoundé',
      'city': 'Douala',
      'branch': 'Ntarinkon',
      'location': 'Douala - Main Branch'
    },
    {
      'id': 'S002',
      'seatNumber': 'A2',
      'busId': 'B001',
      'type': 'Aisle',
      'status': 'Pending',
      'price': '7,000 XAF',
      'route': 'Douala → Yaoundé'
    },
    {
      'id': 'S003',
      'seatNumber': 'B1',
      'busId': 'B002',
      'type': 'Window',
      'status': 'Available',
      'price': '8,000 XAF',
      'route': 'Yaoundé → Bamenda',
      'city': 'Yaoundé',
      'branch': 'Mfoundi'
    },
    {
      'id': 'S004',
      'seatNumber': 'B2',
      'busId': 'B002',
      'type': 'Aisle',
      'status': 'Pending',
      'price': '7,500 XAF',
      'route': 'Yaoundé → Bamenda'
    },
    {
      'id': 'S005',
      'seatNumber': 'C1',
      'busId': 'B003',
      'type': 'Window',
      'status': 'Available',
      'price': '7,000 XAF',
      'route': 'Douala → Bafoussam',
      'location': 'Douala - Airport Branch'
    },
    {
      'id': 'S006',
      'seatNumber': 'C2',
      'busId': 'B003',
      'type': 'Aisle',
      'status': 'Available',
      'price': '6,500 XAF',
      'route': 'Douala → Bafoussam'
    },
    {
      'id': 'S007',
      'seatNumber': 'D1',
      'busId': 'B004',
      'type': 'Window',
      'status': 'Pending',
      'price': '7,800 XAF',
      'route': 'Garoua → Maroua',
      'location': 'Garoua - Central Branch'
    },
    {
      'id': 'S008',
      'seatNumber': 'D2',
      'busId': 'B004',
      'type': 'Aisle',
      'status': 'Available',
      'price': '7,200 XAF',
      'route': 'Garoua → Maroua',
      'location': 'Garoua - Central Branch'
    },
    {
      'id': 'S009',
      'seatNumber': 'E1',
      'busId': 'B005',
      'type': 'Window',
      'status': 'Available',
      'price': '6,800 XAF',
      'route': 'Bamenda → Yaoundé'
    },
    {
      'id': 'S010',
      'seatNumber': 'E2',
      'busId': 'B005',
      'type': 'Aisle',
      'status': 'Pending',
      'price': '6,500 XAF',
      'route': 'Bamenda → Yaoundé'
    },
  ];

  @override
  void initState() {
    super.initState();
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    _slideAnimationController.forward();
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 2.h),
              _buildSearchAndFilterSection(),
              SizedBox(height: 2.h),
              _buildFleetTabs(),
              SizedBox(height: 2.h),
              _buildFleetContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fleet Management',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Manage routes, buses, and seat availability',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: onSurfaceVariantColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: GoogleFonts.inter(
                  color: textColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: _getSearchHint(),
                  hintStyle: GoogleFonts.inter(
                    color: onSurfaceVariantColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: onSurfaceVariantColor,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 2.h,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          // Filter button
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _showFilterBottomSheet();
            },
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.filter_list,
                color: onSurfaceVariantColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSearchHint() {
    switch (_selectedFleetTab) {
      case 0:
        return 'Search routes, destinations...';
      case 1:
        return 'Search buses, drivers, plates...';
      case 2:
        return 'Search seats, types, status...';
      default:
        return 'Search...';
    }
  }

  Widget _buildFleetTabs() {
    return Container(
      padding: EdgeInsets.all(0.5.w),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: _fleetTabs.asMap().entries.map((entry) {
          final int index = entry.key;
          final String tab = entry.value;
          final bool isSelected = _selectedFleetTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedFleetTab = index;
                });
                _slideAnimationController.reset();
                _slideAnimationController.forward();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                margin: EdgeInsets.all(0.5.w),
                padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutCubic,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : onSurfaceVariantColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    child: Text(tab),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFleetContent() {
    switch (_selectedFleetTab) {
      case 0:
        return _buildRoutesView();
      case 1:
        return _buildBusesView();
      case 2:
        return _buildSeatsView();
      default:
        return _buildRoutesView();
    }
  }

  Widget _buildRoutesView() {
    final filteredRoutes = _getFilteredData();
    return Column(
      children: [
        _buildSectionHeader('Available Routes', filteredRoutes.length),
        SizedBox(height: 1.h),
        ...filteredRoutes.map((route) => _buildRouteCard(route)).toList(),
      ],
    );
  }

  Widget _buildBusesView() {
    final filteredBuses = _getFilteredData();
    return Column(
      children: [
        _buildSectionHeader('Fleet Buses', filteredBuses.length),
        SizedBox(height: 1.h),
        ...filteredBuses.map((bus) => _buildBusCard(bus)).toList(),
      ],
    );
  }

  Widget _buildSeatsView() {
    final filteredSeats = _getFilteredData();
    return Column(
      children: [
        _buildSectionHeader('Seat Availability', filteredSeats.length),
        SizedBox(height: 1.h),
        ...filteredSeats.map((seat) => _buildSeatCard(seat)).toList(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(width: 2.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
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
                        route['name'],
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${route['distance']} • ${route['duration']}',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: onSurfaceVariantColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _buildStatusBadge(route['status']),
                    SizedBox(height: 0.5.h),
                    _buildAvailabilityBadge(
                        route['hasAvailableBuses'], route['availableBuses']),
                  ],
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Price', route['price']),
                ),
                Expanded(
                  child: _buildInfoItem('Trips/Day', '${route['tripsPerDay']}'),
                ),
                Expanded(
                  child: _buildInfoItem('Popularity', route['popularity']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusCard(Map<String, dynamic> bus) {
    return GestureDetector(
      onTap: () => _showBusDetailSheet(bus),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(3.w),
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
                          bus['plateNumber'],
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          bus['model'],
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: onSurfaceVariantColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(bus['statusFlag']),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem('Available',
                        '${bus['availableSeats']}/${bus['capacity']} seats'),
                  ),
                  Expanded(
                    child: _buildInfoItem('Driver', bus['driver']),
                  ),
                  Expanded(
                    child: _buildInfoItem('Route', bus['route']),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Expanded(
                    child:
                        _buildInfoItem('Last Service', bus['lastMaintenance']),
                  ),
                  Expanded(
                    child:
                        _buildInfoItem('Next Service', bus['nextMaintenance']),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 3.w,
                    color: primaryColor,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Tap to view seats & book',
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
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

  Widget _buildSeatCard(Map<String, dynamic> seat) {
    return GestureDetector(
      onTap: () => _navigateToSeatBooking(seat),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: EdgeInsets.only(bottom: 1.5.h),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      seat['seatNumber'],
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seat ${seat['seatNumber']}',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        '${seat['type']} • ${seat['route']}',
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          color: onSurfaceVariantColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.2.h),
                      Text(
                        'Tap to book',
                        style: GoogleFonts.inter(
                          fontSize: 8.sp,
                          color: primaryColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(seat['status']),
                    SizedBox(height: 0.3.h),
                    Text(
                      seat['price'],
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
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

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            color: onSurfaceVariantColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    switch (status.toLowerCase()) {
      case 'active':
        badgeColor = Colors.green;
        break;
      case 'maintenance':
        badgeColor = Colors.orange;
        break;
      case 'inactive':
        badgeColor = Colors.red;
        break;
      case 'booked':
        badgeColor = Colors.blue;
        break;
      case 'pending':
        badgeColor = Colors.orange;
        break;
      case 'available':
        badgeColor = Colors.green;
        break;
      case 'full':
        badgeColor = Colors.red;
        break;
      case 'almost full':
        badgeColor = Colors.orange;
        break;
      case 'almost empty':
        badgeColor = Colors.lightGreen;
        break;
      case 'empty':
        badgeColor = Colors.grey;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 8.sp,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  List<String> _getBranchesForCity(String city) {
    switch (city) {
      case 'Douala':
        return ['All', 'Ntarinkon', 'Sonac Street', 'City Chemist', 'Airport'];
      case 'Yaoundé':
        return ['All', 'Mfoundi', 'Nlongkak', 'Central', 'Bastos'];
      case 'Bamenda':
        return ['All', 'Commercial', 'Upstation', 'Mile 4', 'Nkwen'];
      case 'Garoua':
        return ['All', 'Central', 'Airport', 'Industrial', 'Maroua Road'];
      case 'Limbe':
        return ['All', 'Down Beach', 'Tiko Road', 'Mile 1', 'Victoria'];
      case 'Bafoussam':
        return ['All', 'Commercial', 'Airport', 'Mankon', 'Upstation'];
      default:
        return ['All'];
    }
  }

  Widget _buildAvailabilityBadge(bool hasAvailableBuses, int availableBuses) {
    Color badgeColor;
    String text;

    if (hasAvailableBuses) {
      badgeColor = Colors.green;
      text = '$availableBuses buses available';
    } else {
      badgeColor = Colors.red;
      text = 'No buses';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 8.sp,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  void _showBusDetailSheet(Map<String, dynamic> bus) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BusDetailSheet(
        bus: bus,
        onBookSeat: (seatNumber) => _navigateToSeatSelection(bus, seatNumber),
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _navigateToSeatSelection(Map<String, dynamic> bus, String? seatNumber) {
    Navigator.pop(context); // Close the sheet first
    // Navigate to seat selection screen
    Navigator.pushNamed(
      context,
      '/seat-selection',
      arguments: {
        'bus': bus,
        'preSelectedSeat': seatNumber,
      },
    );
  }

  void _navigateToSeatBooking(Map<String, dynamic> seat) {
    print('Seat clicked: ${seat['seatNumber']}'); // Debug print
    HapticFeedback.selectionClick();

    // Find the corresponding bus and route info
    final bus = _buses.firstWhere(
      (bus) => bus['id'] == seat['busId'],
      orElse: () => _buses.first,
    );

    final route = _routes.firstWhere(
      (route) => route['name'] == seat['route'],
      orElse: () => _routes.first,
    );

    print('Found bus: ${bus['model']}, route: ${route['name']}'); // Debug print

    // Navigate to seat booking summary screen
    Navigator.pushNamed(
      context,
      '/seat-booking-summary',
      arguments: {
        'seat': seat,
        'busInfo': bus,
        'routeInfo': route,
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 2.h),
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: onSurfaceVariantColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Text(
                  'Filter Fleet',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // City filter
                      _buildFilterSection(
                          'City',
                          [
                            'All',
                            'Douala',
                            'Yaoundé',
                            'Bamenda',
                            'Garoua',
                            'Limbe',
                            'Bafoussam'
                          ],
                          setModalState),
                      SizedBox(height: 2.h),
                      // Branch filter (based on selected city)
                      if (_filters['city'] != 'All') ...[
                        _buildFilterSection(
                            'Branch',
                            _getBranchesForCity(_filters['city']),
                            setModalState),
                        SizedBox(height: 2.h),
                      ],
                      // Status filter
                      _buildFilterSection(
                          'Status',
                          ['All', 'Active', 'Inactive', 'Maintenance'],
                          setModalState),
                      SizedBox(height: 2.h),
                      // Route filter
                      _buildFilterSection(
                          'Route',
                          [
                            'All',
                            'Douala → Yaoundé',
                            'Yaoundé → Bamenda',
                            'Douala → Bafoussam',
                            'Garoua → Maroua',
                            'Bamenda → Yaoundé',
                            'Douala → Limbe'
                          ],
                          setModalState),
                      SizedBox(height: 2.h),
                      // Capacity filter
                      _buildFilterSection(
                          'Capacity',
                          ['All', 'Available', 'Almost Full', 'Full', 'Empty'],
                          setModalState),
                      SizedBox(height: 2.h),
                      // Driver filter
                      _buildFilterSection(
                          'Driver',
                          [
                            'All',
                            'Jean Mballa',
                            'Marie Nguema',
                            'Paul Essomba',
                            'Grace Mvondo',
                            'David Nkeng',
                            'Sarah Mvondo',
                            'Peter Nguema'
                          ],
                          setModalState),
                      SizedBox(height: 2.h),
                      // Maintenance filter
                      _buildFilterSection(
                          'Maintenance',
                          ['All', 'Due Soon', 'Recently Done', 'Overdue'],
                          setModalState),
                      SizedBox(height: 3.h),
                    ],
                  ),
                ),
              ),
              // Fixed bottom buttons
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(
                    top: BorderSide(
                      color: borderColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _filters = {
                              'city': 'All',
                              'branch': 'All',
                              'status': 'All',
                              'route': 'All',
                              'capacity': 'All',
                              'driver': 'All',
                              'maintenance': 'All',
                            };
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: onSurfaceVariantColor,
                          side: BorderSide(color: borderColor),
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Apply Filters',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
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
        ),
      ),
    );
  }

  Widget _buildFilterSection(
      String title, List<String> options, StateSetter setStateCallback) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          children: options.map((option) {
            final String filterKey = title.toLowerCase().replaceAll(' ', '');
            final bool isSelected = _filters[filterKey] == option;

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setStateCallback(() {
                  // Toggle selection: if already selected, deselect; otherwise select
                  if (_filters[filterKey] == option) {
                    _filters[filterKey] = 'All';
                  } else {
                    _filters[filterKey] = option;
                  }
                  // Reset branch filter when city changes
                  if (title == 'City') {
                    _filters['branch'] = 'All';
                  }
                });
                // Also update the main widget state to apply filters
                setState(() {});
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                margin: EdgeInsets.only(right: 2.w, bottom: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withOpacity(0.2)
                      : surfaceColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : borderColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        Icons.check,
                        size: 16,
                        color: primaryColor,
                      ),
                      SizedBox(width: 1.w),
                    ],
                    Text(
                      option,
                      style: GoogleFonts.inter(
                        color: isSelected ? primaryColor : textColor,
                        fontSize: 10.sp,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredData() {
    List<Map<String, dynamic>> data = [];

    switch (_selectedFleetTab) {
      case 0:
        data = List.from(_routes);
        break;
      case 1:
        data = List.from(_buses);
        break;
      case 2:
        // For seats tab, only show available and pending seats
        data = _seats
            .where((seat) =>
                seat['status'] == 'Available' || seat['status'] == 'Pending')
            .toList();
        break;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      data = data.where((item) {
        final query = _searchQuery.toLowerCase();
        return item.values
            .any((value) => value.toString().toLowerCase().contains(query));
      }).toList();
    }

    // Apply other filters
    if (_filters['city'] != 'All') {
      data = data.where((item) => item['city'] == _filters['city']).toList();
    }

    if (_filters['branch'] != 'All') {
      data =
          data.where((item) => item['branch'] == _filters['branch']).toList();
    }

    if (_filters['status'] != 'All') {
      data = data
          .where((item) =>
              item['status'] == _filters['status'] ||
              item['statusFlag'] == _filters['status'])
          .toList();
    }

    if (_filters['route'] != 'All') {
      data = data
          .where((item) =>
              item['route'] == _filters['route'] ||
              item['name'] == _filters['route'])
          .toList();
    }

    return data;
  }
}
