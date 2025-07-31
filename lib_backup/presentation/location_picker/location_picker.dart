import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/mock_data_service.dart';

class LocationPicker extends StatefulWidget {
  final String? pickerType; // 'from' or 'to'
  
  const LocationPicker({super.key, this.pickerType});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _cardAnimation;

  Map<String, dynamic>? _selectedLocation;
  List<Map<String, dynamic>> _searchSuggestions = [];
  bool _isLoadingLocation = false;
  bool _showSuggestions = false;
  
  List<Map<String, dynamic>> _popularCities = [];
  List<Map<String, dynamic>> _recentBookings = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardAnimationController.forward();
    });
  }

  void _loadData() {
    setState(() {
      _popularCities = MockDataService.getPopularDestinations();
      _recentBookings = MockDataService.getRecentBookings();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _searchSuggestions = [];
      });
      return;
    }

    setState(() {
      _showSuggestions = true;
      _searchSuggestions = MockDataService.searchCities(query);
    });
  }

  void _onLocationSelected(Map<String, dynamic> location) {
    setState(() {
      _selectedLocation = location;
    });
    
    // Haptic feedback
    HapticFeedback.selectionClick();
    
    // Return selected location
    Navigator.pop(context, location);
  }

  void _onCurrentLocationPressed() async {
    setState(() {
      _isLoadingLocation = true;
    });

    // Simulate getting current location
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock current location (Douala for demonstration)
    final currentLocation = {
      "id": 0,
      "name": "Current Location",
      "region": "Littoral",
      "city": "Douala",
      "isPopular": false,
      "busStationsCount": 1
    };

    setState(() {
      _isLoadingLocation = false;
      _selectedLocation = currentLocation;
    });

    Navigator.pop(context, currentLocation);
  }

  @override
  Widget build(BuildContext context) {
    final pickerTitle = widget.pickerType == 'from' ? 'Select Departure' : 'Select Destination';
    final pickerIcon = widget.pickerType == 'from' ? 'my_location' : 'location_on';
    final pickerColor = widget.pickerType == 'from' ? const Color(0xFFC8E53F) : Colors.red;

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
              _buildHeader(pickerTitle, pickerIcon, pickerColor),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_slideAnimation),
                    child: FadeTransition(
                      opacity: _slideAnimation,
                      child: Column(
                        children: [
                          _buildSearchSection(),
                          Expanded(
                            child: _showSuggestions 
                                ? _buildSearchResults()
                                : _buildLocationOptions(),
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
      ),
    );
  }

  Widget _buildHeader(String title, String iconName, Color iconColor) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              child: Column(
                children: [
                  Row(
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
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                        child: CustomIconWidget(
                          iconName: iconName,
                          color: iconColor,
                          size: 6.w,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Choose from popular destinations or search for a specific location',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSection() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * _cardAnimation.value),
          child: Opacity(
            opacity: _cardAnimation.value,
            child: Container(
              margin: EdgeInsets.all(6.w),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for a city or location...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Container(
                          padding: EdgeInsets.all(4.w),
                          child: CustomIconWidget(
                            iconName: 'search',
                            color: const Color(0xFF1A4A47),
                            size: 5.w,
                          ),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _showSuggestions = false;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  child: CustomIconWidget(
                                    iconName: 'close',
                                    color: Colors.grey.shade400,
                                    size: 5.w,
                                  ),
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 4.h,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A4A47),
                      ),
                    ),
                  ),
                  
                  // Current Location Button
                  SizedBox(height: 3.h),
                  if (widget.pickerType == 'from')
                    GestureDetector(
                      onTap: _isLoadingLocation ? null : _onCurrentLocationPressed,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8E53F).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.w),
                          border: Border.all(
                            color: const Color(0xFFC8E53F).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoadingLocation)
                              SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF1A4A47),
                                  ),
                                ),
                              )
                            else
                              CustomIconWidget(
                                iconName: 'my_location',
                                color: const Color(0xFF1A4A47),
                                size: 5.w,
                              ),
                            SizedBox(width: 3.w),
                            Text(
                              _isLoadingLocation ? 'Getting location...' : 'Use Current Location',
                              style: TextStyle(
                                color: const Color(0xFF1A4A47),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
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
      },
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      itemCount: _searchSuggestions.length,
      itemBuilder: (context, index) {
        final city = _searchSuggestions[index];
        return _buildLocationItem(city, index);
      },
    );
  }

  Widget _buildLocationOptions() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Popular Destinations', 'trending_up'),
          SizedBox(height: 2.h),
          _buildPopularGrid(),
          SizedBox(height: 4.h),
          if (_recentBookings.isNotEmpty) ...[
            _buildSectionTitle('Recent Trips', 'history'),
            SizedBox(height: 2.h),
            _buildRecentTrips(),
            SizedBox(height: 4.h),
          ],
          _buildSectionTitle('All Cities', 'location_city'),
          SizedBox(height: 2.h),
          _buildAllCitiesList(),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String iconName) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1A4A47).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: const Color(0xFF1A4A47),
            size: 4.w,
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF1A4A47),
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPopularGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 3.w,
      ),
      itemCount: _popularCities.length,
      itemBuilder: (context, index) {
        final city = _popularCities[index];
        return _buildPopularCityCard(city);
      },
    );
  }

  Widget _buildPopularCityCard(Map<String, dynamic> city) {
    return GestureDetector(
      onTap: () => _onLocationSelected(city),
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1A4A47).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: CustomIconWidget(
                iconName: 'location_city',
                color: const Color(0xFF1A4A47),
                size: 6.w,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              city['name'],
              style: TextStyle(
                color: const Color(0xFF1A4A47),
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              city['region'],
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFC8E53F).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Text(
                '${city['busStationsCount']} stations',
                style: TextStyle(
                  color: const Color(0xFF1A4A47),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTrips() {
    return Column(
      children: _recentBookings.map((booking) {
        final fromCity = booking['fromCity'];
        final toCity = booking['toCity'];
        
        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          child: GestureDetector(
            onTap: () {
              final selectedCity = widget.pickerType == 'from' ? fromCity : toCity;
              final cityData = MockDataService.cameroonCities.firstWhere(
                (city) => city['name'] == selectedCity,
                orElse: () => {'name': selectedCity, 'region': 'Unknown'},
              );
              _onLocationSelected(cityData);
            },
            child: Container(
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
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: CustomIconWidget(
                      iconName: 'history',
                      color: Colors.grey.shade600,
                      size: 5.w,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$fromCity → $toCity',
                          style: TextStyle(
                            color: const Color(0xFF1A4A47),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Booked ${booking['departureDate'].difference(DateTime.now()).inDays.abs()} days ago',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 4.w,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllCitiesList() {
    return Column(
      children: MockDataService.cameroonCities.map((city) {
        return _buildLocationItem(city, MockDataService.cameroonCities.indexOf(city));
      }).toList(),
    );
  }

  Widget _buildLocationItem(Map<String, dynamic> city, int index) {
    return GestureDetector(
      onTap: () => _onLocationSelected(city),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1A4A47).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: CustomIconWidget(
                iconName: 'location_on',
                color: const Color(0xFF1A4A47),
                size: 5.w,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city['name'],
                    style: TextStyle(
                      color: const Color(0xFF1A4A47),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${city['region']} Region',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (city['isPopular'])
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E53F),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  'Popular',
                  style: TextStyle(
                    color: const Color(0xFF1A4A47),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            SizedBox(width: 2.w),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 4.w,
            ),
          ],
        ),
      ),
    );
  }
}