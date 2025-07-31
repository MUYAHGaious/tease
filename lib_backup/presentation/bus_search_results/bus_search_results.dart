import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/mock_data_service.dart';

class BusSearchResults extends StatefulWidget {
  const BusSearchResults({super.key});

  @override
  State<BusSearchResults> createState() => _BusSearchResultsState();
}

class _BusSearchResultsState extends State<BusSearchResults>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String _selectedSort = 'price';
  Map<String, dynamic> _activeFilters = {};
  List<Map<String, dynamic>> _busSchedules = [];
  Map<String, dynamic> _searchCriteria = {};
  
  late AnimationController _animationController;
  late AnimationController _listAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _listAnimation;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSearchData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  void _loadSearchData() async {
    // Get arguments passed from previous screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      if (args != null) {
        setState(() {
          _searchCriteria = args;
        });
        _performSearch();
      } else {
        // Fallback data for testing
        setState(() {
          _searchCriteria = {
            'fromLocation': 'Douala',
            'toLocation': 'Yaoundé',
            'selectedDate': DateTime.now(),
            'selectedTime': 'Depart Now',
          };
        });
        _performSearch();
      }
    });
  }

  void _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final fromCity = _searchCriteria['fromLocation'] ?? 'Douala';
    final toCity = _searchCriteria['toLocation'] ?? 'Yaoundé';
    
    final schedules = MockDataService.generateBusSchedules(fromCity, toCity);
    
    // Debug: Print the number of schedules generated
    print('Generated ${schedules.length} bus schedules from $fromCity to $toCity');
    
    setState(() {
      _busSchedules = schedules;
      _isLoading = false;
    });

    // Start list animation immediately when data loads
    _listAnimationController.forward();
  }

  void _onSortChanged(String sortType) {
    setState(() {
      _selectedSort = sortType;
      _sortBuses();
    });
    
    HapticFeedback.selectionClick();
  }

  void _sortBuses() {
    switch (_selectedSort) {
      case 'price':
        _busSchedules.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'departure':
        _busSchedules.sort((a, b) => a['departureTime'].compareTo(b['departureTime']));
        break;
      case 'duration':
        _busSchedules.sort((a, b) => a['estimatedDuration'].compareTo(b['estimatedDuration']));
        break;
      case 'rating':
        _busSchedules.sort((a, b) => b['operatorRating'].compareTo(a['operatorRating']));
        break;
    }
  }

  void _onBusSelected(Map<String, dynamic> busSchedule) {
    Navigator.pushNamed(
      context,
      AppRoutes.seatSelectionScreen,
      arguments: {
        'busSchedule': busSchedule,
        'searchCriteria': _searchCriteria,
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _listAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A4A47),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A4A47),
              Color(0xFF2A5D5A),
              Color(0xFF1A4A47),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSearchSummary(),
                      _buildSortAndFilter(),
                      Expanded(
                        child: _isLoading 
                            ? _buildLoadingState()
                            : _busSchedules.isEmpty
                                ? _buildEmptyState()
                                : _buildBusList(),
                      ),
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

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
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
                          'Available Buses',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${_searchCriteria['fromLocation'] ?? ''} → ${_searchCriteria['toLocation'] ?? ''}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8E53F).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    child: CustomIconWidget(
                      iconName: 'directions_bus',
                      color: const Color(0xFFC8E53F),
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSummary() {
    return Container(
      margin: EdgeInsets.all(6.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
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
                      'From',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _searchCriteria['fromLocation'] ?? 'Departure',
                      style: TextStyle(
                        color: const Color(0xFF1A4A47),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A4A47).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: const Color(0xFF1A4A47),
                  size: 4.w,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'To',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _searchCriteria['toLocation'] ?? 'Destination',
                      style: TextStyle(
                        color: const Color(0xFF1A4A47),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'calendar_today',
                      color: const Color(0xFF1A4A47),
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      _searchCriteria['selectedDate'] != null 
                          ? '${(_searchCriteria['selectedDate'] as DateTime).day}/${(_searchCriteria['selectedDate'] as DateTime).month}/${(_searchCriteria['selectedDate'] as DateTime).year}'
                          : 'Today',
                      style: TextStyle(
                        color: const Color(0xFF1A4A47),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E53F).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  '${_busSchedules.length} buses found',
                  style: TextStyle(
                    color: const Color(0xFF1A4A47),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortAndFilter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('Price', 'price'),
                  SizedBox(width: 3.w),
                  _buildSortChip('Departure', 'departure'),
                  SizedBox(width: 3.w),
                  _buildSortChip('Duration', 'duration'),
                  SizedBox(width: 3.w),
                  _buildSortChip('Rating', 'rating'),
                ],
              ),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () => _showFilterModal(),
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1A4A47),
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: CustomIconWidget(
                iconName: 'filter_list',
                color: const Color(0xFFC8E53F),
                size: 5.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String sortType) {
    final isSelected = _selectedSort == sortType;
    
    return GestureDetector(
      onTap: () => _onSortChanged(sortType),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A4A47) : Colors.white,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A4A47) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFC8E53F) : const Color(0xFF1A4A47),
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(5, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30.w,
                          height: 2.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          width: 20.w,
                          height: 1.5.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 15.w,
                    height: 2.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Container(
                width: double.infinity,
                height: 2.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(1.w),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1A4A47).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: CustomIconWidget(
              iconName: 'directions_bus_filled',
              color: const Color(0xFF1A4A47),
              size: 15.w,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'No buses found',
            style: TextStyle(
              color: const Color(0xFF1A4A47),
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              'We couldn\'t find any buses for your selected route and date. Try adjusting your search criteria.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A4A47),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            ),
            child: Text(
              'Modify Search',
              style: TextStyle(
                color: const Color(0xFFC8E53F),
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusList() {
    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          itemCount: _busSchedules.length,
          itemBuilder: (context, index) {
            // Ensure minimum opacity for visibility
            double opacity = _listAnimation.value.clamp(0.3, 1.0);
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _listAnimation.value)),
              child: Opacity(
                opacity: opacity,
                child: _buildBusCard(_busSchedules[index], index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBusCard(Map<String, dynamic> busSchedule, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5.w),
            child: Column(
              children: [
                // Operator Info
                Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A4A47).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                      child: Center(
                        child: Text(
                          busSchedule['operatorName'][0],
                          style: TextStyle(
                            color: const Color(0xFF1A4A47),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
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
                            busSchedule['operatorName'],
                            style: TextStyle(
                              color: const Color(0xFF1A4A47),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: const Color(0xFFFFA726),
                                size: 3.5.w,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                '${busSchedule['operatorRating']}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC8E53F).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(1.5.w),
                                ),
                                child: Text(
                                  busSchedule['busType'],
                                  style: TextStyle(
                                    color: const Color(0xFF1A4A47),
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${busSchedule['currency']} ${busSchedule['price']}',
                          style: TextStyle(
                            color: const Color(0xFF1A4A47),
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${busSchedule['availableSeats']} seats left',
                          style: TextStyle(
                            color: busSchedule['availableSeats'] <= 5 
                                ? Colors.red 
                                : Colors.green,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 4.h),
                
                // Journey Details
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            busSchedule['departureTime'],
                            style: TextStyle(
                              color: const Color(0xFF1A4A47),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            busSchedule['fromCity'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                            child: Text(
                              busSchedule['estimatedDuration'],
                              style: TextStyle(
                                color: const Color(0xFF1A4A47),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Container(
                                width: 2.w,
                                height: 2.w,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC8E53F),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              Container(
                                width: 2.w,
                                height: 2.w,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            busSchedule['arrivalTime'],
                            style: TextStyle(
                              color: const Color(0xFF1A4A47),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            busSchedule['toCity'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11.sp,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 3.h),
                
                // Amenities
                if (busSchedule['amenities'] != null && (busSchedule['amenities'] as List).isNotEmpty)
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: (busSchedule['amenities'] as List).take(3).map<Widget>((amenity) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(1.5.w),
                        ),
                        child: Text(
                          amenity,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          
          // Select Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1A4A47),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5.w),
                bottomRight: Radius.circular(5.w),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onBusSelected(busSchedule),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5.w),
                  bottomRight: Radius.circular(5.w),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'event_seat',
                        color: const Color(0xFFC8E53F),
                        size: 5.w,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Select Seats',
                        style: TextStyle(
                          color: const Color(0xFFC8E53F),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
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
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6.w),
            topRight: Radius.circular(6.w),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              child: Row(
                children: [
                  Text(
                    'Filter Results',
                    style: TextStyle(
                      color: const Color(0xFF1A4A47),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade600,
                        size: 5.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bus Type',
                      style: TextStyle(
                        color: const Color(0xFF1A4A47),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Wrap(
                      spacing: 3.w,
                      runSpacing: 2.h,
                      children: ['All', 'Executive', 'VIP', 'Standard', 'Economy'].map((type) {
                        return GestureDetector(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(3.w),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                color: const Color(0xFF1A4A47),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Departure Time',
                      style: TextStyle(
                        color: const Color(0xFF1A4A47),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Wrap(
                      spacing: 3.w,
                      runSpacing: 2.h,
                      children: ['Early Morning (6AM-12PM)', 'Afternoon (12PM-6PM)', 'Evening (6PM-12AM)'].map((time) {
                        return GestureDetector(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(3.w),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              time,
                              style: TextStyle(
                                color: const Color(0xFF1A4A47),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(6.w),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 3.h),
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: const Color(0xFF1A4A47),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A4A47),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 3.h),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: const Color(0xFFC8E53F),
                          fontSize: 14.sp,
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
    );
  }
}