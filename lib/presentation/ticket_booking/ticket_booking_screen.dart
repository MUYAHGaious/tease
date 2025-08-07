import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/city_search_widget.dart';
import './widgets/date_picker_widget.dart';
import './widgets/passenger_count_widget.dart';
import './widgets/ticket_type_selector_widget.dart';

class TicketBookingScreen extends StatefulWidget {
  const TicketBookingScreen({super.key});

  @override
  State<TicketBookingScreen> createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _contentAnimation;

  String _fromCity = '';
  String _toCity = '';
  DateTime? _departureDate;
  DateTime? _returnDate;
  int _passengerCount = 1;
  String _ticketType = 'one-way';
  bool _showFromCitySuggestions = false;
  bool _showToCitySuggestions = false;

  final FocusNode _fromCityFocusNode = FocusNode();
  final FocusNode _toCityFocusNode = FocusNode();
  final TextEditingController _fromCityController = TextEditingController();
  final TextEditingController _toCityController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentController = AnimationController(
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

    _contentAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _contentController.forward();
    });

    _fromCityFocusNode.addListener(() {
      setState(() {
        _showFromCitySuggestions = _fromCityFocusNode.hasFocus;
      });
    });

    _toCityFocusNode.addListener(() {
      setState(() {
        _showToCitySuggestions = _toCityFocusNode.hasFocus;
      });
    });

    _fromCityController.addListener(() {
      setState(() {
        _fromCity = _fromCityController.text;
      });
    });

    _toCityController.addListener(() {
      setState(() {
        _toCity = _toCityController.text;
      });
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _fromCityFocusNode.dispose();
    _toCityFocusNode.dispose();
    _fromCityController.dispose();
    _toCityController.dispose();
    super.dispose();
  }

  void _handleSwapCities() {
    HapticFeedback.lightImpact();
    final tempCity = _fromCity;
    final tempController = _fromCityController.text;
    
    setState(() {
      _fromCity = _toCity;
      _toCity = tempCity;
      _fromCityController.text = _toCityController.text;
      _toCityController.text = tempController;
    });
  }

  void _handleCitySelected(String city, bool isFromCity) {
    setState(() {
      if (isFromCity) {
        _fromCity = city;
        _fromCityController.text = city;
        _showFromCitySuggestions = false;
        _fromCityFocusNode.unfocus();
      } else {
        _toCity = city;
        _toCityController.text = city;
        _showToCitySuggestions = false;
        _toCityFocusNode.unfocus();
      }
    });
  }

  void _handleDateSelected(DateTime date, bool isDeparture) {
    setState(() {
      if (isDeparture) {
        _departureDate = date;
      } else {
        _returnDate = date;
      }
    });
  }

  void _handlePassengerCountChanged(int count) {
    setState(() {
      _passengerCount = count;
    });
  }

  void _handleTicketTypeChanged(String type) {
    setState(() {
      _ticketType = type;
      if (type == 'one-way') {
        _returnDate = null;
      }
    });
  }

  void _searchTickets() {
    if (_fromCity.isEmpty || _toCity.isEmpty || _departureDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all required fields',
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

    HapticFeedback.lightImpact();
    // Navigate to search results
    Navigator.pushNamed(context, '/search-booking');
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
              'Book Ticket',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
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
              FadeTransition(
                opacity: _headerAnimation,
                child: _buildAppBar(),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SlideTransition(
                    position: _contentAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),

                          // Ticket Type Selector
                          TicketTypeSelectorWidget(
                            selectedType: _ticketType,
                            onTypeChanged: _handleTicketTypeChanged,
                          ),

                          SizedBox(height: 3.h),

                          // City Search
                          CitySearchWidget(
                            fromCity: _fromCity,
                            toCity: _toCity,
                            fromCityController: _fromCityController,
                            toCityController: _toCityController,
                            fromCityFocusNode: _fromCityFocusNode,
                            toCityFocusNode: _toCityFocusNode,
                            showFromCitySuggestions: _showFromCitySuggestions,
                            showToCitySuggestions: _showToCitySuggestions,
                            onCitySelected: _handleCitySelected,
                            onSwapCities: _handleSwapCities,
                          ),

                          SizedBox(height: 3.h),

                          // Date Picker
                          DatePickerWidget(
                            departureDate: _departureDate,
                            returnDate: _returnDate,
                            isRoundTrip: _ticketType == 'round-trip',
                            onDateSelected: _handleDateSelected,
                          ),

                          SizedBox(height: 3.h),

                          // Passenger Count
                          PassengerCountWidget(
                            passengerCount: _passengerCount,
                            onCountChanged: _handlePassengerCountChanged,
                          ),

                          SizedBox(height: 4.h),

                          // Search Button
                          Container(
                            width: double.infinity,
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
                              onPressed: _searchTickets,
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
                                    'Search Tickets',
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

                          SizedBox(height: 5.h),
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
}