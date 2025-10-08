import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class BusDetailSheet extends StatefulWidget {
  final Map<String, dynamic> bus;
  final Function(String?) onBookSeat;
  final VoidCallback onClose;

  const BusDetailSheet({
    Key? key,
    required this.bus,
    required this.onBookSeat,
    required this.onClose,
  }) : super(key: key);

  @override
  State<BusDetailSheet> createState() => _BusDetailSheetState();
}

class _BusDetailSheetState extends State<BusDetailSheet>
    with TickerProviderStateMixin {
  // Theme-aware colors
  Color get primaryColor => Theme.of(context).colorScheme.primary;
  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(context).colorScheme.surface;
  Color get textColor => Theme.of(context).colorScheme.onSurface;
  Color get onSurfaceVariantColor =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  Color get shadowColor => Theme.of(context).colorScheme.shadow;
  Color get borderColor => Theme.of(context).colorScheme.outline;

  // Animation controllers
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // Selected seat
  String? _selectedSeat;

  // Mock seat data for this bus
  late List<Map<String, dynamic>> _busSeats;

  @override
  void initState() {
    super.initState();
    _initializeSeats();
    _initializeAnimations();
  }

  void _initializeSeats() {
    // Generate seats based on bus capacity
    int capacity = widget.bus['capacity'];
    _busSeats = [];

    for (int i = 1; i <= capacity; i++) {
      String seatNumber = _getSeatNumber(i);
      String type = (i % 2 == 1) ? 'Window' : 'Aisle';
      String status = _getRandomSeatStatus();

      _busSeats.add({
        'id': 'S${widget.bus['id']}_$i',
        'seatNumber': seatNumber,
        'type': type,
        'status': status,
        'price': _getSeatPrice(widget.bus['route']),
      });
    }
  }

  String _getSeatNumber(int index) {
    int row = ((index - 1) ~/ 4) + 1;
    int seatInRow = ((index - 1) % 4) + 1;
    String rowLetter = String.fromCharCode(64 + row); // A, B, C, etc.
    return '$rowLetter$seatInRow';
  }

  String _getRandomSeatStatus() {
    List<String> statuses = ['Available', 'Booked', 'Available', 'Available'];
    return statuses[DateTime.now().millisecond % statuses.length];
  }

  String _getSeatPrice(String route) {
    if (route.contains('Yaoundé → Bamenda') ||
        route.contains('Bamenda → Yaoundé')) {
      return '8,000 XAF';
    } else if (route.contains('Douala → Yaoundé')) {
      return '7,500 XAF';
    } else if (route.contains('Douala → Bafoussam')) {
      return '7,000 XAF';
    } else {
      return '6,500 XAF';
    }
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimationController.forward();
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBusInfo(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      width: 12.w,
      height: 0.5.h,
      decoration: BoxDecoration(
        color: onSurfaceVariantColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.bus['plateNumber'],
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  widget.bus['model'],
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: onSurfaceVariantColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.close,
                color: onSurfaceVariantColor,
                size: 5.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusInfo() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Basic Info Row
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Driver', widget.bus['driver']),
              ),
              Expanded(
                child: _buildInfoItem(
                    'Conductor', widget.bus['conductor'] ?? 'N/A'),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          // Route Row
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Route', widget.bus['route']),
              ),
              Expanded(
                child: SizedBox(), // Empty space for alignment
              ),
            ],
          ),
          SizedBox(height: 1.h),
          // Capacity and Status Row
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Available',
                    '${widget.bus['availableSeats']}/${widget.bus['capacity']} seats'),
              ),
              Expanded(
                child: _buildInfoItem(
                    'Status', widget.bus['statusFlag'] ?? widget.bus['status']),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          // Additional Details Row
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                    'Fuel Level', widget.bus['fuelLevel'] ?? 'N/A'),
              ),
              Expanded(
                child:
                    _buildInfoItem('Mileage', widget.bus['mileage'] ?? 'N/A'),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          // Maintenance and Year Row
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Year', widget.bus['year'] ?? 'N/A'),
              ),
              Expanded(
                child: _buildInfoItem(
                    'Next Maintenance', widget.bus['nextMaintenance'] ?? 'N/A'),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // View All Seats Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Close the sheet first
                Navigator.pushNamed(context, '/seat-selection');
              },
              icon: Icon(Icons.event_seat, size: 5.w),
              label: Text(
                'View All Seats',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seat Layout',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Driver area
              Container(
                width: double.infinity,
                height: 4.h,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Driver',
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              // Seat grid
              _buildSeatGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeatGrid() {
    int seatsPerRow = 4;
    int totalRows = (_busSeats.length / seatsPerRow).ceil();

    return Column(
      children: List.generate(totalRows, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(bottom: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(seatsPerRow, (seatIndex) {
              int seatNumber = rowIndex * seatsPerRow + seatIndex;
              if (seatNumber >= _busSeats.length) {
                return SizedBox(width: 8.w); // Empty space
              }

              final seat = _busSeats[seatNumber];
              return _buildSeatButton(seat);
            }),
          ),
        );
      }),
    );
  }

  Widget _buildSeatButton(Map<String, dynamic> seat) {
    bool isSelected = _selectedSeat == seat['seatNumber'];
    bool isAvailable = seat['status'] == 'Available';
    bool isBooked = seat['status'] == 'Booked';

    Color seatColor;
    if (isSelected) {
      seatColor = primaryColor;
    } else if (isBooked) {
      seatColor = Colors.red;
    } else if (isAvailable) {
      seatColor = Colors.green;
    } else {
      seatColor = Colors.orange;
    }

    return GestureDetector(
      onTap: isAvailable
          ? () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedSeat = isSelected ? null : seat['seatNumber'];
              });
            }
          : null,
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: seatColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: seatColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_seat,
              color: seatColor,
              size: 4.w,
            ),
            SizedBox(height: 0.5.h),
            Text(
              seat['seatNumber'],
              style: GoogleFonts.inter(
                fontSize: 7.sp,
                fontWeight: FontWeight.w600,
                color: seatColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legend',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: _buildLegendItem('Available', Colors.green),
            ),
            Expanded(
              child: _buildLegendItem('Booked', Colors.red),
            ),
            Expanded(
              child: _buildLegendItem('Maintenance', Colors.orange),
            ),
            Expanded(
              child: _buildLegendItem('Selected', primaryColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 8.sp,
            color: onSurfaceVariantColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_selectedSeat != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Selected Seat: $_selectedSeat',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Price: ${_busSeats.firstWhere((s) => s['seatNumber'] == _selectedSeat)['price']}',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: onSurfaceVariantColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  widget.onBookSeat(_selectedSeat);
                },
                icon: Icon(Icons.event_seat),
                label: Text(
                  _selectedSeat != null ? 'Book Selected Seat' : 'Choose Seat',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  widget.onBookSeat(null); // Navigate to full seat selection
                },
                icon: Icon(Icons.search),
                label: Text(
                  'View All Seats',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            color: onSurfaceVariantColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
