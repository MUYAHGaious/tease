import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class BottomNavigationWidget extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': 'home',
      'activeIcon': 'home',
      'label': 'Home',
      'route': '/home-dashboard',
    },
    {
      'icon': 'search',
      'activeIcon': 'search',
      'label': 'Search',
      'route': '/search-booking',
    },
    {
      'icon': 'confirmation_number_outlined',
      'activeIcon': 'confirmation_number',
      'label': 'Tickets',
      'route': '/my-tickets',
    },
    {
      'icon': 'person_outline',
      'activeIcon': 'person',
      'label': 'Profile',
      'route': '/profile',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      _navItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _fadeAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    if (widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(BottomNavigationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      if (oldWidget.currentIndex < _animationControllers.length) {
        _animationControllers[oldWidget.currentIndex].reverse();
      }
      if (widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildNavItem(Map<String, dynamic> item, int index) {
    final bool isSelected = widget.currentIndex == index;

    return AnimatedBuilder(
      animation: _animationControllers[index],
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onTap(index);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Transform.scale(
                    scale: _scaleAnimations[index].value,
                    child: FadeTransition(
                      opacity: _fadeAnimations[index],
                      child: CustomIconWidget(
                        iconName:
                            isSelected ? item['activeIcon'] : item['icon'],
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        size: 6.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1.w),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ) ??
                      const TextStyle(),
                  child: Text(
                    item['label'],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: EdgeInsets.only(top: 1.w),
                    width: 4.w,
                    height: 0.5.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 5.w,
              vertical: 2.w,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _navItems.asMap().entries.map((entry) {
                  return Expanded(
                    child: _buildNavItem(entry.value, entry.key),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}