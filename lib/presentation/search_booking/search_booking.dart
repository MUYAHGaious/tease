import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/global_bottom_navigation.dart';
import '../../theme/theme_notifier.dart';

class SearchBooking extends StatefulWidget {
  const SearchBooking({super.key});

  @override
  State<SearchBooking> createState() => _SearchBookingState();
}

class _SearchBookingState extends State<SearchBooking>
    with TickerProviderStateMixin {
  // Theme-aware colors
  Color get primaryColor => const Color(0xFF008B8B);
  Color get backgroundColor => ThemeNotifier().isDarkMode
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFF5F5F5);
  Color get surfaceColor =>
      ThemeNotifier().isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get textColor =>
      ThemeNotifier().isDarkMode ? Colors.white : Colors.black87;
  Color get onSurfaceVariantColor =>
      ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54;
  Color get borderColor => ThemeNotifier().isDarkMode
      ? Colors.white.withOpacity(0.2)
      : Colors.grey[300]!;
  late AnimationController _headerController;
  late AnimationController _searchController;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _searchAnimation;

  String _origin = '';
  String _destination = '';
  DateTime? _selectedDate;
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _showSuggestions = false;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _suggestions = [];

  final ScrollController _scrollController = ScrollController();
  final FocusNode _originFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  // Popular routes for suggestions
  final List<Map<String, dynamic>> _popularRoutes = [
    {
      'from': 'Douala',
      'to': 'Yaoundé',
      'price': '6,500 XAF',
      'duration': '4h 30m'
    },
    {
      'from': 'Yaoundé',
      'to': 'Bamenda',
      'price': '8,000 XAF',
      'duration': '6h 15m'
    },
    {
      'from': 'Douala',
      'to': 'Bafoussam',
      'price': '7,200 XAF',
      'duration': '5h 45m'
    },
    {
      'from': 'Bamenda',
      'to': 'Garoua',
      'price': '12,000 XAF',
      'duration': '8h 30m'
    },
    {
      'from': 'Yaoundé',
      'to': 'Maroua',
      'price': '15,000 XAF',
      'duration': '10h 15m'
    },
  ];

  // Search tips
  late final List<Map<String, dynamic>> _searchTips;

  // Recent searches
  final List<Map<String, dynamic>> _recentSearches = [
    {'from': 'Douala', 'to': 'Yaoundé', 'date': 'Today', 'price': '6,500 XAF'},
    {
      'from': 'Yaoundé',
      'to': 'Bamenda',
      'date': 'Yesterday',
      'price': '8,000 XAF'
    },
    {
      'from': 'Douala',
      'to': 'Bafoussam',
      'date': '2 days ago',
      'price': '7,200 XAF'
    },
  ];

  // Featured tickets
  late final List<Map<String, dynamic>> _featuredTickets;

  @override
  void initState() {
    super.initState();
    _searchTips = [
      {
        'icon': Icons.schedule,
        'tip': 'Book early for better prices',
        'color': primaryColor
      },
      {
        'icon': Icons.star,
        'tip': 'Check ratings before booking',
        'color': Colors.orange
      },
      {
        'icon': Icons.wifi,
        'tip': 'Look for WiFi amenities',
        'color': primaryColor
      },
      {
        'icon': Icons.local_offer,
        'tip': 'Compare prices across operators',
        'color': primaryColor
      },
    ];
    _featuredTickets = [
      {
        'title': 'Weekend Special',
        'subtitle': 'Save up to 20%',
        'icon': Icons.weekend,
        'color': primaryColor,
        'validUntil': 'Dec 31, 2024'
      },
      {
        'title': 'Student Discount',
        'subtitle': '15% off with ID',
        'icon': Icons.school,
        'color': primaryColor,
        'validUntil': 'Always'
      },
      {
        'title': 'Group Booking',
        'subtitle': '5+ passengers',
        'icon': Icons.groups,
        'color': primaryColor,
        'validUntil': 'Always'
      },
    ];
    ThemeNotifier().addListener(_onThemeChanged);

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _searchController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      _searchController.forward();
    });

    // Focus listeners for suggestions
    _originFocusNode.addListener(() {
      if (_originFocusNode.hasFocus) {
        setState(() {
          _showSuggestions = true;
          _suggestions = _getSuggestions(_origin);
        });
      }
    });

    _destinationFocusNode.addListener(() {
      if (_destinationFocusNode.hasFocus) {
        setState(() {
          _showSuggestions = true;
          _suggestions = _getSuggestions(_destination);
        });
      }
    });
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    _headerController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _originFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  List<Map<String, dynamic>> _getSuggestions(String query) {
    if (query.isEmpty) return _popularRoutes;

    return _popularRoutes.where((route) {
      return route['from'].toLowerCase().contains(query.toLowerCase()) ||
          route['to'].toLowerCase().contains(query.toLowerCase());
    }).toList();
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

  void _handleSuggestionTap(Map<String, dynamic> suggestion) {
    if (_originFocusNode.hasFocus) {
      setState(() {
        _origin = suggestion['from'];
        _showSuggestions = false;
      });
    } else if (_destinationFocusNode.hasFocus) {
      setState(() {
        _destination = suggestion['to'];
        _showSuggestions = false;
      });
    }
    _originFocusNode.unfocus();
    _destinationFocusNode.unfocus();
  }

  Future<void> _performSearch() async {
    if (_origin.trim().isEmpty || _destination.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter both origin and destination',
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = false;
      _showSuggestions = false;
    });

    _originFocusNode.unfocus();
    _destinationFocusNode.unfocus();
    HapticFeedback.lightImpact();

    // Simulate search delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSearching = false;
        _hasSearched = true;
        _searchResults = _getMockResults();
      });
    }
  }

  List<Map<String, dynamic>> _getMockResults() {
    return [
      {
        'id': 'bus_001',
        'operator': 'Cameroon Express',
        'route': '$_origin → $_destination',
        'departure': '08:00',
        'arrival': '14:30',
        'duration': '6h 30m',
        'price': 45000,
        'busType': 'AC Seater',
        'availableSeats': 12,
        'rating': 4.3,
        'amenities': ['WiFi', 'AC'],
      },
      {
        'id': 'bus_002',
        'operator': 'Central Voyages',
        'route': '$_origin → $_destination',
        'departure': '10:15',
        'arrival': '16:30',
        'duration': '6h 15m',
        'price': 52000,
        'busType': 'Luxury AC',
        'availableSeats': 8,
        'rating': 4.7,
        'amenities': ['WiFi', 'AC', 'Meals'],
      },
      {
        'id': 'bus_003',
        'operator': 'Guaranty Express',
        'route': '$_origin → $_destination',
        'departure': '13:20',
        'arrival': '19:45',
        'duration': '6h 25m',
        'price': 48000,
        'busType': 'Volvo AC',
        'availableSeats': 15,
        'rating': 4.6,
        'amenities': ['WiFi', 'Charging'],
      },
    ];
  }

  void _handleResultTap(Map<String, dynamic> result) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/seat-selection');
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerAnimation,
      child: Container(
        padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
        decoration: BoxDecoration(
          color: ThemeNotifier().isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: ThemeNotifier().isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeNotifier().isDarkMode
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: primaryColor,
                  size: 4.5.w,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Buses',
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: ThemeNotifier().isDarkMode
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Find your perfect journey',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: ThemeNotifier().isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Quick action button
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.tune,
                color: primaryColor,
                size: 4.5.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchForm() {
    return SlideTransition(
      position: _searchAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: ThemeNotifier().isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeNotifier().isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeNotifier().isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Modern search form header
            Container(
              padding: EdgeInsets.fromLTRB(4.w, 3.w, 4.w, 2.w),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: primaryColor,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Search for buses',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: ThemeNotifier().isDarkMode
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  // Origin and Destination in one row
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernLocationField(
                          label: 'From',
                          hint: 'Departure city',
                          value: _origin,
                          focusNode: _originFocusNode,
                          onChanged: (value) {
                            setState(() {
                              _origin = value;
                              _suggestions = _getSuggestions(value);
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 3.w),
                      // Modern swap button
                      GestureDetector(
                        onTap: _handleSwap,
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.swap_horiz,
                            color: Colors.white,
                            size: 5.w,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildModernLocationField(
                          label: 'To',
                          hint: 'Destination city',
                          value: _destination,
                          focusNode: _destinationFocusNode,
                          onChanged: (value) {
                            setState(() {
                              _destination = value;
                              _suggestions = _getSuggestions(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Date picker and search button in one row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildModernDatePicker(),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        flex: 1,
                        child: _buildModernSearchButton(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLocationField({
    required String label,
    required String hint,
    required String value,
    required FocusNode focusNode,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: ThemeNotifier().isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focusNode.hasFocus
                  ? primaryColor
                  : ThemeNotifier().isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.3),
              width: focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: TextField(
            focusNode: focusNode,
            onChanged: onChanged,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                color: ThemeNotifier().isDarkMode
                    ? Colors.white60
                    : Colors.grey[500],
                fontSize: 13.sp,
              ),
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: primaryColor,
                size: 4.5.w,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 2.5.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Travel Date',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: primaryColor,
                      onPrimary: Colors.white,
                      surface: ThemeNotifier().isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      onSurface: ThemeNotifier().isDarkMode
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              _handleDateSelected(date);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.5.h),
            decoration: BoxDecoration(
              color: ThemeNotifier().isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeNotifier().isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: primaryColor,
                  size: 4.5.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select date',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: _selectedDate != null
                          ? ThemeNotifier().isDarkMode
                              ? Colors.white
                              : Colors.black87
                          : ThemeNotifier().isDarkMode
                              ? Colors.white60
                              : Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSearchButton() {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _performSearch,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSearching)
                  SizedBox(
                    width: 4.w,
                    height: 4.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 4.5.w,
                  ),
                SizedBox(width: 2.w),
                Text(
                  _isSearching ? 'Searching...' : 'Search',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    if (!_showSuggestions || _suggestions.isEmpty)
      return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Text(
              'Popular Routes',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          ..._suggestions
              .map((suggestion) => _buildSuggestionItem(suggestion))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(Map<String, dynamic> suggestion) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleSuggestionTap(suggestion),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: primaryColor,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${suggestion['from']} → ${suggestion['to']}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${suggestion['duration']} • ${suggestion['price']}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: onSurfaceVariantColor,
                size: 3.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasSearched) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern results header
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: ThemeNotifier().isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeNotifier().isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_bus,
                  color: primaryColor,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Buses',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: ThemeNotifier().isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      Text(
                        'Found ${_searchResults.length} buses for your route',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: ThemeNotifier().isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${_searchResults.length}',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          ..._searchResults.map((result) => _buildBusCard(result)).toList(),
        ],
      ),
    );
  }

  Widget _buildBusCard(Map<String, dynamic> result) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: ThemeNotifier().isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeNotifier().isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeNotifier().isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleResultTap(result),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Header with operator and rating
              Container(
                padding: EdgeInsets.fromLTRB(4.w, 3.w, 4.w, 2.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result['operator'],
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: ThemeNotifier().isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            result['busType'],
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: ThemeNotifier().isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 3.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            result['rating'].toString(),
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    // Time information
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTimeInfo(
                              'Departure', result['departure'], Icons.schedule),
                        ),
                        Container(
                          width: 1,
                          height: 4.h,
                          color: ThemeNotifier().isDarkMode
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildModernTimeInfo(
                              'Arrival', result['arrival'], Icons.flag),
                        ),
                        Container(
                          width: 1,
                          height: 4.h,
                          color: ThemeNotifier().isDarkMode
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildModernTimeInfo('Duration',
                              result['duration'], Icons.access_time),
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Bottom section with seats and price
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Seats',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  color: ThemeNotifier().isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_seat,
                                    color: primaryColor,
                                    size: 3.w,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    '${result['availableSeats']} seats left',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
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
                              'Starting from',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: ThemeNotifier().isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                            SizedBox(height: 0.3.h),
                            Text(
                              '${result['price']} XAF',
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildModernTimeInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: primaryColor,
          size: 4.w,
        ),
        SizedBox(height: 0.8.h),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTips() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Tips',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: _searchTips.map((tip) => _buildTipItem(tip)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(Map<String, dynamic> tip) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: tip['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              tip['icon'],
              color: tip['color'],
              size: 4.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              tip['tip'],
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: _recentSearches
                  .map((search) => _buildRecentSearchItem(search))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(Map<String, dynamic> search) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _origin = search['from'];
            _destination = search['to'];
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Row(
            children: [
              Icon(
                Icons.history,
                color: onSurfaceVariantColor,
                size: 4.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${search['from']} → ${search['to']}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${search['date']} • ${search['price']}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: onSurfaceVariantColor,
                size: 3.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedTickets() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Offers',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: _featuredTickets
                  .map((ticket) => _buildTicketItem(ticket))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketItem(Map<String, dynamic> ticket) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: ticket['color'].withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ticket['color'].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: ticket['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              ticket['icon'],
              color: ticket['color'],
              size: 4.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket['title'],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  ticket['subtitle'],
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: onSurfaceVariantColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            ticket['validUntil'],
            style: TextStyle(
              fontSize: 10.sp,
              color: ticket['color'],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search Form
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildSearchForm(),
                    SizedBox(height: 2.h),
                    _buildSuggestions(),
                    if (!_hasSearched) ...[
                      _buildSearchTips(),
                      SizedBox(height: 2.h),
                      _buildRecentSearches(),
                      SizedBox(height: 2.h),
                      _buildFeaturedTickets(),
                    ],
                    _buildSearchResults(),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: GlobalBottomNavigation(
        initialIndex: 1, // Search tab
      ),
    );
  }
}
