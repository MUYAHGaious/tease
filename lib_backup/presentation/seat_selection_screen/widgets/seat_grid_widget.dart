import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SeatGridWidget extends StatefulWidget {
  final List<Map<String, dynamic>> seatData;
  final Function(List<String>) onSeatsSelected;
  final List<String> selectedSeats;

  const SeatGridWidget({
    Key? key,
    required this.seatData,
    required this.onSeatsSelected,
    required this.selectedSeats,
  }) : super(key: key);

  @override
  State<SeatGridWidget> createState() => _SeatGridWidgetState();
}

class _SeatGridWidgetState extends State<SeatGridWidget> {
  List<String> _selectedSeats = [];

  @override
  void initState() {
    super.initState();
    _selectedSeats = List.from(widget.selectedSeats);
  }

  void _toggleSeat(String seatNumber, String status) {
    if (status == 'occupied' || status == 'unavailable' || seatNumber == 'DRIVER') {
      return;
    }

    setState(() {
      if (_selectedSeats.contains(seatNumber)) {
        _selectedSeats.remove(seatNumber);
      } else {
        _selectedSeats.add(seatNumber);
      }
    });

    HapticFeedback.selectionClick();
    widget.onSeatsSelected(_selectedSeats);
  }

  Color _getSeatColor(String status, String seatNumber) {
    if (_selectedSeats.contains(seatNumber)) {
      return const Color(0xFFC8E53F);
    }
    
    switch (status) {
      case 'occupied':
        return const Color(0xFF1A4A47);
      case 'unavailable':
        return Colors.grey.shade400;
      case 'available':
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Check if we have seat data
    print('Seat data length: ${widget.seatData.length}');
    if (widget.seatData.isNotEmpty) {
      print('First seat: ${widget.seatData[0]}');
    }
    
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Bus front indicator
          Container(
            width: 80.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'directions_bus',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'FRONT',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Simple grid layout
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1.0,
                crossAxisSpacing: 1.w,
                mainAxisSpacing: 1.h,
              ),
              itemCount: widget.seatData.length,
              itemBuilder: (context, index) {
                final seat = widget.seatData[index];
                final seatNumber = seat['seatNumber'] as String;
                final status = seat['status'] as String;
                final isWindow = seat['isWindow'] as bool? ?? false;
                final isAisle = seat['isAisle'] as bool? ?? false;
                final isDriverSeat = seat['isDriverSeat'] as bool? ?? false;
                
                // Debug individual seat
                if (index < 3) {
                  print('Seat $index: $seatNumber, status: $status, color: ${_getSeatColor(status, seatNumber)}');
                }

                return GestureDetector(
                  onTap: () => _toggleSeat(seatNumber, status),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getSeatColor(status, seatNumber),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedSeats.contains(seatNumber)
                            ? const Color(0xFF1A4A47)
                            : Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isDriverSeat) ...[
                          CustomIconWidget(
                            iconName: 'person',
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(height: 0.2.h),
                          Text(
                            'DRIVER',
                            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 8.sp,
                              color: Colors.white,
                            ),
                          ),
                        ] else ...[
                          Text(
                            seatNumber,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                              color: _selectedSeats.contains(seatNumber) || status == 'occupied'
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          if (isWindow || isAisle) ...[
                            SizedBox(height: 0.2.h),
                            CustomIconWidget(
                              iconName: isWindow ? 'window' : 'airline_seat_recline_normal',
                              color: _selectedSeats.contains(seatNumber) || status == 'occupied'
                                  ? Colors.white
                                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                              size: 8,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}