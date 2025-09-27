import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/theme_notifier.dart';
import '../../../../services/auth_service.dart';

enum PassengerType { adult, child, senior }

class PassengerInfo {
  final int seatId;
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

class BookingSummaryWidget extends StatefulWidget {
  final List<Map<String, dynamic>> selectedSeats;
  final Map<String, dynamic> busInfo;
  final VoidCallback onContinue;
  final ScrollController? scrollController;

  const BookingSummaryWidget({
    Key? key,
    required this.selectedSeats,
    required this.busInfo,
    required this.onContinue,
    this.scrollController,
  }) : super(key: key);

  @override
  State<BookingSummaryWidget> createState() => _BookingSummaryWidgetState();
}

class _BookingSummaryWidgetState extends State<BookingSummaryWidget>
    with TickerProviderStateMixin {
  late AnimationController _priceAnimationController;
  late Animation<double> _priceAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  // Passenger information management
  Map<int, PassengerInfo> _passengerInfo = {};
  bool _hasUserInteracted = false;

  @override
  void initState() {
    super.initState();
    _initializePassengerInfo();

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

    // Pulse animation for swipe indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Arrow bounce animation
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _arrowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _arrowController,
        curve: Curves.elasticOut,
      ),
    );

    _priceAnimationController.forward();
    
    // Start pulse animation if user hasn't interacted
    if (!_hasUserInteracted) {
      _pulseController.repeat(reverse: true);
      _arrowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _priceAnimationController.dispose();
    _pulseController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  void _initializePassengerInfo() {
    for (var seat in widget.selectedSeats) {
      int seatId = seat['id'] as int;
      String seatNumber = seat['number'] as String;
      double basePrice = seat['price'] as double;

      _passengerInfo[seatId] = PassengerInfo(
        seatId: seatId,
        seatNumber: seatNumber,
        type: PassengerType.adult, // Default to adult
        name: '', // Empty name to be filled by user
        idCardNumber: '', // Empty ID card number to be filled by user
        basePrice: basePrice,
        finalPrice: basePrice,
      );
    }
  }

  double get totalPrice {
    return _passengerInfo.values.fold(0.0, (sum, passenger) {
      return sum + passenger.finalPrice;
    });
  }

  double get originalTotalPrice {
    return _passengerInfo.values.fold(0.0, (sum, passenger) {
      return sum + passenger.basePrice;
    });
  }

  double get totalSavings {
    return originalTotalPrice - totalPrice;
  }

  void _updatePassengerName(int seatId, String name) {
    setState(() {
      final passenger = _passengerInfo[seatId]!;
      _passengerInfo[seatId] = PassengerInfo(
        seatId: passenger.seatId,
        seatNumber: passenger.seatNumber,
        type: passenger.type,
        name: name,
        idCardNumber: passenger.idCardNumber,
        basePrice: passenger.basePrice,
        finalPrice: passenger.finalPrice,
      );
    });
  }

  void _updatePassengerIdCard(int seatId, String idCardNumber) {
    setState(() {
      final passenger = _passengerInfo[seatId]!;
      _passengerInfo[seatId] = PassengerInfo(
        seatId: passenger.seatId,
        seatNumber: passenger.seatNumber,
        type: passenger.type,
        name: passenger.name,
        idCardNumber: idCardNumber,
        basePrice: passenger.basePrice,
        finalPrice: passenger.finalPrice,
      );
    });
  }

  void _updatePassengerType(int seatId, PassengerType type) {
    setState(() {
      final passenger = _passengerInfo[seatId]!;
      _passengerInfo[seatId] = PassengerInfo(
        seatId: passenger.seatId,
        seatNumber: passenger.seatNumber,
        type: type,
        name: passenger.name,
        idCardNumber: passenger.idCardNumber,
        basePrice: passenger.basePrice,
        finalPrice: passenger.finalPrice,
      );
    });
  }

  Future<void> _useMyInfo(int seatId) async {
    try {
      // Get current user data
      final userResponse = await AuthService.getCachedUser();
      if (userResponse == null) {
        _showErrorMessage('User data not found. Please login again.');
        return;
      }

      final user = userResponse;

      // Auto-fill specific passenger information
      setState(() {
        final passenger = _passengerInfo[seatId]!;
        _passengerInfo[seatId] = PassengerInfo(
          seatId: passenger.seatId,
          seatNumber: passenger.seatNumber,
          type: passenger.type,
          name: user.fullName,
          idCardNumber: user.idCardNumber ?? '',
          basePrice: passenger.basePrice,
          finalPrice: passenger.finalPrice,
        );
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your information has been filled for Seat ${_passengerInfo[seatId]!.seatNumber}',
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

  Future<void> _lookupPassengerByPhone(int seatId) async {
    // Show phone number input dialog
    final phoneNumber = await _showPhoneInputDialog();
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    try {
      // Show loading indicator
      _showLoadingDialog('Looking up passenger information...');

      // Simulate API call to lookup passenger by phone number
      await Future.delayed(const Duration(seconds: 2));

      // Check if the passenger allows phone lookup (simulate API response)
      final passengerAllowsLookup = await _checkPassengerLookupPermission(
        phoneNumber,
      );

      if (!passengerAllowsLookup) {
        // Hide loading dialog
        Navigator.of(context).pop();

        // Show privacy message
        _showPrivacyMessage();
        return;
      }

      // Mock passenger data (in real app, this would come from API)
      final mockPassengerData = {
        'name': 'John Doe',
        'idCardNumber': '1234567890',
        'phone': phoneNumber,
        'email': 'john.doe@example.com',
      };

      // Hide loading dialog
      Navigator.of(context).pop();

      // Show passenger info confirmation dialog
      final confirmed = await _showPassengerInfoDialog(
        seatId,
        mockPassengerData,
      );

      if (confirmed) {
        // Auto-fill passenger information
        setState(() {
          final passenger = _passengerInfo[seatId]!;
          _passengerInfo[seatId] = PassengerInfo(
            seatId: passenger.seatId,
            seatNumber: passenger.seatNumber,
            type: passenger.type,
            name: mockPassengerData['name']!,
            idCardNumber: mockPassengerData['idCardNumber']!,
            basePrice: passenger.basePrice,
            finalPrice: passenger.finalPrice,
          );
        });

        _showSuccessMessage('Passenger information filled successfully');
      }
    } catch (e) {
      // Hide loading dialog if it's still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showErrorMessage('Failed to lookup passenger. Please try again.');
    }
  }

  Future<bool> _checkPassengerLookupPermission(String phoneNumber) async {
    // Simulate API call to check if passenger allows lookup
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock: 80% of users allow phone lookup
    return DateTime.now().millisecond % 10 < 8;
  }

  void _showPrivacyMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
        children: [
            Icon(Icons.privacy_tip, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text(
              'Privacy Protected',
              style: TextStyle(
                color: Colors.orange,
                      fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This passenger has disabled phone number lookup for privacy reasons.',
              style: TextStyle(
                fontSize: 14,
                color: ThemeNotifier().isDarkMode
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What you can do:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Ask the passenger to share their information directly\n• Have them book the ticket themselves\n• Contact them to enable phone lookup in their settings',
                    style: TextStyle(
                      fontSize: 11,
                      color: ThemeNotifier().isDarkMode
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
              ),
            ],
          ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text("Understood"),
          ),
        ],
      ),
    );
  }

  Future<String?> _showPhoneInputDialog() async {
    String phoneNumber = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Lookup Passenger',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
            color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the passenger\'s phone number to lookup their information:',
              style: GoogleFonts.inter(
                color: ThemeNotifier().isDarkMode
                    ? Colors.white70
                    : Colors.black54,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (value) => phoneNumber = value,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+237 6XX XXX XXX',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                labelStyle: GoogleFonts.inter(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                ),
                hintStyle: GoogleFonts.inter(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white54
                      : Colors.black38,
                ),
              ),
              style: GoogleFonts.inter(
                color: ThemeNotifier().isDarkMode
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(phoneNumber),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008B8B),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Lookup',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF008B8B),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
          ),
        ],
      ),
      ),
    );
  }

  Future<bool> _showPassengerInfoDialog(
    int seatId,
    Map<String, String> passengerData,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Found Passenger Information',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: ThemeNotifier().isDarkMode
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            content: Column(
        mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                Text(
                  'Is this the correct passenger information?',
                  style: GoogleFonts.inter(
                    color: ThemeNotifier().isDarkMode
                        ? Colors.white70
                        : Colors.black54,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
          Container(
                  padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                    color: ThemeNotifier().isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ThemeNotifier().isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                      _buildInfoRow('Name', passengerData['name']!),
                      SizedBox(height: 8),
                      _buildInfoRow('ID Card', passengerData['idCardNumber']!),
                      SizedBox(height: 8),
                      _buildInfoRow('Phone', passengerData['phone']!),
                      SizedBox(height: 8),
                      _buildInfoRow('Email', passengerData['email']!),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Use This Info',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: GoogleFonts.inter(
              color: ThemeNotifier().isDarkMode
                  ? Colors.white70
                  : Colors.black54,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
    return _passengerInfo.values.every((passenger) {
      // Name is always required and must have at least two words (first and last name)
      if (passenger.name.isEmpty) return false;

      // Check if name has at least two words (first and last name)
      final nameWords = passenger.name
          .trim()
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .toList();
      if (nameWords.length < 2) return false;

      // ID card number is only required for adults
      if (passenger.type == PassengerType.adult &&
          passenger.idCardNumber.isEmpty) {
        return false;
      }

      return true;
    });
  }

  String _getValidationMessage() {
    for (var passenger in _passengerInfo.values) {
      if (passenger.name.isEmpty) {
        return 'Please enter passenger name for Seat ${passenger.seatNumber}';
      }

      final nameWords = passenger.name
          .trim()
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .toList();
      if (nameWords.length < 2) {
        return 'Please enter both first and last name for Seat ${passenger.seatNumber}';
      }

      if (passenger.type == PassengerType.adult &&
          passenger.idCardNumber.isEmpty) {
        return 'Please enter ID card number for Seat ${passenger.seatNumber}';
      }
    }
    return '';
  }

  void _onUserInteraction() {
    if (!_hasUserInteracted) {
      setState(() {
        _hasUserInteracted = true;
      });
      _pulseController.stop();
      _arrowController.stop();
    }
  }

  void _resetAnimations() {
    if (_hasUserInteracted) {
      setState(() {
        _hasUserInteracted = false;
      });
      _pulseController.repeat(reverse: true);
      _arrowController.repeat(reverse: true);
    }
  }

  Widget _buildMinimizedView() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: widget.selectedSeats.isEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_seat,
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white.withOpacity(0.5)
                      : Colors.grey[400],
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                    Text(
                  'Select seats to continue',
                  style: GoogleFonts.inter(
                    color: ThemeNotifier().isDarkMode
                        ? Colors.white.withOpacity(0.5)
                        : Colors.grey[400],
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF008B8B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                      child: Text(
                        '${widget.selectedSeats.length} seat${widget.selectedSeats.length > 1 ? 's' : ''}',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF008B8B),
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '${totalPrice.toStringAsFixed(0)} XAF',
                      style: GoogleFonts.inter(
                        color: ThemeNotifier().isDarkMode
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Swipe indicator with pulsing animation
                    if (!_hasUserInteracted) _buildSwipeIndicator(),
                    SizedBox(width: 2.w),
                    ElevatedButton(
                      onPressed: () {
                        _onUserInteraction();
                        widget.onContinue();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008B8B),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.5.h,
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSwipeIndicator() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _arrowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
              color: const Color(0xFF008B8B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                color: const Color(0xFF008B8B).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
              mainAxisSize: MainAxisSize.min,
                    children: [
                Transform.translate(
                  offset: Offset(_arrowAnimation.value * 3, 0),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    color: const Color(0xFF008B8B),
                    size: 4.w,
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  'Swipe up',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF008B8B),
                    fontWeight: FontWeight.w500,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Information
          _buildTripInfo(),
          SizedBox(height: 24),

          // Passenger Details Section
          _buildPassengerDetailsSection(),
          SizedBox(height: 24),

          // Pricing Breakdown
          _buildPricingBreakdown(),
          SizedBox(height: 24),

          // Continue Button
          _buildContinueButton(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTripInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeNotifier().isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.grey[50],
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
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF008B8B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.directions_bus,
              color: const Color(0xFF008B8B),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.busInfo['name'] as String,
                  style: GoogleFonts.inter(
                    color: ThemeNotifier().isDarkMode
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                            Text(
                              '${widget.busInfo['from']} → ${widget.busInfo['to']}',
                  style: GoogleFonts.inter(
                    color: ThemeNotifier().isDarkMode
                        ? Colors.white70
                        : Colors.black54,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                            Text(
                  '${widget.busInfo['date']} • ${widget.busInfo['time']}',
                  style: GoogleFonts.inter(
                    color: ThemeNotifier().isDarkMode
                        ? Colors.white70
                        : Colors.black54,
                    fontSize: 12,
                              ),
                            ),
                          ],
                        ),
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
            color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 16),
        ..._passengerInfo.values.map(
          (passenger) => _buildPassengerCard(passenger),
        ),
      ],
    );
  }

  Widget _buildPassengerCard(PassengerInfo passenger) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Seat number and price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF008B8B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        passenger.seatNumber,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                Text(
                    'Seat ${passenger.seatNumber}',
                    style: GoogleFonts.inter(
                      color: ThemeNotifier().isDarkMode
                          ? Colors.white
                          : Colors.black87,
                    fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                '${passenger.finalPrice.toStringAsFixed(0)} XAF',
                style: GoogleFonts.inter(
                  color: const Color(0xFF008B8B),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Action buttons row
          Row(
            children: [
              // Use My Info button
              Expanded(
                child: GestureDetector(
                  onTap: () => _useMyInfo(passenger.seatId),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFF008B8B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF008B8B).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          color: const Color(0xFF008B8B),
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'My Info',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF008B8B),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Lookup by Phone button
              Expanded(
                child: GestureDetector(
                  onTap: () => _lookupPassengerByPhone(passenger.seatId),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          color: const Color(0xFF4CAF50),
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Lookup',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Passenger type selection
          _buildPassengerTypeSelector(passenger),

          SizedBox(height: 16),

          // Name input
          _buildNameInput(passenger),

          SizedBox(height: 12),

          // ID Card Number input (only show for adults)
          if (passenger.type == PassengerType.adult)
            _buildIdCardInput(passenger),
        ],
      ),
    );
  }

  Widget _buildPassengerTypeSelector(PassengerInfo passenger) {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton(
            passenger,
            PassengerType.adult,
            'Adult',
            const Color(0xFF008B8B),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildTypeButton(
            passenger,
            PassengerType.child,
            'Child',
            const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton(
    PassengerInfo passenger,
    PassengerType type,
    String label,
    Color color,
  ) {
    final isSelected = passenger.type == type;
    return GestureDetector(
      onTap: () => _updatePassengerType(passenger.seatId, type),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNameInput(PassengerInfo passenger) {
    return TextField(
      onChanged: (value) => _updatePassengerName(passenger.seatId, value),
      decoration: InputDecoration(
        labelText: 'Passenger Name',
        hintText: 'Enter first and last name',
        helperText: 'Please enter both first and last name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: ThemeNotifier().isDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: ThemeNotifier().isDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: const Color(0xFF008B8B), width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          color: ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54,
        ),
        hintStyle: GoogleFonts.inter(
          color: ThemeNotifier().isDarkMode ? Colors.white54 : Colors.black38,
        ),
        helperStyle: GoogleFonts.inter(
          color: ThemeNotifier().isDarkMode ? Colors.white60 : Colors.black45,
          fontSize: 11,
        ),
      ),
      style: GoogleFonts.inter(
        color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildIdCardInput(PassengerInfo passenger) {
    return TextField(
      onChanged: (value) => _updatePassengerIdCard(passenger.seatId, value),
      decoration: InputDecoration(
        labelText: 'ID Card Number',
        hintText: 'Enter ID card number',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: ThemeNotifier().isDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: ThemeNotifier().isDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: const Color(0xFF008B8B), width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          color: ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54,
        ),
        hintStyle: GoogleFonts.inter(
          color: ThemeNotifier().isDarkMode ? Colors.white54 : Colors.black38,
        ),
      ),
      style: GoogleFonts.inter(
        color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildPricingBreakdown() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeNotifier().isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeNotifier().isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Original Price',
                style: GoogleFonts.inter(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                  fontSize: 14,
                ),
              ),
              Text(
                '${originalTotalPrice.toStringAsFixed(0)} XAF',
                style: GoogleFonts.inter(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (totalSavings > 0) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Savings',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF4CAF50),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '-${totalSavings.toStringAsFixed(0)} XAF',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF4CAF50),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 12),
          Container(
            height: 1,
            color: ThemeNotifier().isDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.withOpacity(0.3),
          ),
          SizedBox(height: 12),
          Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                style: GoogleFonts.inter(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white
                      : Colors.black87,
                              fontWeight: FontWeight.w600,
                  fontSize: 18,
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
                        color: const Color(0xFF008B8B),
                              fontWeight: FontWeight.w700,
                        fontSize: 20,
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
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
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
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    validationMessage,
                    style: GoogleFonts.inter(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Continue button
                SizedBox(
                  width: double.infinity,
          height: 56,
                  child: ElevatedButton(
            onPressed: isValid ? widget.onContinue : _showValidationError,
                    style: ElevatedButton.styleFrom(
              backgroundColor: isValid
                  ? const Color(0xFF008B8B)
                  : Colors.grey[400],
              foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                  isValid ? 'Continue to Payment' : 'Complete Required Fields',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                            fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  isValid ? Icons.arrow_forward : Icons.warning,
                  color: Colors.white,
                  size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
      ],
    );
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
    return GestureDetector(
      onTap: _onUserInteraction,
      onPanStart: (_) => _onUserInteraction(),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeNotifier().isDarkMode
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: ThemeNotifier().isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            GestureDetector(
              onTap: _onUserInteraction,
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white.withOpacity(0.3)
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                children: [
                  // Minimized view (always visible)
                  _buildMinimizedView(),

                  // Expanded content (only show if seats are selected)
                  if (widget.selectedSeats.isNotEmpty) _buildExpandedContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
