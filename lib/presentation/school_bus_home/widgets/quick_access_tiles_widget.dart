import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickAccessTilesWidget extends StatefulWidget {
  const QuickAccessTilesWidget({super.key});

  @override
  State<QuickAccessTilesWidget> createState() => _QuickAccessTilesWidgetState();
}

class _QuickAccessTilesWidgetState extends State<QuickAccessTilesWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late List<Animation<double>> _bounceAnimations;

  final List<Map<String, dynamic>> _quickAccessTiles = [
    {
      'title': 'My Bookings',
      'icon': Icons.bookmark,
      'color': AppTheme.primaryLight,
      'route': AppRoutes.bookingHistory,
    },
    {
      'title': 'Live Tracking',
      'icon': Icons.gps_fixed,
      'color': AppTheme.successLight,
      'route': null,
    },
    {
      'title': 'Wallet Balance',
      'icon': Icons.account_balance_wallet,
      'color': AppTheme.secondaryLight,
      'route': null,
    },
    {
      'title': 'Customer Support',
      'icon': Icons.support_agent,
      'color': AppTheme.warningLight,
      'route': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _bounceAnimations = List.generate(
      _quickAccessTiles.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _bounceController,
          curve: Interval(
            index * 0.15,
            0.6 + (index * 0.15),
            curve: Curves.bounceOut,
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _bounceController.forward();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
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
              mainAxisSpacing: 3.h,
              childAspectRatio: 1.8,
            ),
            itemCount: _quickAccessTiles.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _bounceAnimations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bounceAnimations[index].value,
                    child: _buildAccessTile(_quickAccessTiles[index], index),
                  );
                },
              );
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
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.w),
          boxShadow: [
            BoxShadow(
              color: tile['color'].withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: tile['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Icon(
                tile['icon'],
                color: tile['color'],
                size: 6.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tile['title'],
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryLight,
                        ),
                    maxLines: 2,
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
    Color subtitleColor = AppTheme.neutralLight;

    switch (index) {
      case 0: // My Bookings
        subtitle = '3 active bookings';
        break;
      case 1: // Live Tracking
        subtitle = 'Track in real-time';
        subtitleColor = AppTheme.successLight;
        break;
      case 2: // Wallet Balance
        subtitle = 'Balance not required';
        subtitleColor = AppTheme.secondaryLight;
        break;
      case 3: // Customer Support
        subtitle = '24/7 available';
        break;
      default:
        subtitle = 'Tap to access';
    }

    return Text(
      subtitle,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: subtitleColor,
            fontWeight: FontWeight.w500,
          ),
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
                color: AppTheme.secondaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Column(
                children: [
                  Text(
                    'Free',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.secondaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    'Available Balance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.neutralLight,
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
        Icon(icon, color: AppTheme.primaryLight, size: 5.w),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
