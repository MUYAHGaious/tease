import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class WalkInBookingWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onBookingCreated;
  final VoidCallback onCancel;

  const WalkInBookingWidget({
    Key? key,
    required this.onBookingCreated,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<WalkInBookingWidget> createState() => _WalkInBookingWidgetState();
}

class _WalkInBookingWidgetState extends State<WalkInBookingWidget>
    with TickerProviderStateMixin {
  // Theme-aware colors following your pattern
  Color get primaryColor => Theme.of(context).colorScheme.primary;
  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(context).colorScheme.surface;
  Color get textColor => Theme.of(context).colorScheme.onSurface;
  Color get onSurfaceVariantColor =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  Color get shadowColor => Theme.of(context).colorScheme.shadow;
  Color get borderColor => Theme.of(context).colorScheme.outline;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _passengerNameController = TextEditingController();
  final _passengerPhoneController = TextEditingController();
  final _passengerEmailController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  // Form state
  String _selectedRoute = 'Douala → Yaoundé';
  String _selectedDate = 'Today';
  String _selectedTime = '09:30 AM';
  int _passengerCount = 1;
  List<int> _selectedSeats = [];
  double _totalPrice = 0.0;

  late AnimationController _animationController;
  late Animation<double> _animation;

  // Mock data
  final List<String> _routes = [
    'Douala → Yaoundé',
    'Yaoundé → Bamenda',
    'Douala → Bafoussam',
    'Garoua → Maroua',
    'Bamenda → Yaoundé',
  ];

  final List<String> _times = [
    '09:30 AM',
    '02:15 PM',
    '06:45 PM',
    '11:00 PM',
  ];

  final List<Map<String, dynamic>> _availableSeats = [
    {'id': 1, 'number': 'A1', 'price': 22500.0, 'type': 'window'},
    {'id': 2, 'number': 'A3', 'price': 22500.0, 'type': 'window'},
    {'id': 3, 'number': 'B1', 'price': 22500.0, 'type': 'window'},
    {'id': 4, 'number': 'B4', 'price': 20000.0, 'type': 'aisle'},
    {'id': 5, 'number': 'C4', 'price': 20000.0, 'type': 'aisle'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
    _calculateTotalPrice();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _passengerNameController.dispose();
    _passengerPhoneController.dispose();
    _passengerEmailController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 90.h,
          maxWidth: 95.w,
        ),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRouteSelection(),
                      SizedBox(height: 3.h),
                      _buildPassengerDetails(),
                      SizedBox(height: 3.h),
                      _buildSeatSelection(),
                      SizedBox(height: 3.h),
                      _buildPriceSummary(),
                      SizedBox(height: 3.h),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Walk-in Booking',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Create booking for walk-in customer',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: onSurfaceVariantColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              widget.onCancel();
            },
            icon: Icon(
              Icons.close,
              color: textColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSelection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route & Schedule',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRoute,
                  decoration: InputDecoration(
                    labelText: 'Route',
                    labelStyle: GoogleFonts.inter(
                      color: onSurfaceVariantColor,
                      fontSize: 12.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                  ),
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: 14.sp,
                  ),
                  items: _routes.map((route) {
                    return DropdownMenuItem(
                      value: route,
                      child: Text(route),
                    );
                  }).toList(),
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedRoute = value!;
                    });
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDate,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    labelStyle: GoogleFonts.inter(
                      color: onSurfaceVariantColor,
                      fontSize: 12.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                  ),
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: 14.sp,
                  ),
                  items: ['Today', 'Tomorrow', 'Next Week'].map((date) {
                    return DropdownMenuItem(
                      value: date,
                      child: Text(date),
                    );
                  }).toList(),
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedDate = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          DropdownButtonFormField<String>(
            value: _selectedTime,
            decoration: InputDecoration(
              labelText: 'Departure Time',
              labelStyle: GoogleFonts.inter(
                color: onSurfaceVariantColor,
                fontSize: 12.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 1.h,
              ),
            ),
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: 14.sp,
            ),
            items: _times.map((time) {
              return DropdownMenuItem(
                value: time,
                child: Text(time),
              );
            }).toList(),
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedTime = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerDetails() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passenger Details',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          _buildTextField(
            controller: _passengerNameController,
            label: 'Full Name',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter passenger name';
              }
              return null;
            },
          ),
          SizedBox(height: 2.h),
          _buildTextField(
            controller: _passengerPhoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
          SizedBox(height: 2.h),
          _buildTextField(
            controller: _passengerEmailController,
            label: 'Email (Optional)',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 2.h),
          _buildTextField(
            controller: _emergencyContactController,
            label: 'Emergency Contact',
            icon: Icons.emergency,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter emergency contact';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: onSurfaceVariantColor,
          fontSize: 12.sp,
        ),
        prefixIcon: Icon(
          icon,
          color: primaryColor,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 3.w,
          vertical: 1.h,
        ),
      ),
    );
  }

  Widget _buildSeatSelection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seat Selection',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_selectedSeats.length} selected',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 2.h,
            children: _availableSeats.map((seat) {
              final bool isSelected = _selectedSeats.contains(seat['id']);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (isSelected) {
                      _selectedSeats.remove(seat['id']);
                    } else if (_selectedSeats.length < _passengerCount) {
                      _selectedSeats.add(seat['id']);
                    }
                    _calculateTotalPrice();
                  });
                },
                child: Container(
                  width: 15.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withOpacity(0.2)
                        : surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : borderColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.chair,
                        color:
                            isSelected ? primaryColor : onSurfaceVariantColor,
                        size: 4.w,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        seat['number'],
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? primaryColor : textColor,
                        ),
                      ),
                      Text(
                        '${seat['price'].toStringAsFixed(0)} XAF',
                        style: GoogleFonts.inter(
                          fontSize: 8.sp,
                          color:
                              isSelected ? primaryColor : onSurfaceVariantColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Summary',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seats (${_selectedSeats.length})',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: onSurfaceVariantColor,
                ),
              ),
              Text(
                '${_totalPrice.toStringAsFixed(0)} XAF',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service Fee',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: onSurfaceVariantColor,
                ),
              ),
              Text(
                '0 XAF',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          Divider(color: borderColor.withOpacity(0.3)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              Text(
                '${_totalPrice.toStringAsFixed(0)} XAF',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              widget.onCancel();
            },
            child: Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: onSurfaceVariantColor,
              side: BorderSide(color: borderColor),
              padding: EdgeInsets.symmetric(vertical: 2.h),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: ElevatedButton(
            onPressed: _selectedSeats.length == _passengerCount
                ? _createBooking
                : null,
            child: Text('Create Booking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: 2.h),
            ),
          ),
        ),
      ],
    );
  }

  void _calculateTotalPrice() {
    _totalPrice = _selectedSeats.fold(0.0, (sum, seatId) {
      final seat = _availableSeats.firstWhere((s) => s['id'] == seatId);
      return sum + seat['price'];
    });
  }

  void _createBooking() {
    if (_formKey.currentState!.validate() &&
        _selectedSeats.length == _passengerCount) {
      HapticFeedback.selectionClick();

      final bookingData = {
        'passengerName': _passengerNameController.text,
        'passengerPhone': _passengerPhoneController.text,
        'passengerEmail': _passengerEmailController.text,
        'emergencyContact': _emergencyContactController.text,
        'route': _selectedRoute,
        'date': _selectedDate,
        'time': _selectedTime,
        'seats': _selectedSeats,
        'totalPrice': _totalPrice,
        'bookingId':
            'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      };

      widget.onBookingCreated(bookingData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields and select seats'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

