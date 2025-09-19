import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

// 2025 Design Constants
const Color primaryColor = Color(0xFF20B2AA);
const double cardBorderRadius = 16.0;

class QuickActionsWidget extends StatefulWidget {
  final Function(String) onActionTap;

  const QuickActionsWidget({
    super.key,
    required this.onActionTap,
  });

  @override
  State<QuickActionsWidget> createState() => _QuickActionsWidgetState();
}

class _QuickActionsWidgetState extends State<QuickActionsWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;

  // Simple 2025 Quick Actions - Original colors, no gradients
  final List<Map<String, dynamic>> _quickActions = [
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

  @override
  void initState() {
    super.initState();
    // Simplified - no complex animations for 2025 design
    _animationControllers = List.generate(
      _quickActions.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    _fadeAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.0).animate(controller);
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Modern 2025 Action Card - Clean design, no gradients
  Widget _buildActionCard(Map<String, dynamic> action, int index) {
    return AnimatedBuilder(
      animation: _animationControllers[index],
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimations[index],
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(cardBorderRadius),
              border: Border.all(
                color: AppTheme.onSurfaceLight.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.onSurfaceLight.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onActionTap(action['route']);
                },
                onTapDown: (_) => _animationControllers[index].forward(),
                onTapUp: (_) => _animationControllers[index].reverse(),
                onTapCancel: () => _animationControllers[index].reverse(),
                borderRadius: BorderRadius.circular(cardBorderRadius),
                child: Padding(
                  padding: EdgeInsets.all(3.w), // Reduced from 4.w to 3.w
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Modern icon container
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: action['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomIconWidget(
                          iconName: action['icon'],
                          color: action['color'],
                          size: 6.w,
                        ),
                      ),
                      SizedBox(height: 1.h), // Reduced from 2.h to 1.h
                      // Title with modern typography
                      Text(
                        action['title'],
                        style: TextStyle(
                          color: AppTheme.onSurfaceLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      // Subtitle
                      Text(
                        action['subtitle'],
                        style: TextStyle(
                          color: AppTheme.onSurfaceLight.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                          fontSize: 9.sp,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern section header
        Container(
          margin: EdgeInsets.only(left: 5.w, right: 5.w),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              color: AppTheme.onSurfaceLight,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // Modern grid layout - 2x2 instead of horizontal scroll
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.3, // Increased from 1.1 to make cards shorter
              crossAxisSpacing: 3.w, // Reduced from 4.w
              mainAxisSpacing: 1.h, // Reduced from 2.h
            ),
            itemCount: _quickActions.length,
            itemBuilder: (context, index) {
              return _buildActionCard(_quickActions[index], index);
            },
          ),
        ),
      ],
    );
  }
}
