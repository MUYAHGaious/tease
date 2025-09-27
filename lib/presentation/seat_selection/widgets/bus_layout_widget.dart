import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/theme_notifier.dart';

class BusLayoutWidget extends StatefulWidget {
  final List<Map<String, dynamic>> seats;
  final List<int> selectedSeats;
  final Function(int) onSeatTap;
  final double zoomLevel;

  const BusLayoutWidget({
    Key? key,
    required this.seats,
    required this.selectedSeats,
    required this.onSeatTap,
    required this.zoomLevel,
  }) : super(key: key);

  @override
  State<BusLayoutWidget> createState() => _BusLayoutWidgetState();
}

class _BusLayoutWidgetState extends State<BusLayoutWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getSeatColor(Map<String, dynamic> seat) {
    final seatId = seat['id'] as int;
    final status = seat['status'] as String;

    if (widget.selectedSeats.contains(seatId)) {
      return const Color(0xFF4CAF50); // Selected - Green
    }

    switch (status) {
      case 'available':
        return const Color(0xFF008B8B); // Available - Teal
      case 'occupied':
        return const Color(0xFF757575); // Occupied - Grey
      case 'premium':
        return const Color(0xFFFF9800); // Premium - Orange
      default:
        return const Color(0xFF757575);
    }
  }

  Widget _buildSeat(Map<String, dynamic> seat, int index) {
    final seatId = seat['id'] as int;
    final seatNumber = seat['number'] as String;
    final status = seat['status'] as String;
    final isSelected = widget.selectedSeats.contains(seatId);
    final isAvailable = status == 'available' || status == 'premium';

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: isAvailable ? () => widget.onSeatTap(seatId) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 10.w * widget.zoomLevel,
              height: 10.w * widget.zoomLevel,
              margin: EdgeInsets.all(0.8.w),
              decoration: BoxDecoration(
                color: _getSeatColor(seat),
                borderRadius: BorderRadius.circular(1.5.w),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getSeatColor(seat).withOpacity(0.3),
                    blurRadius: isSelected ? 6 : 2,
                    spreadRadius: isSelected ? 1 : 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  seatNumber,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: (7 * widget.zoomLevel).sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDriverSection() {
    return Container(
      width: double.infinity,
      height: 6.h,
      margin: EdgeInsets.only(bottom: 3.h),
      decoration: BoxDecoration(
        color: ThemeNotifier().isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(1.5.w),
        border: Border.all(
          color: ThemeNotifier().isDarkMode
              ? Colors.white.withOpacity(0.2)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: ThemeNotifier().isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(1.5.w),
                  bottomLeft: Radius.circular(1.5.w),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.drive_eta,
                      color: const Color(0xFF008B8B),
                      size: 4.w,
                    ),
                    SizedBox(width: 1.5.w),
                    Text(
                      'Driver',
                      style: GoogleFonts.inter(
                        color: ThemeNotifier().isDarkMode
                            ? Colors.white70
                            : Colors.black87,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: ThemeNotifier().isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(1.5.w),
                  bottomRight: Radius.circular(1.5.w),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.door_front_door,
                  color: ThemeNotifier().isDarkMode
                      ? Colors.white60
                      : Colors.grey[600],
                  size: 4.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: ThemeNotifier().isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: ThemeNotifier().isDarkMode
              ? Colors.white.withOpacity(0.15)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeNotifier().isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: Column(
              children: [
                _buildDriverSection(),
                Expanded(
                  child: Row(
                    children: [
                      // Left side seats (2 columns)
                      Expanded(
                        flex: 2,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 1.w,
                            mainAxisSpacing: 1.w,
                          ),
                          itemCount: (widget.seats.length / 2).ceil(),
                          itemBuilder: (context, index) {
                            if (index * 2 < widget.seats.length) {
                              return _buildSeat(
                                  widget.seats[index * 2], index * 2);
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Container(
                        width: 2.w,
                        decoration: BoxDecoration(
                          color: ThemeNotifier().isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                      ),
                      SizedBox(width: 1.w),
                      // Right side seats (2 columns)
                      Expanded(
                        flex: 2,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 1.w,
                            mainAxisSpacing: 1.w,
                          ),
                          itemCount: (widget.seats.length / 2).ceil(),
                          itemBuilder: (context, index) {
                            if (index * 2 + 1 < widget.seats.length) {
                              return _buildSeat(
                                  widget.seats[index * 2 + 1], index * 2 + 1);
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
