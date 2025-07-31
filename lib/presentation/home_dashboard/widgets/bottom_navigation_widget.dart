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
  final int cartBadgeCount;

  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartBadgeCount = 0,
  });

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget>
    with TickerProviderStateMixin {
  late AnimationController _centerButtonController;
  late Animation<double> _centerButtonAnimation;

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.home,
      'label': 'Home',
      'route': '/home-dashboard',
    },
    {
      'icon': Icons.favorite_border,
      'label': 'Favorites',
      'route': '/favorites',
    },
    {
      'icon': null, // Center button placeholder
      'label': 'Book',
      'route': '/search-booking',
    },
    {
      'icon': Icons.shopping_bag_outlined,
      'label': 'Tickets',
      'route': '/my-tickets',
    },
    {
      'icon': Icons.menu,
      'label': 'Menu',
      'route': '/menu',
    },
  ];

  @override
  void initState() {
    super.initState();
    _centerButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _centerButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _centerButtonController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _centerButtonController.dispose();
    super.dispose();
  }

  Widget _buildNavItem(Map<String, dynamic> item, int index) {
    final bool isSelected = widget.currentIndex == index;
    
    // Center button (index 2)
    if (index == 2) {
      return _buildCenterButton();
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Icon(
          item['icon'],
          color: isSelected ? Colors.orange : Colors.grey[400],
          size: 7.w,
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTapDown: (_) {
        _centerButtonController.forward();
      },
      onTapUp: (_) {
        _centerButtonController.reverse();
      },
      onTapCancel: () {
        _centerButtonController.reverse();
      },
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap(2);
      },
      child: AnimatedBuilder(
        animation: _centerButtonAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _centerButtonAnimation.value,
            child: Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 7.w,
                  ),
                  if (widget.cartBadgeCount > 0)
                    Positioned(
                      top: 2.w,
                      right: 2.w,
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 4.w,
                          minHeight: 4.w,
                        ),
                        child: Text(
                          widget.cartBadgeCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.h,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _navItems.asMap().entries.map((entry) {
              return _buildNavItem(entry.value, entry.key);
            }).toList(),
          ),
        ),
      ),
    );
  }
}