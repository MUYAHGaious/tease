import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/date_picker_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/origin_destination_widget.dart';
import './widgets/predictive_suggestions_widget.dart';
import './widgets/premium_search_results_widget.dart';

class SearchBooking extends StatefulWidget {
  const SearchBooking({super.key});

  @override
  State<SearchBooking> createState() => _SearchBookingState();
}

class _SearchBookingState extends State<SearchBooking>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _searchController;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _searchAnimation;

  String _origin = '';
  String _destination = '';
  DateTime? _selectedDate;
  bool _showSuggestions = false;
  bool _isSearching = false;
  bool _hasSearched = false;
  Map<String, dynamic> _currentFilters = {};
  List<Map<String, dynamic>> _searchResults = [];

  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    ));

    _searchAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _searchController.forward();
    });

    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions = _searchFocusNode.hasFocus &&
            (_origin.isNotEmpty || _destination.isNotEmpty);
      });
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleOriginChanged(String value) {
    setState(() {
      _origin = value;
      _showSuggestions = value.isNotEmpty || _destination.isNotEmpty;
    });
  }

  void _handleDestinationChanged(String value) {
    setState(() {
      _destination = value;
      _showSuggestions = _origin.isNotEmpty || value.isNotEmpty;
    });
  }

  void _handleSwap() {
    HapticFeedback.lightImpact();
    final temp = _origin;
    setState(() {
      _origin = _destination;
      _destination = temp;
    });
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _handleSuggestionSelected(String origin, String destination) {
    setState(() {
      _origin = origin;
      _destination = destination;
      _showSuggestions = false;
    });
    _searchFocusNode.unfocus();
  }

  void _showFilterBottomSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _currentFilters,
        onFiltersApplied: _handleFiltersApplied,
      ),
    );
  }

  void _handleFiltersApplied(Map<String, dynamic> filters) {
    setState(() {
      _currentFilters = filters;
    });
    _performSearch();
  }

  void _performSearch() {
    if (_origin.isEmpty || _destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter both origin and destination',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onError,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = false;
      _showSuggestions = false;
    });

    _searchFocusNode.unfocus();

    // Simulate API call with comprehensive mock bus results
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _hasSearched = true;
          _searchResults = [
            {
              'id': 'bus_001',
              'operator': 'Express Voyage',
              'route': '$_origin → $_destination',
              'departure': '08:30 AM',
              'arrival': '02:45 PM',
              'duration': '6h 15m',
              'price': 45.99,
              'originalPrice': 55.99,
              'busType': 'AC Sleeper',
              'availableSeats': 12,
              'totalSeats': 45,
              'amenities': ['WiFi', 'AC', 'Charging Port', 'Snacks'],
              'rating': 4.5,
              'reviews': 234,
              'image': 'https://images.pexels.com/photos/1545743/pexels-photo-1545743.jpeg?auto=compress&cs=tinysrgb&w=800',
            },
            {
              'id': 'bus_002',
              'operator': 'Cameroon Express',
              'route': '$_origin → $_destination',
              'departure': '10:15 AM',
              'arrival': '04:30 PM',
              'duration': '6h 15m',
              'price': 39.99,
              'originalPrice': 49.99,
              'busType': 'AC Seater',
              'availableSeats': 8,
              'totalSeats': 45,
              'amenities': ['WiFi', 'AC', 'Movies'],
              'rating': 4.2,
              'reviews': 189,
              'image': 'https://images.pexels.com/photos/1098365/pexels-photo-1098365.jpeg?auto=compress&cs=tinysrgb&w=800',
            },
            {
              'id': 'bus_003',
              'operator': 'Central Voyages',
              'route': '$_origin → $_destination',
              'departure': '01:20 PM',
              'arrival': '07:45 PM',
              'duration': '6h 25m',
              'price': 52.99,
              'originalPrice': 62.99,
              'busType': 'Luxury AC',
              'availableSeats': 15,
              'totalSeats': 45,
              'amenities': ['WiFi', 'AC', 'Charging Port', 'Meals', 'Reclining Seats'],
              'rating': 4.7,
              'reviews': 312,
              'image': 'https://images.pexels.com/photos/1098364/pexels-photo-1098364.jpeg?auto=compress&cs=tinysrgb&w=800',
            },
            {
              'id': 'bus_004',
              'operator': 'Guaranty Express',
              'route': '$_origin → $_destination',
              'departure': '06:00 PM',
              'arrival': '11:30 PM',
              'duration': '5h 30m',
              'price': 58.99,
              'originalPrice': 68.99,
              'busType': 'Volvo AC',
              'availableSeats': 20,
              'totalSeats': 40,
              'amenities': ['WiFi', 'Entertainment', 'USB Charging', 'Snacks', 'Reading Light'],
              'rating': 4.6,
              'reviews': 445,
              'image': 'https://images.pexels.com/photos/1098365/pexels-photo-1098365.jpeg?auto=compress&cs=tinysrgb&w=800',
            },
          ];
        });
      }
    });
  }

  void _handleResultTap(Map<String, dynamic> result) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/seat-selection');
  }

  void _handleSaveRoute(Map<String, dynamic> result) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Route saved to favorites',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _handleShareRoute(Map<String, dynamic> result) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Route shared successfully',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _handlePriceAlert(Map<String, dynamic> result) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Price alert set for this route',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    _currentFilters.forEach((key, value) {
      if (value is List && value.isNotEmpty) count++;
      if (value is RangeValues) count++;
    });
    return count;
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              'Search Buses',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _showFilterBottomSheet();
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.tune,
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
              AppTheme.lightTheme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),
              
              // Search Form
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SlideTransition(
                        position: _searchAnimation,
                        child: Column(
                          children: [
                            SizedBox(height: 3.h),

                            // Origin/Destination Widget
                            Focus(
                              focusNode: _searchFocusNode,
                              child: OriginDestinationWidget(
                                origin: _origin,
                                destination: _destination,
                                onOriginChanged: _handleOriginChanged,
                                onDestinationChanged: _handleDestinationChanged,
                                onSwap: _handleSwap,
                              ),
                            ),

                            SizedBox(height: 2.h),

                            // Date Picker Widget
                            DatePickerWidget(
                              selectedDate: _selectedDate,
                              onDateSelected: _handleDateSelected,
                            ),

                            SizedBox(height: 2.h),

                            // Search and Filter Buttons
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _performSearch,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(vertical: 2.5.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.search,
                                              color: Colors.white,
                                              size: 6.w,
                                            ),
                                            SizedBox(width: 3.w),
                                            Text(
                                              'Search Buses',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: _getActiveFilterCount() > 0
                                          ? AppTheme.lightTheme.colorScheme.secondary
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      child: InkWell(
                                        onTap: _showFilterBottomSheet,
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: EdgeInsets.all(4.w),
                                          child: Stack(
                                            children: [
                                              Icon(
                                                Icons.tune,
                                                color: _getActiveFilterCount() > 0
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                                size: 6.w,
                                              ),
                                              if (_getActiveFilterCount() > 0)
                                                Positioned(
                                                  right: -2,
                                                  top: -2,
                                                  child: Container(
                                                    width: 4.w,
                                                    height: 4.w,
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${_getActiveFilterCount()}',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 8.sp,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 3.h),
                          ],
                        ),
                      ),

                      // Predictive Suggestions
                      if (_showSuggestions)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          child: PredictiveSuggestionsWidget(
                            query: _origin.isNotEmpty ? _origin : _destination,
                            isVisible: _showSuggestions,
                            onSuggestionSelected: _handleSuggestionSelected,
                          ),
                        ),

                      // Search Results
                      if (_hasSearched || _isSearching)
                        Container(
                          constraints: BoxConstraints(minHeight: 50.h),
                          child: PremiumSearchResultsWidget(
                            isLoading: _isSearching,
                            results: _searchResults,
                            onResultTap: _handleResultTap,
                            onSaveRoute: _handleSaveRoute,
                            onShareRoute: _handleShareRoute,
                            onPriceAlert: _handlePriceAlert,
                          ),
                        ),

                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}