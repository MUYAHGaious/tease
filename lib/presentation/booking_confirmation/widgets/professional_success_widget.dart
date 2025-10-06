import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../theme/theme_notifier.dart';

/// Professional payment success screen based on Material Design 3 principles
/// and tech giant best practices (Apple Pay, Google Pay 2025)
class ProfessionalSuccessWidget extends StatefulWidget {
  final VoidCallback onContinue;
  final Map<String, dynamic> bookingData;

  const ProfessionalSuccessWidget({
    Key? key,
    required this.onContinue,
    required this.bookingData,
  }) : super(key: key);

  @override
  State<ProfessionalSuccessWidget> createState() =>
      _ProfessionalSuccessWidgetState();
}

class _ProfessionalSuccessWidgetState extends State<ProfessionalSuccessWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pageController;
  late AnimationController _tickMoveController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _pageSlideAnimation;
  late Animation<Offset> _tickMoveAnimation;
  late Animation<double> _tickScaleAnimation;

  bool _showContent = false;
  late PageController _cardPageController;
  late PageController _ticketPageController;
  int _currentTicketIndex = 0;

  // Get list of passengers from booking data
  List<Map<String, dynamic>> get _passengers {
    final passengers = widget.bookingData["passengers"];
    if (passengers is List && passengers.isNotEmpty) {
      return List<Map<String, dynamic>>.from(passengers);
    }
    // Fallback to single passenger from main booking data
    return [
      {
        "name": widget.bookingData["passengerName"] ?? widget.bookingData["name"] ?? "N/A",
        "seat": (widget.bookingData["selectedSeats"] as List?)?.first ?? "N/A",
        "idCardNumber": widget.bookingData["idCardNumber"] ?? widget.bookingData["cniNumber"] ?? "N/A",
        "price": widget.bookingData["ticketPrice"] ?? widget.bookingData["totalPrice"] ?? "0",
      }
    ];
  }

  // Material Design 3 compliant colors
  Color get primaryColor => const Color(0xFF008B8B);
  Color get backgroundColor => const Color(0xFF008B8B);
  Color get surfaceColor => Colors.white.withOpacity(0.95);
  Color get onSurfaceColor => const Color(0xFF1A1A1A);
  Color get successColor => Colors.white;

  @override
  void initState() {
    super.initState();
    _cardPageController = PageController();
    _ticketPageController = PageController();
    _setupAnimations();
    _startSuccessSequence();
  }

  void _setupAnimations() {
    // Content fade: Subtle and fast (200ms)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Slide animation: Natural motion (250ms)
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Page slide animation: Smooth transition (400ms)
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Tick move animation: Fast upward movement (300ms)
    _tickMoveController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Fade with emphasis curve
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );

    // Slide with material motion
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Scale with material spring
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
    );

    // Page slide animation
    _pageSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0)).animate(
          CurvedAnimation(parent: _pageController, curve: Curves.easeInOut),
        );

    // Tick move animation (center to top)
    _tickMoveAnimation =
        Tween<Offset>(
          begin: Offset.zero, // Start at perfect center
          end: const Offset(0, -0.8), // Move to top
        ).animate(
          CurvedAnimation(
            parent: _tickMoveController,
            curve: Curves.easeInQuart,
          ),
        );

    // Tick scale animation (large to small)
    _tickScaleAnimation =
        Tween<double>(
          begin: 1.5, // Large at center
          end: 0.6, // Smaller at top
        ).animate(
          CurvedAnimation(
            parent: _tickMoveController,
            curve: Curves.easeInQuart,
          ),
        );
  }

  Future<void> _startSuccessSequence() async {
    // Immediate haptic feedback (tech giant standard)
    HapticFeedback.heavyImpact();

    // Phase 1: Let tick animation play fully (2 seconds for complete animation)
    await Future.delayed(const Duration(milliseconds: 2000));

    // Phase 2: Immediately move tick up and show content simultaneously
    _tickMoveController.forward();
    setState(() {
      _showContent = true;
    });
    _fadeController.forward();

    // Phase 3: Slide in supporting content quickly after
    await Future.delayed(const Duration(milliseconds: 150));
    _slideController.forward();

    // Light haptic confirmation
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();

    // Phase 4: Auto-slide to QR code after 0.5 seconds
    await Future.delayed(const Duration(milliseconds: 500));
    _cardPageController.animateToPage(
      1, // Slide to QR code page
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    HapticFeedback.mediumImpact();

    // Phase 5: Auto-cycle through all tickets if multiple passengers
    if (_passengers.length > 1) {
      await Future.delayed(const Duration(milliseconds: 1500)); // Wait on QR code

      // Cycle through remaining tickets
      for (int i = 1; i < _passengers.length; i++) {
        // Swipe to next ticket with smooth animation
        await _ticketPageController.animateToPage(
          i,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
        HapticFeedback.selectionClick();

        // Stay on details page for a moment
        await Future.delayed(const Duration(milliseconds: 1500));

        // Auto-slide to QR code for this ticket
        await _cardPageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        HapticFeedback.lightImpact();

        // Wait on QR code
        await Future.delayed(const Duration(milliseconds: 1500));

        // Go back to details for next ticket (unless it's the last one)
        if (i < _passengers.length - 1) {
          await _cardPageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    _tickMoveController.dispose();
    _cardPageController.dispose();
    _ticketPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Stack(
            children: [
              // Animated tick (always visible, moves and scales)
              SlideTransition(
                position: _tickMoveAnimation,
                child: ScaleTransition(
                  scale: _tickScaleAnimation,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSuccessIndicator(),
                        SizedBox(height: 3.h),
                        // Payment Successful text appears with tick
                        if (!_showContent)
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Payment Successful',
                              style: GoogleFonts.inter(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Main page (booking summary) - only shows after tick moves
              if (_showContent) _buildMainPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainPage() {
    return Column(
      children: [
        // Swipeable content (entire upper section)
        Expanded(
          child: PageView.builder(
            controller: _ticketPageController,
            itemCount: _passengers.length,
            physics: const BouncingScrollPhysics(),
            pageSnapping: true,
            padEnds: true,
            onPageChanged: (index) {
              setState(() {
                _currentTicketIndex = index;
              });
              HapticFeedback.selectionClick();
            },
            itemBuilder: (context, index) {
              return _buildFullTicketPage(index);
            },
          ),
        ),

        SizedBox(height: 1.5.h),

        // Ticket indicator (only show for multiple passengers)
        if (_passengers.length > 1) _buildTicketIndicator(),
        if (_passengers.length > 1) SizedBox(height: 1.5.h),

        // Action buttons at bottom
        _buildActionButtons(),

        SizedBox(height: 1.5.h),
      ],
    );
  }

  Widget _buildSuccessIndicator() {
    return Container(
      width: 40.w,
      height: 40.w,
      child: Lottie.asset(
        'assets/tick_animation.json',
        width: 40.w,
        height: 40.w,
        repeat: false,
        animate: true,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to a simple checkmark icon if Lottie fails
          return Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4CAF50),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.check, color: Colors.white, size: 20.w),
          );
        },
      ),
    );
  }

  Widget _buildFullTicketPage(int passengerIndex) {
    final passenger = _passengers[passengerIndex];
    final passengerCount = _passengers.length;

    return Column(
      children: [
        SizedBox(height: 5.h),

        // Success message with passenger-specific booking ID
        FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              children: [
                Text(
                  'Booking ID: ${widget.bookingData["bookingId"]?.toString() ?? "N/A"}',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  passengerCount > 1
                    ? 'Ticket ${passengerIndex + 1} of $passengerCount - ${passenger["name"] ?? "N/A"}'
                    : 'Ticket Confirmed',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Ticket card for this passenger
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildTicketCard(passengerIndex),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_passengers.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: index == _currentTicketIndex ? 8.w : 2.w,
          height: 2.w,
          decoration: BoxDecoration(
            color: index == _currentTicketIndex
              ? primaryColor
              : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(1.w),
          ),
        );
      }),
    );
  }

  Widget _buildTicketCard(int passengerIndex) {
    final passenger = _passengers[passengerIndex];
    return ClipPath(
      clipper: TicketClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border.all(
            color: onSurfaceColor.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: primaryColor,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Booking Summary',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Slide-based content
          Expanded(
            child: PageView(
              controller: _cardPageController,
              children: [
                // Slide 1: Route and details
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          // Route
                          _buildRouteSection(),

                          SizedBox(height: 1.5.h),

                          // Details grid for specific passenger
                          _buildDetailsGrid(passengerIndex),
                        ],
                      ),

                      // Slide indicator at bottom
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: onSurfaceColor.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Slide 2: QR Code for this passenger
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: _buildQRSection(passengerIndex),
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

  Widget _buildRouteSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FROM',
                style: GoogleFonts.inter(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w500,
                  color: onSurfaceColor.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                widget.bookingData["fromCity"]?.toString() ?? "N/A",
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(1.5.w),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.arrow_forward, color: primaryColor, size: 3.5.w),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TO',
                style: GoogleFonts.inter(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w500,
                  color: onSurfaceColor.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                widget.bookingData["toCity"]?.toString() ?? "N/A",
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceColor,
                ),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid(int passengerIndex) {
    final passenger = _passengers[passengerIndex];
    return Column(
      children: [
        // Passenger Name Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: onSurfaceColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: onSurfaceColor.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: primaryColor,
                  size: 3.5.w,
                ),
              ),
              SizedBox(width: 2.5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PASSENGER NAME',
                      style: GoogleFonts.inter(
                        fontSize: 7.sp,
                        fontWeight: FontWeight.w500,
                        color: onSurfaceColor.withOpacity(0.5),
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      passenger["name"]?.toString() ?? "N/A",
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: onSurfaceColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 1.2.h),

        // ID Card Number Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: onSurfaceColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: onSurfaceColor.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.badge_outlined,
                  color: primaryColor,
                  size: 3.5.w,
                ),
              ),
              SizedBox(width: 2.5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID CARD NUMBER',
                      style: GoogleFonts.inter(
                        fontSize: 7.sp,
                        fontWeight: FontWeight.w500,
                        color: onSurfaceColor.withOpacity(0.5),
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      passenger["idCardNumber"]?.toString() ?? "N/A",
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: onSurfaceColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 1.2.h),

        // Time Information
        Container(
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildCompactDetail(
                  Icons.schedule,
                  'DEPARTURE',
                  widget.bookingData["departureTime"]?.toString() ?? "N/A",
                ),
              ),
              Container(
                width: 1,
                height: 4.h,
                color: onSurfaceColor.withOpacity(0.1),
              ),
              Expanded(
                child: _buildCompactDetail(
                  Icons.access_time,
                  'ARRIVAL',
                  widget.bookingData["arrivalTime"]?.toString() ?? "N/A",
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 1.2.h),

        // Date and Seats Grid
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Date',
                widget.bookingData["date"]?.toString() ?? "N/A",
                Icons.calendar_today_outlined,
              ),
            ),
            SizedBox(width: 1.5.w),
            Expanded(
              child: _buildInfoCard(
                'Seat',
                passenger["seat"]?.toString() ?? "N/A",
                Icons.event_seat_outlined,
              ),
            ),
          ],
        ),

        SizedBox(height: 1.2.h),

        // Total Amount
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.1),
                primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    color: primaryColor,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'TICKET PRICE',
                    style: GoogleFonts.inter(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                      color: onSurfaceColor.withOpacity(0.6),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Text(
                "XAF ${passenger["price"]?.toString() ?? widget.bookingData["ticketPrice"]?.toString() ?? "0"}",
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 3.5.w),
        SizedBox(height: 0.3.h),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 7.sp,
            fontWeight: FontWeight.w500,
            color: onSurfaceColor.withOpacity(0.5),
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 0.2.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: onSurfaceColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: onSurfaceColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: onSurfaceColor.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor, size: 3.5.w),
          SizedBox(height: 0.7.h),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 7.sp,
              fontWeight: FontWeight.w500,
              color: onSurfaceColor.withOpacity(0.5),
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 0.2.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: onSurfaceColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQRSection(int passengerIndex) {
    final passenger = _passengers[passengerIndex];
    final bookingId = widget.bookingData["bookingId"] ?? "12345";
    final ticketData = '$bookingId-P${passengerIndex + 1}-${passenger["seat"]}-${passenger["name"]}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: onSurfaceColor.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              QrImageView(
                data: 'https://tease.com/ticket/$ticketData',
                version: QrVersions.auto,
                size: 70.w,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
              // Logo overlay (black logo on white background)
              Container(
                width: 70.w * 0.22,
                height: 70.w * 0.22,
                child: Image.asset(
                  'qr_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.5.h),
        Text(
          'Ticket for ${passenger["name"]}',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: onSurfaceColor,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          'Seat ${passenger["seat"]} • Show to driver',
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            fontWeight: FontWeight.w400,
            color: onSurfaceColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Secondary actions
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryButton(
                    'Share',
                    Icons.share_outlined,
                    () => _shareTicket(),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildSecondaryButton(
                    'Download',
                    Icons.download_outlined,
                    () => _downloadTicket(),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildSecondaryButton(
                    'Copy Link',
                    Icons.link_outlined,
                    () => _copyLink(),
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Primary action
            _buildPrimaryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 7.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 4.w, color: Colors.white),
            SizedBox(height: 0.5.h),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return Container(
      width: double.infinity,
      height: 7.h, // Increased height
      child: ElevatedButton(
        onPressed: widget.onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 2.h,
          ), // Added padding
        ),
        child: Text(
          'Continue',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _shareTicket() {
    HapticFeedback.lightImpact();
    // Implement share functionality
  }

  void _downloadTicket() {
    HapticFeedback.lightImpact();
    // Implement download functionality
  }

  void _copyLink() {
    HapticFeedback.lightImpact();
    // Implement copy link functionality
  }
}

// Custom clipper for ticket-style corner cuts
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final cornerCutRadius = 15.0;
    final sideCutRadius = 12.0;
    final midHeight = size.height / 2;

    // Start from top-left (after corner cut)
    path.moveTo(cornerCutRadius, 0);

    // Top edge
    path.lineTo(size.width - cornerCutRadius, 0);

    // Top-right corner cut (concave)
    path.arcToPoint(
      Offset(size.width, cornerCutRadius),
      radius: Radius.circular(cornerCutRadius),
      clockwise: false,
    );

    // Right edge - top half
    path.lineTo(size.width, midHeight - sideCutRadius);

    // Right center cut (concave)
    path.arcToPoint(
      Offset(size.width, midHeight + sideCutRadius),
      radius: Radius.circular(sideCutRadius),
      clockwise: false,
    );

    // Right edge - bottom half
    path.lineTo(size.width, size.height - cornerCutRadius);

    // Bottom-right corner cut (concave)
    path.arcToPoint(
      Offset(size.width - cornerCutRadius, size.height),
      radius: Radius.circular(cornerCutRadius),
      clockwise: false,
    );

    // Bottom edge
    path.lineTo(cornerCutRadius, size.height);

    // Bottom-left corner cut (concave)
    path.arcToPoint(
      Offset(0, size.height - cornerCutRadius),
      radius: Radius.circular(cornerCutRadius),
      clockwise: false,
    );

    // Left edge - bottom half
    path.lineTo(0, midHeight + sideCutRadius);

    // Left center cut (concave)
    path.arcToPoint(
      Offset(0, midHeight - sideCutRadius),
      radius: Radius.circular(sideCutRadius),
      clockwise: false,
    );

    // Left edge - top half
    path.lineTo(0, cornerCutRadius);

    // Top-left corner cut (concave)
    path.arcToPoint(
      Offset(cornerCutRadius, 0),
      radius: Radius.circular(cornerCutRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
