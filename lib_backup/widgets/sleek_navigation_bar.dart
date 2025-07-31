import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';

class SleekNavigationBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackTap;

  const SleekNavigationBar({
    Key? key,
    this.onMenuTap,
    this.onNotificationTap,
    this.title = 'Tease',
    this.showBackButton = false,
    this.onBackTap,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 20);

  @override
  State<SleekNavigationBar> createState() => _SleekNavigationBarState();
}

class _SleekNavigationBarState extends State<SleekNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isMenuHovered = false;
  bool _isNotificationHovered = false;
  bool _isLogoHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntranceAnimation();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  void _startEntranceAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _slideController.forward();
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A4A47),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
              ),
            ),
            child: SafeArea(
            bottom: false,
            child: Container(
              height: widget.preferredSize.height,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              child: Row(
                children: [
                  // Left Action Button
                  _buildActionButton(
                    icon: widget.showBackButton ? Icons.arrow_back_ios : Icons.menu,
                    isHovered: _isMenuHovered,
                    onHoverChange: (hover) => setState(() => _isMenuHovered = hover),
                    onTap: widget.showBackButton ? widget.onBackTap : widget.onMenuTap,
                  ),
                  
                  Spacer(),
                  
                  // Right Action Button
                  _buildActionButton(
                    icon: Icons.notifications_outlined,
                    isHovered: _isNotificationHovered,
                    onHoverChange: (hover) => setState(() => _isNotificationHovered = hover),
                    onTap: widget.onNotificationTap,
                    showBadge: true,
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required bool isHovered,
    required ValueChanged<bool> onHoverChange,
    VoidCallback? onTap,
    bool showBadge = false,
  }) {
    return MouseRegion(
      onEnter: (_) => onHoverChange(true),
      onExit: (_) => onHoverChange(false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            gradient: isHovered 
                ? LinearGradient(
                    colors: [
                      const Color(0xFFC8E53F).withOpacity(0.2),
                      const Color(0xFFC8E53F).withOpacity(0.1),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered 
                  ? const Color(0xFFC8E53F).withOpacity(0.4)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: isHovered ? [
              BoxShadow(
                color: const Color(0xFFC8E53F).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 150),
                scale: isHovered ? 1.05 : 1.0,
                child: Icon(
                  icon,
                  color: isHovered ? const Color(0xFFC8E53F) : Colors.white.withOpacity(0.9),
                  size: 6.w,
                ),
              ),
              if (showBadge)
                Positioned(
                  top: -1,
                  right: -1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 3.w,
                    height: 3.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFC8E53F),
                          const Color(0xFFA3C635),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC8E53F).withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isLogoHovered = true),
      onExit: (_) => setState(() => _isLogoHovered = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          // Navigate to home or refresh
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            gradient: _isLogoHovered
                ? LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isLogoHovered 
                  ? const Color(0xFFC8E53F).withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: _isLogoHovered ? [
              BoxShadow(
                color: const Color(0xFFC8E53F).withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedRotation(
                duration: const Duration(milliseconds: 400),
                turns: _isLogoHovered ? 0.02 : 0,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFC8E53F),
                        const Color(0xFFA3C635),
                        const Color(0xFF1A4A47).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFC8E53F).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC8E53F).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'directions_bus',
                      color: const Color(0xFF1A4A47),
                      size: 6.w,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _isLogoHovered ? 22.sp : 20.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFC8E53F).withOpacity(0.6),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(widget.title),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom sticky navigation bar that stays at top
class StickyNavigationBar extends StatelessWidget {
  final Widget child;
  final SleekNavigationBar navigationBar;

  const StickyNavigationBar({
    Key? key,
    required this.child,
    required this.navigationBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              minHeight: navigationBar.preferredSize.height,
              maxHeight: navigationBar.preferredSize.height,
              child: navigationBar,
            ),
          ),
          SliverFillRemaining(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}