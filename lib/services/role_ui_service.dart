import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../models/user_model.dart';

// 2025 Design Constants
const Color primaryColor = Color(0xFF008B8B);
const double cardBorderRadius = 16.0;

class RoleUIService {
  // Get role-based navigation items for drawer
  static List<Map<String, dynamic>> getNavigationItems(UserModel user) {
    List<Map<String, dynamic>> items = [];

    // Main Services (available to all)
    items.addAll([
      {
        'category': 'Main Services',
        'items': [
          {
            'title': 'Home',
            'icon': Icons.home_rounded,
            'route': '/home-dashboard',
            'badge': null,
          },
          {
            'title': 'Book Ticket',
            'icon': Icons.confirmation_num_outlined,
            'route': '/search-booking',
            'badge': null,
          },
          {
            'title': 'Track Buses',
            'icon': Icons.location_on_outlined,
            'route': '/bus-tracking-map',
            'badge': 'Live',
          },
          {
            'title': 'My Tickets',
            'icon': Icons.receipt_long_outlined,
            'route': '/my-tickets',
            'badge': null,
          },
        ],
      },
    ]);

    // University Services (for university-affiliated users)
    if (user.isUniversityAffiliated && user.canAccessSchoolBus) {
      items.add({
        'category': 'University Services',
        'items': [
          {
            'title': 'School Bus',
            'icon': Icons.school_outlined,
            'route': '/school-bus-home',
            'badge': user.position == 'student' ? 'Student' : 'Staff',
          },
          {
            'title': 'Campus Routes',
            'icon': Icons.map_outlined,
            'route': '/campus-routes',
            'badge': null,
          },
          {
            'title': 'Schedule',
            'icon': Icons.schedule_outlined,
            'route': '/campus-schedule',
            'badge': null,
          },
        ],
      });
    }

    // Work Tools (for agency-affiliated users)
    if (user.isAgencyAffiliated || user.canScanTickets || user.canManageSeats) {
      List<Map<String, dynamic>> workTools = [];

      if (user.canScanTickets) {
        workTools.addAll([
          {
            'title': 'Scan Tickets',
            'icon': Icons.qr_code_scanner_rounded,
            'route': '/ticket-scanner',
            'badge': 'Live',
          },
          {
            'title': 'Bus Status',
            'icon': Icons.directions_bus_outlined,
            'route': '/bus-status',
            'badge': null,
          },
          {
            'title': 'Passenger List',
            'icon': Icons.people_outline_rounded,
            'route': '/passenger-list',
            'badge': null,
          },
        ]);
      }

      if (user.canManageSeats) {
        workTools.addAll([
          {
            'title': 'Seat Management',
            'icon': Icons.airline_seat_recline_normal_outlined,
            'route': '/seat-management',
            'badge': null,
          },
          {
            'title': 'Bookings',
            'icon': Icons.book_online_outlined,
            'route': '/booking-management',
            'badge': null,
          },
          {
            'title': 'Routes',
            'icon': Icons.route_outlined,
            'route': '/route-management',
            'badge': null,
          },
          {
            'title': 'Reports',
            'icon': Icons.analytics_outlined,
            'route': '/reports',
            'badge': null,
          },
        ]);
      }

      if (workTools.isNotEmpty) {
        items.add({
          'category': 'Work Tools',
          'items': workTools,
        });
      }
    }

    // Personal (available to regular users)
    if (user.isOrdinaryUser || (!user.canScanTickets && !user.canManageSeats)) {
      items.add({
        'category': 'Personal',
        'items': [
          {
            'title': 'Favorites',
            'icon': Icons.favorite_outline_rounded,
            'route': '/favorites',
            'badge': null,
          },
          {
            'title': 'Booking History',
            'icon': Icons.history_rounded,
            'route': '/booking-history',
            'badge': null,
          },
          {
            'title': 'Payment Methods',
            'icon': Icons.payment_rounded,
            'route': '/payment-methods',
            'badge': null,
          },
        ],
      });
    }

    // Get Access (for role elevation)
    if (!user.pinVerified || user.role == 'ordinary_user') {
      items.add({
        'category': 'Get Access',
        'items': [
          {
            'title': 'Join University',
            'icon': Icons.school_rounded,
            'route': '/university-access',
            'badge': 'PIN',
          },
          {
            'title': 'Agency Portal',
            'icon': Icons.work_outline_rounded,
            'route': '/agency-access',
            'badge': 'PIN',
          },
        ],
      });
    }

    return items;
  }

  // Get role-based quick actions
  static List<Map<String, dynamic>> getQuickActions(UserModel user) {
    switch (user.role) {
      case 'conductor':
      case 'driver':
        return [
          {
            'title': 'Scan Tickets',
            'icon': 'qr_code_scanner',
            'route': '/ticket-scanner',
            'color': primaryColor,
            'subtitle': 'Check passengers',
          },
          {
            'title': 'Bus Status',
            'icon': 'directions_bus',
            'route': '/bus-status',
            'color': Colors.blue,
            'subtitle': 'Update status',
          },
          {
            'title': 'Emergency',
            'icon': 'emergency',
            'route': '/emergency',
            'color': Colors.red,
            'subtitle': 'Emergency call',
          },
          {
            'title': 'Passenger List',
            'icon': 'people',
            'route': '/passenger-list',
            'color': Colors.green,
            'subtitle': 'View passengers',
          },
        ];

      case 'booking_clerk':
      case 'schedule_manager':
        return [
          {
            'title': 'Manage Seats',
            'icon': 'airline_seat_recline_normal',
            'route': '/seat-management',
            'color': primaryColor,
            'subtitle': 'Seat control',
          },
          {
            'title': 'Bookings',
            'icon': 'book_online',
            'route': '/booking-management',
            'color': Colors.orange,
            'subtitle': 'Manage bookings',
          },
          {
            'title': 'Routes',
            'icon': 'route',
            'route': '/route-management',
            'color': Colors.blue,
            'subtitle': 'Route planning',
          },
          {
            'title': 'Reports',
            'icon': 'analytics',
            'route': '/reports',
            'color': Colors.purple,
            'subtitle': 'View analytics',
          },
        ];

      default:
        if (user.canAccessSchoolBus) {
          return [
            {
              'title': 'Book Ticket',
              'icon': 'add_circle_outline',
              'route': '/search-booking',
              'color': Colors.orange,
              'subtitle': 'Quick booking',
            },
            {
              'title': 'School Bus',
              'icon': 'school',
              'route': '/school-bus-home',
              'color': primaryColor,
              'subtitle': 'Campus transport',
            },
            {
              'title': 'Track Buses',
              'icon': 'location_on',
              'route': '/bus-tracking-map',
              'color': Colors.blue,
              'subtitle': 'Live tracking',
            },
            {
              'title': 'My Tickets',
              'icon': 'confirmation_number_outlined',
              'route': '/my-tickets',
              'color': Colors.green,
              'subtitle': 'Active trips',
            },
          ];
        }
        return [
          {
            'title': 'Book Ticket',
            'icon': 'add_circle_outline',
            'route': '/search-booking',
            'color': Colors.orange,
            'subtitle': 'Quick booking',
          },
          {
            'title': 'Search Buses',
            'icon': 'search',
            'route': '/search-booking',
            'color': primaryColor,
            'subtitle': 'Find routes',
          },
          {
            'title': 'Track Buses',
            'icon': 'location_on',
            'route': '/bus-tracking-map',
            'color': Colors.blue,
            'subtitle': 'Live tracking',
          },
          {
            'title': 'My Tickets',
            'icon': 'confirmation_number_outlined',
            'route': '/my-tickets',
            'color': Colors.green,
            'subtitle': 'Active trips',
          },
        ];
    }
  }

  // Get role-based greeting message
  static String getRoleGreeting(UserModel user) {
    final hour = DateTime.now().hour;
    String timeGreeting;

    if (hour < 12) {
      timeGreeting = 'Good Morning';
    } else if (hour < 17) {
      timeGreeting = 'Good Afternoon';
    } else {
      timeGreeting = 'Good Evening';
    }

    switch (user.role) {
      case 'conductor':
        return '$timeGreeting, Conductor ${user.firstName}';
      case 'driver':
        return '$timeGreeting, Driver ${user.firstName}';
      case 'booking_clerk':
        return '$timeGreeting, ${user.firstName}';
      case 'schedule_manager':
        return '$timeGreeting, Manager ${user.firstName}';
      default:
        if (user.isUniversityAffiliated) {
          final title = user.position == 'student' ? 'Student' : 'Professor';
          return '$timeGreeting, $title ${user.firstName}';
        }
        return '$timeGreeting, ${user.firstName}';
    }
  }

  // Get role-based tip/message
  static String getRoleTip(UserModel user) {
    switch (user.role) {
      case 'conductor':
      case 'driver':
        return 'Remember to scan all tickets and update bus status regularly.';
      case 'booking_clerk':
      case 'schedule_manager':
        return 'Check today\'s bookings and manage seat availability.';
      default:
        if (user.canAccessSchoolBus) {
          return 'Book your campus shuttle in advance to secure your seat.';
        }
        return 'Book early to get the best seats and prices for your journey.';
    }
  }

  // Get role badge widget
  static Widget? getRoleBadge(UserModel user) {
    if (user.role == 'ordinary_user' && !user.isUniversityAffiliated) {
      return null;
    }

    String badgeText;
    Color badgeColor;

    switch (user.role) {
      case 'conductor':
        badgeText = 'CONDUCTOR';
        badgeColor = Colors.blue;
        break;
      case 'driver':
        badgeText = 'DRIVER';
        badgeColor = Colors.green;
        break;
      case 'booking_clerk':
        badgeText = 'BOOKING CLERK';
        badgeColor = Colors.orange;
        break;
      case 'schedule_manager':
        badgeText = 'MANAGER';
        badgeColor = Colors.purple;
        break;
      default:
        if (user.isUniversityAffiliated) {
          badgeText = user.position == 'student' ? 'STUDENT' : 'STAFF';
          badgeColor = primaryColor;
        } else {
          return null;
        }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 8.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Check if feature should be visible for user
  static bool shouldShowFeature(UserModel user, String feature) {
    switch (feature) {
      case 'school_bus':
        return user.canAccessSchoolBus;
      case 'ticket_scanner':
        return user.canScanTickets;
      case 'seat_management':
        return user.canManageSeats;
      case 'bus_status':
        return user.canChangeBusStatus;
      case 'booking_history':
        return user.isOrdinaryUser || !user.canScanTickets;
      case 'favorites':
        return user.isOrdinaryUser || !user.canScanTickets;
      case 'emergency':
        return user.canScanTickets;
      case 'reports':
        return user.canManageSeats;
      default:
        return true;
    }
  }

  // Get role-specific colors
  static Color getRoleColor(UserModel user) {
    switch (user.role) {
      case 'conductor':
        return Colors.blue;
      case 'driver':
        return Colors.green;
      case 'booking_clerk':
        return Colors.orange;
      case 'schedule_manager':
        return Colors.purple;
      default:
        return primaryColor;
    }
  }
}
