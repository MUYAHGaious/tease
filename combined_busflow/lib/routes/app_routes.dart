import 'package:flutter/material.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/seat_selection/seat_selection.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/search_booking/search_booking.dart';
import '../presentation/booking_confirmation/booking_confirmation.dart';
import '../presentation/school_bus_home/premium_home_screen.dart';
import '../presentation/parent_dashboard/parent_dashboard.dart';
import '../presentation/bus_booking_form/bus_booking_form.dart';
import '../presentation/qr_code_display/qr_code_display.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String onboardingFlow = '/onboarding-flow';
  static const String splashScreen = '/splash-screen';
  static const String seatSelection = '/seat-selection';
  static const String homeDashboard = '/home-dashboard';
  static const String searchBooking = '/search-booking';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String schoolBusHome = '/school-bus-home';
  static const String parentDashboard = '/parent-dashboard';
  static const String busBookingForm = '/bus-booking-form';
  static const String qrCodeDisplay = '/qr-code-display';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    splashScreen: (context) => const SplashScreen(),
    seatSelection: (context) => const SeatSelection(),
    homeDashboard: (context) => const HomeDashboard(),
    searchBooking: (context) => const SearchBooking(),
    bookingConfirmation: (context) => const BookingConfirmation(),
    schoolBusHome: (context) => const PremiumHomeScreen(),
    parentDashboard: (context) => const ParentDashboard(),
    busBookingForm: (context) => const BusBookingForm(),
    qrCodeDisplay: (context) => const QrCodeDisplay(),
    // TODO: Add your other routes here
  };
}
