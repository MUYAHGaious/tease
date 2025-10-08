import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../services/auth_service.dart';

enum PassengerType { adult, child, senior }

class PassengerInfo {
  final String seatId;
  final String seatNumber;
  final PassengerType type;
  final String name;
  final String idCardNumber;
  final double basePrice;
  final double finalPrice;

  PassengerInfo({
    required this.seatId,
    required this.seatNumber,
    required this.type,
    required this.name,
    required this.idCardNumber,
    required this.basePrice,
    required this.finalPrice,
  });
}

class SeatBookingSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> seat;
  final Map<String, dynamic> busInfo;
  final Map<String, dynamic> routeInfo;

  const SeatBookingSummaryScreen({
    Key? key,
    required this.seat,
    required this.busInfo,
    required this.routeInfo,
  }) : super(key: key);

  @override
  State<SeatBookingSummaryScreen> createState() =>
      _SeatBookingSummaryScreenState();
}

class _SeatBookingSummaryScreenState extends State<SeatBookingSummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _priceAnimationController;
  late Animation<double> _priceAnimation;
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // Passenger information management
  late PassengerInfo _passengerInfo;

  // Theme-aware colors using proper theme system
  Color get primaryColor => Theme.of(context).colorScheme.primary;
  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(context).colorScheme.surface;
  Color get textColor => Theme.of(context).colorScheme.onSurface;
  Color get onSurfaceVariantColor =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  Color get shadowColor => Theme.of(context).colorScheme.shadow;
  Color get borderColor => Theme.of(context).colorScheme.outline;

  @override
  void initState() {
    super.initState();
    _initializePassengerInfo();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _priceAnimationController.dispose();
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _priceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _priceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _priceAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _priceAnimationController.forward();
    _slideAnimationController.forward();
    _fadeAnimationController.forward();
  }

  void _initializePassengerInfo() {
    // Extract price from seat data (remove 'XAF' and convert to double)
    String priceStr = widget.seat['price']
        .toString()
        .replaceAll('XAF', '')
        .replaceAll(',', '')
        .trim();
    double basePrice = double.tryParse(priceStr) ?? 7500.0;

    _passengerInfo = PassengerInfo(
      seatId: widget.seat['id'],
      seatNumber: widget.seat['seatNumber'],
      type: PassengerType.adult, // Default to adult
      name: '', // Empty name to be filled by user
      idCardNumber: '', // Empty ID card number to be filled by user
      basePrice: basePrice,
      finalPrice: basePrice,
    );
  }

  double get totalPrice => _passengerInfo.finalPrice;

  void _updatePassengerName(String name) {
    setState(() {
      _passengerInfo = PassengerInfo(
        seatId: _passengerInfo.seatId,
        seatNumber: _passengerInfo.seatNumber,
        type: _passengerInfo.type,
        name: name,
        idCardNumber: _passengerInfo.idCardNumber,
        basePrice: _passengerInfo.basePrice,
        finalPrice: _passengerInfo.finalPrice,
      );
    });
  }

  void _updatePassengerIdCard(String idCardNumber) {
    setState(() {
      _passengerInfo = PassengerInfo(
        seatId: _passengerInfo.seatId,
        seatNumber: _passengerInfo.seatNumber,
        type: _passengerInfo.type,
        name: _passengerInfo.name,
        idCardNumber: idCardNumber,
        basePrice: _passengerInfo.basePrice,
        finalPrice: _passengerInfo.finalPrice,
      );
    });
  }

  void _updatePassengerType(PassengerType type) {
    setState(() {
      _passengerInfo = PassengerInfo(
        seatId: _passengerInfo.seatId,
        seatNumber: _passengerInfo.seatNumber,
        type: type,
        name: _passengerInfo.name,
        idCardNumber: _passengerInfo.idCardNumber,
        basePrice: _passengerInfo.basePrice,
        finalPrice: _passengerInfo.finalPrice,
      );
    });
  }

  Future<void> _useMyInfo() async {
    try {
      // Get current user data
      final userResponse = await AuthService.getCachedUser();
      if (userResponse == null) {
        _showErrorMessage('User data not found. Please login again.');
        return;
      }

      final user = userResponse;

      // Auto-fill passenger information
      setState(() {
        _passengerInfo = PassengerInfo(
          seatId: _passengerInfo.seatId,
          seatNumber: _passengerInfo.seatNumber,
          type: _passengerInfo.type,
          name: user.fullName,
          idCardNumber: user.idCardNumber ?? '',
          basePrice: _passengerInfo.basePrice,
          finalPrice: _passengerInfo.finalPrice,
        );
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your information has been filled for Seat ${_passengerInfo.seatNumber}',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      _showErrorMessage('Failed to load your information. Please try again.');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  bool _isFormValid() {
    // Name is always required and must have at least two words (first and last name)
    if (_passengerInfo.name.isEmpty) return false;

    // Check if name has at least two words (first and last name)
    final nameWords = _passengerInfo.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (nameWords.length < 2) return false;

    // ID card number is only required for adults
    if (_passengerInfo.type == PassengerType.adult &&
        _passengerInfo.idCardNumber.isEmpty) {
      return false;
    }

    return true;
  }

  String _getValidationMessage() {
    if (_passengerInfo.name.isEmpty) {
      return 'Please enter passenger name';
    }

    final nameWords = _passengerInfo.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (nameWords.length < 2) {
      return 'Please enter both first and last name';
    }

    if (_passengerInfo.type == PassengerType.adult &&
        _passengerInfo.idCardNumber.isEmpty) {
      return 'Please enter ID card number';
    }
    return '';
  }

  void _proceedToPayment() {
    if (!_isFormValid()) {
      _showValidationError();
      return;
    }

    HapticFeedback.selectionClick();
    // Navigate to payment gateway screen
    Navigator.pushNamed(context, '/payment-gateway', arguments: {
      'seat': widget.seat,
      'busInfo': widget.busInfo,
      'routeInfo': widget.routeInfo,
      'passengerInfo': _passengerInfo,
      'previousRoute':
          '/booking-management', // Pass the booking management route
    });
  }

  void _showValidationError() {
    final validationMessage = _getValidationMessage();
    if (validationMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  validationMessage,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.05),
              backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header matching booking management style
              _buildModernHeader(),

              // Content with animations
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),

                          // Trip Information Card
                          _buildTripInfoCard(),
                          SizedBox(height: 2.h),

                          // Seat Information Card
                          _buildSeatInfoCard(),
                          SizedBox(height: 2.h),

                          // Passenger Details Section
                          _buildPassengerDetailsSection(),
                          SizedBox(height: 2.h),

                          // Pricing Breakdown Card
                          _buildPricingBreakdownCard(),
                          SizedBox(height: 2.h),

                          // Continue Button
                          _buildContinueButton(),
                          SizedBox(height: 3.h),
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

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          // Back button with haptic feedback
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back,
                color: textColor,
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
                  'Seat Booking',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Complete your booking details',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: onSurfaceVariantColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoCard() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.directions_bus,
              color: primaryColor,
              size: 6.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.busInfo['model'] ?? 'Express Bus',
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  widget.routeInfo['name'] ?? 'Route Information',
                  style: GoogleFonts.inter(
                    color: onSurfaceVariantColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  '${widget.routeInfo['distance']} • ${widget.routeInfo['duration']}',
                  style: GoogleFonts.inter(
                    color: onSurfaceVariantColor,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatInfoCard() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _passengerInfo.seatNumber,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
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
                  'Seat ${_passengerInfo.seatNumber}',
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  widget.seat['type'] ?? 'Window Seat',
                  style: GoogleFonts.inter(
                    color: onSurfaceVariantColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.2.h),
                Text(
                  'Tap to book',
                  style: GoogleFonts.inter(
                    fontSize: 8.sp,
                    color: primaryColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_passengerInfo.finalPrice.toStringAsFixed(0)} XAF',
                style: GoogleFonts.inter(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 0.2.h),
              Text(
                'Total Price',
                style: GoogleFonts.inter(
                  color: onSurfaceVariantColor,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passenger Details',
          style: GoogleFonts.inter(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Action buttons row
              Row(
                children: [
                  // Use My Info button
                  Expanded(
                    child: GestureDetector(
                      onTap: _useMyInfo,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.5.h, horizontal: 2.w),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              color: primaryColor,
                              size: 4.w,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Use My Info',
                              style: GoogleFonts.inter(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Passenger type selection
              _buildPassengerTypeSelector(),

              SizedBox(height: 2.h),

              // Name input
              _buildNameInput(),

              SizedBox(height: 1.5.h),

              // ID Card Number input (only show for adults)
              if (_passengerInfo.type == PassengerType.adult)
                _buildIdCardInput(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton(
            PassengerType.adult,
            'Adult',
            primaryColor,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildTypeButton(
            PassengerType.child,
            'Child',
            const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton(
    PassengerType type,
    String label,
    Color color,
  ) {
    final isSelected = _passengerInfo.type == type;
    return GestureDetector(
      onTap: () => _updatePassengerType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 10.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return TextField(
      onChanged: _updatePassengerName,
      decoration: InputDecoration(
        labelText: 'Passenger Name',
        hintText: 'Enter first and last name',
        helperText: 'Please enter both first and last name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          color: onSurfaceVariantColor,
          fontSize: 10.sp,
        ),
        hintStyle: GoogleFonts.inter(
          color: onSurfaceVariantColor.withOpacity(0.7),
          fontSize: 10.sp,
        ),
        helperStyle: GoogleFonts.inter(
          color: onSurfaceVariantColor.withOpacity(0.7),
          fontSize: 9.sp,
        ),
      ),
      style: GoogleFonts.inter(
        color: textColor,
        fontSize: 10.sp,
      ),
    );
  }

  Widget _buildIdCardInput() {
    return TextField(
      onChanged: _updatePassengerIdCard,
      decoration: InputDecoration(
        labelText: 'ID Card Number',
        hintText: 'Enter ID card number',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          color: onSurfaceVariantColor,
          fontSize: 10.sp,
        ),
        hintStyle: GoogleFonts.inter(
          color: onSurfaceVariantColor.withOpacity(0.7),
          fontSize: 10.sp,
        ),
      ),
      style: GoogleFonts.inter(
        color: textColor,
        fontSize: 10.sp,
      ),
    );
  }

  Widget _buildPricingBreakdownCard() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seat Price',
                style: GoogleFonts.inter(
                  color: onSurfaceVariantColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_passengerInfo.basePrice.toStringAsFixed(0)} XAF',
                style: GoogleFonts.inter(
                  color: onSurfaceVariantColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Container(
            height: 1,
            color: borderColor.withOpacity(0.2),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.inter(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
              AnimatedBuilder(
                animation: _priceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _priceAnimation.value,
                    child: Text(
                      '${totalPrice.toStringAsFixed(0)} XAF',
                      style: GoogleFonts.inter(
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final isValid = _isFormValid();
    final validationMessage = _getValidationMessage();

    return Column(
      children: [
        // Show validation message if form is invalid
        if (!isValid && validationMessage.isNotEmpty)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 2.h),
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    validationMessage,
                    style: GoogleFonts.inter(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Continue button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed: isValid ? _proceedToPayment : _showValidationError,
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid ? primaryColor : Colors.grey[400],
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: isValid
                  ? primaryColor.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isValid ? 'Continue to Payment' : 'Complete Required Fields',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  isValid ? Icons.arrow_forward : Icons.warning,
                  color: Colors.white,
                  size: 5.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
