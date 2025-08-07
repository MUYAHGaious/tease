import 'package:flutter/material.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/signup_screen.dart';
import '../presentation/seat_selection/seat_selection.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/search_booking/search_booking.dart';
import '../presentation/booking_confirmation/booking_confirmation.dart';
import '../presentation/school_bus_home/premium_home_screen.dart';
import '../presentation/bus_booking_formSchoolbus/bus_booking_form.dart';
import '../presentation/qr_code_displaySchoolbus/qr_code_display.dart';
import '../presentation/my_tickets/my_tickets.dart';
import '../presentation/passenger_details/passenger_details.dart';
import '../presentation/payment_gateway/payment_gateway.dart';
import '../presentation/profile_settings/profile_settings.dart';
import '../presentation/admin_route_managementSchoolbus/admin_route_management.dart';
import '../presentation/booking_historySchoolbus/booking_history.dart';
import '../presentation/driver_boarding_interfaceSchoolbus/driver_boarding_interface.dart';
import '../presentation/favorites/favorites.dart';
import '../presentation/ticket_booking/ticket_booking_screen.dart';
import '../presentation/bus_tracking_map/safe_bus_tracking_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String onboardingFlow = '/onboarding-flow';
  static const String seatSelection = '/seat-selection';
  static const String homeDashboard = '/home-dashboard';
  static const String searchBooking = '/search-booking';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String schoolBusHome = '/school-bus-home';
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
  static const String favorites = '/favorites';
  static const String ticketBooking = '/ticket-booking';
  static const String busTrackingMap = '/bus-tracking-map';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    seatSelection: (context) => const SeatSelection(),
    homeDashboard: (context) => const HomeDashboard(),
    searchBooking: (context) => const SearchBooking(),
    bookingConfirmation: (context) => const BookingConfirmation(),
    schoolBusHome: (context) => const PremiumHomeScreen(),
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
    favorites: (context) => const Favorites(),
    ticketBooking: (context) => const TicketBookingScreen(),
    busTrackingMap: (context) => const SafeBusTrackingScreen(),
    // TODO: Add your other routes here
  };
}
