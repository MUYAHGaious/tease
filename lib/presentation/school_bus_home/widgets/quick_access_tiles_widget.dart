import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/theme_notifier.dart';
import '../../../core/app_export.dart';

class QuickAccessTilesWidget extends StatefulWidget {
  const QuickAccessTilesWidget({super.key});

  @override
  State<QuickAccessTilesWidget> createState() => _QuickAccessTilesWidgetState();
}

class _QuickAccessTilesWidgetState extends State<QuickAccessTilesWidget> {
  // Theme-aware colors that prevent glitching
  Color get primaryColor => const Color(0xFF008B8B);
  Color get backgroundColor => ThemeNotifier().isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get textColor => ThemeNotifier().isDarkMode ? Colors.white : Colors.black87;
  Color get surfaceColor => ThemeNotifier().isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get onSurfaceColor => ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54;

  late final List<Map<String, dynamic>> _quickAccessTiles;

  @override
  void initState() {
    super.initState();
    _quickAccessTiles = [
    {
      'title': 'My Bookings',
      'icon': Icons.bookmark,
      'color': primaryColor,
      'route': AppRoutes.bookingHistory,
    },
    {
      'title': 'Live Tracking',
      'icon': Icons.gps_fixed,
      'color': Colors.green,
      'route': null,
    },
    {
      'title': 'Wallet Balance',
      'icon': Icons.account_balance_wallet,
      'color': Colors.orange,
      'route': null,
    },
    {
      'title': 'Customer Support',
      'icon': Icons.support_agent,
      'color': Colors.blue,
      'route': null,
    },
  ];
    ThemeNotifier().addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: primaryColor,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 2.8,
            ),
            itemCount: _quickAccessTiles.length,
            itemBuilder: (context, index) {
              return _buildAccessTile(_quickAccessTiles[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccessTile(Map<String, dynamic> tile, int index) {
    return GestureDetector(
      onTap: () => _handleTileAction(tile, index),
      child: Container(
        padding: EdgeInsets.all(3.5.w),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(4.w),
          boxShadow: [
            BoxShadow(
              color: tile['color'].withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: tile['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(2.5.w),
              ),
              child: Icon(
                tile['icon'],
                color: tile['color'],
                size: 5.w,
              ),
            ),
            SizedBox(width: 2.5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tile['title'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  _buildTileSubtitle(tile, index),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileSubtitle(Map<String, dynamic> tile, int index) {
    String subtitle;
    Color subtitleColor = onSurfaceColor;

    switch (index) {
      case 0: // My Bookings
        subtitle = '3 active bookings';
        break;
      case 1: // Live Tracking
        subtitle = 'Track in real-time';
        subtitleColor = Colors.green;
        break;
      case 2: // Wallet Balance
        subtitle = 'Balance not required';
        subtitleColor = Colors.orange;
        break;
      case 3: // Customer Support
        subtitle = '24/7 available';
        break;
      default:
        subtitle = 'Tap to access';
    }

    return Text(
      subtitle,
      style: TextStyle(
        fontSize: 10.sp,
        color: subtitleColor,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  void _handleTileAction(Map<String, dynamic> tile, int index) {
    switch (index) {
      case 0: // My Bookings
        Navigator.pushNamed(context, AppRoutes.bookingHistory);
        break;
      case 1: // Live Tracking
        _showLiveTrackingDialog();
        break;
      case 2: // Wallet Balance
        _showWalletDialog();
        break;
      case 3: // Customer Support
        _showSupportDialog();
        break;
    }
  }

  void _showLiveTrackingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Tracking'),
        content: const Text(
          'Live tracking feature will be available soon. You\'ll be able to track your bus in real-time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showWalletDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wallet Balance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Column(
                children: [
                  Text(
                    'Free',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Add Money'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('History'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customer Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Need help? Contact us:'),
            SizedBox(height: 2.h),
            _buildSupportOption(Icons.phone, 'Call: +237 6 12 34 56 78'),
            SizedBox(height: 1.h),
            _buildSupportOption(Icons.email, 'Email: support@schoolbuspro.com'),
            SizedBox(height: 1.h),
            _buildSupportOption(Icons.chat, 'Live Chat: Available 24/7'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 5.w),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}