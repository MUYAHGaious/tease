import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/date_picker_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/origin_destination_widget.dart';
import './widgets/predictive_suggestions_widget.dart';
import './widgets/search_results_widget.dart';

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

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _hasSearched = true;
          _searchResults = []; // Will use mock data from SearchResultsWidget
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            AnimatedBuilder(
              animation: _headerAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _headerAnimation,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppTheme
                                  .lightTheme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(
                              iconName: 'arrow_back',
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Search & Book',
                                style: AppTheme
                                    .lightTheme.textTheme.headlineSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Find your perfect bus route',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.textMediumEmphasisLight,
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
            ),

            // Search Form
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        SlideTransition(
                          position: _searchAnimation,
                          child: Column(
                            children: [
                              SizedBox(height: 2.h),

                              // Origin/Destination Widget
                              Focus(
                                focusNode: _searchFocusNode,
                                child: OriginDestinationWidget(
                                  origin: _origin,
                                  destination: _destination,
                                  onOriginChanged: _handleOriginChanged,
                                  onDestinationChanged:
                                      _handleDestinationChanged,
                                  onSwap: _handleSwap,
                                ),
                              ),

                              // Date Picker Widget
                              DatePickerWidget(
                                selectedDate: _selectedDate,
                                onDateSelected: _handleDateSelected,
                              ),

                              // Search and Filter Buttons
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 2.h),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _performSearch,
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 2.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomIconWidget(
                                              iconName: 'search',
                                              color: AppTheme.lightTheme
                                                  .colorScheme.onPrimary,
                                              size: 20,
                                            ),
                                            SizedBox(width: 2.w),
                                            Text(
                                              'Search Routes',
                                              style: AppTheme.lightTheme
                                                  .textTheme.labelLarge
                                                  ?.copyWith(
                                                color: AppTheme.lightTheme
                                                    .colorScheme.onPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 3.w),
                                    GestureDetector(
                                      onTap: _showFilterBottomSheet,
                                      child: Container(
                                        padding: EdgeInsets.all(3.w),
                                        decoration: BoxDecoration(
                                          color: _getActiveFilterCount() > 0
                                              ? AppTheme.lightTheme.colorScheme
                                                  .secondary
                                              : AppTheme.lightTheme.colorScheme
                                                  .surfaceContainerHighest
                                                  .withValues(alpha: 0.8),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppTheme
                                                .lightTheme.colorScheme.outline
                                                .withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            CustomIconWidget(
                                              iconName: 'tune',
                                              color: _getActiveFilterCount() > 0
                                                  ? AppTheme.lightTheme
                                                      .colorScheme.onSecondary
                                                  : AppTheme.lightTheme
                                                      .colorScheme.onSurface,
                                              size: 20,
                                            ),
                                            if (_getActiveFilterCount() > 0)
                                              Positioned(
                                                right: -2,
                                                top: -2,
                                                child: Container(
                                                  width: 4.w,
                                                  height: 4.w,
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.lightTheme
                                                        .colorScheme.error,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${_getActiveFilterCount()}',
                                                      style: AppTheme.lightTheme
                                                          .textTheme.labelSmall
                                                          ?.copyWith(
                                                        color: AppTheme
                                                            .lightTheme
                                                            .colorScheme
                                                            .onError,
                                                        fontSize: 8.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Search Results
                        if (_hasSearched || _isSearching)
                          Container(
                            height: 60.h,
                            child: SearchResultsWidget(
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

                  // Predictive Suggestions Overlay
                  if (_showSuggestions)
                    Positioned(
                      top: 25.h,
                      left: 0,
                      right: 0,
                      child: PredictiveSuggestionsWidget(
                        query: _origin.isNotEmpty ? _origin : _destination,
                        isVisible: _showSuggestions,
                        onSuggestionSelected: _handleSuggestionSelected,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
