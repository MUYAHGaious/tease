import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SeatPreferenceCard extends StatelessWidget {
  final String? selectedSeat;
  final Function(String?) onSeatSelected;
  final List<String> availableSeats;
  final List<String> occupiedSeats;

  const SeatPreferenceCard({
    Key? key,
    required this.selectedSeat,
    required this.onSeatSelected,
    required this.availableSeats,
    required this.occupiedSeats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.lightTheme.colorScheme.surface,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: CustomIconWidget(
                    iconName: 'airline_seat_recline_normal',
                    color: AppTheme.secondaryLight,
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Seat Preference',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  // Driver section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          'DRIVER',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // Bus layout
                  _buildBusLayout(),
                  SizedBox(height: 2.h),
                  // Legend
                  _buildLegend(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusLayout() {
    return Column(
      children: [
        // Rows 1-2
        _buildSeatRow(['1A', '1B', '', '1C', '1D']),
        SizedBox(height: 1.h),
        _buildSeatRow(['2A', '2B', '', '2C', '2D']),
        SizedBox(height: 1.h),
        // Rows 3-4
        _buildSeatRow(['3A', '3B', '', '3C', '3D']),
        SizedBox(height: 1.h),
        _buildSeatRow(['4A', '4B', '', '4C', '4D']),
        SizedBox(height: 1.h),
        // Rows 5-6
        _buildSeatRow(['5A', '5B', '', '5C', '5D']),
        SizedBox(height: 1.h),
        _buildSeatRow(['6A', '6B', '', '6C', '6D']),
      ],
    );
  }

  Widget _buildSeatRow(List<String> seats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: seats.map((seat) {
        if (seat.isEmpty) {
          return SizedBox(width: 8.w); // Aisle space
        }
        return _buildSeat(seat);
      }).toList(),
    );
  }

  Widget _buildSeat(String seatNumber) {
    final bool isSelected = selectedSeat == seatNumber;
    final bool isOccupied = occupiedSeats.contains(seatNumber);
    final bool isAvailable = availableSeats.contains(seatNumber);

    Color seatColor;
    Color borderColor;

    if (isOccupied) {
      seatColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
      borderColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    } else if (isSelected) {
      seatColor = AppTheme.secondaryLight;
      borderColor = AppTheme.secondaryLight;
    } else if (isAvailable) {
      seatColor = Colors.transparent;
      borderColor = AppTheme.secondaryLight;
    } else {
      seatColor = AppTheme.lightTheme.colorScheme.surfaceContainerHighest;
      borderColor = AppTheme.lightTheme.colorScheme.outline;
    }

    return GestureDetector(
      onTap:
          isAvailable && !isOccupied ? () => onSeatSelected(seatNumber) : null,
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: seatColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Center(
          child: Text(
            seatNumber,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: isSelected || isOccupied
                  ? (isSelected
                      ? AppTheme.lightTheme.colorScheme.onSecondary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant)
                  : AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 8.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Available', AppTheme.secondaryLight, true),
        _buildLegendItem('Selected', AppTheme.secondaryLight, false),
        _buildLegendItem('Occupied',
            AppTheme.lightTheme.colorScheme.onSurfaceVariant, false),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isOutline) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4.w,
          height: 4.w,
          decoration: BoxDecoration(
            color: isOutline ? Colors.transparent : color,
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
