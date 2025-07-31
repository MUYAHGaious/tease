import 'package:flutter/material.dart';
import '../presentation/seat_selection_screen/seat_selection_screen.dart';
import '../presentation/booking_confirmation_screen/booking_confirmation_screen.dart';
import '../presentation/my_bookings_screen/my_bookings_screen.dart';
import '../presentation/booking_details_screen/booking_details_screen.dart';
import '../presentation/payment_screen/payment_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/splash_screen/premium_splash_screen.dart';
import '../presentation/profile/profile.dart';
import '../presentation/location_permission_onboarding/location_permission_onboarding.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/bus_search_results/bus_search_results.dart';
import '../presentation/location_picker/location_picker.dart';
import '../presentation/onboarding/onboarding_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/wallet_screen/wallet_screen.dart';
import '../presentation/offers_screen/offers_screen.dart';
import '../presentation/trip_history_screen/trip_history_screen.dart';
import '../presentation/customer_support_screen/customer_support_screen.dart';
import '../presentation/help_faq_screen/help_faq_screen.dart';
import '../presentation/school_bus_dashboard/school_bus_dashboard.dart';
import '../presentation/school_bus_booking_form/school_bus_booking_form.dart';
import '../presentation/school_bus_qr_display/school_bus_qr_display.dart';
import '../presentation/school_bus_booking_history/school_bus_booking_history.dart';

class AppRoutes {
  static const String splashScreen = '/splash-screen';
  static const String homeScreen = '/';
  static const String locationPermissionOnboarding = '/location-permission-onboarding';
  static const String locationPicker = '/location-picker';
  static const String busSearchResults = '/bus-search-results';
  static const String seatSelectionScreen = '/seat-selection-screen';
  static const String bookingConfirmationScreen = '/booking-confirmation-screen';
  static const String myBookingsScreen = '/my-bookings-screen';
  static const String bookingDetailsScreen = '/booking-details-screen';
  static const String paymentScreen = '/payment-screen';
  static const String profile = '/profile';
  static const String onboardingScreen = '/onboarding-screen';
  static const String settingsScreen = '/settings-screen';
  static const String walletScreen = '/wallet-screen';
  static const String offersScreen = '/offers';
  static const String historyScreen = '/history';
  static const String supportScreen = '/support';
  static const String helpScreen = '/help';
  
  // School Bus Routes
  static const String schoolBusDashboard = '/school-bus-dashboard';
  static const String schoolBusBookingForm = '/school-bus-booking-form';
  static const String schoolBusQrDisplay = '/school-bus-qr-display';
  static const String schoolBusBookingHistory = '/school-bus-booking-history';

  static Map<String, WidgetBuilder> routes = {
    splashScreen: (context) => const PremiumSplashScreen(),
    homeScreen: (context) => const HomeScreen(),
    locationPermissionOnboarding: (context) => const LocationPermissionOnboarding(),
    locationPicker: (context) => const LocationPicker(),
    busSearchResults: (context) => const BusSearchResults(),
    seatSelectionScreen: (context) => const SeatSelectionScreen(),
    bookingConfirmationScreen: (context) => const BookingConfirmationScreen(),
    myBookingsScreen: (context) => const MyBookingsScreen(),
    bookingDetailsScreen: (context) => const BookingDetailsScreen(),
    paymentScreen: (context) => const PaymentScreen(),
    profile: (context) => const Profile(),
    onboardingScreen: (context) => const OnboardingScreen(),
    settingsScreen: (context) => const SettingsScreen(),
    walletScreen: (context) => const WalletScreen(),
    offersScreen: (context) => const OffersScreen(),
    historyScreen: (context) => const TripHistoryScreen(),
    supportScreen: (context) => const CustomerSupportScreen(),
    helpScreen: (context) => const HelpFaqScreen(),
    
    // School Bus Routes
    schoolBusDashboard: (context) => const SchoolBusDashboard(),
    schoolBusBookingForm: (context) => const SchoolBusBookingForm(),
    schoolBusQrDisplay: (context) => const SchoolBusQrDisplay(),
    schoolBusBookingHistory: (context) => const SchoolBusBookingHistory(),
  };
}
