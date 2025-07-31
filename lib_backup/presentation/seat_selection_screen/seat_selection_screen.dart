import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/bus_header_widget.dart';
import './widgets/seat_grid_widget.dart';
import './widgets/seat_info_panel_widget.dart';
import './widgets/seat_legend_widget.dart';
import './widgets/selected_seats_summary_widget.dart';

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({Key? key}) : super(key: key);

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  List<String> _selectedSeats = [];
  String? _tappedSeat;
  Map<String, dynamic>? _tappedSeatInfo;

  // Mock bus details
  final Map<String, dynamic> _busDetails = {
    "busNumber": "GE 203",
    "busType": "AC Sleeper",
    "fromCity": "Douala",
    "toCity": "Yaoundé",
    "departureTime": "08:30 AM",
    "arrivalTime": "02:15 PM",
    "date": "July 20, 2025",
    "duration": "4h 30m",
    "operatorName": "Guarantee Express"
  };

  // Mock seat data with realistic bus layout (70 seats)
  final List<Map<String, dynamic>> _seatData = _generateRealisticBusLayout();

  static List<Map<String, dynamic>> _generateRealisticBusLayout() {
    List<Map<String, dynamic>> seats = [];
    
    // Row 1: Passenger seat (LEFT) + Driver seat (RIGHT)
    seats.add({
      "seatNumber": "1A",
      "status": "available",
      "price": 3500.0,
      "currency": "XFA",
      "isWindow": true,
      "isAisle": false,
      "extraLegroom": true, // Front row extra legroom
      "nearRestroom": false,
      "nearDoor": false,
    });
    
    seats.add({
      "seatNumber": "DRIVER",
      "status": "unavailable", // Driver seat - not selectable
      "price": 0.0,
      "currency": "XFA",
      "isWindow": true,
      "isAisle": false,
      "extraLegroom": false,
      "nearRestroom": false,
      "nearDoor": false,
      "isDriverSeat": true,
    });
    
    // Regular passenger rows (2-15) with door at row 4 (4D,4E positions)
    for (int row = 2; row <= 15; row++) {
      bool isDoorRow = (row == 4); // First door at 4D,4E positions
      
      if (isDoorRow) {
        // Door row 4: Only A, B, C seats (4D and 4E are the door)
        for (String seatLetter in ['A', 'B', 'C']) {
          String status = 'available';
          // Add some random occupied seats
          if (row == 4 && seatLetter == 'B') {
            status = 'occupied';
          }
          
          seats.add({
            "seatNumber": "$row$seatLetter",
            "status": status,
            "price": 3500.0,
            "currency": "XFA",
            "isWindow": seatLetter == 'A',
            "isAisle": seatLetter == 'B' || seatLetter == 'C',
            "extraLegroom": false,
            "nearRestroom": false,
            "nearDoor": true, // Near the first door at 4D,4E
          });
        }
      } else {
        // Regular rows: 3 seats + gap + 2 seats (A,B,C + D,E)
        for (String seatLetter in ['A', 'B', 'C', 'D', 'E']) {
          String status = 'available';
          // Add some random occupied and unavailable seats
          if ((row == 3 && seatLetter == 'B') || 
              (row == 5 && seatLetter == 'D') ||
              (row == 8 && seatLetter == 'A') ||
              (row == 10 && seatLetter == 'C') ||
              (row == 13 && seatLetter == 'E')) {
            status = 'occupied';
          } else if ((row == 4 && seatLetter == 'C') || 
                     (row == 9 && seatLetter == 'E') ||
                     (row == 14 && seatLetter == 'B')) {
            status = 'unavailable';
          }
          
          seats.add({
            "seatNumber": "$row$seatLetter",
            "status": status,
            "price": 3500.0,
            "currency": "XFA",
            "isWindow": seatLetter == 'A' || seatLetter == 'E',
            "isAisle": seatLetter == 'B' || seatLetter == 'D',
            "extraLegroom": row == 2, // Second row extra legroom
            "nearRestroom": row >= 14, // Back rows near restroom
            "nearDoor": false,
          });
        }
      }
    }
    
    return seats;
  }


  void _onSeatTapped(String seatNumber) {
    final seatInfo = _seatData.firstWhere(
      (seat) => seat['seatNumber'] == seatNumber,
      orElse: () => {},
    );

    setState(() {
      _tappedSeat = seatNumber;
      _tappedSeatInfo = seatInfo.isNotEmpty ? seatInfo : null;
    });
  }


  void _onBackPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Bus header with route details
          BusHeaderWidget(
            busDetails: _busDetails,
            onBackPressed: _onBackPressed,
          ),

          // Main content area
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 2.h),

                // Seat legend
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: const SeatLegendWidget(),
                ),

                SizedBox(height: 2.h),

                // Seat grid and info panel
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seat grid
                      Expanded(
                        flex: 3,
                        child: SeatGridWidget(
                          seatData: _seatData,
                          onSeatsSelected: _onSeatsSelected,
                          selectedSeats: _selectedSeats,
                        ),
                      ),

                      // Seat info panel (landscape only)
                      if (MediaQuery.of(context).orientation ==
                          Orientation.landscape) ...[
                        SizedBox(width: 2.w),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 50.h,
                            padding: EdgeInsets.only(right: 4.w),
                            child: SeatInfoPanelWidget(
                              selectedSeat: _tappedSeat,
                              seatInfo: _tappedSeatInfo,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Seat info panel (portrait only)
                if (MediaQuery.of(context).orientation ==
                    Orientation.portrait) ...[
                  SizedBox(height: 2.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: SeatInfoPanelWidget(
                      selectedSeat: _tappedSeat,
                      seatInfo: _tappedSeatInfo,
                    ),
                  ),
                ],

                SizedBox(height: 10.h), // Space for bottom summary
              ],
            ),
          ),
        ],
      ),

      // Bottom summary with selected seats and continue button
      bottomSheet: SelectedSeatsSummaryWidget(
        selectedSeats: _selectedSeats,
        pricePerSeat: 3500.0,
        currency: "XFA",
        onContinue: _onContinue,
      ),
    );
  }

  void _onSeatsSelected(List<String> selectedSeats) {
    setState(() {
      _selectedSeats = selectedSeats;
    });
  }

  void _onContinue() {
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 3.w),
              Text('Please select at least one seat'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.w),
          ),
          margin: EdgeInsets.all(4.w),
        ),
      );
      return;
    }

    // Calculate total amount
    final totalPrice = _selectedSeats.length * 3500.0;
    
    // Prepare booking data to pass to payment screen with correct field names
    final bookingData = {
      // Route information (from _busDetails)
      'from': _busDetails['fromCity'] ?? 'Douala',
      'to': _busDetails['toCity'] ?? 'Yaoundé',
      'busNumber': _busDetails['busNumber'] ?? 'GE 203',
      'busType': _busDetails['busType'] ?? 'AC Sleeper',
      'departureTime': _busDetails['departureTime'] ?? '08:30 AM',
      'arrivalTime': _busDetails['arrivalTime'] ?? '02:15 PM',
      'travelDate': _busDetails['date'] ?? 'July 20, 2025',
      
      // Seat information
      'selectedSeats': _selectedSeats,
      'seatCount': _selectedSeats.length,
      'pricePerSeat': 3500.0,
      'basePrice': 3500.0,
      'totalPrice': totalPrice,
      'currency': 'XFA',
      
      // Additional data
      'addOns': [], // Empty add-ons for now
      'bookingId': 'TE${DateTime.now().millisecondsSinceEpoch}',
      'operatorName': _busDetails['operatorName'] ?? 'Guarantee Express',
    };

    // Navigate to payment screen with booking data
    Navigator.pushNamed(
      context,
      AppRoutes.paymentScreen,
      arguments: bookingData,
    );
  }
}
