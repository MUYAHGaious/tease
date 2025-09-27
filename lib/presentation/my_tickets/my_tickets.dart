
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/theme_notifier.dart';
import '../../widgets/global_bottom_navigation.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/segmented_control_widget.dart';
import './widgets/ticket_card_widget.dart';

class MyTickets extends StatefulWidget {
  const MyTickets({Key? key}) : super(key: key);

  @override
  State<MyTickets> createState() => _MyTicketsState();
}

class _MyTicketsState extends State<MyTickets> with TickerProviderStateMixin {

  // Theme-aware colors
  Color get primaryColor => const Color(0xFF008B8B);
  Color get backgroundColor => ThemeNotifier().isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get surfaceColor => ThemeNotifier().isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get textColor => ThemeNotifier().isDarkMode ? Colors.white : Colors.black87;
  Color get onSurfaceVariantColor => ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54;
  Color get shadowColor => ThemeNotifier().isDarkMode ? Colors.black : Colors.grey[300]!;
  int _selectedSegment = 0;
  int _currentBottomNavIndex = 2;
  String _searchQuery = '';
  Map<String, dynamic> _currentFilters = {};
  bool _isRefreshing = false;

  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // Mock ticket data
  final List<Map<String, dynamic>> _allTickets = [
    {
      "id": "BF001",
      "bookingId": "BF2025001",
      "busOperator": "Tease Express",
      "fromCity": "Douala",
      "fromTerminal": "Douala Central",
      "toCity": "Yaoundé",
      "toTerminal": "Yaoundé Station",
      "travelDate": "Jul 30, 2025",
      "departureTime": "09:30 AM",
      "arrivalTime": "01:30 PM",
      "seatNumbers": "A1, A2",
      "status": "upcoming",
      "price": "44,950 XAF",
      "passengerCount": 2,
      "qrCode": "QR_BF2025001",
      "bookingDate": "Jul 28, 2025",
    },
    {
      "id": "BF002",
      "bookingId": "BF2025002",
      "busOperator": "Cameroon Express",
      "fromCity": "Yaoundé",
      "fromTerminal": "Yaoundé Station",
      "toCity": "Bamenda",
      "toTerminal": "Bamenda Terminal",
      "travelDate": "Aug 05, 2025",
      "departureTime": "02:15 PM",
      "arrivalTime": "06:45 PM",
      "seatNumbers": "B3",
      "status": "confirmed",
      "price": "37,750 XAF",
      "passengerCount": 1,
      "qrCode": "QR_BF2025002",
      "bookingDate": "Jul 27, 2025",
    },
    {
      "id": "BF003",
      "bookingId": "BF2025003",
      "busOperator": "Central Voyages",
      "fromCity": "Douala",
      "fromTerminal": "Douala Central",
      "toCity": "Bafoussam",
      "toTerminal": "Bafoussam Station",
      "travelDate": "Jul 15, 2025",
      "departureTime": "11:00 AM",
      "arrivalTime": "01:30 PM",
      "seatNumbers": "C5, C6",
      "status": "completed",
      "price": "22,500 XAF",
      "passengerCount": 2,
      "qrCode": "QR_BF2025003",
      "bookingDate": "Jul 10, 2025",
    },
    {
      "id": "BF004",
      "bookingId": "BF2025004",
      "busOperator": "Guaranty Express",
      "fromCity": "Garoua",
      "fromTerminal": "Garoua Terminal",
      "toCity": "Maroua",
      "toTerminal": "Maroua Terminal",
      "travelDate": "Jun 20, 2025",
      "departureTime": "08:45 AM",
      "arrivalTime": "12:15 PM",
      "seatNumbers": "D1",
      "status": "completed",
      "price": "27,875 XAF",
      "passengerCount": 1,
      "qrCode": "QR_BF2025004",
      "bookingDate": "Jun 15, 2025",
    },
    {
      "id": "BF005",
      "bookingId": "BF2025005",
      "busOperator": "Tease Express",
      "fromCity": "Bamenda",
      "fromTerminal": "Bamenda Terminal",
      "toCity": "Yaoundé",
      "toTerminal": "Yaoundé Station",
      "travelDate": "May 10, 2025",
      "departureTime": "07:30 AM",
      "arrivalTime": "11:45 AM",
      "seatNumbers": "A10",
      "status": "cancelled",
      "price": "41,000 XAF",
      "passengerCount": 1,
      "qrCode": "QR_BF2025005",
      "bookingDate": "May 05, 2025",
    },
  ];

  @override
  void initState() {
    super.initState();
    ThemeNotifier().addListener(_onThemeChanged);
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeAnimationController);

    _slideAnimationController.forward();
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
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
              _buildAppBar(),
              _buildSearchSection(),
              _buildSegmentedControl(),
              Expanded(
                child: _buildTicketsList(),
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

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: ThemeNotifier().isDarkMode ? Colors.white.withOpacity(0.2) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back,
                color: textColor,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Tickets',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Manage your bookings',
                  style: TextStyle(
                    fontSize: 14.sp,
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
                Icons.notifications_outlined,
                color: onSurfaceVariantColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return SearchBarWidget(
      hintText: 'Search by destination, date, or booking ID...',
      onSearchChanged: (query) {
        setState(() {
          _searchQuery = query;
        });
      },
      onFilterPressed: _showFilterBottomSheet,
    );
  }

  Widget _buildSegmentedControl() {
    return SegmentedControlWidget(
      segments: const ['Upcoming', 'Past'],
      selectedIndex: _selectedSegment,
      onSelectionChanged: (index) {
        setState(() {
          _selectedSegment = index;
        });
        _slideAnimationController.reset();
        _slideAnimationController.forward();
      },
    );
  }

  Widget _buildTicketsList() {
    final filteredTickets = _getFilteredTickets();

    if (filteredTickets.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshTickets,
      color: primaryColor,
      backgroundColor: surfaceColor,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 2.h),
            itemCount: filteredTickets.length,
            itemBuilder: (context, index) {
              final ticket = filteredTickets[index];
              return TicketCardWidget(
                ticketData: ticket,
                onTap: () => _showTicketDetails(ticket),
                onCancel: () => _cancelTicket(ticket),
                onModify: () => _modifyTicket(ticket),
                onShare: () => _shareTicket(ticket),
                onRebook: () => _rebookTicket(ticket),
                onRate: () => _rateTrip(ticket),
                onDownload: () => _downloadReceipt(ticket),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isUpcoming = _selectedSegment == 0;

    return EmptyStateWidget(
      title: isUpcoming ? 'No Upcoming Trips' : 'No Past Trips',
      subtitle: isUpcoming
          ? 'You don\'t have any upcoming bus trips. Book your next journey now!'
          : 'You haven\'t completed any trips yet. Start exploring new destinations!',
      buttonText: 'Book Now',
      onButtonPressed: () => _navigateToBooking(),
      illustrationUrl: isUpcoming
          ? 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3'
          : 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
    );
  }

  List<Map<String, dynamic>> _getFilteredTickets() {
    List<Map<String, dynamic>> tickets = List.from(_allTickets);

    // Filter by segment (upcoming/past)
    if (_selectedSegment == 0) {
      tickets = tickets
          .where((ticket) =>
              ticket['status'] == 'upcoming' || ticket['status'] == 'confirmed')
          .toList();
    } else {
      tickets = tickets
          .where((ticket) =>
              ticket['status'] == 'completed' ||
              ticket['status'] == 'cancelled')
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      tickets = tickets.where((ticket) {
        final query = _searchQuery.toLowerCase();
        return (ticket['fromCity'] as String).toLowerCase().contains(query) ||
            (ticket['toCity'] as String).toLowerCase().contains(query) ||
            (ticket['bookingId'] as String).toLowerCase().contains(query) ||
            (ticket['travelDate'] as String).toLowerCase().contains(query);
      }).toList();
    }

    // Apply additional filters
    if (_currentFilters['status'] != null) {
      tickets = tickets
          .where((ticket) => ticket['status'] == _currentFilters['status'])
          .toList();
    }

    if (_currentFilters['route'] != null) {
      final route = _currentFilters['route'] as String;
      tickets = tickets.where((ticket) {
        final ticketRoute = '${ticket['fromCity']} - ${ticket['toCity']}';
        return ticketRoute == route;
      }).toList();
    }

    if (_currentFilters['dateRange'] != null) {
      final dateRange = _currentFilters['dateRange'] as DateTimeRange;
      tickets = tickets.where((ticket) {
        // Simple date comparison (in real app, parse actual dates)
        return true; // Simplified for demo
      }).toList();
    }

    return tickets;
  }

  Future<void> _refreshTickets() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _currentFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _currentFilters = filters;
          });
        },
      ),
    );
  }

  void _showTicketDetails(Map<String, dynamic> ticket) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: shadowColor
                    .withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ticket Details',
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: textColor
                          .withValues(alpha: 0.7),
                      size: 24,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'qr_code',
                    color: primaryColor,
                    size: 40.w,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Booking ID: ${ticket['bookingId']}',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                '${ticket['fromCity']} → ${ticket['toCity']}',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: textColor
                      .withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No new notifications'),
        backgroundColor: surfaceColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _cancelTicket(Map<String, dynamic> ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Ticket'),
        content: Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ticket cancelled successfully')),
              );
            },
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _modifyTicket(Map<String, dynamic> ticket) {
    Navigator.pushNamed(context, '/passenger-details');
  }

  void _shareTicket(Map<String, dynamic> ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ticket shared successfully')),
    );
  }

  void _rebookTicket(Map<String, dynamic> ticket) {
    Navigator.pushNamed(context, '/home-dashboard');
  }

  void _rateTrip(Map<String, dynamic> ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate Your Trip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How was your experience?'),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Thank you for your rating!')),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    child: CustomIconWidget(
                      iconName: 'star',
                      color: Colors.orange,
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _downloadReceipt(Map<String, dynamic> ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Receipt downloaded successfully')),
    );
  }

  void _navigateToBooking() {
    Navigator.pushNamed(context, '/home-dashboard');
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home-dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/home-dashboard');
        break;
      case 2:
        // Current screen
        break;
      case 3:
        Navigator.pushNamed(context, '/profile-settings');
        break;
    }
  }
}
