import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/app_state.dart';
import '../../../theme/app_theme.dart';
import '../../../services/role_ui_service.dart';

// 2025 Design Constants
const Color primaryColor = Color(0xFF008B8B);
const double headerPadding = 16.0;

class GreetingHeaderWidget extends StatefulWidget {
  const GreetingHeaderWidget({super.key});

  @override
  State<GreetingHeaderWidget> createState() => _GreetingHeaderWidgetState();
}

class _GreetingHeaderWidgetState extends State<GreetingHeaderWidget> {
  int _currentTipIndex = 0;

  // Role-based tips
  List<Map<String, dynamic>> _getRoleTips() {
    final appState = AppState();
    final user = appState.currentUser;

    if (user != null) {
      switch (user.role) {
        case 'conductor':
        case 'driver':
          return [
            {
              'icon': Icons.qr_code_scanner,
              'tip': 'Scan tickets efficiently for quick boarding',
              'color': Colors.blue,
            },
            {
              'icon': Icons.bus_alert,
              'tip': 'Update bus status regularly',
              'color': Colors.orange,
            },
            {
              'icon': Icons.emergency,
              'tip': 'Emergency button is always available',
              'color': Colors.red,
            },
          ];
        case 'booking_clerk':
        case 'schedule_manager':
          return [
            {
              'icon': Icons.analytics,
              'tip': 'Check daily reports for insights',
              'color': Colors.purple,
            },
            {
              'icon': Icons.airline_seat_recline_normal,
              'tip': 'Monitor seat availability closely',
              'color': primaryColor,
            },
            {
              'icon': Icons.schedule,
              'tip': 'Optimize routes for better efficiency',
              'color': Colors.blue,
            },
          ];
        default:
          if (user.canAccessSchoolBus) {
            return [
              {
                'icon': Icons.school,
                'tip': 'Book campus shuttle in advance',
                'color': primaryColor,
              },
              {
                'icon': Icons.schedule,
                'tip': 'Check university bus schedules',
                'color': Colors.blue,
              },
              {
                'icon': Icons.favorite,
                'tip': 'Save your regular campus routes',
                'color': Colors.red,
              },
            ];
          }
      }
    }

    // Default tips for regular users
    return [
      {
        'icon': Icons.flash_on,
        'tip': 'Tap Quick Book for instant reservations',
        'color': Colors.orange,
      },
      {
        'icon': Icons.favorite,
        'tip': 'Save frequent routes to Favorites',
        'color': Colors.red,
      },
      {
        'icon': Icons.schedule,
        'tip': 'Check real-time schedules and delays',
        'color': Colors.blue,
      },
      {
        'icon': Icons.qr_code,
        'tip': 'Show QR tickets for contactless boarding',
        'color': primaryColor,
      },
    ];
  }

  String _getGreeting() {
    final appState = AppState();
    final user = appState.currentUser;

    if (user != null) {
      return RoleUIService.getRoleGreeting(user);
    }

    final hour = DateTime.now().hour;
    const userName = 'Guest';

    if (hour < 12) {
      return 'Good Morning, $userName!';
    } else if (hour < 17) {
      return 'Good Afternoon, $userName!';
    } else {
      return 'Good Evening, $userName!';
    }
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return Icons.wb_sunny; // Morning - sunny
    } else if (hour < 17) {
      return Icons.wb_cloudy; // Afternoon - cloudy
    } else {
      return Icons.nights_stay; // Evening - moon
    }
  }

  @override
  void initState() {
    super.initState();
    _startSimpleTipRotation();
  }

  void _startSimpleTipRotation() {
    // Simple, clean tip rotation without complex animations
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          final tips = _getRoleTips();
          _currentTipIndex = (_currentTipIndex + 1) % tips.length;
        });
      } else {
        timer.cancel();
      }
    });
  }

  // Simple tap handler for menu drawer
  void _openDrawer(BuildContext context) {
    HapticFeedback.selectionClick();
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: 5.w, vertical: 1.h), // Reduced from 2.h to 1.h
      child: Column(
        children: [
          // Clean header row - 2025 style
          Row(
            children: [
              // Modern avatar with clean design
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getGreetingIcon(),
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 4.w),

              // Greeting text with modern typography
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      'Where would you like to go?',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Clean menu button
              GestureDetector(
                onTap: () => _openDrawer(context),
                child: Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.menu,
                    color: primaryColor,
                    size: 5.w,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h), // Reduced from 2.h to 1.h

          // Modern tips section - clean and simple
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(_currentTipIndex),
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: 4.w, vertical: 1.h), // Reduced from 1.5.h to 1.h
              decoration: BoxDecoration(
                color:
                    _getRoleTips()[_currentTipIndex]['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getRoleTips()[_currentTipIndex]['color']
                      .withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: _getRoleTips()[_currentTipIndex]['color'],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getRoleTips()[_currentTipIndex]['icon'],
                      color: Colors.white,
                      size: 4.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      _getRoleTips()[_currentTipIndex]['tip'],
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface, // Same color as greeting message
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.lightbulb_outline,
                    color: _getRoleTips()[_currentTipIndex]['color']
                        .withOpacity(0.7),
                    size: 4.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
