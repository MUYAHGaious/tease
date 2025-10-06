import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/theme_notifier.dart';
import '../../widgets/global_bottom_navigation.dart';
import './widgets/booking_card_widget.dart';
import './widgets/seat_management_widget.dart';
import './widgets/walk_in_booking_widget.dart';
import './widgets/reports_widget.dart';
import './widgets/customer_service_widget.dart';
import './widgets/quick_actions_widget.dart';

class BookingManagement extends StatefulWidget {
  const BookingManagement({Key? key}) : super(key: key);

  @override
  State<BookingManagement> createState() => _BookingManagementState();
}

class _BookingManagementState extends State<BookingManagement>
    with TickerProviderStateMixin {
  // Theme-aware colors using proper theme system
  Color get primaryColor => Theme.of(context).colorScheme.primary;
  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(context).colorScheme.surface;
  Color get textColor => Theme.of(context).colorScheme.onSurface;
  Color get onSurfaceVariantColor =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  Color get shadowColor => Theme.of(context).colorScheme.shadow;
  Color get borderColor => Theme.of(context).colorScheme.outline;

  // Tab management - following your segmented control pattern
  int _selectedTab = 0;
  final List<String> _tabs = [
    'Today\'s Bookings',
    'Seat Management',
    'Customer Service',
    'Reports'
  ];

  // Search and filter state
  String _searchQuery = '';

  // Animation controllers following your pattern
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _tabAnimationController;

  // Mock booking data
  final List<Map<String, dynamic>> _allBookings = [
    {
      "id": "BK001",
      "bookingId": "BF2025001",
      "passengerName": "John Doe",
      "passengerEmail": "john.doe@email.com",
      "passengerPhone": "+237 123 456 789",
      "fromCity": "Douala",
      "toCity": "Yaoundé",
      "travelDate": "Jul 30, 2025",
      "departureTime": "09:30 AM",
      "seatNumbers": "A1, A2",
      "status": "confirmed",
      "price": "44,950 XAF",
      "passengerCount": 2,
      "bookingDate": "Jul 28, 2025",
      "busOperator": "Tease Express",
      "paymentStatus": "paid",
    },
    {
      "id": "BK002",
      "bookingId": "BF2025002",
      "passengerName": "Jane Smith",
      "passengerEmail": "jane.smith@email.com",
      "passengerPhone": "+237 987 654 321",
      "fromCity": "Yaoundé",
      "toCity": "Bamenda",
      "travelDate": "Aug 05, 2025",
      "departureTime": "02:15 PM",
      "seatNumbers": "B3",
      "status": "pending",
      "price": "37,750 XAF",
      "passengerCount": 1,
      "bookingDate": "Jul 27, 2025",
      "busOperator": "Cameroon Express",
      "paymentStatus": "pending",
    },
    {
      "id": "BK003",
      "bookingId": "BF2025003",
      "passengerName": "Mike Johnson",
      "passengerEmail": "mike.johnson@email.com",
      "passengerPhone": "+237 555 123 456",
      "fromCity": "Douala",
      "toCity": "Bafoussam",
      "travelDate": "Jul 15, 2025",
      "departureTime": "11:00 AM",
      "seatNumbers": "C5, C6",
      "status": "cancelled",
      "price": "22,500 XAF",
      "passengerCount": 2,
      "bookingDate": "Jul 10, 2025",
      "busOperator": "Central Voyages",
      "paymentStatus": "refunded",
    },
    {
      "id": "BK004",
      "bookingId": "BF2025004",
      "passengerName": "Sarah Wilson",
      "passengerEmail": "sarah.wilson@email.com",
      "passengerPhone": "+237 444 777 888",
      "fromCity": "Garoua",
      "toCity": "Maroua",
      "travelDate": "Jun 20, 2025",
      "departureTime": "08:45 AM",
      "seatNumbers": "D1",
      "status": "completed",
      "price": "27,875 XAF",
      "passengerCount": 1,
      "bookingDate": "Jun 15, 2025",
      "busOperator": "Guaranty Express",
      "paymentStatus": "paid",
    },
    {
      "id": "BK005",
      "bookingId": "BF2025005",
      "passengerName": "David Brown",
      "passengerEmail": "david.brown@email.com",
      "passengerPhone": "+237 333 666 999",
      "fromCity": "Bamenda",
      "toCity": "Yaoundé",
      "travelDate": "May 10, 2025",
      "departureTime": "07:30 AM",
      "seatNumbers": "A10",
      "status": "confirmed",
      "price": "41,000 XAF",
      "passengerCount": 1,
      "bookingDate": "May 05, 2025",
      "busOperator": "Tease Express",
      "paymentStatus": "paid",
    },
  ];

  @override
  void initState() {
    super.initState();
    ThemeNotifier().addListener(_onThemeChanged);

    // Slide animation for content transitions
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    // Fade animation for smooth transitions
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    // Tab animation for smooth tab switching
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _slideAnimationController.forward();
    _fadeAnimationController.forward();
    _tabAnimationController.forward();
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _tabAnimationController.dispose();
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
              _buildModernHeader(),
              _buildSearchAndFilterSection(),
              _buildSegmentedControl(),
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: GlobalBottomNavigation(
        initialIndex: 2, // My Tickets tab
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          // Back button with haptic feedback
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                  'Booking Management',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Manage passenger bookings & operations',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: onSurfaceVariantColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Quick actions container
          Container(
            decoration: BoxDecoration(
              color: surfaceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                _showQuickActions();
              },
              icon: Icon(
                Icons.more_vert,
                color: onSurfaceVariantColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search bookings, passengers, routes...',
                  hintStyle: GoogleFonts.inter(
                    color: onSurfaceVariantColor,
                    fontSize: 14.sp,
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
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.filter_list,
                color: Theme.of(context).colorScheme.onPrimary,
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
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
        children: _tabs.asMap().entries.map((entry) {
          final int index = entry.key;
          final String tab = entry.value;
          final bool isSelected = _selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedTab = index;
                });
                _slideAnimationController.reset();
                _slideAnimationController.forward();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                margin: EdgeInsets.all(0.5.w),
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
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
                      fontSize: 12.sp,
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

  Widget _buildTabContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _getTabContent(),
      ),
    );
  }

  Widget _getTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildTodaysBookings();
      case 1:
        return SeatManagementWidget(
          onSeatStatusChanged: _onSeatStatusChanged,
        );
      case 2:
        return CustomerServiceWidget(
          onWalkInBooking: _processWalkInBooking,
          onRefundProcessed: _onRefundProcessed,
        );
      case 3:
        return ReportsWidget(
          onExportReport: _exportReport,
        );
      default:
        return _buildTodaysBookings();
    }
  }

  Widget _buildTodaysBookings() {
    final filteredBookings = _getFilteredBookings();

    if (filteredBookings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshBookings,
      color: primaryColor,
      backgroundColor: surfaceColor,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 2.h),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          return BookingCardWidget(
            booking: booking,
            onViewDetails: () => _showBookingDetails(booking),
            onEditBooking: () => _editBooking(booking),
            onPrintBooking: () => _printBooking(booking),
            onCancelBooking: () => _cancelBooking(booking),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.selectionClick();
        _showQuickBookingDialog();
      },
      backgroundColor: primaryColor,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      icon: Icon(Icons.add),
      label: Text(
        'Quick Booking',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 20.w,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'No Bookings Found',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'No bookings match your current filters',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: onSurfaceVariantColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              _showQuickBookingDialog();
            },
            icon: Icon(Icons.add),
            label: Text('Create New Booking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // New comprehensive methods following your patterns
  void _onSeatStatusChanged(String seatId, String status) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seat $seatId status updated to $status'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _processWalkInBooking(Map<String, dynamic> bookingData) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Walk-in booking processed successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _onRefundProcessed(String bookingId, double amount) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Refund of $amount XAF processed for booking $bookingId'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _exportReport(String reportType) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$reportType report exported successfully'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showQuickBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => WalkInBookingWidget(
        onBookingCreated: _processWalkInBooking,
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsWidget(
        onActionSelected: (action) {
          Navigator.pop(context);
          _handleQuickAction(action);
        },
      ),
    );
  }

  void _handleQuickAction(String action) {
    HapticFeedback.selectionClick();
    switch (action) {
      case 'quick_booking':
        _showQuickBookingDialog();
        break;
      case 'seat_management':
        setState(() => _selectedTab = 1);
        break;
      case 'reports':
        setState(() => _selectedTab = 3);
        break;
      case 'customer_service':
        setState(() => _selectedTab = 2);
        break;
    }
  }

  void _cancelBooking(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: Text(
          'Cancel Booking',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel booking ${booking['bookingId']}?',
          style: GoogleFonts.inter(
            color: textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking cancelled successfully'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
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
                color: shadowColor.withOpacity(0.2),
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
                    'Booking Details',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: textColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              _buildDetailRow('Booking ID', booking['bookingId']),
              _buildDetailRow('Passenger', booking['passengerName']),
              _buildDetailRow(
                  'Route', '${booking['fromCity']} → ${booking['toCity']}'),
              _buildDetailRow('Date', booking['travelDate']),
              _buildDetailRow('Time', booking['departureTime']),
              _buildDetailRow('Seats', booking['seatNumbers']),
              _buildDetailRow('Price', booking['price']),
              _buildDetailRow(
                  'Status', booking['status'].toString().toUpperCase()),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _printBooking(booking);
                      },
                      icon: Icon(Icons.print),
                      label: Text('Print'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editBooking(booking);
                      },
                      icon: Icon(Icons.edit),
                      label: Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: onSurfaceVariantColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _editBooking(Map<String, dynamic> booking) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit booking functionality will be implemented'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _printBooking(Map<String, dynamic> booking) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Print booking functionality will be implemented'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: onSurfaceVariantColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Filter Bookings',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: 3.h),
            // Status filter
            _buildFilterSection('Status',
                ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled']),
            SizedBox(height: 2.h),
            // Date range filter
            _buildFilterSection(
                'Date Range', ['Today', 'This Week', 'This Month', 'Custom']),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: onSurfaceVariantColor,
                      side: BorderSide(color: borderColor),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      HapticFeedback.selectionClick();
                    },
                    child: Text('Apply'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
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
        Wrap(
          spacing: 2.w,
          children: options.map((option) {
            return FilterChip(
              label: Text(option),
              selected: false,
              onSelected: (selected) {
                HapticFeedback.selectionClick();
              },
              backgroundColor: surfaceColor,
              selectedColor: primaryColor.withOpacity(0.2),
              checkmarkColor: primaryColor,
              labelStyle: GoogleFonts.inter(
                color: textColor,
                fontSize: 12.sp,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredBookings() {
    List<Map<String, dynamic>> bookings = List.from(_allBookings);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      bookings = bookings.where((booking) {
        final query = _searchQuery.toLowerCase();
        return (booking['bookingId'] as String).toLowerCase().contains(query) ||
            (booking['passengerName'] as String)
                .toLowerCase()
                .contains(query) ||
            (booking['passengerEmail'] as String)
                .toLowerCase()
                .contains(query) ||
            (booking['fromCity'] as String).toLowerCase().contains(query) ||
            (booking['toCity'] as String).toLowerCase().contains(query);
      }).toList();
    }

    return bookings;
  }

  Future<void> _refreshBookings() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bookings refreshed successfully'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
