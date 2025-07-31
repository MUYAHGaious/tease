import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ICTUniversityNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool showBadge;

  const ICTUniversityNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.showBadge = false,
  }) : super(key: key);

  @override
  State<ICTUniversityNav> createState() => _ICTUniversityNavState();
}

class _ICTUniversityNavState extends State<ICTUniversityNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  final List<ICTNavItem> _navItems = [
    ICTNavItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      description: 'Student Hub',
    ),
    ICTNavItem(
      icon: Icons.directions_bus_rounded,
      label: 'Book Ride',
      description: 'Schedule Trip',
    ),
    ICTNavItem(
      icon: Icons.qr_code_scanner_rounded,
      label: 'My Ticket',
      description: 'Active Pass',
    ),
    ICTNavItem(
      icon: Icons.history_rounded,
      label: 'History',
      description: 'Past Trips',
    ),
    ICTNavItem(
      icon: Icons.school_rounded,
      label: 'ICT Hub',
      description: 'University',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      _navItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _animations = _controllers.map(
      (controller) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      )),
    ).toList();

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeOutCubic,
    ));

    // Start initial animation
    _backgroundController.forward();
    _controllers[widget.currentIndex].forward();

    // Staggered entrance animation
    for (int i = 0; i < _navItems.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(ICTUniversityNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _updateSelection(oldWidget.currentIndex, widget.currentIndex);
    }
  }

  void _updateSelection(int oldIndex, int newIndex) {
    _controllers[oldIndex].reverse();
    _controllers[newIndex].forward();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1B4D3E), // ICT University Dark Green
                Color(0xFF2D5A47), // Secondary Green
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B4D3E).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 5),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 8.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _navItems.length,
                  (index) => _buildNavItem(index),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = widget.currentIndex == index;

    return Expanded(
      child: AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          return GestureDetector(
            onTap: () => _onItemTap(index),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 8.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with scale and glow animation
                  Transform.scale(
                    scale: isSelected 
                        ? 1.0 + (_animations[index].value * 0.2)
                        : 1.0,
                    child: Container(
                      padding: EdgeInsets.all(isSelected ? 2.w : 1.5.w),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFFFFD700).withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFFFFD700).withOpacity(0.4),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected 
                                ? const Color(0xFFFFD700)
                                : Colors.white.withOpacity(0.7),
                            size: isSelected ? 6.w : 5.w,
                          ),
                          // Badge for notifications
                          if (index == 0 && widget.showBadge)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 2.w,
                                height: 2.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF44336),
                                  borderRadius: BorderRadius.circular(1.w),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 0.5.h),
                  
                  // Label with fade animation
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isSelected ? 1.0 : 0.8,
                    child: Column(
                      children: [
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected 
                                ? const Color(0xFFFFD700)
                                : Colors.white.withOpacity(0.9),
                            fontSize: isSelected ? 9.sp : 8.sp,
                            fontWeight: isSelected 
                                ? FontWeight.w700 
                                : FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isSelected) ...[
                          Text(
                            item.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 7.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
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

  void _onItemTap(int index) {
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }
}

class ICTNavItem {
  final IconData icon;
  final String label;
  final String description;

  const ICTNavItem({
    required this.icon,
    required this.label,
    required this.description,
  });
}