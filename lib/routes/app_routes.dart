import 'package:flutter/material.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/seat_selection/seat_selection.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/search_booking/search_booking.dart';
import '../presentation/booking_confirmation/booking_confirmation.dart';
import '../presentation/school_bus_home/premium_home_screen.dart';
import '../presentation/parent_dashboardSchoolbus/parent_dashboard.dart';
import '../presentation/bus_booking_formSchoolbus/bus_booking_form.dart';
import '../presentation/qr_code_displaySchoolbus/qr_code_display.dart';
import '../presentation/my_tickets/my_tickets.dart';
import '../presentation/passenger_details/passenger_details.dart';
import '../presentation/payment_gateway/payment_gateway.dart';
import '../presentation/profile_settings/profile_settings.dart';
import '../presentation/admin_route_managementSchoolbus/admin_route_management.dart';
import '../presentation/booking_historySchoolbus/booking_history.dart';
import '../presentation/driver_boarding_interfaceSchoolbus/driver_boarding_interface.dart';

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
  static const String bookingHistory = '/booking-history';
  static const String myTickets = '/my-tickets';
  static const String passengerDetails = '/passenger-details';
  static const String paymentGateway = '/payment-gateway';
  static const String profileSettings = '/profile-settings';
  static const String adminRouteManagement = '/admin-route-management';
  static const String adminDashboard = '/admin-dashboard';
  static const String schoolBusBooking = '/school-bus-booking';
  static const String bookingHistorySchoolbus = '/booking-history-schoolbus';
  static const String driverBoardingInterface = '/driver-boarding-interface';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(), // Back to original
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
    bookingHistory: (context) => const BookingHistory(),
    myTickets: (context) => const MyTickets(),
    passengerDetails: (context) => const PassengerDetails(),
    paymentGateway: (context) => const PaymentGateway(),
    profileSettings: (context) => const ProfileSettings(),
    adminRouteManagement: (context) => const AdminRouteManagement(),
    adminDashboard: (context) => const AdminRouteManagement(), // Using admin route management as admin dashboard
    schoolBusBooking: (context) => const PremiumHomeScreen(), // Using premium home for school bus booking
    bookingHistorySchoolbus: (context) => const BookingHistory(),
    driverBoardingInterface: (context) => const DriverBoardingInterface(),
    // TODO: Add your other routes here
  };
}
