import 'package:flutter/material.dart';

class CustomIconWidget extends StatelessWidget {
  final String iconName;
  final double size;
  final Color? color;

  const CustomIconWidget({
    Key? key,
    required this.iconName,
    this.size = 24,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simplified icon map with only the icons actually used in the app
    final Map<String, IconData> iconMap = {
      // Navigation and UI
      'home': Icons.home,
      'menu': Icons.menu,
      'close': Icons.close,
      'arrow_back': Icons.arrow_back,
      'arrow_forward': Icons.arrow_forward,
      'arrow_forward_ios': Icons.arrow_forward_ios,
      'chevron_right': Icons.chevron_right,
      'chevron_left': Icons.chevron_left,
      'keyboard_arrow_up': Icons.keyboard_arrow_up,
      'keyboard_arrow_down': Icons.keyboard_arrow_down,
      'expand_less': Icons.expand_less,
      'expand_more': Icons.expand_more,
      
      // User and Profile
      'person': Icons.person,
      'account_circle': Icons.account_circle,
      'edit': Icons.edit,
      'logout': Icons.logout,
      'notifications': Icons.notifications,
      'settings': Icons.settings,
      
      // Transportation and Booking
      'directions_bus': Icons.directions_bus,
      'confirmation_number': Icons.confirmation_number,
      'event_seat': Icons.event_seat,
      'airline_seat_recline_normal': Icons.airline_seat_recline_extra,
      'schedule': Icons.schedule,
      'access_time': Icons.access_time,
      'calendar_today': Icons.calendar_today,
      'my_location': Icons.my_location,
      'route': Icons.route,
      'map': Icons.map,
      
      // Actions and Status
      'search': Icons.search,
      'check': Icons.check,
      'star': Icons.star,
      'star_border': Icons.star_border,
      'history': Icons.history,
      'refresh': Icons.refresh,
      'share': Icons.share,
      'download': Icons.download,
      'info': Icons.info,
      'info_outline': Icons.info_outline,
      'warning': Icons.warning,
      'error_outline': Icons.error_outline,
      'error': Icons.error,
      'explore': Icons.explore,
      'sentiment_satisfied': Icons.sentiment_satisfied,
      'location_on': Icons.location_on,
      
      // Communication and Support
      'help': Icons.help,
      'support_agent': Icons.support_agent,
      'send': Icons.send,
      'qr_code': Icons.qr_code,
      'qr_code_2': Icons.qr_code_2,
      'qr_code_scanner': Icons.qr_code_scanner,
      
      // Finance and Wallet
      'account_balance_wallet': Icons.account_balance_wallet,
      'payment': Icons.payment,
      'receipt': Icons.receipt,
      'savings': Icons.savings,
      
      // UI Controls
      'visibility': Icons.visibility,
      'thumb_up': Icons.thumb_up,
      'thumb_down': Icons.thumb_down,
      'content_copy': Icons.content_copy,
      'touch_app': Icons.touch_app,
      'swap_vert': Icons.swap_vert,
      
      // Connectivity and Tech
      'wifi_off': Icons.wifi_off,
      'analytics': Icons.analytics,
      'verified': Icons.verified,
      'diamond': Icons.diamond,
      
      // Misc
      'local_offer': Icons.local_offer,
      'event': Icons.event,
      'window': Icons.window,
      'language': Icons.language,
      'privacy_tip': Icons.privacy_tip,
    };

    // Get the icon from the map or use a fallback
    IconData iconData = iconMap[iconName] ?? Icons.help_outline;

    return Icon(
      iconData,
      size: size,
      color: color,
    );
  }
}