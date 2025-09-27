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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    _tickMoveController.dispose();
    _cardPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Stack(
            children: [
              // Animated tick (always visible, moves and scales)
              SlideTransition(
                position: _tickMoveAnimation,
                child: ScaleTransition(
                  scale: _tickScaleAnimation,
                  child: Center(child: _buildSuccessIndicator()),
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
        // Top spacer (less space since tick is at top)
        SizedBox(height: 15.h),

        // Success message
        _buildSuccessMessage(),

        SizedBox(height: 4.h),

        // Booking summary card
        Expanded(child: _buildBookingSummaryCard()),

        SizedBox(height: 2.h),

        // Action buttons at bottom
        _buildActionButtons(),

        SizedBox(height: 2.h),
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

  Widget _buildSuccessMessage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            Text(
              'Booking ID: ${widget.bookingData["bookingId"]?.toString() ?? "N/A"}',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Payment Successful',
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Your booking has been confirmed',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummaryCard() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Route
                          _buildRouteSection(),

                          SizedBox(height: 1.5.h),

                          // Details grid
                          _buildDetailsGrid(),

                          SizedBox(height: 2.h),

                          // Slide indicator
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

                    // Slide 2: QR Code
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Column(
                        children: [
                          SizedBox(height: 2.h),
                          Center(child: _buildQRSection()),
                          SizedBox(height: 2.h),
                        ],
                      ),
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
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: onSurfaceColor.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                widget.bookingData["fromCity"]?.toString() ?? "N/A",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.arrow_forward, color: primaryColor, size: 4.w),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TO',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: onSurfaceColor.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                widget.bookingData["toCity"]?.toString() ?? "N/A",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
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

  Widget _buildDetailsGrid() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Date',
                  widget.bookingData["date"]?.toString() ?? "N/A",
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Time',
                  widget.bookingData["departureTime"]?.toString() ?? "N/A",
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Seats',
                  (widget.bookingData["selectedSeats"] as List?)?.join(", ") ??
                      "N/A",
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Total',
                  "${widget.bookingData["totalPrice"]?.toString() ?? "0"} XAF",
                ),
              ),
            ],
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
            color: onSurfaceColor.withOpacity(0.6),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: onSurfaceColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQRSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: onSurfaceColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: QrImageView(
            data:
                'https://tease.com/booking/${widget.bookingData["bookingId"] ?? "12345"}',
            version: QrVersions.auto,
            size: 50.w, // Reduced from 60.w to prevent overflow
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
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
