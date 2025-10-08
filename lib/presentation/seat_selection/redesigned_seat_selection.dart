import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/theme_notifier.dart';
import './widgets/seat_legend_widget.dart';

enum PassengerType { adult, child, senior, student, military }

class PassengerInfo {
  final int seatId;
  final String seatNumber;
  final PassengerType type;
  final String name;
  final String idCard; // ID card number - main requirement
  final String phone; // For account lookup
  final double basePrice;
  final double finalPrice;
  final bool isForSelf; // Track if using own account
  final bool isFromOtherAccount; // Track if using another person's account
  final bool hasNoId; // Track if passenger doesn't have ID (kids, etc.)
  final int? age; // Age for age-based validation
  final String savedInfo; // Store previous input for switching back
  final bool isKid; // Track if this is a kid ticket (simplified flow)
  final bool isUsingMyInfo; // Track if user selected "Use My Info" (hide manual inputs)

  PassengerInfo({
    required this.seatId,
    required this.seatNumber,
    required this.type,
    required this.name,
    this.idCard = '',
    this.phone = '',
    required this.basePrice,
    required this.finalPrice,
    this.isForSelf = false,
    this.isFromOtherAccount = false,
    this.hasNoId = false,
    this.age,
    this.savedInfo = '',
    this.isKid = false,
    this.isUsingMyInfo = false,
  });

  PassengerInfo copyWith({
    int? seatId,
    String? seatNumber,
    PassengerType? type,
    String? name,
    String? idCard,
    String? phone,
    double? basePrice,
    double? finalPrice,
    bool? isForSelf,
    bool? isFromOtherAccount,
    bool? hasNoId,
    int? age,
    String? savedInfo,
    bool? isKid,
    bool? isUsingMyInfo,
  }) {
    return PassengerInfo(
      seatId: seatId ?? this.seatId,
      seatNumber: seatNumber ?? this.seatNumber,
      type: type ?? this.type,
      name: name ?? this.name,
      idCard: idCard ?? this.idCard,
      phone: phone ?? this.phone,
      basePrice: basePrice ?? this.basePrice,
      finalPrice: finalPrice ?? this.finalPrice,
      isForSelf: isForSelf ?? this.isForSelf,
      isFromOtherAccount: isFromOtherAccount ?? this.isFromOtherAccount,
      hasNoId: hasNoId ?? this.hasNoId,
      age: age ?? this.age,
      savedInfo: savedInfo ?? this.savedInfo,
      isKid: isKid ?? this.isKid,
      isUsingMyInfo: isUsingMyInfo ?? this.isUsingMyInfo,
    );
  }

  // Helper method to check if ID is required
  bool get isIdRequired {
    if (hasNoId) return false; // User explicitly said no ID
    if (age != null && age! < 16) return false; // Kids under 16 don't need ID
    return true; // Adults need ID by default
  }

  // Helper method to check if info is complete
  bool get isComplete {
    final nameComplete = name.trim().split(' ').length >= 2; // At least two names
    if (!isIdRequired) return nameComplete; // Only name needed if no ID required
    return nameComplete && idCard.trim().isNotEmpty; // Name + ID for adults
  }
}

class RedesignedSeatSelection extends StatefulWidget {
  const RedesignedSeatSelection({Key? key}) : super(key: key);

  @override
  State<RedesignedSeatSelection> createState() =>
      _RedesignedSeatSelectionState();
}

class _RedesignedSeatSelectionState extends State<RedesignedSeatSelection>
    with TickerProviderStateMixin {
  // Theme-aware colors
  Color get backgroundColor => ThemeNotifier().isDarkMode
      ? const Color(0xFF121212)
      : const Color(0xFFF8F9FA);
  Color get primaryColor => const Color(0xFF008B8B);
  Color get surfaceColor =>
      ThemeNotifier().isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get textColor =>
      ThemeNotifier().isDarkMode ? Colors.white : Colors.black87;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _priceAnimationController;
  late AnimationController _hintAnimationController;
  late AnimationController _ripple1Controller;
  late AnimationController _ripple2Controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _priceAnimation;
  late Animation<double> _ripple1Animation;
  late Animation<double> _ripple2Animation;

  // State variables
  List<int> _selectedSeats = [];
  Map<int, PassengerInfo> _passengerInfo = {};
  DraggableScrollableController? _sheetController;
  bool _hasAutoExpanded = false; // Track if sheet has been auto-expanded
  bool _showScrollHint = false; // Show scroll-up hint indicator

  // Passenger selection state
  int? _selfAssignedSeatId; // Track which seat is assigned to "For Myself"
  Map<int, bool> _expandedPassengers = {}; // Track expanded passenger cards
  Map<int, TextEditingController> _usernameControllers = {}; // Controllers for username fields

  // Improved animations
  late AnimationController _cardSlideController;
  late AnimationController _headerTransformController;
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _headerTransformAnimation;

  // Mock bus data
  final Map<String, dynamic> _busInfo = {
    'id': 1,
    'name': 'Express Luxury Coach',
    'from': 'Douala',
    'to': 'Yaoundé',
    'date': 'July 28, 2025',
    'time': '09:30 AM',
    'duration': '4h 30m',
    'rating': 4.8,
  };

  // Mock seat data - 73 seats total
  late final List<Map<String, dynamic>> _seats;

  // Pricing multipliers for passenger types
  static const Map<PassengerType, double> _priceMultipliers = {
    PassengerType.adult: 1.0,
    PassengerType.child: 0.65,
    PassengerType.senior: 0.75,
    PassengerType.student: 0.85,
    PassengerType.military: 0.8,
  };

  @override
  void initState() {
    super.initState();
    _generateSeats();
    _setupAnimations();
    ThemeNotifier().addListener(_onThemeChanged);

    // Initialize DraggableScrollableController
    _sheetController = DraggableScrollableController();
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    _fadeController.dispose();
    _priceAnimationController.dispose();
    _cardSlideController.dispose();
    _headerTransformController.dispose();
    _ripple1Controller.dispose();
    _ripple2Controller.dispose();
    _sheetController?.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _priceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Improved card slide animation (Airbnb-style)
    _cardSlideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Sticky header transform animation
    _headerTransformController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Ripple controllers for pulsating effect
    _ripple1Controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _ripple2Controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Smooth price animation with elastic curve
    _priceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _priceAnimationController, curve: Curves.elasticOut),
    );

    // Card slide animation with easeInOut curve
    _cardSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardSlideController, curve: Curves.easeInOut),
    );

    // Header transform animation
    _headerTransformAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerTransformController, curve: Curves.easeInOut),
    );

    // Ripple animations - expanding circles
    _ripple1Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ripple1Controller, curve: Curves.easeOut),
    );

    _ripple2Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ripple2Controller, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  void _generateSeats() {
    _seats = [];
    int seatNumber = 1;

    // Add 2 wheelchair seats (1-2)
    for (int i = 0; i < 2; i++) {
      _seats.add({
        'id': seatNumber,
        'number': '$seatNumber',
        'status': 'available',
        'type': 'Wheelchair',
        'price': 6000.0,
      });
      seatNumber++;
    }

    // Generate 71 regular seats (3-73)
    int seatsGenerated = 0;
    int targetSeats = 71;

    while (seatsGenerated < targetSeats) {
      List<String> seatLetters = ['A', 'B', 'C', 'D', 'E'];

      for (int seatIndex = 0;
          seatIndex < seatLetters.length && seatsGenerated < targetSeats;
          seatIndex++) {
        String letter = seatLetters[seatIndex];
        int seatId = seatNumber;

        String type = '';
        double price = 5500.0;

        if (letter == 'A' || letter == 'E') {
          type = 'Window';
          price = 6500.0;
        } else if (letter == 'B' || letter == 'D') {
          type = 'Aisle';
          price = 5500.0;
        } else {
          type = 'Middle';
          price = 5000.0;
        }

        String status = 'available';
        if (seatId % 7 == 0) {
          status = 'occupied';
        } else if (seatId % 11 == 0) {
          status = 'premium';
          type = '$type Premium';
          price = 8000.0;
        }

        _seats.add({
          'id': seatId,
          'number': '$seatId',
          'status': status,
          'type': type,
          'price': price,
        });
        seatNumber++;
        seatsGenerated++;
      }
    }
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _handleSheetTap() {
    if (_sheetController == null) return;

    // Get current sheet size
    final currentSize = _sheetController!.size;

    if (currentSize < 0.5) {
      // If minimized, go to 75% (max position)
      _sheetController!.animateTo(0.75,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack);
    } else {
      // If at 75%, go back to minimized
      _sheetController!.animateTo(0.15,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack);
    }
  }

  void _onSeatTap(int seatId) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
        _passengerInfo.remove(seatId);
        // Reset auto-expand flag when all seats are deselected
        if (_selectedSeats.isEmpty) {
          _hasAutoExpanded = false;
        }
      } else {
        _selectedSeats.add(seatId);
        _initializePassengerInfo(seatId);
      }
    });
    _priceAnimationController.reset();
    _priceAnimationController.forward();

    // Show ripple hint when seats are selected, hide when no seats selected
    if (_selectedSeats.isNotEmpty && !_showScrollHint) {
      _showScrollHint = true; // Show the hint indicator
      HapticFeedback.lightImpact(); // Gentle feedback

      // Start ripple animations with delay for staggered effect
      _ripple1Controller.repeat();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (_showScrollHint && mounted) {
          _ripple2Controller.repeat();
        }
      });
    } else if (_selectedSeats.isEmpty && _showScrollHint) {
      _showScrollHint = false; // Hide when no seats selected
      _ripple1Controller.stop();
      _ripple2Controller.stop();
      _ripple1Controller.reset();
      _ripple2Controller.reset();
    }
  }

  void _initializePassengerInfo(int seatId) {
    final seat = _seats.firstWhere((s) => s['id'] == seatId);
    String seatNumber = seat['number'] as String;
    double basePrice = seat['price'] as double;

    _passengerInfo[seatId] = PassengerInfo(
      seatId: seatId,
      seatNumber: seatNumber,
      type: PassengerType.adult,
      name: '',
      basePrice: basePrice,
      finalPrice: basePrice,
    );
  }

  double get totalPrice {
    return _passengerInfo.values.fold(0.0, (sum, passenger) {
      return sum + passenger.finalPrice;
    });
  }

  // Validation: At least two names required
  bool get hasValidNames {
    int validNames = 0;
    for (var passenger in _passengerInfo.values) {
      if (passenger.name.trim().isNotEmpty &&
          passenger.name.trim().split(' ').length >= 2) {
        validNames++;
      }
    }
    return validNames >=
        _selectedSeats.length; // All passengers must have valid names
  }

  // Mock user registration data (would come from auth service)
  Map<String, String> get currentUserData => {
        'name': 'John Doe Smith', // Full name
        'phone': '+237123456789',
        'idCard': 'ID123456789',
      };

  List<Map<String, dynamic>> get _selectedSeatDetails {
    return _seats.where((seat) => _selectedSeats.contains(seat['id'])).toList();
  }

  // Removed duplicate totalPrice getter - using the one at line 332

  void _updatePassengerType(int seatId, PassengerType type) {
    setState(() {
      final passenger = _passengerInfo[seatId]!;
      final multiplier = _priceMultipliers[type]!;
      final newPrice = passenger.basePrice * multiplier;

      _passengerInfo[seatId] = passenger.copyWith(
        type: type,
        finalPrice: newPrice,
      );

      _priceAnimationController.reset();
      _priceAnimationController.forward();
    });
    HapticFeedback.selectionClick();
  }

  void _updatePassengerInfo(int seatId, {String? name, String? phone}) {
    setState(() {
      final passenger = _passengerInfo[seatId]!;
      _passengerInfo[seatId] = passenger.copyWith(
        name: name ?? passenger.name,
        phone: phone ?? passenger.phone,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Main content area - Seat map and header
            Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _buildSeatMapArea(),
                ),
              ],
            ),

            // Instagram-style magnetic draggable bottom sheet - HARD 75% LIMIT
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.15, // Start minimized
              minChildSize: 0.15, // Always visible minimized state
              maxChildSize: 0.75, // HARD LIMIT - Cannot go beyond 3/4 screen
              snap: true, // Magnetic snap behavior
              snapSizes: const [
                0.15,
                0.75
              ], // Only two positions: minimized and 3/4 screen
              snapAnimationDuration: const Duration(
                  milliseconds: 250), // Slightly slower for more control
              builder: (context, scrollController) {
                return _buildBottomSheet(scrollController);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 4.w,
        right: 4.w,
        top: MediaQuery.of(context).padding.top + 2.h,
        bottom: 2.h,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: primaryColor,
                size: 5.w,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Your Seats',
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),
                ),
                Text(
                  '${_busInfo['from']} → ${_busInfo['to']} • ${_busInfo['date']}',
                  style: GoogleFonts.inter(
                    color: textColor.withOpacity(0.7),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${_selectedSeats.length}/73',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatMapArea() {
    return Container(
      margin: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Compact legend
          Container(
            margin: EdgeInsets.only(bottom: 2.h),
            child: SeatLegendWidget(),
          ),

          // Seat map with proper scrolling
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
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
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    4.w, 4.w, 4.w, 20.h), // Bottom padding for sheet
                child: _buildSeatGrid(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatGrid() {
    List<Widget> rows = [];
    int currentSeatIndex = 2; // Start from seat 3 (skip wheelchair seats 1-2)

    // Add driver section first
    rows.add(_buildDriverSection());

    for (int rowIndex = 0; rowIndex < 16; rowIndex++) {
      bool isEntryRow = rowIndex == 3 || rowIndex == 11;

      if (isEntryRow) {
        rows.add(_buildEntryRow(currentSeatIndex));
        currentSeatIndex += 3; // Entry rows have 3 seats
      } else {
        rows.add(_buildRegularRow(currentSeatIndex));
        currentSeatIndex += 5; // Regular rows have 5 seats
      }
    }

    return Column(children: rows);
  }

  Widget _buildDriverSection() {
    return Container(
      height: 8.h,
      margin: EdgeInsets.only(bottom: 3.h),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.3),
                    primaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.drive_eta, color: primaryColor, size: 6.w),
                  SizedBox(width: 2.w),
                  Text(
                    'DRIVER',
                    style: GoogleFonts.inter(
                      color: primaryColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(child: _buildSeat(_seats[0])),
                SizedBox(width: 1.w),
                Expanded(child: _buildSeat(_seats[1])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularRow(int startIndex) {
    return Container(
      height: 8.h,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          // Left side - 3 seats
          Expanded(
            flex: 3,
            child: Row(
              children: List.generate(3, (seatIndex) {
                int globalIndex = startIndex + seatIndex;
                if (globalIndex >= _seats.length) {
                  return Expanded(child: SizedBox());
                }
                return Expanded(child: _buildSeat(_seats[globalIndex]));
              }),
            ),
          ),
          SizedBox(width: 3.w),
          // Aisle
          Container(
            width: 2.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: ThemeNotifier().isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(1.w),
            ),
          ),
          SizedBox(width: 3.w),
          // Right side - 2 seats
          Expanded(
            flex: 2,
            child: Row(
              children: List.generate(2, (seatIndex) {
                int globalIndex = startIndex + 3 + seatIndex;
                if (globalIndex >= _seats.length) {
                  return Expanded(child: SizedBox());
                }
                return Expanded(child: _buildSeat(_seats[globalIndex]));
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryRow(int startIndex) {
    return Container(
      height: 8.h,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          // Left side - 3 seats
          Expanded(
            flex: 3,
            child: Row(
              children: List.generate(3, (seatIndex) {
                int globalIndex = startIndex + seatIndex;
                if (globalIndex >= _seats.length) {
                  return Expanded(child: SizedBox());
                }
                return Expanded(child: _buildSeat(_seats[globalIndex]));
              }),
            ),
          ),
          SizedBox(width: 3.w),
          Container(
            width: 2.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: ThemeNotifier().isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(1.w),
            ),
          ),
          SizedBox(width: 3.w),
          // Entry door
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              decoration: BoxDecoration(
                color: ThemeNotifier().isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.door_front_door,
                      color: ThemeNotifier().isDarkMode
                          ? Colors.white70
                          : Colors.grey[600],
                      size: 5.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'ENTRY',
                      style: GoogleFonts.inter(
                        color: ThemeNotifier().isDarkMode
                            ? Colors.white70
                            : Colors.grey[600],
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeat(Map<String, dynamic> seat) {
    final seatId = seat['id'] as int;
    final seatNumber = seat['number'] as String;
    final status = seat['status'] as String;
    final isSelected = _selectedSeats.contains(seatId);
    final isAvailable = status == 'available' || status == 'premium';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      child: GestureDetector(
        onTap: isAvailable ? () => _onSeatTap(seatId) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _getSeatColor(status, isSelected),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : _getSeatColor(status, isSelected).withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _getSeatColor(status, isSelected).withOpacity(0.3),
                blurRadius: isSelected ? 8 : 4,
                spreadRadius: isSelected ? 1 : 0,
                offset: Offset(0, isSelected ? 3 : 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      seatNumber,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (status == 'premium')
                      Icon(Icons.star, color: Colors.white, size: 3.w),
                  ],
                ),
              ),
              if (status == 'occupied')
                Positioned(
                  top: 1.w,
                  right: 1.w,
                  child: Icon(Icons.block, color: Colors.white, size: 4.w),
                ),
              if (isSelected)
                Positioned(
                  top: 1.w,
                  right: 1.w,
                  child:
                      Icon(Icons.check_circle, color: Colors.white, size: 4.w),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeatColor(String status, bool isSelected) {
    if (isSelected) {
      return const Color(0xFF4CAF50); // Selected - Green
    }

    switch (status) {
      case 'available':
        return primaryColor; // Available - Teal
      case 'occupied':
        return const Color(0xFF757575); // Occupied - Grey
      case 'premium':
        return const Color(0xFFFF9800); // Premium - Orange
      default:
        return const Color(0xFF757575);
    }
  }

  // Google Maps-style 3-phase bottom sheet with sticky header and transforms
  Widget _buildBottomSheet(ScrollController scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          // Update header transform based on scroll
          if (notification is ScrollUpdateNotification) {
            final scrollOffset = scrollController.hasClients ? scrollController.offset : 0;
            final transformProgress = (scrollOffset / 100).clamp(0.0, 1.0);

            if (_headerTransformController.value != transformProgress) {
              _headerTransformController.animateTo(
                transformProgress,
                duration: const Duration(milliseconds: 50),
              );
            }
          }
          return false;
        },
        child: CustomScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Phase 1: Sticky header with transform animations
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: _BookingSummaryHeaderDelegate(
                minHeight: 60,
                maxHeight: 120,
                headerTransformAnimation: _headerTransformAnimation,
                selectedSeats: _selectedSeats,
                totalPrice: totalPrice,
                textColor: textColor,
                primaryColor: primaryColor,
                surfaceColor: surfaceColor,
              ),
            ),

            // Phase 2: Essential booking summary (Uber ActionCard approach)
            SliverToBoxAdapter(
              child: _selectedSeats.isEmpty
                  ? _buildEmptyActionCard()
                  : _buildDetailedBookingCard(),
            ),

            // Phase 3: Progressive disclosure content (only when expanded)
            if (_selectedSeats.isNotEmpty) ...[
              SliverToBoxAdapter(child: _buildPassengerActionCards()),
              SliverToBoxAdapter(child: _buildContinueActionCard()),
              SliverToBoxAdapter(child: SizedBox(height: 3.h)),
            ],
          ],
        ),
      ),
    );
  }

  // Detailed booking card for expanded state
  Widget _buildDetailedBookingCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip details
          Row(
            children: [
              Icon(Icons.directions_bus_rounded, color: primaryColor, size: 5.w),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Douala → Yaoundé • Today 14:30',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Seat summary
          Row(
            children: [
              Icon(Icons.event_seat_rounded, color: primaryColor, size: 4.w),
              SizedBox(width: 2.w),
              Text(
                '${_selectedSeats.length} seat${_selectedSeats.length > 1 ? 's' : ''} selected',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: textColor.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              Text(
                'Seats: ${_selectedSeats.join(', ')}',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.event_seat_outlined,
              color: primaryColor,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select your perfect seats',
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  'Tap seats on the map to get started',
                  style: GoogleFonts.inter(
                    color: textColor.withOpacity(0.7),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSummary() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeNotifier().isDarkMode
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Material Design 3 Professional scroll hint
          if (_showScrollHint)
            Container(
              height: 7.h,
              margin: EdgeInsets.only(bottom: 2.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ripple - refined animation
                  AnimatedBuilder(
                    animation: _ripple1Animation,
                    builder: (context, child) {
                      return Container(
                        width: 40 * _ripple1Animation.value,
                        height: 40 * _ripple1Animation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(
                                0.12 * (1 - _ripple1Animation.value)),
                            width: 1,
                          ),
                        ),
                      );
                    },
                  ),
                  // Inner ripple - refined animation
                  AnimatedBuilder(
                    animation: _ripple2Animation,
                    builder: (context, child) {
                      return Container(
                        width: 24 * _ripple2Animation.value,
                        height: 24 * _ripple2Animation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(
                                0.16 * (1 - _ripple2Animation.value)),
                            width: 1.2,
                          ),
                        ),
                      );
                    },
                  ),
                  // Center indicator - Material Design 3 style
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: primaryColor,
                      size: 4.w,
                    ),
                  ),
                  // Hint text - MD3 Body Small
                  Positioned(
                    bottom: 0.5.h,
                    child: Text(
                      'Swipe up for details',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp, // MD3 Body Small
                        height: 1.33, // 16px line height
                        fontWeight: FontWeight.w400,
                        color: textColor.withOpacity(0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Tech giant-inspired header section
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Trip type indicator - Uber/Airbnb style
              Container(
                width: 11.w,
                height: 11.w,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.directions_bus_rounded,
                  color: primaryColor,
                  size: 5.5.w,
                ),
              ),
              SizedBox(width: 3.w),

              // Trip info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route - MD3 Title Medium
                    Text(
                      'Douala → Yaoundé',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp, // MD3 Title Medium
                        height: 1.5, // 24px line height
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        letterSpacing: 0.15,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    // Date/time - MD3 Body Medium
                    Text(
                      'Today • Premium Bus',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp, // MD3 Body Medium
                        height: 1.43, // 20px line height
                        fontWeight: FontWeight.w400,
                        color: textColor.withOpacity(0.6),
                        letterSpacing: 0.25,
                      ),
                    ),
                  ],
                ),
              ),

              // Seat count badge - Material 3 style
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_seat_rounded,
                      color: primaryColor,
                      size: 3.5.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${_selectedSeats.length}',
                      style: GoogleFonts.inter(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp, // MD3 Body Small
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Price section with action - Material Design 3
          Row(
            children: [
              // Price info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price label - MD3 Body Medium
                    Text(
                      'Total Amount',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp, // MD3 Body Medium
                        height: 1.43,
                        fontWeight: FontWeight.w400,
                        color: textColor.withOpacity(0.6),
                        letterSpacing: 0.25,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    // Price value - MD3 Title Large
                    AnimatedBuilder(
                      animation: _priceAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.98 + (0.02 * _priceAnimation.value),
                          child: Text(
                            '${totalPrice.toStringAsFixed(0)} XAF',
                            style: GoogleFonts.inter(
                              fontSize: 20.sp, // MD3 Title Large
                              height: 1.27, // 28px line height
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                              letterSpacing: 0,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Quick action button - Material 3 filled button
              FilledButton.icon(
                onPressed: hasValidNames ? () => _onContinue() : null,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      hasValidNames ? primaryColor : Colors.grey[400],
                  foregroundColor: Colors.white,
                  elevation: hasValidNames ? 2 : 0,
                  shadowColor: primaryColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                ),
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  size: 4.w,
                ),
                label: Text(
                  'Continue',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Clean ActionCard for empty state when no seats selected
  Widget _buildEmptyActionCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.airline_seat_recline_normal,
            color: primaryColor.withOpacity(0.5),
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'Select seats to continue',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Clean ActionCard for booking summary (replaces verbose summary)
  Widget _buildBookingSummaryCard() {
    return _buildQuickSummary();
  }

  // Clean ActionCard for trip essentials (replaces redundant _buildTripDetails)
  Widget _buildTripActionCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Trip icon
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: primaryColor,
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          // Trip details - essential info only
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today 14:30 • 4h 30min',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    letterSpacing: 0.1,
                  ),
                ),
                Text(
                  'Premium Bus Service',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: textColor.withOpacity(0.6),
                    letterSpacing: 0.25,
                  ),
                ),
              ],
            ),
          ),
          // Status indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'On Time',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.green[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Clean ActionCard for passenger management (replaces verbose section)
  Widget _buildPassengerActionCards() {
    return Column(
      children: _passengerInfo.values
          .map((passenger) => _buildPassengerActionCard(passenger))
          .toList(),
    );
  }

  Widget _buildPassengerActionCard(PassengerInfo passenger) {
    bool hasValidName = passenger.name.trim().isNotEmpty &&
        passenger.name.trim().split(' ').length >= 2;
    bool isExpanded = _expandedPassengers[passenger.seatId] ?? false;
    bool canAssignSelf = _selfAssignedSeatId == null || _selfAssignedSeatId == passenger.seatId;

    return AnimatedBuilder(
      animation: _cardSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _cardSlideAnimation.value)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasValidName
                    ? Colors.green.withOpacity(0.3)
                    : primaryColor.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04 * _cardSlideAnimation.value),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Main row with seat and passenger info
                Row(
                  children: [
                    // Seat indicator
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: _getPassengerTypeColor(passenger.type),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          passenger.seatNumber,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    // Passenger info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasValidName ? passenger.name : 'Enter passenger details',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: hasValidName ? textColor : textColor.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (hasValidName)
                            Text(
                              passenger.isForSelf ? 'For Myself' : 'Another Person',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Action button
                    if (!hasValidName)
                      IconButton(
                        onPressed: () => _togglePassengerExpansion(passenger.seatId),
                        icon: AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.expand_more,
                            color: primaryColor,
                            size: 5.w,
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 5.w,
                      ),
                  ],
                ),

                // Expandable passenger selection and input form
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _buildPassengerForm(passenger, canAssignSelf),
                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                  firstCurve: Curves.easeIn,
                  secondCurve: Curves.easeOut,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Auto-fill methods with "For Myself" constraint
  void _fillForMyself(int seatId) {
    final userData = currentUserData;
    final currentPassenger = _passengerInfo[seatId]!;

    setState(() {
      // Save current info before switching (if it's from another account)
      String savedInfo = '';
      if (currentPassenger.isFromOtherAccount) {
        savedInfo = '${currentPassenger.name}|${currentPassenger.idCard}|${currentPassenger.phone}|${currentPassenger.hasNoId}';
      }

      // Remove "For Myself" from previous seat if assigned
      if (_selfAssignedSeatId != null && _selfAssignedSeatId != seatId) {
        final previousPassenger = _passengerInfo[_selfAssignedSeatId!]!;
        _passengerInfo[_selfAssignedSeatId!] = previousPassenger.copyWith(
          // Restore saved info if available, otherwise clear
          name: previousPassenger.savedInfo.isNotEmpty ? previousPassenger.savedInfo.split('|')[0] : '',
          idCard: previousPassenger.savedInfo.isNotEmpty ? previousPassenger.savedInfo.split('|')[1] : '',
          phone: previousPassenger.savedInfo.isNotEmpty ? previousPassenger.savedInfo.split('|')[2] : '',
          hasNoId: previousPassenger.savedInfo.isNotEmpty ? previousPassenger.savedInfo.split('|')[3] == 'true' : false,
          isForSelf: false,
          isFromOtherAccount: previousPassenger.savedInfo.isNotEmpty,
        );
      }

      // Assign to current seat
      _passengerInfo[seatId] = currentPassenger.copyWith(
        name: userData['name']!,
        idCard: userData['idCard']!,
        phone: userData['phone']!,
        isForSelf: true,
        isFromOtherAccount: false,
        hasNoId: false, // User account always has ID
        savedInfo: savedInfo, // Save previous info for potential restoration
      );

      // Track which seat has "For Myself"
      _selfAssignedSeatId = seatId;
    });

    // Trigger smooth animation
    _cardSlideController.reset();
    _cardSlideController.forward();
    HapticFeedback.selectionClick();
  }

  void _useAnotherAccount(int seatId) {
    final currentPassenger = _passengerInfo[seatId]!;

    setState(() {
      _expandedPassengers[seatId] = true;

      // If switching from "For Myself", restore saved info or clear
      if (currentPassenger.isForSelf) {
        if (currentPassenger.savedInfo.isNotEmpty) {
          // Restore previous info
          final parts = currentPassenger.savedInfo.split('|');
          _passengerInfo[seatId] = currentPassenger.copyWith(
            name: parts[0],
            idCard: parts[1],
            phone: parts[2],
            hasNoId: parts[3] == 'true',
            isForSelf: false,
            isFromOtherAccount: true,
          );
        } else {
          // Clear for new input
          _passengerInfo[seatId] = currentPassenger.copyWith(
            name: '',
            idCard: '',
            phone: '',
            hasNoId: false,
            isForSelf: false,
            isFromOtherAccount: true,
          );
        }

        // Clear "For Myself" tracking
        _selfAssignedSeatId = null;
      } else {
        // Just mark as from other account
        _passengerInfo[seatId] = currentPassenger.copyWith(
          isFromOtherAccount: true,
        );
      }
    });

    // Trigger smooth animation
    _cardSlideController.reset();
    _cardSlideController.forward();
    HapticFeedback.selectionClick();
  }

  // Toggle passenger card expansion
  void _togglePassengerExpansion(int seatId) {
    setState(() {
      _expandedPassengers[seatId] = !(_expandedPassengers[seatId] ?? false);
    });
    HapticFeedback.lightImpact();
  }

  // Update passenger info from input fields
  void _updatePassengerName(int seatId, String name) {
    setState(() {
      _passengerInfo[seatId] = _passengerInfo[seatId]!.copyWith(name: name);
    });
  }

  void _updatePassengerPhone(int seatId, String phone) {
    setState(() {
      _passengerInfo[seatId] = _passengerInfo[seatId]!.copyWith(phone: phone);
    });
  }

  void _updatePassengerIdCard(int seatId, String idCard) {
    setState(() {
      _passengerInfo[seatId] = _passengerInfo[seatId]!.copyWith(idCard: idCard);
    });
  }

  void _updatePassengerAge(int seatId, int? age) {
    setState(() {
      _passengerInfo[seatId] = _passengerInfo[seatId]!.copyWith(age: age);
    });
  }

  void _toggleNoId(int seatId, bool hasNoId) {
    setState(() {
      _passengerInfo[seatId] = _passengerInfo[seatId]!.copyWith(
        hasNoId: hasNoId,
        idCard: hasNoId ? '' : _passengerInfo[seatId]!.idCard, // Clear ID if no ID
      );
    });
  }

  void _toggleKidMode(int seatId, bool isKid) {
    setState(() {
      _passengerInfo[seatId] = _passengerInfo[seatId]!.copyWith(
        isKid: isKid,
        hasNoId: isKid, // Kids don't need ID by default
        idCard: isKid ? '' : _passengerInfo[seatId]!.idCard, // Clear ID for kids
      );
    });

    // Trigger smooth animation
    _cardSlideController.reset();
    _cardSlideController.forward();
    HapticFeedback.selectionClick();
  }

  // Mock user database for username lookup
  Map<String, Map<String, String>> _userDatabase = {
    'john_doe': {'name': 'John Doe Smith', 'idCard': 'ID123456789', 'phone': '+1234567890'},
    'jane_smith': {'name': 'Jane Alice Smith', 'idCard': 'ID987654321', 'phone': '+0987654321'},
    'alice_wonder': {'name': 'Alice Wonder Johnson', 'idCard': 'ID555666777', 'phone': '+1122334455'},
  };

  Future<void> _lookupUserByUsername(int seatId, String username) async {
    if (username.trim().isEmpty) return;

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    final userData = _userDatabase[username.toLowerCase()];
    if (userData != null) {
      setState(() {
        _passengerInfo[seatId] = _passengerInfo[seatId]!.copyWith(
          name: userData['name']!,
          idCard: userData['idCard']!,
          phone: userData['phone']!,
          hasNoId: false, // User account has ID
        );
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User found: ${userData['name']}'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.all(4.w),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Username "$username" not found'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.all(4.w),
        ),
      );
    }
  }

  // Use account holder's info for passengers without ID (kids, etc.)
  void _useMyInfoForPassenger(int seatId) {
    final userData = currentUserData;
    setState(() {
      _passengerInfo[seatId] = _passengerInfo[seatId]!.copyWith(
        name: userData['name']!,
        idCard: userData['idCard']!,
        phone: userData['phone']!,
        hasNoId: false, // Account holder has ID, will be used
        isFromOtherAccount: true, // Still marked as another person but using account holder's info
        isUsingMyInfo: true, // Hide manual input fields
      );
    });

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Using your account info for this passenger'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(4.w),
      ),
    );

    // Trigger smooth animation
    _cardSlideController.reset();
    _cardSlideController.forward();
    HapticFeedback.selectionClick();
  }

  // Switch back to manual input mode
  void _switchToManualInput(int seatId) {
    setState(() {
      _passengerInfo[seatId] = _passengerInfo[seatId]!.copyWith(
        isUsingMyInfo: false, // Show manual input fields again
        // Keep the filled data but allow editing
      );
    });

    // Trigger smooth animation
    _cardSlideController.reset();
    _cardSlideController.forward();
    HapticFeedback.selectionClick();
  }

  // Clean ActionCard for continue flow (replaces verbose button sections)
  Widget _buildContinueActionCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: FilledButton(
        onPressed: hasValidNames ? () => _onContinue() : null,
        style: FilledButton.styleFrom(
          backgroundColor: hasValidNames ? primaryColor : Colors.grey[400],
          foregroundColor: Colors.white,
          elevation: hasValidNames ? 2 : 0,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          minimumSize: Size(double.infinity, 6.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue to Payment',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                letterSpacing: 0.1,
              ),
            ),
            SizedBox(width: 2.w),
            Icon(
              Icons.arrow_forward_rounded,
              size: 4.w,
            ),
          ],
        ),
      ),
    );
  }

  // Expandable passenger form (replaces modal dialog)
  Widget _buildPassengerForm(PassengerInfo passenger, bool canAssignSelf) {
    return Container(
      margin: EdgeInsets.only(top: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick selection buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canAssignSelf ? () => _fillForMyself(passenger.seatId) : null,
                  icon: Icon(Icons.person, size: 4.w),
                  label: Text(
                    canAssignSelf ? 'For Myself' : 'Already Used',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                    side: BorderSide(
                      color: canAssignSelf ? primaryColor : Colors.grey,
                      width: 1,
                    ),
                    foregroundColor: canAssignSelf ? primaryColor : Colors.grey,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _useAnotherAccount(passenger.seatId),
                  icon: Icon(Icons.person_add, size: 4.w),
                  label: Text(
                    'Another Person',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                    side: BorderSide(color: primaryColor, width: 1),
                    foregroundColor: primaryColor,
                  ),
                ),
              ),
            ],
          ),

          // Step-by-step passenger details (simplified)
          ...passenger.isFromOtherAccount ? [
            SizedBox(height: 2.h),

            // Adult/Kid toggle slider
            Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _toggleKidMode(passenger.seatId, false),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        decoration: BoxDecoration(
                          color: !passenger.isKid ? primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Adult',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: !passenger.isKid ? Colors.white : textColor.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _toggleKidMode(passenger.seatId, true),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        decoration: BoxDecoration(
                          color: passenger.isKid ? primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Kid',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: passenger.isKid ? Colors.white : textColor.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Dynamic content based on mode
            if (passenger.isUsingMyInfo) ...[
              // Show summary when using "My Info"
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: primaryColor, size: 5.w),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Using Your Account Info',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _switchToManualInput(passenger.seatId),
                          icon: Icon(Icons.edit, color: primaryColor, size: 4.w),
                          tooltip: 'Edit details',
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Name: ${passenger.name}',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                    if (!passenger.isKid) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        'ID: ${passenger.idCard}',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              // Show input fields when in manual mode
              // Step 1: Name field with username lookup
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Builder(
                      builder: (context) {
                        _usernameControllers[passenger.seatId] ??= TextEditingController();
                        final controller = _usernameControllers[passenger.seatId]!;

                        return TextField(
                          controller: controller,
                          onChanged: (value) => _updatePassengerName(passenger.seatId, value),
                          decoration: InputDecoration(
                            hintText: passenger.isKid
                                ? 'Kid\'s Full Name'
                                : 'Full Name or Username',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: textColor.withOpacity(0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                            prefixIcon: Icon(
                              passenger.isKid ? Icons.child_care : Icons.person_outline,
                              color: primaryColor,
                              size: 4.w,
                            ),
                          ),
                          style: GoogleFonts.inter(fontSize: 12.sp),
                        );
                      },
                    ),
                  ),
                  if (!passenger.isKid) ...[
                    SizedBox(width: 2.w),
                    ElevatedButton(
                      onPressed: () {
                        final controller = _usernameControllers[passenger.seatId]!;
                        _lookupUserByUsername(passenger.seatId, controller.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Lookup',
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Step 2: Adult-specific fields (ID card + Use My Info)
              if (!passenger.isKid) ...[
                SizedBox(height: 1.5.h),

                TextField(
                  onChanged: (value) => _updatePassengerIdCard(passenger.seatId, value),
                  decoration: InputDecoration(
                    hintText: 'ID Card Number',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: textColor.withOpacity(0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    prefixIcon: Icon(Icons.credit_card_outlined, color: primaryColor, size: 4.w),
                  ),
                  style: GoogleFonts.inter(fontSize: 12.sp),
                ),

                SizedBox(height: 1.5.h),

                OutlinedButton.icon(
                  onPressed: () => _useMyInfoForPassenger(passenger.seatId),
                  icon: Icon(Icons.account_circle, size: 4.w),
                  label: Text(
                    'Use My Account Info',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
                    side: BorderSide(color: primaryColor, width: 1),
                    foregroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],

              // For kids: just show a simple note
              if (passenger.isKid) ...[
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green, size: 4.w),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Kids don\'t need ID. Your account info will be used.',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ] : [],
        ],
      ),
    );
  }

  // Removed redundant verbose passenger card methods - replaced with clean ActionCards above

  // Old form methods removed - using simplified passenger card UI above

  // Removed redundant _buildPricingBreakdown and _buildContinueButton - replaced with clean ActionCard approach

  // Helper methods for passenger types
  String _getPassengerTypeLabel(PassengerType type) {
    switch (type) {
      case PassengerType.adult:
        return 'Adult (18-64)';
      case PassengerType.child:
        return 'Child (2-17)';
      case PassengerType.senior:
        return 'Senior (65+)';
      case PassengerType.student:
        return 'Student';
      case PassengerType.military:
        return 'Military';
    }
  }

  Color _getPassengerTypeColor(PassengerType type) {
    switch (type) {
      case PassengerType.adult:
        return primaryColor;
      case PassengerType.child:
        return const Color(0xFF4CAF50);
      case PassengerType.senior:
        return const Color(0xFFFF9800);
      case PassengerType.student:
        return const Color(0xFF2196F3);
      case PassengerType.military:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getPassengerTypeIcon(PassengerType type) {
    switch (type) {
      case PassengerType.adult:
        return Icons.person;
      case PassengerType.child:
        return Icons.child_care;
      case PassengerType.senior:
        return Icons.elderly;
      case PassengerType.student:
        return Icons.school;
      case PassengerType.military:
        return Icons.security;
    }
  }

  void _onContinue() {
    if (_selectedSeats.isNotEmpty) {
      // Prepare booking data to pass to confirmation screen
      final bookingData = {
        'bookingId':
            'BF${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        'fromCity': 'Douala',
        'toCity': 'Yaoundé',
        'date': 'July 28, 2025',
        'departureTime': '09:30 AM',
        'arrivalTime': '01:45 PM',
        'selectedSeats': _selectedSeats.toList(),
        'totalPrice': '${totalPrice.toStringAsFixed(0)} XAF',
        'passengers': _selectedSeatDetails
            .map((seat) => {
                  'name': seat['name'] ?? 'Passenger',
                  'seatNumber': seat['seatNumber'] ?? seat['id'],
                  'type': seat['type'] ?? 'adult',
                })
            .toList(),
        'priceBreakdown': {
          'Base Fare (${_selectedSeats.length} seats)':
              '${totalPrice.toStringAsFixed(0)} XAF',
          'Service Fee': '0 XAF',
          'Taxes': '0 XAF',
        },
      };

      Navigator.pushNamed(
        context,
        '/payment-gateway',
        arguments: bookingData,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one seat to continue'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}

// Sticky header delegate for booking summary
class _BookingSummaryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Animation<double> headerTransformAnimation;
  final List<int> selectedSeats;
  final double totalPrice;
  final Color textColor;
  final Color primaryColor;
  final Color surfaceColor;

  _BookingSummaryHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.headerTransformAnimation,
    required this.selectedSeats,
    required this.totalPrice,
    required this.textColor,
    required this.primaryColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final shrinkPercentage = (shrinkOffset / (maxHeight - minHeight)).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: headerTransformAnimation,
      builder: (context, child) {
        return Container(
          height: maxHeight - shrinkOffset,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20 * (1 - shrinkPercentage)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1 * shrinkPercentage),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag indicator (fades out as header shrinks)
              if (shrinkPercentage < 0.8)
                Opacity(
                  opacity: 1 - (shrinkPercentage * 1.25),
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

              // Header content that transforms
              Expanded(
                child: Row(
                  children: [
                    // Icon that changes as header shrinks
                    Container(
                      width: 8.w + (4.w * (1 - shrinkPercentage)),
                      height: 8.w + (4.w * (1 - shrinkPercentage)),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8 + (4 * (1 - shrinkPercentage))),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: primaryColor,
                        size: 4.w + (2.w * (1 - shrinkPercentage)),
                      ),
                    ),
                    SizedBox(width: 3.w),

                    // Text content that adapts to available space
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: GoogleFonts.inter(
                              fontSize: (16 - (2 * shrinkPercentage)).sp,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            child: Text(
                              selectedSeats.isEmpty
                                  ? 'Select Your Seats'
                                  : 'Booking Summary',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (shrinkPercentage < 0.7 && selectedSeats.isNotEmpty)
                            AnimatedOpacity(
                              opacity: 1 - (shrinkPercentage * 1.5),
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                '${selectedSeats.length} seat${selectedSeats.length > 1 ? 's' : ''} selected',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: textColor.withOpacity(0.6),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Price that becomes prominent when header shrinks
                    if (selectedSeats.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h + (0.5.h * (1 - shrinkPercentage)),
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1 + (0.05 * shrinkPercentage)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.2 + (0.1 * shrinkPercentage)),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${totalPrice.toStringAsFixed(0)} XAF',
                          style: GoogleFonts.inter(
                            fontSize: (14 + (2 * shrinkPercentage)).sp,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
