import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

/// Ultra-modern floating bottom navigation with advanced animations
class UltraModernNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;

  const UltraModernNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<UltraModernNav> createState() => _UltraModernNavState();
}

class _UltraModernNavState extends State<UltraModernNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _itemControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  late AnimationController _indicatorController;
  late Animation<Offset> _indicatorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialAnimation();
  }

  void _initializeAnimations() {
    // Item animations
    _itemControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    _scaleAnimations = _itemControllers.map(
      (controller) => Tween<double>(
        begin: 0.8,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      )),
    ).toList();

    _fadeAnimations = _itemControllers.map(
      (controller) => Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      )),
    ).toList();

    // Background animation
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

    // Indicator animation
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _indicatorAnimation = Tween<Offset>(
      begin: Offset(widget.currentIndex.toDouble(), 0),
      end: Offset(widget.currentIndex.toDouble(), 0),
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.elasticOut,
    ));
  }

  void _startInitialAnimation() {
    _backgroundController.forward();
    _itemControllers[widget.currentIndex].forward();
    
    // Staggered entrance animation
    for (int i = 0; i < widget.items.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _itemControllers[i].forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(UltraModernNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _updateSelection(oldWidget.currentIndex, widget.currentIndex);
    }
  }

  void _updateSelection(int oldIndex, int newIndex) {
    // Reset old item
    _itemControllers[oldIndex].reverse();
    
    // Animate new item
    _itemControllers[newIndex].forward();
    
    // Animate indicator
    _indicatorAnimation = Tween<Offset>(
      begin: Offset(oldIndex.toDouble(), 0),
      end: Offset(newIndex.toDouble(), 0),
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.elasticOut,
    ));
    
    _indicatorController.reset();
    _indicatorController.forward();
  }

  @override
  void dispose() {
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    _backgroundController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  Color get _backgroundColor => widget.backgroundColor ?? const Color(0xFF1A4A47);
  Color get _activeColor => widget.activeColor ?? const Color(0xFFC8E53F);
  Color get _inactiveColor => widget.inactiveColor ?? Colors.white.withOpacity(0.6);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Floating background
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: _backgroundColor.withOpacity(0.3),
                      blurRadius: 40,
                      offset: const Offset(0, 5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Container(
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
                  ),
                ),
              ),
              
              // Floating indicator
              _buildFloatingIndicator(),
              
              // Navigation items
              Container(
                height: 70,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    widget.items.length,
                    (index) => _buildNavItem(index),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingIndicator() {
    return AnimatedBuilder(
      animation: _indicatorAnimation,
      builder: (context, child) {
        // Calculate more accurate positioning
        final screenWidth = MediaQuery.of(context).size.width;
        final navBarWidth = screenWidth - (12.w); // Account for horizontal margins
        final itemWidth = navBarWidth / widget.items.length;
        final indicatorWidth = itemWidth * 0.6; // Make indicator smaller
        final indicatorPosition = (_indicatorAnimation.value.dx * itemWidth) + 
                                  (itemWidth - indicatorWidth) / 2 + 6.w; // Center it within each item
        
        return Positioned(
          left: indicatorPosition,
          top: 10, // Position it higher in the navigation bar
          child: Container(
            width: indicatorWidth,
            height: 45, // Reduced height
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _activeColor.withOpacity(0.2),
                  _activeColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(22.5),
              border: Border.all(
                color: _activeColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index) {
    final item = widget.items[index];
    final isSelected = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimations[index],
            _fadeAnimations[index],
          ]),
          builder: (context, child) {
            return Container(
              height: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with scale animation - removed extra circle container
                  Transform.scale(
                    scale: isSelected ? _scaleAnimations[index].value : 1.0,
                    child: CustomIconWidget(
                      iconName: item.iconName,
                      color: isSelected ? _activeColor : _inactiveColor,
                      size: isSelected ? 24 : 20,
                    ),
                  ),
                  
                  SizedBox(height: 4),
                  
                  // Label with fade animation
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isSelected ? 1.0 : 0.7,
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? _activeColor : _inactiveColor,
                        fontSize: isSelected ? 10.sp : 9.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onItemTap(int index) {
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }
}

/// Navigation item model
class NavItem {
  final String iconName;
  final String label;

  const NavItem({
    required this.iconName,
    required this.label,
  });
}

/// Predefined navigation items
class NavItems {
  static const home = NavItem(iconName: 'home', label: 'Home');
  static const bookings = NavItem(iconName: 'confirmation_number', label: 'Trips');
  static const profile = NavItem(iconName: 'person', label: 'Profile');
  static const search = NavItem(iconName: 'search', label: 'Search');
  static const favorites = NavItem(iconName: 'favorite', label: 'Saved');
}