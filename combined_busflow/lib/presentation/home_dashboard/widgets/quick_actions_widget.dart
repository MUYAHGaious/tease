import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

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

  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Book Now',
      'icon': 'add_circle_outline',
      'route': '/search-booking',
      'color': Color(0xFF1a4d3a),
      'gradient': [Color(0xFF1a4d3a), Color(0xFF2d5a3d)],
    },
    {
      'title': 'My Tickets',
      'icon': 'confirmation_number_outlined',
      'route': '/my-tickets',
      'color': Color(0xFFf4d03f),
      'gradient': [Color(0xFFf4d03f), Color(0xFFf1c40f)],
    },
    {
      'title': 'Trip History',
      'icon': 'history',
      'route': '/trip-history',
      'color': Color(0xFF2d5a3d),
      'gradient': [Color(0xFF2d5a3d), Color(0xFF1a4d3a)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      _quickActions.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + (index * 200)),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.elasticOut,
        ),
      );
    }).toList();

    _fadeAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ),
      );
    }).toList();

    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _animationControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildActionCard(Map<String, dynamic> action, int index) {
    return AnimatedBuilder(
      animation: _animationControllers[index],
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimations[index],
          child: ScaleTransition(
            scale: _scaleAnimations[index],
            child: GestureDetector(
              onTap: () => widget.onActionTap(action['route']),
              onTapDown: (_) {
                _animationControllers[index].reverse().then((_) {
                  if (mounted) {
                    _animationControllers[index].forward();
                  }
                });
              },
              child: Container(
                height: 20.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: (action['gradient'] as List<Color>)
                        .map((color) => color.withValues(alpha: 0.9))
                        .toList(),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (action['color'] as Color).withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.1),
                                Colors.white.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CustomIconWidget(
                                iconName: action['icon'],
                                color: Colors.white,
                                size: 8.w,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              action['title'],
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Text(
            'Quick Actions',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 20.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            scrollDirection: Axis.horizontal,
            itemCount: _quickActions.length,
            separatorBuilder: (context, index) => SizedBox(width: 4.w),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 40.w,
                child: _buildActionCard(_quickActions[index], index),
              );
            },
          ),
        ),
      ],
    );
  }
}
