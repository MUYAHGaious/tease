import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/theme_notifier.dart';
import './widgets/booking_summary_widget.dart';
import './widgets/advanced_booking_summary.dart';
import './widgets/seat_legend_widget.dart';

class SeatSelection extends StatefulWidget {
  const SeatSelection({Key? key}) : super(key: key);

  @override
  State<SeatSelection> createState() => _SeatSelectionState();
}

class _SeatSelectionState extends State<SeatSelection>
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
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pullIndicatorController;
  late Animation<double> _pullIndicatorAnimation;
  late Animation<double> _bendAnimation;
  late DraggableScrollableController _draggableController;

  List<int> _selectedSeats = [];

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

  // Mock seat data - 73 seats total (2 wheelchair + 71 regular)
  late final List<Map<String, dynamic>> _seats;

  void _generateSeats() {
    _seats = [];
    int seatNumber = 1;

    // Add 2 seats in wheelchair area (seats 1-2)
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

    // Generate exactly 71 seats - seats 3-73
    int seatsGenerated = 0;
    int targetSeats = 71;

    while (seatsGenerated < targetSeats) {
      List<String> seatLetters = ['A', 'B', 'C', 'D', 'E'];

      for (int seatIndex = 0;
          seatIndex < seatLetters.length && seatsGenerated < targetSeats;
          seatIndex++) {
        String letter = seatLetters[seatIndex];
        int seatId = seatNumber;

        // Determine seat type
        String type = '';
        double price = 5500.0;

        if (letter == 'A' || letter == 'E') {
          type = 'Window';
          price = 6500.0;
        } else {
          type = 'Aisle';
          price = 5500.0;
        }

        // Random status for demo (you can customize this)
        String status = 'available';
        if (seatId % 7 == 0) {
          status = 'occupied';
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

  @override
  void initState() {
    super.initState();
    _generateSeats(); // Generate 70 seats
    ThemeNotifier().addListener(_onThemeChanged);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Initialize pull indicator animation
    _pullIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pullIndicatorAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _pullIndicatorController,
      curve: Curves.elasticOut,
    ));

    _bendAnimation = Tween<double>(
      begin: 0.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _pullIndicatorController,
      curve: Curves.easeInOut,
    ));

    _draggableController = DraggableScrollableController();

    _fadeController.forward();
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    _fadeController.dispose();
    _pullIndicatorController.dispose();
    _draggableController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _startPullIndicatorAnimation() {
    // Delay the animation to start only when user selects a seat
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _selectedSeats.isNotEmpty) {
        _pullIndicatorController.repeat(reverse: true);
      }
    });
  }

  void _stopPullIndicatorAnimation() {
    _pullIndicatorController.stop();
    _pullIndicatorController.reset();
  }

  void _expandBookingCard() {
    if (_draggableController.isAttached) {
      _draggableController.animateTo(
        0.55, // Expand to half size
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _stopPullIndicatorAnimation();
    }
  }

  void _onSeatTap(int seatId) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
        if (_selectedSeats.isEmpty) {
          _stopPullIndicatorAnimation();
        }
      } else {
        _selectedSeats.add(seatId);
        if (_selectedSeats.length == 1) {
          // Start animation when first seat is selected
          _startPullIndicatorAnimation();
        }
      }
    });
  }

  void _onContinue() {
    if (_selectedSeats.isNotEmpty) {
      // Prepare booking data to pass to confirmation screen
      final bookingData = {
        'selectedSeats': _selectedSeatDetails,
        'busInfo': _busInfo,
        'totalPrice': _calculateTotalPrice(),
        'passengerCount': _selectedSeats.length,
      };

      Navigator.pushNamed(
        context,
        '/booking-confirmation',
        arguments: bookingData,
      );
    } else {
      // Show message if no seats selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one seat to continue'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  double _calculateTotalPrice() {
    return _selectedSeatDetails.fold(0.0, (sum, seat) {
      return sum + (seat['price'] as double);
    });
  }

  List<Map<String, dynamic>> get _selectedSeatDetails {
    return _seats.where((seat) => _selectedSeats.contains(seat['id'])).toList();
  }

  Widget _buildCleanSeatGrid() {
    List<Widget> rows = [];
    int currentSeatIndex = 2; // Start from seat 3 (skip wheelchair seats 1-2)

    for (int rowIndex = 0; rowIndex < 16; rowIndex++) {
      // 16 total rows (14 regular + 2 entry rows)
      // Check if this should be an entry door row
      bool isEntryRow =
          rowIndex == 3 || rowIndex == 11; // Entry rows after row 3 and row 11

      if (isEntryRow) {
        // Entry door row - left side has 3 seats, right side has entry door
        rows.add(
          Container(
            height: 8.h,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            child: Row(
              children: [
                // Left side seats (A, B, C)
                Expanded(
                  flex: 3,
                  child: Row(
                    children: List.generate(3, (seatIndex) {
                      if (currentSeatIndex >= _seats.length) {
                        return Expanded(child: SizedBox());
                      }
                      final seat = _seats[currentSeatIndex];
                      currentSeatIndex++;
                      return Expanded(child: _buildCleanSeat(seat));
                    }),
                  ),
                ),

                // Aisle
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

                // Entry door section (takes up 2 seat spaces)
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
          ),
        );
      } else {
        // Regular seat row - left side 3 seats, aisle, right side 2 seats
        rows.add(
          Container(
            height: 8.h,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            child: Row(
              children: [
                // Left side seats (A, B, C)
                Expanded(
                  flex: 3,
                  child: Row(
                    children: List.generate(3, (seatIndex) {
                      if (currentSeatIndex >= _seats.length) {
                        return Expanded(child: SizedBox());
                      }
                      final seat = _seats[currentSeatIndex];
                      currentSeatIndex++;
                      return Expanded(child: _buildCleanSeat(seat));
                    }),
                  ),
                ),

                // Aisle
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

                // Right side seats (D, E)
                Expanded(
                  flex: 2,
                  child: Row(
                    children: List.generate(2, (seatIndex) {
                      if (currentSeatIndex >= _seats.length) {
                        return Expanded(child: SizedBox());
                      }
                      final seat = _seats[currentSeatIndex];
                      currentSeatIndex++;
                      return Expanded(child: _buildCleanSeat(seat));
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Column(children: rows);
  }

  Widget _buildCleanSeat(Map<String, dynamic> seat) {
    final seatId = seat['id'] as int;
    final seatNumber = seat['number'] as String;
    final status = seat['status'] as String;
    final isSelected = _selectedSeats.contains(seatId);
    final isAvailable = status == 'available';

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
                  ],
                ),
              ),
              // Status indicator
              if (status == 'occupied')
                Positioned(
                  top: 1.w,
                  right: 1.w,
                  child: Icon(
                    Icons.block,
                    color: Colors.white,
                    size: 4.w,
                  ),
                ),
              if (isSelected)
                Positioned(
                  top: 1.w,
                  right: 1.w,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 4.w,
                  ),
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
        return const Color(0xFF008B8B); // Available - Teal
      case 'occupied':
        return const Color(0xFF757575); // Occupied - Grey
      default:
        return const Color(0xFF757575);
    }
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 2.h,
        left: 4.w,
        right: 4.w,
        bottom: 2.h,
      ),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: ThemeNotifier().isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(2.5.w),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: textColor,
                  size: 6.w,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Seats',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_busInfo['from']} → ${_busInfo['to']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: onSurfaceVariantColor,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedSeats.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Text(
                '${_selectedSeats.length}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
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
      backgroundColor: backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                _buildAppBar(),
                // Compact legend at the top
                Container(
                  margin: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.h),
                  child: SeatLegendWidget(),
                ),
                // Main seat selection area with proper scrolling
                Expanded(
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
                        // Bus header
                        Container(
                          padding: EdgeInsets.all(3.w),
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
                                      'Express Luxury Coach',
                                      style: GoogleFonts.inter(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeNotifier().isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      '${_busInfo['from']} → ${_busInfo['to']} • ${_busInfo['date']}',
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
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
                        ),

                        // Scrollable seat map
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(4.w, 4.w, 4.w,
                                20.h), // Add bottom padding for booking summary
                            child: Column(
                              children: [
                                // Driver section
                                Container(
                                  height: 8.h,
                                  margin: EdgeInsets.only(bottom: 3.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 1.w),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                primaryColor.withOpacity(0.3),
                                                primaryColor.withOpacity(0.1),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: primaryColor,
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.drive_eta,
                                                color: primaryColor,
                                                size: 6.w,
                                              ),
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
                                            // First wheelchair seat (seat 1)
                                            Expanded(
                                              child: _buildCleanSeat(_seats[0]),
                                            ),
                                            SizedBox(width: 1.w),
                                            // Second wheelchair seat (seat 2)
                                            Expanded(
                                              child: _buildCleanSeat(_seats[1]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Seat grid
                                _buildCleanSeatGrid(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Advanced booking summary overlay at bottom - swipeable
            DraggableScrollableSheet(
              controller: _draggableController,
              initialChildSize: 0.18, // Start minimized
              minChildSize: 0.18, // Minimum size when collapsed
              maxChildSize: 0.92, // Maximum size when fully expanded
              expand: false, // Allow dragging beyond initial bounds
              snap: true, // Snap to min/max positions
              snapSizes: [
                0.18,
                0.55,
                0.92
              ], // Snap positions: minimized, half, full
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: ThemeNotifier().isDarkMode
                        ? const Color(0xFF1E1E1E)
                        : Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, -8),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Animated pull indicator with bend effect
                      AnimatedBuilder(
                        animation: _pullIndicatorAnimation,
                        builder: (context, child) {
                          return Container(
                            margin: EdgeInsets.only(top: 12),
                            child: CustomPaint(
                              size: Size(48, 4),
                              painter: PullIndicatorPainter(
                                color: ThemeNotifier().isDarkMode
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.grey[500]!,
                                animationValue: _pullIndicatorAnimation.value,
                                bendValue: _bendAnimation.value,
                              ),
                            ),
                          );
                        },
                      ),
                      // Tap area to help with dragging
                      GestureDetector(
                        onTap: () {
                          // Provide visual feedback and expand card
                          HapticFeedback.selectionClick();
                          _expandBookingCard();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              color: ThemeNotifier().isDarkMode
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.grey[400],
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Expanded(
                        child: AdvancedBookingSummary(
                          selectedSeats: _selectedSeatDetails,
                          busInfo: _busInfo,
                          onContinue: _onContinue,
                          scrollController: scrollController,
                          onPassengerDataChanged: (passengerData) {
                            // Store passenger information for later use
                            // This would be saved to state management in a real app
                          },
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
    );
  }
}

/// Custom painter for animated pull indicator with bend effect
class PullIndicatorPainter extends CustomPainter {
  final Color color;
  final double animationValue;
  final double bendValue;

  PullIndicatorPainter({
    required this.color,
    required this.animationValue,
    required this.bendValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Create a path for the bar with bend effect
    final path = Path();

    // Calculate bend offset for middle of the bar
    final midX = size.width / 2;
    final bendOffset = bendValue * (1 + animationValue * 0.5);

    // Create curved line with bend in the middle
    path.moveTo(2, 2);
    path.quadraticBezierTo(
      midX, 2 + bendOffset, // Control point with bend
      size.width - 2, 2,    // End point
    );

    // Add vertical movement for pull effect
    canvas.save();
    canvas.translate(0, -animationValue);

    // Draw the animated path
    canvas.drawPath(path, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(PullIndicatorPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.bendValue != bendValue ||
           oldDelegate.color != color;
  }
}
