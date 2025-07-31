import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/booking_card_widget.dart';
import './widgets/booking_filter_sheet.dart';
import './widgets/empty_bookings_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/segmented_control_widget.dart';
import '../home_screen/widgets/ultra_modern_nav.dart';
import '../../widgets/custom_drawer.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({Key? key}) : super(key: key);

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with TickerProviderStateMixin {
  int _currentBottomNavIndex = 1; // Set to bookings tab
  int _selectedSegment = 0;
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  bool _isLoading = false;
  late AnimationController _refreshController;

  final List<String> _segments = ['Upcoming', 'Completed', 'Cancelled'];

  // Mock booking data
  final List<Map<String, dynamic>> _allBookings = [
    {
      "id": 1,
      "bookingReference": "TE2025001",
      "fromCity": "Douala",
      "toCity": "Yaoundé",
      "departureTime": "08:30 AM",
      "arrivalTime": "12:45 PM",
      "duration": "4h 15m",
      "travelDate": "Jan 25, 2025",
      "seatNumbers": ["A12", "A13"],
      "totalAmount": "XFA 3,500",
      "status": "confirmed",
      "busNumber": "GE 203",
      "operatorName": "Guarantee Express",
    },
    {
      "id": 2,
      "bookingReference": "TE2025002",
      "fromCity": "Bamenda",
      "toCity": "Douala",
      "departureTime": "06:00 AM",
      "arrivalTime": "12:30 PM",
      "duration": "6h 30m",
      "travelDate": "Jan 28, 2025",
      "seatNumbers": ["B05"],
      "totalAmount": "XFA 4,500",
      "status": "pending",
      "busNumber": "FE 156",
      "operatorName": "Finexs Express",
    },
    {
      "id": 3,
      "bookingReference": "TE2024156",
      "fromCity": "Kumba",
      "toCity": "Limbe",
      "departureTime": "02:15 PM",
      "arrivalTime": "05:00 PM",
      "duration": "2h 45m",
      "travelDate": "Dec 15, 2024",
      "seatNumbers": ["C08", "C09"],
      "totalAmount": "XFA 2,500",
      "status": "completed",
      "busNumber": "MT 089",
      "operatorName": "Musango Transport",
    },
    {
      "id": 4,
      "bookingReference": "TE2024198",
      "fromCity": "Yaoundé",
      "toCity": "Bafoussam",
      "departureTime": "10:00 AM",
      "arrivalTime": "02:15 PM",
      "duration": "4h 15m",
      "travelDate": "Dec 22, 2024",
      "seatNumbers": ["D15"],
      "totalAmount": "XFA 3,200",
      "status": "cancelled",
      "busNumber": "CE 234",
      "operatorName": "Central Express",
    },
    {
      "id": 5,
      "bookingReference": "TE2024203",
      "fromCity": "Bafoussam",
      "toCity": "Bamenda",
      "departureTime": "04:45 PM",
      "arrivalTime": "07:30 PM",
      "duration": "2h 45m",
      "travelDate": "Nov 18, 2024",
      "seatNumbers": ["A01", "A02"],
      "totalAmount": "XFA 2,800",
      "status": "completed",
      "busNumber": "BT 167",
      "operatorName": "Binam Transport",
    },
  ];

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      drawer: const CustomDrawer(),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          SearchBarWidget(
            hintText: 'Search bookings...',
            onSearchChanged: _onSearchChanged,
            onFilterTap: _showFilterSheet,
          ),
          SegmentedControlWidget(
            segments: _segments,
            selectedIndex: _selectedSegment,
            onSegmentChanged: _onSegmentChanged,
          ),
          Expanded(
            child: _buildBookingsList(context),
          ),
        ],
      ),
      bottomNavigationBar: UltraModernNav(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
        items: const [
          NavItems.home,
          NavItems.bookings,
          NavItems.profile,
        ],
        backgroundColor: const Color(0xFF1A4A47),
        activeColor: const Color(0xFFC8E53F),
        inactiveColor: Colors.white.withOpacity(0.7),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('My Bookings'),
      backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
      foregroundColor: AppTheme.lightTheme.appBarTheme.foregroundColor,
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: CustomIconWidget(
            iconName: 'menu',
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            size: 6.w,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showActionSheet,
          icon: CustomIconWidget(
            iconName: 'more_vert',
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            size: 6.w,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingsList(BuildContext context) {
    final List<Map<String, dynamic>> filteredBookings = _getFilteredBookings();

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryLight,
        ),
      );
    }

    if (filteredBookings.isEmpty) {
      return EmptyBookingsWidget(
        bookingType: _segments[_selectedSegment].toLowerCase(),
        onBookNow: _navigateToHome,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshBookings,
      color: AppTheme.primaryLight,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          return BookingCardWidget(
            booking: booking,
            onViewTicket: () => _viewTicket(booking),
            onModify: () => _modifyBooking(booking),
            onCancel: () => _cancelBooking(booking),
            onShare: () => _shareBooking(booking),
            onDownloadReceipt: () => _downloadReceipt(booking),
            onRebook: () => _rebookJourney(booking),
            onRate: () => _rateJourney(booking),
          );
        },
      ),
    );
  }


  List<Map<String, dynamic>> _getFilteredBookings() {
    List<Map<String, dynamic>> filtered = List.from(_allBookings);

    // Filter by segment
    switch (_selectedSegment) {
      case 0: // Upcoming
        filtered = filtered
            .where((booking) =>
                booking['status'] == 'confirmed' ||
                booking['status'] == 'pending')
            .toList();
        break;
      case 1: // Completed
        filtered = filtered
            .where((booking) => booking['status'] == 'completed')
            .toList();
        break;
      case 2: // Cancelled
        filtered = filtered
            .where((booking) => booking['status'] == 'cancelled')
            .toList();
        break;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((booking) {
        final searchLower = _searchQuery.toLowerCase();
        return (booking['fromCity'] as String)
                .toLowerCase()
                .contains(searchLower) ||
            (booking['toCity'] as String).toLowerCase().contains(searchLower) ||
            (booking['bookingReference'] as String)
                .toLowerCase()
                .contains(searchLower);
      }).toList();
    }

    // Apply additional filters
    if (_activeFilters.isNotEmpty) {
      if (_activeFilters['status'] != null &&
          _activeFilters['status'] != 'All') {
        filtered = filtered
            .where((booking) =>
                (booking['status'] as String).toLowerCase() ==
                (_activeFilters['status'] as String).toLowerCase())
            .toList();
      }

      if (_activeFilters['route'] != null &&
          _activeFilters['route'] != 'All Routes') {
        final selectedRoute = _activeFilters['route'] as String;
        filtered = filtered.where((booking) {
          final route = '${booking['fromCity']} - ${booking['toCity']}';
          return route == selectedRoute;
        }).toList();
      }

      if (_activeFilters['dateRange'] != null) {
        final DateTimeRange dateRange =
            _activeFilters['dateRange'] as DateTimeRange;
        filtered = filtered.where((booking) {
          // For demo purposes, we'll use a simple date comparison
          // In a real app, you'd parse the actual date from booking['travelDate']
          return true; // Placeholder logic
        }).toList();
      }
    }

    return filtered;
  }

  void _onSegmentChanged(int index) {
    setState(() {
      _selectedSegment = index;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onBottomNavTap(int index) {
    if (index == _currentBottomNavIndex) return;
    
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
        break;
      case 1:
        // Already on bookings screen
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingFilterSheet(
        currentFilters: _activeFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _activeFilters = filters;
          });
        },
      ),
    );
  }

  void _showActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'support_agent',
                color: AppTheme.primaryLight,
                size: 6.w,
              ),
              title: Text('Customer Support'),
              onTap: () {
                Navigator.pop(context);
                _contactSupport();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'help_outline',
                color: AppTheme.primaryLight,
                size: 6.w,
              ),
              title: Text('Help & FAQ'),
              onTap: () {
                Navigator.pop(context);
                _showHelp();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.primaryLight,
                size: 6.w,
              ),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _openSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshBookings() async {
    setState(() {
      _isLoading = true;
    });

    _refreshController.forward();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    _refreshController.reset();
  }


  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
  }

  void _viewTicket(Map<String, dynamic> booking) {
    Navigator.pushNamed(
      context,
      '/booking-details-screen',
      arguments: booking,
    );
  }

  void _modifyBooking(Map<String, dynamic> booking) {
    Navigator.pushNamed(
      context,
      '/seat-selection-screen',
      arguments: {'bookingId': booking['id'], 'isModification': true},
    );
  }

  void _cancelBooking(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking'),
        content: Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processCancellation(booking);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
            ),
            child: Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  void _shareBooking(Map<String, dynamic> booking) {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking details shared successfully'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _downloadReceipt(Map<String, dynamic> booking) {
    // Implement receipt download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Receipt downloaded successfully'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _rebookJourney(Map<String, dynamic> booking) {
    Navigator.pushNamed(
      context,
      '/home-screen',
      arguments: {
        'fromCity': booking['fromCity'],
        'toCity': booking['toCity'],
      },
    );
  }

  void _rateJourney(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate Your Journey'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'How was your trip from ${booking['fromCity']} to ${booking['toCity']}?'),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _submitRating(booking, index + 1);
                  },
                  icon: CustomIconWidget(
                    iconName: 'star',
                    color: AppTheme.secondaryLight,
                    size: 8.w,
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Skip'),
          ),
        ],
      ),
    );
  }

  void _processCancellation(Map<String, dynamic> booking) {
    setState(() {
      final index = _allBookings.indexWhere((b) => b['id'] == booking['id']);
      if (index != -1) {
        _allBookings[index]['status'] = 'cancelled';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking cancelled successfully'),
        backgroundColor: AppTheme.errorLight,
      ),
    );
  }

  void _submitRating(Map<String, dynamic> booking, int rating) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for rating your journey! ($rating stars)'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connecting to customer support...'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening help center...'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening settings...'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }
}
