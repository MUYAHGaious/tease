import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/booking_header_widget.dart';
import './widgets/booking_reference_widget.dart';
import './widgets/download_options_widget.dart';
import './widgets/journey_details_card_widget.dart';
import './widgets/notification_settings_widget.dart';
import './widgets/qr_code_widget.dart';
import './widgets/travel_info_widget.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  Map<String, dynamic> bookingData = {};
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookingData();
    });
  }

  void _loadBookingData() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        bookingData = args;
        _dataLoaded = true;
      });
    } else {
      // Fallback data for Cameroon
      setState(() {
        bookingData = {
          "referenceNumber": "TE2025071920",
          "fromCity": "Douala",
          "toCity": "Yaoundé",
          "travelDate": "July 25, 2025",
          "departureTime": "08:30 AM",
          "arrivalTime": "02:15 PM",
          "busNumber": "GE 203",
          "busType": "AC Sleeper",
          "operatorName": "Guarantee Express",
          "seatNumbers": ["3A", "2E", "4A", "3E"],
          "passengers": [
            {"name": "Jean Mbeki", "age": 32, "gender": "Male"},
            {"name": "Marie Ateba", "age": 28, "gender": "Female"},
            {"name": "Paul Nkomo", "age": 25, "gender": "Male"},
            {"name": "Grace Fotso", "age": 30, "gender": "Female"}
          ],
          "baseFare": "XFA 14,000",
          "taxes": "XFA 1,680",
          "addOns": "XFA 0",
          "totalAmount": "XFA 15,680",
          "qrCode": "TE2025071920_QR_DATA"
        };
        _dataLoaded = true;
      });
    }
  }

  final Map<String, dynamic> travelInfo = {
    "reportingTime": "08:00 AM (30 minutes before departure)",
    "boardingPoint": "Douala Central Bus Station, Boulevard de la Liberté, Douala",
    "droppingPoint": "Yaoundé Mvog-Ada Terminal, Rue 1.750, Yaoundé",
    "baggageAllowance": "2 bags up to 23 kg each included",
    "cancellationPolicy": "Free cancellation up to 2 hours before departure. 50% refund thereafter."
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, 
            AppRoutes.homeScreen, 
            (route) => false
          ),
          icon: CustomIconWidget(
            iconName: 'home',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
        ),
        title: Text(
          'Booking Confirmed',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: !_dataLoaded 
        ? Center(
            child: CircularProgressIndicator(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          )
        : Column(
            children: [
              const BookingHeaderWidget(),
              Expanded(
                child: Container(
                  color: AppTheme.lightTheme.scaffoldBackgroundColor,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),
                        BookingReferenceWidget(
                          referenceNumber: bookingData['referenceNumber'] as String? ?? 'TE${DateTime.now().millisecondsSinceEpoch}',
                        ),
                        JourneyDetailsCardWidget(
                          bookingDetails: bookingData,
                        ),
                        QrCodeWidget(
                          qrData: bookingData['qrCode'] as String? ?? 'TE${DateTime.now().millisecondsSinceEpoch}_QR',
                        ),
                        DownloadOptionsWidget(
                          bookingData: bookingData,
                        ),
                        TravelInfoWidget(
                          travelInfo: travelInfo,
                        ),
                        const NotificationSettingsWidget(),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
              ),
              const ActionButtonsWidget(),
            ],
          ),
    );
  }
}
