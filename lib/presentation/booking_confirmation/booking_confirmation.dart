import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/theme_notifier.dart';
import './widgets/booking_progress_widget.dart';
import './widgets/confirm_booking_button_widget.dart';
import './widgets/payment_method_widget.dart';
import './widgets/professional_success_widget.dart';

class BookingConfirmation extends StatefulWidget {
  const BookingConfirmation({Key? key}) : super(key: key);

  @override
  State<BookingConfirmation> createState() => _BookingConfirmationState();
}

class _BookingConfirmationState extends State<BookingConfirmation>
    with TickerProviderStateMixin {
  // Theme-aware colors
  Color get primaryColor => const Color(0xFF008B8B);
  Color get backgroundColor =>
      ThemeNotifier().isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get surfaceColor =>
      ThemeNotifier().isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get textColor =>
      ThemeNotifier().isDarkMode ? Colors.white : Colors.black87;
  Color get onSurfaceVariantColor =>
      ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54;
  Color get shadowColor =>
      ThemeNotifier().isDarkMode ? Colors.black : Colors.grey[300]!;
  late AnimationController _pageController;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _showSuccess = false;
  String _selectedPaymentMethod = 'mtn_momo';
  Map<String, dynamic> _paymentData = {};

  // Booking data - will be populated from arguments or use defaults
  Map<String, dynamic> _bookingData = {};
  bool _dataInitialized = false;

  final List<String> _progressSteps = [
    'Search',
    'Select Seats',
    'Payment',
    'Confirmation',
  ];

  @override
  void initState() {
    super.initState();
    ThemeNotifier().addListener(_onThemeChanged);

    _pageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
        );

    _pageController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataInitialized) {
      // Get booking data from arguments or use defaults
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _bookingData = arguments ?? _getDefaultBookingData();
      _dataInitialized = true;
    }
  }

  Map<String, dynamic> _getDefaultBookingData() {
    return {
      "bookingId":
          "BF${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
      "fromCity": "Douala",
      "toCity": "Yaoundé",
      "date": "July 28, 2025",
      "departureTime": "09:30 AM",
      "arrivalTime": "01:45 PM",
      "selectedSeats": ["3", "4"],
      "totalPrice": "11,000 XAF",
      "passengers": [
        {"name": "Passenger 3", "age": 25, "gender": "Male"},
        {"name": "Passenger 4", "age": 30, "gender": "Female"},
      ],
      "priceBreakdown": {
        "Base Fare (2 seats)": "11,000 XAF",
        "Service Fee": "0 XAF",
        "Taxes": "0 XAF",
      },
    };
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _onPaymentMethodSelected(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  void _onPaymentDataChanged(Map<String, dynamic> data) {
    setState(() {
      _paymentData = data;
    });
  }

  bool _isFormValid() {
    if (_selectedPaymentMethod == 'credit_card') {
      return _paymentData['cardNumber']?.isNotEmpty == true &&
          _paymentData['expiry']?.isNotEmpty == true &&
          _paymentData['cvv']?.isNotEmpty == true &&
          _paymentData['name']?.isNotEmpty == true;
    }
    return true; // Other payment methods don't require form validation
  }

  Future<void> _processPayment() async {
    if (!_isFormValid()) {
      _showErrorMessage('Please fill in all required payment information');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    // Simulate payment success (90% success rate)
    final isSuccess = DateTime.now().millisecond % 10 != 0;

    if (isSuccess) {
      setState(() {
        _isLoading = false;
        _showSuccess = true;
      });
      HapticFeedback.heavyImpact();
    } else {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage(
        'Payment failed. Please try again or use a different payment method.',
      );
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _onSuccessAnimationComplete() {
    // Navigate to home or ticket view after success animation
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home-dashboard',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while data is being initialized
    if (!_dataInitialized || _bookingData.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (_showSuccess) {
      return Scaffold(
        body: ProfessionalSuccessWidget(
          onContinue: _onSuccessAnimationComplete,
          bookingData: _bookingData,
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildSimpleAppBar(),
          Expanded(child: _buildMainContent()),
          // Sticky payment button at bottom
          _buildStickyPaymentButton(),
        ],
      ),
    );
  }

  Widget _buildSimpleAppBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 6.h, 4.w, 2.h),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: onSurfaceVariantColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: ThemeNotifier().isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: textColor,
                        size: 5.w,
                      ),
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Payment',
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Complete your booking securely',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: onSurfaceVariantColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Security Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.security,
                          color: const Color(0xFF4CAF50),
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'SSL',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress Indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: _buildModernProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOldModernSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 15.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: backgroundColor.withOpacity(0.95),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.1),
                primaryColor.withOpacity(0.05),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 2.h),
                  Text(
                    'Secure Payment',
                    style: GoogleFonts.inter(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'Complete your booking securely',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: onSurfaceVariantColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Modern Progress Indicator
                  _buildModernProgressIndicator(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: onSurfaceVariantColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 5.w),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(2.w),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user,
                color: const Color(0xFF4CAF50),
                size: 4.w,
              ),
              SizedBox(width: 1.w),
              Text(
                'SSL',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: const Color(0xFF4CAF50),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernProgressIndicator() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: onSurfaceVariantColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: List.generate(_progressSteps.length, (index) {
          final isCompleted = index <= 2;
          final isActive = index == 2;
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: isCompleted
                    ? (isActive ? primaryColor : primaryColor.withOpacity(0.7))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTripOverviewCard() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [surfaceColor, surfaceColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Header with Booking ID
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.airplane_ticket,
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Overview',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _bookingData["bookingId"] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Route Display with Modern Design
          _buildModernRouteDisplay(),

          SizedBox(height: 3.h),

          // Trip Details in Cards
          _buildTripDetailCards(),
        ],
      ),
    );
  }

  Widget _buildModernRouteDisplay() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          // From City
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'FROM',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  _bookingData["fromCity"] as String,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),

          // Route Indicator
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.trending_flat, color: Colors.white, size: 6.w),
          ),

          // To City
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'TO',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  _bookingData["toCity"] as String,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetailCards() {
    return Row(
      children: [
        Expanded(
          child: _buildDetailCard(
            'Date',
            _bookingData["date"] as String,
            Icons.calendar_today_outlined,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildDetailCard(
            'Time',
            _bookingData["departureTime"] as String,
            Icons.schedule_outlined,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildDetailCard(
            'Seats',
            (_bookingData["selectedSeats"] as List).join(', '),
            Icons.airline_seat_recline_normal_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: onSurfaceVariantColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryColor, size: 5.w),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: onSurfaceVariantColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerDetailsSection() {
    final passengers = _bookingData["passengers"] as List<dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passenger Details',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        SizedBox(height: 2.h),
        ...passengers.asMap().entries.map((entry) {
          final index = entry.key;
          final passenger = entry.value as Map<String, dynamic>;
          return Container(
            margin: EdgeInsets.only(bottom: 2.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryColor.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.2),
                        primaryColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: primaryColor,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passenger["name"]?.toString() ?? "Unknown Passenger",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${passenger["age"]?.toString() ?? "N/A"} years',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: onSurfaceVariantColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              passenger["gender"]?.toString() ??
                                  "Not specified",
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: onSurfaceVariantColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    (_bookingData["selectedSeats"] as List)[index].toString(),
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPriceBreakdownCard() {
    final priceBreakdown =
        _bookingData["priceBreakdown"] as Map<String, dynamic>;

    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.05),
            primaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long, color: Colors.white, size: 5.w),
              ),
              SizedBox(width: 3.w),
              Text(
                'Price Breakdown',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Price Items
          ...priceBreakdown.entries
              .map(
                (entry) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: onSurfaceVariantColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        entry.value as String,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),

          SizedBox(height: 2.h),

          // Divider
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.3),
                  primaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          SizedBox(height: 2.h),

          // Total Amount
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                Text(
                  _bookingData["totalPrice"] as String,
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: primaryColor.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4CAF50),
                          const Color(0xFF4CAF50).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.credit_card,
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Payment',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Your information is protected',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: onSurfaceVariantColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              // Payment Method Widget
              PaymentMethodWidget(
                onPaymentMethodSelected: _onPaymentMethodSelected,
                onPaymentDataChanged: _onPaymentDataChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityBadge() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.1),
            const Color(0xFF4CAF50).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50),
                  const Color(0xFF4CAF50).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.verified_user, color: Colors.white, size: 6.w),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔒 Bank-Level Security',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Your data is protected with 256-bit SSL encryption. We never store your card details.',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: onSurfaceVariantColor,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomSection() {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [surfaceColor, surfaceColor.withOpacity(0.95)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quick Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: onSurfaceVariantColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        _bookingData["totalPrice"] as String,
                        style: GoogleFonts.inter(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.2),
                          primaryColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${(_bookingData["selectedSeats"] as List).length}',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'Passenger${(_bookingData["selectedSeats"] as List).length > 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Terms
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: onSurfaceVariantColor,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: onSurfaceVariantColor,
                        ),
                        children: [
                          const TextSpan(
                            text: 'By proceeding, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Terms of Service',
                            style: GoogleFonts.inter(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: GoogleFonts.inter(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Enhanced Confirm Button
              _buildEnhancedConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedConfirmButton() {
    return Container(
      width: double.infinity,
      height: 6.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isFormValid() && !_isLoading
              ? [primaryColor, primaryColor.withOpacity(0.8)]
              : [Colors.grey[400]!, Colors.grey[300]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFormValid() && !_isLoading
            ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (_isFormValid() && !_isLoading) ? _processPayment : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _isLoading
                ? Center(
                    child: SizedBox(
                      width: 6.w,
                      height: 6.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, color: Colors.white, size: 5.w),
                      SizedBox(width: 2.w),
                      Text(
                        'Complete Secure Payment',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 5.w),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Methods Section - moved to top
          _buildModernPaymentMethodsSection(),
          SizedBox(height: 2.5.h),

          // Trip overview header
          Text(
            "Booking Summary",
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 1.5.h),

          // Trip route card
          _buildRouteCard(),
          SizedBox(height: 2.h),

          // Passengers section
          _buildPassengersSection(),
          SizedBox(height: 2.h),

          // Price breakdown
          _buildPriceBreakdown(),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onSurfaceVariantColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Trip Details",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 1.h),

          // Route
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FROM",
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: onSurfaceVariantColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _bookingData["fromCity"]?.toString() ?? "N/A",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: primaryColor,
                  size: 4.w,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "TO",
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: onSurfaceVariantColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _bookingData["toCity"]?.toString() ?? "N/A",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Trip info grid
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTripDetailItem(
                        "Date",
                        _bookingData["date"]?.toString() ?? "N/A",
                      ),
                    ),
                    Expanded(
                      child: _buildTripDetailItem(
                        "Time",
                        _bookingData["departureTime"]?.toString() ?? "N/A",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildTripDetailItem(
                        "Seats",
                        (_bookingData["selectedSeats"] as List?)?.join(", ") ??
                            "N/A",
                      ),
                    ),
                    Expanded(
                      child: _buildTripDetailItem(
                        "Bus",
                        _bookingData["busNumber"]?.toString() ?? "TRS-001",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: onSurfaceVariantColor,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPassengersSection() {
    List<Map<String, dynamic>> passengers = List<Map<String, dynamic>>.from(
      _bookingData["passengers"] ??
          [
            {
              "name": "John Doe",
              "age": 30,
              "gender": "Male",
              "seatNumber": "12A",
              "price": 15000,
            },
            {
              "name": "Jane Smith",
              "age": 25,
              "gender": "Female",
              "seatNumber": "12B",
              "price": 15000,
            },
          ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onSurfaceVariantColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Passengers (${passengers.length})",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 1.h),
          ...passengers.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> passenger = entry.value;

            return Container(
              margin: EdgeInsets.only(
                bottom: index < passengers.length - 1 ? 2.h : 0,
              ),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Passenger icon
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.person, color: primaryColor, size: 5.w),
                  ),
                  SizedBox(width: 3.w),

                  // Passenger details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          passenger["name"]?.toString() ?? "Unknown Passenger",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        Text(
                          "${passenger["age"]?.toString() ?? "N/A"} years • ${passenger["gender"]?.toString() ?? "Not specified"}",
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: onSurfaceVariantColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Seat and price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Seat ${passenger["seatNumber"]?.toString() ?? "N/A"}",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        "${passenger["price"]?.toString() ?? "0"} XAF",
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: onSurfaceVariantColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    int basePrice =
        int.tryParse(_bookingData["basePrice"]?.toString() ?? "30000") ?? 30000;
    int taxes = (basePrice * 0.05).round(); // 5% tax
    int serviceFee = 1000;
    int total = basePrice + taxes + serviceFee;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onSurfaceVariantColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Price Breakdown",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 1.h),
          _buildPriceRow("Ticket Price", "$basePrice XAF"),
          _buildPriceRow("Taxes & Fees", "$taxes XAF"),
          _buildPriceRow("Service Fee", "$serviceFee XAF"),
          Divider(height: 3.h, color: onSurfaceVariantColor.withOpacity(0.2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Text(
                "$total XAF",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: onSurfaceVariantColor,
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment Method",
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: 1.h),

        // Modern grid-style payment methods
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: onSurfaceVariantColor.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              // First row - Mobile Money
              Row(
                children: [
                  Expanded(
                    child: _buildModernPaymentTile(
                      'mtn_momo',
                      'MTN\nMoMo',
                      'images/mtn-logo.svg',
                      Colors.yellow[700]!,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: _buildModernPaymentTile(
                      'orange_money',
                      'Orange\nMoney',
                      'images/orange-money-logo.svg',
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
              // Second row - Cards
              Row(
                children: [
                  Expanded(
                    child: _buildModernPaymentTile(
                      'visa',
                      'Visa\nCard',
                      'images/visa-logo.svg',
                      Color(0xFF1A1F71),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: _buildModernPaymentTile(
                      'mastercard',
                      'Master\nCard',
                      'images/mastercard-logo.svg',
                      Color(0xFFEB001B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernPaymentTile(
    String method,
    String name,
    String logoPath,
    Color brandColor,
  ) {
    bool isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        height: 10.h,
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? brandColor.withOpacity(0.1) : backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? brandColor
                : onSurfaceVariantColor.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5.h,
              child: SvgPicture.asset(
                logoPath,
                height: 5.h,
                fit: BoxFit.contain,
                colorFilter: isSelected
                    ? null
                    : ColorFilter.mode(
                        onSurfaceVariantColor.withOpacity(0.7),
                        BlendMode.srcIn,
                      ),
              ),
            ),
            SizedBox(height: 0.5.h),
            Flexible(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? brandColor : textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      width: double.infinity,
      height: 6.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _proceedToPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 6.w,
                height: 6.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, color: Colors.white, size: 5.w),
                  SizedBox(width: 2.w),
                  Text(
                    "Pay with ${_getPaymentMethodName()}",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 5.w),
                ],
              ),
      ),
    );
  }

  Widget _buildStickyPaymentButton() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: 7.h, // Increased height
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _proceedToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ), // Added padding
            ),
            child: _isLoading
                ? SizedBox(
                    width: 6.w,
                    height: 6.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, color: Colors.white, size: 5.w),
                      SizedBox(width: 2.w),
                      Flexible(
                        child: Text(
                          "Pay with ${_getPaymentMethodName()}",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 5.w),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSheet(ScrollController scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag indicator
          Container(
            width: 36,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            decoration: BoxDecoration(
              color: onSurfaceVariantColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.all(4.w),
              children: [
                // Total amount
                Text(
                  "Total Amount",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: onSurfaceVariantColor,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  "${_bookingData["totalPrice"]?.toString() ?? "0"} XAF",
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 3.h),

                // Payment Methods
                Text(
                  "Payment Method",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 2.h),

                // Professional payment method options
                _buildPaymentMethodOption(
                  'mtn_momo',
                  'MTN Mobile Money',
                  Icons.phone_android,
                  'Mobile payment via MTN network',
                ),
                SizedBox(height: 2.h),
                _buildPaymentMethodOption(
                  'orange_money',
                  'Orange Money',
                  Icons.phone_android,
                  'Mobile payment via Orange network',
                ),
                SizedBox(height: 2.h),
                _buildPaymentMethodOption(
                  'visa',
                  'Visa Card',
                  Icons.credit_card,
                  'Pay with your Visa credit/debit card',
                ),
                SizedBox(height: 2.h),
                _buildPaymentMethodOption(
                  'mastercard',
                  'Mastercard',
                  Icons.credit_card,
                  'Pay with your Mastercard credit/debit card',
                ),

                SizedBox(height: 3.h),

                // Payment button
                Container(
                  width: double.infinity,
                  height: 7.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: _proceedToPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Pay with ${_getPaymentMethodName()}",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    String method,
    String name,
    IconData icon,
    String description,
  ) {
    bool isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : onSurfaceVariantColor.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withOpacity(0.1)
                    : onSurfaceVariantColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? primaryColor : onSurfaceVariantColor,
                size: 6.w,
              ),
            ),
            SizedBox(width: 3.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: onSurfaceVariantColor,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 4.w),
              )
            else
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: onSurfaceVariantColor.withOpacity(0.3),
                  ),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getPaymentMethodName() {
    switch (_selectedPaymentMethod) {
      case 'mtn_momo':
        return 'MTN MoMo';
      case 'orange_money':
        return 'Orange Money';
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      default:
        return 'Selected Method';
    }
  }

  void _proceedToPayment() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Simulate payment success
    setState(() {
      _isLoading = false;
      _showSuccess = true;
    });

    HapticFeedback.heavyImpact();
  }
}
