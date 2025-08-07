import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/booking_card_widget.dart';
import './widgets/booking_detail_widget.dart';
import './widgets/bottom_toolbar_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/skeleton_card_widget.dart';

class BookingHistory extends StatefulWidget {
  const BookingHistory({Key? key}) : super(key: key);

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allBookings = [];
  List<Map<String, dynamic>> _filteredBookings = [];
  Set<String> _selectedBookings = {};

  String _selectedDateFilter = 'All Time';
  String _selectedStatusFilter = 'All Status';
  String _selectedRouteFilter = 'All Routes';

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isMultiSelectMode = false;

  Map<String, dynamic>? _expandedBooking;

  @override
  void initState() {
    super.initState();
    _loadBookings();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreBookings();
    }
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Mock booking data
    final mockBookings = [
      {
        "bookingRef": "BK001234",
        "route": "Main Campus - Downtown",
        "date": DateTime.now().subtract(const Duration(days: 1)),
        "pickupTime": "08:00 AM",
        "dropoffTime": "08:45 AM",
        "pickupStop": "Main Campus Gate",
        "dropoffStop": "Downtown Terminal",
        "status": "Completed",
        "driverName": "John Smith",
        "busNumber": "SC-101",
        "boardingTime": "08:02 AM",
      },
      {
        "bookingRef": "BK001235",
        "route": "North Campus - City Center",
        "date": DateTime.now(),
        "pickupTime": "09:15 AM",
        "dropoffTime": "10:00 AM",
        "pickupStop": "North Campus Library",
        "dropoffStop": "City Center Mall",
        "status": "Confirmed",
        "driverName": "Sarah Johnson",
        "busNumber": "SC-102",
        "boardingTime": "Not Boarded",
      },
      {
        "bookingRef": "BK001236",
        "route": "South Campus - Airport",
        "date": DateTime.now().add(const Duration(days: 1)),
        "pickupTime": "02:30 PM",
        "dropoffTime": "03:15 PM",
        "pickupStop": "South Campus Dorms",
        "dropoffStop": "Airport Terminal 1",
        "status": "Confirmed",
        "driverName": "Mike Wilson",
        "busNumber": "SC-103",
        "boardingTime": "Not Boarded",
      },
      {
        "bookingRef": "BK001237",
        "route": "Main Campus - Shopping District",
        "date": DateTime.now().subtract(const Duration(days: 3)),
        "pickupTime": "11:00 AM",
        "dropoffTime": "11:30 AM",
        "pickupStop": "Main Campus Cafeteria",
        "dropoffStop": "Shopping District Plaza",
        "status": "Cancelled",
        "driverName": "Not Assigned",
        "busNumber": "N/A",
        "boardingTime": "Not Boarded",
      },
      {
        "bookingRef": "BK001238",
        "route": "East Campus - Train Station",
        "date": DateTime.now().subtract(const Duration(days: 7)),
        "pickupTime": "07:45 AM",
        "dropoffTime": "08:20 AM",
        "pickupStop": "East Campus Parking",
        "dropoffStop": "Central Train Station",
        "status": "No-Show",
        "driverName": "Lisa Brown",
        "busNumber": "SC-104",
        "boardingTime": "Not Boarded",
      },
    ];

    setState(() {
      _allBookings = mockBookings;
      _filteredBookings = List.from(_allBookings);
      _isLoading = false;
    });
  }

  Future<void> _loadMoreBookings() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    // Simulate loading more data
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() => _isLoadingMore = false);
  }

  Future<void> _refreshBookings() async {
    await _loadBookings();
  }

  void _filterBookings() {
    List<Map<String, dynamic>> filtered = List.from(_allBookings);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((booking) {
        final route = (booking['route'] as String? ?? '').toLowerCase();
        final bookingRef =
            (booking['bookingRef'] as String? ?? '').toLowerCase();
        final date = booking['date'] as DateTime?;
        final dateString =
            date != null ? '${date.day}/${date.month}/${date.year}' : '';

        return route.contains(searchTerm) ||
            bookingRef.contains(searchTerm) ||
            dateString.contains(searchTerm);
      }).toList();
    }

    // Apply status filter
    if (_selectedStatusFilter != 'All Status') {
      filtered = filtered
          .where((booking) => booking['status'] == _selectedStatusFilter)
          .toList();
    }

    // Apply date filter
    if (_selectedDateFilter != 'All Time') {
      final now = DateTime.now();
      filtered = filtered.where((booking) {
        final bookingDate = booking['date'] as DateTime?;
        if (bookingDate == null) return false;

        switch (_selectedDateFilter) {
          case 'Today':
            return bookingDate.day == now.day &&
                bookingDate.month == now.month &&
                bookingDate.year == now.year;
          case 'This Week':
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            return bookingDate
                .isAfter(weekStart.subtract(const Duration(days: 1)));
          case 'This Month':
            return bookingDate.month == now.month &&
                bookingDate.year == now.year;
          default:
            return true;
        }
      }).toList();
    }

    setState(() {
      _filteredBookings = filtered;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedDateFilter = 'All Time';
      _selectedStatusFilter = 'All Status';
      _selectedRouteFilter = 'All Routes';
      _searchController.clear();
      _filteredBookings = List.from(_allBookings);
    });
  }

  void _toggleBookingSelection(String bookingRef) {
    setState(() {
      if (_selectedBookings.contains(bookingRef)) {
        _selectedBookings.remove(bookingRef);
      } else {
        _selectedBookings.add(bookingRef);
      }

      if (_selectedBookings.isEmpty) {
        _isMultiSelectMode = false;
      }
    });
  }

  void _enterMultiSelectMode(String bookingRef) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedBookings.add(bookingRef);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedBookings.clear();
      _isMultiSelectMode = false;
    });
  }

  void _exportSelectedBookings() {
    // Mock export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${_selectedBookings.length} bookings...'),
        backgroundColor: AppTheme.successLight,
      ),
    );
    _clearSelection();
  }

  void _cancelSelectedBookings() {
    // Mock cancel functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cancelled ${_selectedBookings.length} bookings'),
        backgroundColor: AppTheme.errorLight,
      ),
    );
    _clearSelection();
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => BookingDetailWidget(
          booking: booking,
          onClose: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _rateTrip(Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rate trip for ${booking['route']}'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _bookAgain(Map<String, dynamic> booking) {
    Navigator.pushNamed(context, '/bus-booking-form');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.secondaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSecondary,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Booking History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: true,
        actions: [
          if (_isMultiSelectMode)
            TextButton(
              onPressed: _clearSelection,
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          SearchBarWidget(
            controller: _searchController,
            onChanged: (value) => _filterBookings(),
            onClear: () => _filterBookings(),
          ),

          // Filter Chips
          Container(
            height: 6.h,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChipWidget(
                  label: _selectedDateFilter,
                  isSelected: _selectedDateFilter != 'All Time',
                  onTap: () => _showDateFilterDialog(),
                  icon: Icons.calendar_today,
                ),
                FilterChipWidget(
                  label: _selectedStatusFilter,
                  isSelected: _selectedStatusFilter != 'All Status',
                  onTap: () => _showStatusFilterDialog(),
                  icon: Icons.info,
                ),
                FilterChipWidget(
                  label: _selectedRouteFilter,
                  isSelected: _selectedRouteFilter != 'All Routes',
                  onTap: () => _showRouteFilterDialog(),
                  icon: Icons.directions_bus,
                ),
              ],
            ),
          ),

          SizedBox(height: 1.h),

          // Booking List
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => const SkeletonCardWidget(),
                  )
                : _filteredBookings.isEmpty
                    ? EmptyStateWidget(onResetFilters: _resetFilters)
                    : RefreshIndicator(
                        onRefresh: _refreshBookings,
                        color: AppTheme.secondaryLight,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _filteredBookings.length +
                              (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _filteredBookings.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.secondaryLight,
                                  ),
                                ),
                              );
                            }

                            final booking = _filteredBookings[index];
                            final bookingRef = booking['bookingRef'] as String;

                            return BookingCardWidget(
                              booking: booking,
                              isSelected:
                                  _selectedBookings.contains(bookingRef),
                              onTap: () {
                                if (_isMultiSelectMode) {
                                  _toggleBookingSelection(bookingRef);
                                } else {
                                  _showBookingDetails(booking);
                                }
                              },
                              onLongPress: () =>
                                  _enterMultiSelectMode(bookingRef),
                              onRateTrip: () => _rateTrip(booking),
                              onBookAgain: () => _bookAgain(booking),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _isMultiSelectMode
          ? BottomToolbarWidget(
              selectedCount: _selectedBookings.length,
              onExport: _exportSelectedBookings,
              onCancel: _cancelSelectedBookings,
              onClearSelection: _clearSelection,
            )
          : null,
    );
  }

  void _showDateFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        title: Text(
          'Filter by Date',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'All Time',
            'Today',
            'This Week',
            'This Month',
          ]
              .map((filter) => ListTile(
                    title: Text(
                      filter,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                    ),
                    leading: Radio<String>(
                      value: filter,
                      groupValue: _selectedDateFilter,
                      onChanged: (value) {
                        setState(() => _selectedDateFilter = value!);
                        _filterBookings();
                        Navigator.pop(context);
                      },
                      activeColor: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showStatusFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        title: Text(
          'Filter by Status',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'All Status',
            'Confirmed',
            'Completed',
            'Cancelled',
            'No-Show',
          ]
              .map((filter) => ListTile(
                    title: Text(
                      filter,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                    ),
                    leading: Radio<String>(
                      value: filter,
                      groupValue: _selectedStatusFilter,
                      onChanged: (value) {
                        setState(() => _selectedStatusFilter = value!);
                        _filterBookings();
                        Navigator.pop(context);
                      },
                      activeColor: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showRouteFilterDialog() {
    final routes = [
      'All Routes',
      'Main Campus - Downtown',
      'North Campus - City Center',
      'South Campus - Airport',
      'East Campus - Train Station',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        title: Text(
          'Filter by Route',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: routes
              .map((filter) => ListTile(
                    title: Text(
                      filter,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                    ),
                    leading: Radio<String>(
                      value: filter,
                      groupValue: _selectedRouteFilter,
                      onChanged: (value) {
                        setState(() => _selectedRouteFilter = value!);
                        _filterBookings();
                        Navigator.pop(context);
                      },
                      activeColor: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
