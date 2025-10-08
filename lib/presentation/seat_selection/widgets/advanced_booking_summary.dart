import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/theme_notifier.dart';

enum PassengerType { adult, child, senior, student, military }

class PassengerInfo {
  final int seatId;
  final String seatNumber;
  final PassengerType type;
  final String name;
  final String email;
  final String phone;
  final double basePrice;
  final double finalPrice;
  final Map<String, dynamic> preferences;

  PassengerInfo({
    required this.seatId,
    required this.seatNumber,
    required this.type,
    required this.name,
    this.email = '',
    this.phone = '',
    required this.basePrice,
    required this.finalPrice,
    this.preferences = const {},
  });

  PassengerInfo copyWith({
    int? seatId,
    String? seatNumber,
    PassengerType? type,
    String? name,
    String? email,
    String? phone,
    double? basePrice,
    double? finalPrice,
    Map<String, dynamic>? preferences,
  }) {
    return PassengerInfo(
      seatId: seatId ?? this.seatId,
      seatNumber: seatNumber ?? this.seatNumber,
      type: type ?? this.type,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      basePrice: basePrice ?? this.basePrice,
      finalPrice: finalPrice ?? this.finalPrice,
      preferences: preferences ?? this.preferences,
    );
  }
}

class AdvancedBookingSummary extends StatefulWidget {
  final List<Map<String, dynamic>> selectedSeats;
  final Map<String, dynamic> busInfo;
  final VoidCallback onContinue;
  final ScrollController? scrollController;
  final Function(List<PassengerInfo>)? onPassengerDataChanged;

  const AdvancedBookingSummary({
    Key? key,
    required this.selectedSeats,
    required this.busInfo,
    required this.onContinue,
    this.scrollController,
    this.onPassengerDataChanged,
  }) : super(key: key);

  @override
  State<AdvancedBookingSummary> createState() => _AdvancedBookingSummaryState();
}

class _AdvancedBookingSummaryState extends State<AdvancedBookingSummary>
    with TickerProviderStateMixin {
  late AnimationController _priceAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _priceAnimation;
  late Animation<Offset> _slideAnimation;

  Map<int, PassengerInfo> _passengerInfo = {};
  bool _isExpanded = false;
  int _currentStep = 0; // 0: Selection, 1: Details, 2: Payment

  // 2025 UX: Advanced pricing with dynamic calculations
  static const Map<PassengerType, double> _priceMultipliers = {
    PassengerType.adult: 1.0,
    PassengerType.child: 0.65,    // 35% discount
    PassengerType.senior: 0.75,   // 25% discount
    PassengerType.student: 0.85,  // 15% discount
    PassengerType.military: 0.8,  // 20% discount
  };

  // 2025 UX: AI-powered seat recommendations based on passenger type
  static const Map<PassengerType, List<String>> _seatRecommendations = {
    PassengerType.adult: ['Window', 'Aisle', 'Extra legroom'],
    PassengerType.child: ['Window', 'Near parent'],
    PassengerType.senior: ['Aisle', 'Front section', 'Extra legroom'],
    PassengerType.student: ['Any available'],
    PassengerType.military: ['Priority boarding', 'Extra legroom'],
  };

  @override
  void initState() {
    super.initState();
    _initializePassengerInfo();
    _setupAnimations();
  }

  @override
  void dispose() {
    _priceAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _priceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _priceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _priceAnimationController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));

    _priceAnimationController.forward();
    _slideAnimationController.forward();
  }

  void _initializePassengerInfo() {
    for (var seat in widget.selectedSeats) {
      int seatId = seat['id'] as int;
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
  }

  // 2025 UX: Real-time price calculation with dynamic updates
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

  double get totalSavings => originalTotalPrice - totalPrice;

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

    // 2025 UX: Haptic feedback for user actions
    HapticFeedback.selectionClick();

    widget.onPassengerDataChanged?.call(_passengerInfo.values.toList());
  }

  void _updatePassengerInfo(int seatId, {String? name, String? email, String? phone}) {
    setState(() {
      final passenger = _passengerInfo[seatId]!;
      _passengerInfo[seatId] = passenger.copyWith(
        name: name ?? passenger.name,
        email: email ?? passenger.email,
        phone: phone ?? passenger.phone,
      );
    });

    widget.onPassengerDataChanged?.call(_passengerInfo.values.toList());
  }

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
        return const Color(0xFF008B8B);
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

  Widget _buildMinimizedView() {
    return GestureDetector(
      onTap: () {
        // Add visual feedback when tapping to expand
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          children: [
            // Expand indicator
            if (widget.selectedSeats.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 1.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: ThemeNotifier().isDarkMode
                          ? Colors.white.withOpacity(0.5)
                          : Colors.grey[600],
                      size: 5.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Swipe up for passenger details',
                      style: GoogleFonts.inter(
                        color: ThemeNotifier().isDarkMode
                            ? Colors.white.withOpacity(0.5)
                            : Colors.grey[600],
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            widget.selectedSeats.isEmpty
                ? _buildEmptyState()
                : _buildMinimizedContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: const Color(0xFF008B8B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.event_seat_outlined,
            color: const Color(0xFF008B8B),
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
                  color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
              Text(
                'Tap seats on the map to get started',
                style: GoogleFonts.inter(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black54,
                  fontSize: 9.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMinimizedContent() {
    return Row(
      children: [
        // 2025 UX: Visual seat indicator with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF008B8B).withOpacity(0.2),
                const Color(0xFF008B8B).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF008B8B).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.airline_seat_recline_normal,
                color: const Color(0xFF008B8B),
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                '${widget.selectedSeats.length} seat${widget.selectedSeats.length > 1 ? 's' : ''}',
                style: GoogleFonts.inter(
                  color: const Color(0xFF008B8B),
                  fontWeight: FontWeight.w600,
                  fontSize: 9.sp,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 3.w),

        // Passenger count indicator
        if (_passengerInfo.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_getPassengerTypeBreakdown()}',
              style: GoogleFonts.inter(
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
                fontSize: 8.sp,
              ),
            ),
          ),
          SizedBox(width: 3.w),
        ],

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2025 UX: Real-time pricing with savings highlight
              AnimatedBuilder(
                animation: _priceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.95 + (0.05 * _priceAnimation.value),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (totalSavings > 0) ...[
                          Text(
                            '${originalTotalPrice.toStringAsFixed(0)} XAF',
                            style: GoogleFonts.inter(
                              color: Colors.grey[500],
                              fontSize: 10.sp,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            'Save ${totalSavings.toStringAsFixed(0)} XAF',
                            style: GoogleFonts.inter(
                              color: Colors.green[600],
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        Text(
                          '${totalPrice.toStringAsFixed(0)} XAF',
                          style: GoogleFonts.inter(
                            color: ThemeNotifier().isDarkMode
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        SizedBox(width: 3.w),

        // 2025 UX: Modern CTA button with loading states
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: ElevatedButton(
            onPressed: widget.selectedSeats.isNotEmpty ? widget.onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008B8B),
              foregroundColor: Colors.white,
              elevation: widget.selectedSeats.isNotEmpty ? 4 : 0,
              shadowColor: const Color(0xFF008B8B).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Continue',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  ),
                ),
                SizedBox(width: 1.w),
                Icon(Icons.arrow_forward, size: 4.w),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getPassengerTypeBreakdown() {
    Map<PassengerType, int> breakdown = {};
    for (var passenger in _passengerInfo.values) {
      breakdown[passenger.type] = (breakdown[passenger.type] ?? 0) + 1;
    }

    List<String> parts = [];
    breakdown.forEach((type, count) {
      String label = type == PassengerType.adult ? 'Adults' :
                    type == PassengerType.child ? 'Children' :
                    type == PassengerType.senior ? 'Seniors' :
                    type == PassengerType.student ? 'Students' : 'Military';
      parts.add('$count ${label.toLowerCase()}');
    });

    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return widget.selectedSeats.isEmpty
        ? _buildMinimizedView()
        : SingleChildScrollView(
            controller: widget.scrollController,
            child: Column(
              children: [
                _buildMinimizedView(),
                if (widget.selectedSeats.isNotEmpty)
                  _buildExpandedContent(),
              ],
            ),
          );
  }

  Widget _buildExpandedContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTripSummaryCard(),
            SizedBox(height: 3.h),
            _buildPassengerDetailsSection(),
            SizedBox(height: 3.h),
            _buildPricingBreakdownCard(),
            SizedBox(height: 3.h),
            _buildAdvancedContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSummaryCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF008B8B).withOpacity(0.05),
            const Color(0xFF008B8B).withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF008B8B).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF008B8B).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with route info
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF008B8B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_bus_filled,
                  color: const Color(0xFF008B8B),
                  size: 6.w,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.busInfo['name'] as String,
                      style: GoogleFonts.inter(
                        color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        _buildLocationChip(widget.busInfo['from'] as String, true),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Icon(
                            Icons.arrow_forward,
                            color: const Color(0xFF008B8B),
                            size: 4.w,
                          ),
                        ),
                        _buildLocationChip(widget.busInfo['to'] as String, false),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.eco, color: Colors.green[600], size: 4.w),
                    Text(
                      'Eco-Friendly',
                      style: GoogleFonts.inter(
                        color: Colors.green[600],
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Trip details with modern info cards
          Row(
            children: [
              Expanded(child: _buildInfoCard('Date', widget.busInfo['date'] as String, Icons.calendar_today)),
              SizedBox(width: 2.w),
              Expanded(child: _buildInfoCard('Time', widget.busInfo['time'] as String, Icons.access_time)),
              SizedBox(width: 2.w),
              Expanded(child: _buildInfoCard('Duration', widget.busInfo['duration'] as String, Icons.schedule)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChip(String location, bool isOrigin) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: isOrigin
            ? const Color(0xFF008B8B).withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOrigin
              ? const Color(0xFF008B8B).withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Text(
        location,
        style: GoogleFonts.inter(
          color: isOrigin ? const Color(0xFF008B8B) : Colors.orange[700],
          fontWeight: FontWeight.w600,
          fontSize: 11.sp,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: ThemeNotifier().isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeNotifier().isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF008B8B),
            size: 4.w,
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: GoogleFonts.inter(
              color: ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
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
        // Section header with 2025 UX: Progress indicator
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: const Color(0xFF008B8B).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.people,
                color: const Color(0xFF008B8B),
                size: 5.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Passenger Details',
                    style: GoogleFonts.inter(
                      color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                  Text(
                    'Personalize your journey for each traveler',
                    style: GoogleFonts.inter(
                      color: ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            // 2025 UX: Smart auto-fill button
            ElevatedButton.icon(
              onPressed: _autoFillPassengerData,
              icon: Icon(Icons.auto_awesome, size: 4.w),
              label: Text(
                'Smart Fill',
                style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008B8B).withOpacity(0.1),
                foregroundColor: const Color(0xFF008B8B),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Passenger cards with 2025 UX enhancements
        ..._passengerInfo.values.map((passenger) => _buildAdvancedPassengerCard(passenger)),
      ],
    );
  }

  Widget _buildAdvancedPassengerCard(PassengerInfo passenger) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: ThemeNotifier().isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getPassengerTypeColor(passenger.type).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getPassengerTypeColor(passenger.type).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with seat info and type
          Row(
            children: [
              // 2025 UX: Animated seat visualization
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getPassengerTypeColor(passenger.type),
                      _getPassengerTypeColor(passenger.type).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _getPassengerTypeColor(passenger.type).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.airline_seat_recline_normal,
                      color: Colors.white,
                      size: 4.w,
                    ),
                    Text(
                      passenger.seatNumber,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 3.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seat ${passenger.seatNumber}',
                      style: GoogleFonts.inter(
                        color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    Text(
                      _getPassengerTypeLabel(passenger.type),
                      style: GoogleFonts.inter(
                        color: _getPassengerTypeColor(passenger.type),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Price with discount indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (passenger.finalPrice < passenger.basePrice) ...[
                    Text(
                      '${passenger.basePrice.toStringAsFixed(0)} XAF',
                      style: GoogleFonts.inter(
                        color: Colors.grey[500],
                        fontSize: 11.sp,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${(((passenger.basePrice - passenger.finalPrice) / passenger.basePrice) * 100).round()}%',
                        style: GoogleFonts.inter(
                          color: Colors.green[700],
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    '${passenger.finalPrice.toStringAsFixed(0)} XAF',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF008B8B),
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // 2025 UX: Enhanced passenger type selector with animations
          _buildModernPassengerTypeSelector(passenger),

          SizedBox(height: 2.h),

          // 2025 UX: Smart form fields with validation
          _buildSmartPassengerForm(passenger),
        ],
      ),
    );
  }

  Widget _buildModernPassengerTypeSelector(PassengerInfo passenger) {
    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: ThemeNotifier().isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: PassengerType.values.map((type) {
          final isSelected = passenger.type == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => _updatePassengerType(passenger.seatId, type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 1.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _getPassengerTypeColor(type)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: _getPassengerTypeColor(type).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : [],
                ),
                child: Column(
                  children: [
                    Icon(
                      _getPassengerTypeIcon(type),
                      color: isSelected ? Colors.white : _getPassengerTypeColor(type),
                      size: 5.w,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      type.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: isSelected ? Colors.white : _getPassengerTypeColor(type),
                        fontWeight: FontWeight.w600,
                        fontSize: 9.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSmartPassengerForm(PassengerInfo passenger) {
    return Column(
      children: [
        // Name field with smart suggestions
        _buildSmartTextField(
          label: 'Full Name *',
          hint: 'Enter passenger full name',
          icon: Icons.person_outline,
          onChanged: (value) => _updatePassengerInfo(passenger.seatId, name: value),
          validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
        ),

        SizedBox(height: 2.h),

        // Contact info in a row for space efficiency
        Row(
          children: [
            Expanded(
              child: _buildSmartTextField(
                label: 'Email',
                hint: 'passenger@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => _updatePassengerInfo(passenger.seatId, email: value),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildSmartTextField(
                label: 'Phone',
                hint: '+237 xxx xxx xxx',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                onChanged: (value) => _updatePassengerInfo(passenger.seatId, phone: value),
              ),
            ),
          ],
        ),

        if (passenger.type != PassengerType.adult) ...[
          SizedBox(height: 2.h),
          _buildSpecialRequirementsChip(passenger),
        ],
      ],
    );
  }

  Widget _buildSmartTextField({
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF008B8B).withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: GoogleFonts.inter(
              color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
              fontSize: 14.sp,
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: const Color(0xFF008B8B), size: 5.w),
              filled: true,
              fillColor: ThemeNotifier().isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFF008B8B),
                  width: 2,
                ),
              ),
              hintStyle: GoogleFonts.inter(
                color: ThemeNotifier().isDarkMode ? Colors.white54 : Colors.black38,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialRequirementsChip(PassengerInfo passenger) {
    List<String> requirements = _seatRecommendations[passenger.type] ?? [];

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _getPassengerTypeColor(passenger.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPassengerTypeColor(passenger.type).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: _getPassengerTypeColor(passenger.type),
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Recommended for ${_getPassengerTypeLabel(passenger.type)}',
                style: GoogleFonts.inter(
                  color: _getPassengerTypeColor(passenger.type),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 1.w,
            children: requirements.map((req) => Chip(
              label: Text(
                req,
                style: GoogleFonts.inter(fontSize: 10.sp),
              ),
              backgroundColor: _getPassengerTypeColor(passenger.type).withOpacity(0.1),
              side: BorderSide(color: _getPassengerTypeColor(passenger.type).withOpacity(0.3)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingBreakdownCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF008B8B).withOpacity(0.05),
            Colors.green.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF008B8B).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF008B8B).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF008B8B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: const Color(0xFF008B8B),
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Pricing Breakdown',
                  style: GoogleFonts.inter(
                    color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Passenger breakdown
          ..._passengerInfo.values.map((passenger) => Container(
            margin: EdgeInsets.only(bottom: 2.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: ThemeNotifier().isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
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
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
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
                        'Seat ${passenger.seatNumber} - ${_getPassengerTypeLabel(passenger.type)}',
                        style: GoogleFonts.inter(
                          color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                      if (passenger.finalPrice < passenger.basePrice)
                        Text(
                          'Discount applied: -${(((passenger.basePrice - passenger.finalPrice) / passenger.basePrice) * 100).round()}%',
                          style: GoogleFonts.inter(
                            color: Colors.green[600],
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (passenger.finalPrice < passenger.basePrice) ...[
                      Text(
                        '${passenger.basePrice.toStringAsFixed(0)} XAF',
                        style: GoogleFonts.inter(
                          color: Colors.grey[500],
                          fontSize: 10.sp,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    Text(
                      '${passenger.finalPrice.toStringAsFixed(0)} XAF',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF008B8B),
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),

          // Divider
          Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF008B8B).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Total with animation
          AnimatedBuilder(
            animation: _priceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.95 + (0.05 * _priceAnimation.value),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: GoogleFonts.inter(
                            color: ThemeNotifier().isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp,
                          ),
                        ),
                        if (totalSavings > 0)
                          Text(
                            'You save ${totalSavings.toStringAsFixed(0)} XAF!',
                            style: GoogleFonts.inter(
                              color: Colors.green[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                          ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF008B8B),
                            const Color(0xFF008B8B).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF008B8B).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${totalPrice.toStringAsFixed(0)} XAF',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedContinueButton() {
    bool canContinue = _passengerInfo.values.every((passenger) => passenger.name.isNotEmpty);

    return Container(
      width: double.infinity,
      height: 7.h,
      decoration: BoxDecoration(
        gradient: canContinue ? LinearGradient(
          colors: [
            const Color(0xFF008B8B),
            const Color(0xFF008B8B).withOpacity(0.8),
          ],
        ) : null,
        color: canContinue ? null : Colors.grey[400],
        borderRadius: BorderRadius.circular(20),
        boxShadow: canContinue ? [
          BoxShadow(
            color: const Color(0xFF008B8B).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: ElevatedButton(
        onPressed: canContinue ? widget.onContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment,
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Continue to Payment',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(width: 2.w),
            Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 4.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _autoFillPassengerData() {
    // 2025 UX: AI-powered auto-fill functionality
    HapticFeedback.mediumImpact();

    // This would integrate with user profile/previous bookings in a real app
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white),
            SizedBox(width: 2.w),
            Text('Smart fill will be available after first booking!'),
          ],
        ),
        backgroundColor: const Color(0xFF008B8B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}