import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../theme/theme_notifier.dart';

class SuccessAnimationWidget extends StatefulWidget {
  final VoidCallback onAnimationComplete;
  final Map<String, dynamic> bookingData;

  const SuccessAnimationWidget({
    Key? key,
    required this.onAnimationComplete,
    required this.bookingData,
  }) : super(key: key);

  @override
  State<SuccessAnimationWidget> createState() => _SuccessAnimationWidgetState();
}

class _SuccessAnimationWidgetState extends State<SuccessAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _doneController;
  late AnimationController _moveController;
  late AnimationController _contentController;

  late Animation<double> _doneScaleAnimation;
  late Animation<double> _doneOpacityAnimation;
  late Animation<Offset> _donePositionAnimation;
  late Animation<double> _receiptAnimation;
  late Animation<double> _qrAnimation;
  late Animation<double> _buttonsAnimation;

  // Theme-aware colors matching booking confirmation
  Color get primaryColor => const Color(0xFF008B8B);
  Color get backgroundColor =>
      ThemeNotifier().isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get surfaceColor =>
      ThemeNotifier().isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get textColor =>
      ThemeNotifier().isDarkMode ? Colors.white : Colors.black87;
  Color get subtitleColor =>
      ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54;
  Color get successColor => const Color(0xFF4CAF50);
  Color get shadowColor =>
      ThemeNotifier().isDarkMode ? Colors.black : Colors.grey[300]!;

  @override
  void initState() {
    super.initState();

    // Done animation controller (center checkmark)
    _doneController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Move animation controller (checkmark moving up)
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Content animation controller (receipt, QR, buttons appearing)
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Done animation (scale and fade in)
    _doneScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _doneController,
      curve: Curves.elasticOut,
    ));

    _doneOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _doneController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Movement animation (center to top)
    _donePositionAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -0.7),
    ).animate(CurvedAnimation(
      parent: _moveController,
      curve: Curves.fastOutSlowIn,
    ));

    // Content animations (staggered)
    _receiptAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _qrAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    ));

    _buttonsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    _startSequence();
  }

  void _startSequence() async {
    // Step 1: Done animation appears in center (elastic bounce)
    HapticFeedback.mediumImpact();
    await _doneController.forward();

    // Brief pause to appreciate the done animation
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 2: Done animation moves up quickly (like Duolingo)
    await _moveController.forward();

    // Step 3: Content appears sequentially
    await _contentController.forward();
  }

  @override
  void dispose() {
    _doneController.dispose();
    _moveController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content area with all elements
            AnimatedBuilder(
              animation: Listenable.merge([_doneController, _moveController, _contentController]),
              builder: (context, child) {
                return Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      // Top area for moved checkmark
                      SizedBox(height: 8.h),

                      // Success header (only shows after movement)
                      if (_moveController.value > 0.5)
                        SlideTransition(
                          position: _donePositionAnimation,
                          child: FadeTransition(
                            opacity: _doneOpacityAnimation,
                            child: ScaleTransition(
                              scale: _doneScaleAnimation,
                              child: _buildCompactSuccessHeader(),
                            ),
                          ),
                        ),

                      SizedBox(height: 3.h),

                      // Content that appears after movement
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Receipt
                              FadeTransition(
                                opacity: _receiptAnimation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(_receiptAnimation),
                                  child: _buildCompactTicket(),
                                ),
                              ),

                              SizedBox(height: 2.h),

                              // QR Code
                              FadeTransition(
                                opacity: _qrAnimation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(_qrAnimation),
                                  child: _buildQRCodeSection(),
                                ),
                              ),

                              SizedBox(height: 3.h),

                              // Action buttons
                              FadeTransition(
                                opacity: _buttonsAnimation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(_buttonsAnimation),
                                  child: _buildCompactActionButtons(),
                                ),
                              ),

                              SizedBox(height: 3.h),

                              // Navigation button
                              FadeTransition(
                                opacity: _buttonsAnimation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(_buttonsAnimation),
                                  child: _buildNavigationButton(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Center checkmark (initial animation)
            if (_moveController.value < 0.5)
              Center(
                child: AnimatedBuilder(
                  animation: _doneController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _doneOpacityAnimation,
                      child: ScaleTransition(
                        scale: _doneScaleAnimation,
                        child: _buildCenterDoneAnimation(),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Column(
      children: [
        // Large success checkmark
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: successColor,
            boxShadow: [
              BoxShadow(
                color: successColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 10.w,
          ),
        ),

        SizedBox(height: 3.h),

        // Success message
        Text(
          'Payment Successful!',
          style: GoogleFonts.inter(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),

        SizedBox(height: 1.h),

        Text(
          'Your booking has been confirmed',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCenterDoneAnimation() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Large checkmark for center animation
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: successColor,
            boxShadow: [
              BoxShadow(
                color: successColor.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 15.w,
          ),
        ),

        SizedBox(height: 4.h),

        // Text that appears with the checkmark
        Text(
          'Payment Successful!',
          style: GoogleFonts.inter(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSuccessHeader() {
    return Row(
      children: [
        // Smaller checkmark for top position
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: successColor,
          ),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 4.w,
          ),
        ),

        SizedBox(width: 3.w),

        // Compact success text
        Text(
          'Payment Successful',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDigitalTicket() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ticket header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.airplane_ticket, color: primaryColor, size: 6.w),
                SizedBox(width: 3.w),
                Text(
                  'Digital Ticket',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Ticket content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FROM',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: subtitleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.bookingData["fromCity"]?.toString() ?? "N/A",
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
                                color: subtitleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.bookingData["toCity"]?.toString() ?? "N/A",
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

                  SizedBox(height: 3.h),

                  // Trip details
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Date', widget.bookingData["date"]?.toString() ?? "N/A"),
                        _buildDetailRow('Departure', widget.bookingData["departureTime"]?.toString() ?? "N/A"),
                        _buildDetailRow('Seats', (widget.bookingData["selectedSeats"] as List?)?.join(", ") ?? "N/A"),
                        _buildDetailRow('Passengers', "${(widget.bookingData["selectedSeats"] as List?)?.length ?? 0}"),
                        _buildDetailRow('Total Amount', "${widget.bookingData["totalPrice"]?.toString() ?? "0"} XAF"),
                        Divider(height: 2.h, color: subtitleColor.withOpacity(0.3)),
                        _buildDetailRow('Booking ID', widget.bookingData["bookingId"]?.toString() ?? "N/A"),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Professional QR Code section
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: subtitleColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Digital Verification',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        // QR Code placeholder
                        Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: subtitleColor.withOpacity(0.3)),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.qr_code, size: 8.w, color: textColor),
                                SizedBox(height: 1.h),
                                Text(
                                  'Scan to verify',
                                  style: GoogleFonts.inter(
                                    fontSize: 8.sp,
                                    color: subtitleColor,
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
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: subtitleColor,
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
      ),
    );
  }

  Widget _buildCompactTicket() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Booking ID
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Booking ID: ${widget.bookingData["bookingId"]?.toString() ?? "N/A"}',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Route info in compact format
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.bookingData["fromCity"]?.toString() ?? "N/A",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Icon(Icons.arrow_forward, color: primaryColor, size: 5.w),
              Text(
                widget.bookingData["toCity"]?.toString() ?? "N/A",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Key details in 2x2 grid
          Row(
            children: [
              Expanded(child: _buildCompactDetailItem('Date', widget.bookingData["date"]?.toString() ?? "N/A")),
              Expanded(child: _buildCompactDetailItem('Seats', (widget.bookingData["selectedSeats"] as List?)?.join(", ") ?? "N/A")),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(child: _buildCompactDetailItem('Time', widget.bookingData["departureTime"]?.toString() ?? "N/A")),
              Expanded(child: _buildCompactDetailItem('Total', "${widget.bookingData["totalPrice"]?.toString() ?? "0"} XAF")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: subtitleColor,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQRCodeSection() {
    // Create QR data with booking information
    String qrData = "BOOKING:${widget.bookingData["bookingId"]?.toString() ?? "N/A"}|"
                   "FROM:${widget.bookingData["fromCity"]?.toString() ?? "N/A"}|"
                   "TO:${widget.bookingData["toCity"]?.toString() ?? "N/A"}|"
                   "DATE:${widget.bookingData["date"]?.toString() ?? "N/A"}|"
                   "SEATS:${(widget.bookingData["selectedSeats"] as List?)?.join(",") ?? "N/A"}|"
                   "TOTAL:${widget.bookingData["totalPrice"]?.toString() ?? "0"}";

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: subtitleColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Scan to Verify Ticket',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: ThemeNotifier().isDarkMode ? Colors.white : backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: subtitleColor.withOpacity(0.3)),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 25.w,
              backgroundColor: ThemeNotifier().isDarkMode ? Colors.white : backgroundColor,
              foregroundColor: ThemeNotifier().isDarkMode ? Colors.black : textColor,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Present this QR code for verification',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Share button
        Container(
          width: 35.w,
          height: 5.h,
          child: ElevatedButton.icon(
            onPressed: _shareTicket,
            icon: Icon(Icons.share, size: 4.w),
            label: Text(
              'Share',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: textColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // Download button
        Container(
          width: 35.w,
          height: 5.h,
          child: ElevatedButton.icon(
            onPressed: _downloadTicket,
            icon: Icon(Icons.download, size: 4.w),
            label: Text(
              'Download',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Share button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareTicket,
            icon: Icon(Icons.share, size: 4.w),
            label: Text(
              'Share',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: textColor,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        SizedBox(width: 3.w),

        // Download button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _downloadTicket,
            icon: Icon(Icons.download, size: 4.w),
            label: Text(
              'Download',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton() {
    return Container(
      width: double.infinity,
      height: 6.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: widget.onAnimationComplete,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue to Home',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 2.w),
            Icon(Icons.arrow_forward, color: Colors.white, size: 4.w),
          ],
        ),
      ),
    );
  }

  void _shareTicket() {
    // Implement share functionality
    HapticFeedback.lightImpact();
    // In a real app, this would use share_plus package
  }

  void _downloadTicket() {
    // Implement download functionality
    HapticFeedback.lightImpact();
    // In a real app, this would save the ticket as PDF
  }
}