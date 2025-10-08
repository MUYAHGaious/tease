import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/multi_step_signup_screen.dart';
import '../presentation/auth/welcome_screen.dart';
import '../presentation/auth/hi_screen.dart';
import '../presentation/auth/auth_demo_screen.dart';
import '../presentation/auth/forgot_password_screen.dart';
import '../presentation/auth/affiliation_selection_screen.dart';
import '../presentation/seat_selection/redesigned_seat_selection.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/search_booking/search_booking.dart';
import '../presentation/school_bus_home/premium_home_screen.dart';
import '../presentation/bus_booking_formSchoolbus/bus_booking_form.dart';
import '../presentation/qr_code_displaySchoolbus/qr_code_display.dart';
import '../presentation/my_tickets/my_tickets.dart';
import '../presentation/passenger_details/passenger_details.dart';
import '../presentation/payment_gateway/payment_gateway.dart';
import '../presentation/payment_success/payment_success.dart';
import '../presentation/profile_settings/profile_settings.dart';
import '../presentation/admin_route_managementSchoolbus/admin_route_management.dart';
import '../presentation/booking_historySchoolbus/booking_history.dart';
import '../presentation/driver_boarding_interfaceSchoolbus/driver_boarding_interface.dart';
import '../presentation/parent_dashboardSchoolbus/parent_dashboard.dart';
import '../presentation/favorites/favorites.dart';
import '../presentation/ticket_booking/ticket_booking_screen.dart';
import '../presentation/bus_tracking_map/safe_bus_tracking_screen.dart';
import '../presentation/booking_management/booking_management.dart';
import '../presentation/booking_management/widgets/seat_booking_summary_screen.dart';
import '../presentation/auth/agency_selection_screen.dart';
import '../presentation/auth/role_selection_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String welcome = '/welcome';
  static const String hiScreen = '/hi';
  static const String authDemo = '/auth-demo';
  static const String forgotPassword = '/forgot-password';
  static const String affiliationSelection = '/affiliation-selection';
  static const String agencySelection = '/agency-selection';
  static const String roleSelection = '/role-selection';
  static const String home = '/home';
  static const String seatSelection = '/seat-selection';
  static const String homeDashboard = '/home-dashboard';
  static const String searchBooking = '/search-booking';
  static const String schoolBusHome = '/school-bus-home';
  static const String busBookingForm = '/bus-booking-form';
  static const String qrCodeDisplay = '/qr-code-display';
  static const String bookingHistory = '/booking-history';
  static const String myTickets = '/my-tickets';
  static const String passengerDetails = '/passenger-details';
  static const String paymentGateway = '/payment-gateway';
  static const String paymentSuccess = '/payment-success';
  static const String profileSettings = '/profile-settings';
  static const String adminRouteManagement = '/admin-route-management';
  static const String adminDashboard = '/admin-dashboard';
  static const String schoolBusBooking = '/school-bus-booking';
  static const String bookingHistorySchoolbus = '/booking-history-schoolbus';
  static const String driverBoardingInterface = '/driver-boarding-interface';
  static const String driverBoardingInterfaceSchoolbus =
      '/driver-boarding-interfaceSchoolbus';
  static const String parentDashboard = '/parent-dashboard';
  static const String conductorDashboard = '/conductor-dashboard';
  static const String bookingClerkDashboard = '/booking-clerk-dashboard';
  static const String bookingManagement = '/booking-management';
  static const String seatBookingSummary = '/seat-booking-summary';
  static const String qrCodeDisplaySchoolbus = '/qr-code-display-schoolbus';
  static const String voiceAi = '/voice-ai';
  static const String favorites = '/favorites';
  static const String ticketBooking = '/ticket-booking';
  static const String busTrackingMap = '/bus-tracking-map';
  static const String popularRoutes = '/popular-routes';
  static const String schoolDashboard = '/school-dashboard';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    login: (context) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return LoginScreen(
        email: arguments?['email'],
        name: arguments?['name'],
      );
    },
    signup: (context) {
      final arguments = ModalRoute.of(context)?.settings.arguments as String?;
      return MultiStepSignupScreen(email: arguments);
    },
    welcome: (context) => const WelcomeScreen(),
    home: (context) => const HomeDashboard(),
    hiScreen: (context) => const HiScreen(),
    authDemo: (context) => const AuthDemoScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    affiliationSelection: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return AffiliationSelectionScreen(
        startAffiliation: args != null ? args['affiliation'] as String? : null,
        startStep: args != null ? args['step'] as int? : null,
      );
    },
    agencySelection: (context) => const AgencySelectionScreen(),
    roleSelection: (context) {
      final selectedAgency =
          ModalRoute.of(context)?.settings.arguments as String;
      return RoleSelectionScreen(selectedAgency: selectedAgency);
    },
    seatSelection: (context) => const RedesignedSeatSelection(),
    homeDashboard: (context) => const HomeDashboard(),
    searchBooking: (context) => const SearchBooking(),
    schoolBusHome: (context) => const PremiumHomeScreen(),
    busBookingForm: (context) => const BusBookingForm(),
    qrCodeDisplay: (context) => const QrCodeDisplay(),
    bookingHistory: (context) => const BookingHistory(),
    myTickets: (context) => const MyTickets(),
    passengerDetails: (context) => const PassengerDetails(),
    paymentGateway: (context) => const PaymentGateway(),
    '/payment-success': (context) => const PaymentSuccess(),
    profileSettings: (context) => const ProfileSettings(),
    adminRouteManagement: (context) => const AdminRouteManagement(),
    adminDashboard: (context) =>
        const AdminRouteManagement(), // Using admin route management as admin dashboard
    schoolBusBooking: (context) =>
        const PremiumHomeScreen(), // Using premium home for school bus booking
    bookingHistorySchoolbus: (context) => const BookingHistory(),
    driverBoardingInterface: (context) => const DriverBoardingInterface(),
    driverBoardingInterfaceSchoolbus: (context) =>
        const DriverBoardingInterface(), // Same interface for school bus
    parentDashboard: (context) => const ParentDashboard(),
    conductorDashboard: (context) =>
        const MyTickets(), // Placeholder - conductor can see tickets
    bookingClerkDashboard: (context) =>
        const BookingManagement(), // Booking management for clerks
    bookingManagement: (context) =>
        const BookingManagement(), // Booking management screen
    '/seat-booking-summary': (context) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return SeatBookingSummaryScreen(
        seat: arguments?['seat'] ?? {},
        busInfo: arguments?['busInfo'] ?? {},
        routeInfo: arguments?['routeInfo'] ?? {},
      );
    },
    qrCodeDisplaySchoolbus: (context) =>
        const QrCodeDisplay(), // School bus QR display
    voiceAi: (context) =>
        const HomeDashboard(), // Placeholder - Voice AI coming soon
    favorites: (context) => const Favorites(),
    ticketBooking: (context) => const TicketBookingScreen(),
    busTrackingMap: (context) => const SafeBusTrackingScreen(),
    popularRoutes: (context) =>
        const SearchBooking(), // Use SearchBooking for popular routes
    schoolDashboard: (context) =>
        const PremiumHomeScreen(), // University home screen
    // TODO: Add your other routes here
  };
}
