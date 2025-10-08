import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/theme_notifier.dart';
import '../booking_confirmation/widgets/professional_success_widget.dart';

class PaymentSuccess extends StatefulWidget {
  const PaymentSuccess({Key? key}) : super(key: key);

  @override
  State<PaymentSuccess> createState() => _PaymentSuccessState();
}

class _PaymentSuccessState extends State<PaymentSuccess> {
  // Theme-aware colors
  Color get primaryColor => const Color(0xFF008B8B);
  Color get backgroundColor =>
      ThemeNotifier().isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

  Map<String, dynamic> _bookingData = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get booking data from arguments
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _bookingData = arguments ?? _getDefaultBookingData();
  }

  Map<String, dynamic> _getDefaultBookingData() {
    return {
      "bookingId":
          "BF${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
      "fromCity": "Douala",
      "toCity": "Yaoundé",
      "date": "July 28, 2025",
      "departureTime": "09:30 AM",
      "arrivalTime": "01:45 PM",
      "selectedSeats": ["3", "4"],
      "totalPrice": "7,700 XAF",
      "passengers": [
        {"name": "John Doe", "age": 32, "gender": "Male"},
        {"name": "Jane Smith", "age": 28, "gender": "Female"},
      ],
      "priceBreakdown": {
        "Base Fare": "7,500 XAF",
        "Convenience Fee": "200 XAF",
        "Service Tax": "0 XAF",
        "GST": "0 XAF",
        "Platform Fee": "0 XAF",
      },
    };
  }

  void _onSuccessAnimationComplete() {
    // Navigate to home dashboard after success animation
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home-dashboard',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: ProfessionalSuccessWidget(
        onContinue: _onSuccessAnimationComplete,
        bookingData: _bookingData,
      ),
    );
  }
}
