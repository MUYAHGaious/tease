import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/booking_header_widget.dart';
import './widgets/bus_details_widget.dart';
import './widgets/customer_support_widget.dart';
import './widgets/download_options_widget.dart';
import './widgets/journey_status_widget.dart';
import './widgets/modification_options_widget.dart';
import './widgets/passenger_information_widget.dart';
import './widgets/pricing_breakdown_widget.dart';
import './widgets/qr_ticket_widget.dart';
import './widgets/route_information_widget.dart';

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  // Mock booking data
  final Map<String, dynamic> bookingData = {
    "bookingReference": "TE2025071920",
    "status": "booked",
    "departureTime": DateTime(2025, 7, 20, 8, 30),
    "arrivalTime": DateTime(2025, 7, 20, 13, 0),
    "route": {
      "from": "Douala",
      "to": "Yaoundé",
      "stops": [
        {
          "name": "Douala Central Station",
          "address": "Akwa, Douala, Cameroon",
          "time": "08:30 AM",
          "duration": null,
        },
        {
          "name": "Edéa Junction",
          "address": "Edéa, Sanaga-Maritime, Cameroon",
          "time": "09:45 AM",
          "duration": "1h 15min",
        },
        {
          "name": "Eséka Bus Stop",
          "address": "Eséka, Nyong-et-Kéllé, Cameroon",
          "time": "10:30 AM",
          "duration": "45min",
        },
        {
          "name": "Mbalmayo Terminal",
          "address": "Mbalmayo, Nyong-et-So'o, Cameroon",
          "time": "11:45 AM",
          "duration": "1h 15min",
        },
        {
          "name": "Yaoundé Central Station",
          "address": "Centre-ville, Yaoundé, Cameroon",
          "time": "13:00 PM",
          "duration": "1h 15min",
        },
      ],
    },
    "bus": {
      "busNumber": "GE 203",
      "operator": "Guarantee Express",
      "busType": "AC Sleeper",
      "totalSeats": 45,
      "amenities": [
        "WiFi",
        "AC",
        "USB Charging",
        "Entertainment",
        "Refreshments",
        "Blanket",
        "Reading Light",
        "Reclining Seats"
      ],
    },
    "passengers": [
      {
        "name": "Jean Mbarga",
        "age": 32,
        "gender": "Male",
        "seatNumber": "A12",
        "idNumber": "ID123456789",
        "phone": "+237 6XX XXX XXX",
      },
      {
        "name": "Marie Ngono",
        "age": 28,
        "gender": "Female",
        "seatNumber": "A13",
        "idNumber": "ID987654321",
        "phone": "+237 6XX XXX XXX",
      },
    ],
    "pricing": {
      "items": [
        {
          "name": "Bus Tickets (2x)",
          "description": "Douala to Yaoundé",
          "price": "XFA 7,000",
        },
        {
          "name": "Extra Baggage",
          "description": "2 additional bags",
          "price": "XFA 2,000",
        },
        {
          "name": "Seat Selection",
          "description": "Premium seats A12, A13",
          "price": "XFA 1,500",
        },
        {
          "name": "Travel Insurance",
          "description": "Trip protection coverage",
          "price": "XFA 1,000",
        },
      ],
      "subtotal": "XFA 11,500",
      "taxes": "XFA 1,150",
      "discount": "-XFA 650",
      "total": "XFA 12,000",
    },
    "qrData": "BG2025071920-JOHN-SMITH-A12-A13",
  };

  bool _canModifyBooking = true;

  @override
  void initState() {
    super.initState();
    _checkModificationEligibility();
  }

  void _checkModificationEligibility() {
    final DateTime departureTime = bookingData['departureTime'] as DateTime;
    final DateTime now = DateTime.now();
    final Duration timeUntilDeparture = departureTime.difference(now);

    setState(() {
      _canModifyBooking = timeUntilDeparture.inHours > 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          BookingHeaderWidget(
            bookingReference: bookingData['bookingReference'] as String,
            onBackPressed: () => Navigator.pop(context),
            onSharePressed: _shareBooking,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  JourneyStatusWidget(
                    currentStatus: bookingData['status'] as String,
                    departureTime: bookingData['departureTime'] as DateTime,
                    arrivalTime: bookingData['arrivalTime'] as DateTime,
                  ),
                  RouteInformationWidget(
                    routeData: bookingData['route'] as Map<String, dynamic>,
                  ),
                  BusDetailsWidget(
                    busData: bookingData['bus'] as Map<String, dynamic>,
                  ),
                  PassengerInformationWidget(
                    passengers: (bookingData['passengers'] as List)
                        .cast<Map<String, dynamic>>(),
                  ),
                  PricingBreakdownWidget(
                    pricingData: bookingData['pricing'] as Map<String, dynamic>,
                  ),
                  QrTicketWidget(
                    qrData: bookingData['qrData'] as String,
                    onViewFullScreen: _showFullScreenQR,
                  ),
                  DownloadOptionsWidget(
                    onDownloadPdf: _downloadPdfTicket,
                    onAddToWallet: _addToWallet,
                    onEmailTicket: _emailTicket,
                  ),
                  ModificationOptionsWidget(
                    onChangeSeats: _changeSeats,
                    onAddBaggage: _addBaggage,
                    onCancelBooking: _cancelBooking,
                    canModify: _canModifyBooking,
                  ),
                  CustomerSupportWidget(
                    onChatSupport: _startLiveChat,
                    onCallSupport: _callSupport,
                    onEmailSupport: _emailSupport,
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareBooking() {
    final String bookingRef = bookingData['bookingReference'] as String;
    final String shareText =
        'My BusGo booking: $bookingRef\nDouala to Yaoundé\nDeparture: ${_formatDateTime(bookingData['departureTime'] as DateTime)}';

    Clipboard.setData(ClipboardData(text: shareText));
    Fluttertoast.showToast(
      msg: "Booking details copied to clipboard",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showFullScreenQR() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Digital Ticket',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 6.w,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'qr_code_2',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 50.w,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  bookingData['bookingReference'] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Show this QR code to the conductor',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _downloadPdfTicket() {
    Fluttertoast.showToast(
      msg: "PDF ticket downloaded successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _addToWallet() {
    Fluttertoast.showToast(
      msg: "Ticket added to wallet",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _emailTicket() {
    Fluttertoast.showToast(
      msg: "Ticket details sent to your email",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _changeSeats() {
    Navigator.pushNamed(context, '/seat-selection-screen');
  }

  void _addBaggage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Extra Baggage',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add extra baggage to your booking for XFA 1,000 per bag.',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              Text(
                'Current baggage: 2 bags',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Baggage added successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
              child: Text('Add Baggage'),
            ),
          ],
        );
      },
    );
  }

  void _cancelBooking() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cancel Booking',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.errorLight,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel this booking?',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.errorLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cancellation Policy:',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorLight,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '• 50% refund if cancelled 24+ hours before departure\n• 25% refund if cancelled 2-24 hours before\n• No refund if cancelled within 2 hours',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.errorLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Keep Booking'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my-bookings-screen');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorLight,
              ),
              child: Text('Cancel Booking'),
            ),
          ],
        );
      },
    );
  }

  void _startLiveChat() {
    Fluttertoast.showToast(
      msg: "Starting live chat with support...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _callSupport() {
    Fluttertoast.showToast(
      msg: "Calling support: +237-XXX-XXX-XXX",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _emailSupport() {
    Fluttertoast.showToast(
      msg: "Opening email to support@busgo.cm",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
