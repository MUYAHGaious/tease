import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4D3E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.airline_seat_recline_normal,
                    color: const Color(0xFF1B4D3E),
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Seat Selection',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF1B4D3E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            // Legend
            Row(
              children: [
                _buildLegendItem('Available', const Color(0xFF4CAF50)),
                SizedBox(width: 4.w),
                _buildLegendItem('Occupied', Colors.grey),
                SizedBox(width: 4.w),
                _buildLegendItem('Selected', const Color(0xFF1B4D3E)),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            // Seat Grid
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  // Driver area indicator
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.drive_eta,
                          size: 4.w,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Driver',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Seat rows
                  ...List.generate(6, (rowIndex) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSeat('${rowIndex + 1}A'),
                          _buildSeat('${rowIndex + 1}B'),
                          SizedBox(width: 4.w), // Aisle
                          _buildSeat('${rowIndex + 1}C'),
                          _buildSeat('${rowIndex + 1}D'),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            if (selectedSeat != null) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF4CAF50),
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Selected Seat: $selectedSeat',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5.w),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSeat(String seatNumber) {
    final isOccupied = occupiedSeats.contains(seatNumber);
    final isSelected = selectedSeat == seatNumber;
    final isAvailable = availableSeats.contains(seatNumber) && !isOccupied;

    Color seatColor;
    if (isSelected) {
      seatColor = const Color(0xFF1B4D3E);
    } else if (isOccupied) {
      seatColor = Colors.grey;
    } else if (isAvailable) {
      seatColor = const Color(0xFF4CAF50);
    } else {
      seatColor = Colors.grey;
    }

    return GestureDetector(
      onTap: isAvailable && !isOccupied ? () => onSeatSelected(seatNumber) : null,
      child: Container(
        width: 12.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: seatColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: seatColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            seatNumber,
            style: TextStyle(
              fontSize: 11.sp,
              color: seatColor,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}