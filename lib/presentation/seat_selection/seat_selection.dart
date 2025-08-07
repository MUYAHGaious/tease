import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/booking_summary_widget.dart';
import './widgets/bus_layout_widget.dart';
import './widgets/passenger_assignment_widget.dart';
import './widgets/seat_legend_widget.dart';
import './widgets/zoom_controls_widget.dart';

class SeatSelection extends StatefulWidget {
  const SeatSelection({Key? key}) : super(key: key);

  @override
  State<SeatSelection> createState() => _SeatSelectionState();
}

class _SeatSelectionState extends State<SeatSelection>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  double _zoomLevel = 1.0;
  List<int> _selectedSeats = [];
  bool _showPassengerForm = false;
  final Map<int, Map<String, String>> _passengerInfo = {};

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

  // Mock seat data
  final List<Map<String, dynamic>> _seats = [
    {
      'id': 1,
      'number': '1A',
      'status': 'available',
      'type': 'Window',
      'price': 6500.0
    },
    {
      'id': 2,
      'number': '1B',
      'status': 'available',
      'type': 'Aisle',
      'price': 5500.0
    },
    {
      'id': 3,
      'number': '1C',
      'status': 'occupied',
      'type': 'Aisle',
      'price': 5500.0
    },
    {
      'id': 4,
      'number': '1D',
      'status': 'available',
      'type': 'Window',
      'price': 6500.0
    },
    {
      'id': 5,
      'number': '2A',
      'status': 'premium',
      'type': 'Window Premium',
      'price': 8000.0
    },
    {
      'id': 6,
      'number': '2B',
      'status': 'available',
      'type': 'Aisle',
      'price': 5500.0
    },
    {
      'id': 7,
      'number': '2C',
      'status': 'available',
      'type': 'Aisle',
      'price': 5500.0
    },
    {
      'id': 8,
      'number': '2D',
      'status': 'premium',
      'type': 'Window Premium',
      'price': 8000.0
    },
    {
      'id': 9,
      'number': '3A',
      'status': 'available',
      'type': 'Window',
      'price': 6500.0
    },
    {
      'id': 10,
      'number': '3B',
      'status': 'occupied',
      'type': 'Aisle',
      'price': 5500.0
    },
    {
      'id': 11,
      'number': '3C',
      'status': 'available',
      'type': 'Aisle',
      'price': 5500.0
    },
    {
      'id': 12,
      'number': '3D',
      'status': 'available',
      'type': 'Window',
      'price': 6500.0
    },
    {
      'id': 13,
      'number': '4A',
      'status': 'available',
      'type': 'Window',
      'price': 6500.0
    },
    {
      'id': 14,
      'number': '4B',
      'status': 'available',
      'type': 'Aisle',
      'price': 5500.0
    },
    {
      'id': 15,
      'number': '4C',
      'status': 'occupied',
      'type': 'Aisle',
      'price': 5500.0
    },
    {
      'id': 16,
      'number': '4D',
      'status': 'available',
      'type': 'Window',
      'price': 6500.0
    },
    {
      'id': 17,
      'number': '5A',
      'status': 'available',
      'type': 'Window',
      'price': 6500.0
    },
    {
      'id': 18,
      'number': '5B',
      'status': 'available',
      'type': 'Aisle',
      'price': 5500.0
    },
    {
      'id': 19,
      'number': '5C',
      'status': 'available',
      'type': 'Aisle',
      'price': 5500.0
    },
    {
      'id': 20,
      'number': '5D',
      'status': 'available',
      'type': 'Window',
      'price': 6500.0
    },
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onSeatTap(int seatId) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
        _passengerInfo.remove(seatId);
      } else {
        _selectedSeats.add(seatId);
      }
    });
  }

  void _onZoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.2).clamp(0.5, 2.0);
    });
  }

  void _onZoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.2).clamp(0.5, 2.0);
    });
  }

  void _onResetZoom() {
    setState(() {
      _zoomLevel = 1.0;
    });
  }

  void _onContinue() {
    if (_selectedSeats.isNotEmpty) {
      setState(() {
        _showPassengerForm = true;
      });
      _slideController.forward();
    }
  }

  void _onPassengerAssigned(int seatId, Map<String, String> passengerInfo) {
    setState(() {
      _passengerInfo[seatId] = passengerInfo;
    });
  }

  void _proceedToBooking() {
    Navigator.pushNamed(context, '/booking-confirmation');
  }

  List<Map<String, dynamic>> get _selectedSeatDetails {
    return _seats.where((seat) => _selectedSeats.contains(seat['id'])).toList();
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
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
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
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2.5.w),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
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
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_busInfo['from']} → ${_busInfo['to']}',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedSeats.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Text(
                '${_selectedSeats.length}',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
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
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        SeatLegendWidget(),
                        SizedBox(height: 4.h),
                        Container(
                          height: 60.h,
                          child: Stack(
                            children: [
                              InteractiveViewer(
                                boundaryMargin: EdgeInsets.all(4.w),
                                minScale: 0.5,
                                maxScale: 2.0,
                                onInteractionUpdate: (details) {
                                  setState(() {
                                    _zoomLevel = details.scale.clamp(0.5, 2.0);
                                  });
                                },
                                child: BusLayoutWidget(
                                  seats: _seats,
                                  selectedSeats: _selectedSeats,
                                  onSeatTap: _onSeatTap,
                                  zoomLevel: _zoomLevel,
                                ),
                              ),
                              Positioned(
                                right: 4.w,
                                top: 4.h,
                                child: ZoomControlsWidget(
                                  zoomLevel: _zoomLevel,
                                  onZoomIn: _onZoomIn,
                                  onZoomOut: _onZoomOut,
                                  onResetZoom: _onResetZoom,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BookingSummaryWidget(
                selectedSeats: _selectedSeatDetails,
                busInfo: _busInfo,
                onContinue: _onContinue,
              ),
            ),
            if (_showPassengerForm)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPassengerForm = false;
                      });
                      _slideController.reverse();
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            if (_showPassengerForm)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 80.h,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PassengerAssignmentWidget(
                            selectedSeats: _selectedSeatDetails,
                            onPassengerAssigned: _onPassengerAssigned,
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.lightTheme.colorScheme.shadow
                                      .withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _showPassengerForm = false;
                                      });
                                      _slideController.reverse();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.h),
                                      side: BorderSide(
                                        color: AppTheme
                                            .lightTheme.colorScheme.outline,
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(2.w),
                                      ),
                                    ),
                                    child: Text(
                                      'Back',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelLarge
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: _proceedToBooking,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      foregroundColor: AppTheme
                                          .lightTheme.colorScheme.onPrimary,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.h),
                                      elevation: 4,
                                      shadowColor: AppTheme
                                          .lightTheme.colorScheme.shadow,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(2.w),
                                      ),
                                    ),
                                    child: Text(
                                      'Proceed to Booking',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelLarge
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}
