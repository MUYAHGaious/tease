import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';

/// Global Bottom Navigation Widget following 2025 Material Design guidelines
///
/// Features:
/// - Persistent across all screens
/// - State preservation using IndexedStack
/// - Glassmorphism design matching app theme
/// - Consistent color scheme (Medium Turquoise)
/// - Optimized for thumb navigation zone
/// - 5 main navigation destinations
class GlobalBottomNavigation extends StatefulWidget {
  final int initialIndex;

  const GlobalBottomNavigation({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<GlobalBottomNavigation> createState() => _GlobalBottomNavigationState();
}

class _GlobalBottomNavigationState extends State<GlobalBottomNavigation>
    with AutomaticKeepAliveClientMixin {
  late int _currentIndex;
  final PageController _pageController = PageController();

  // Main navigation destinations - following Material Design 3-5 tab rule
  final List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icons.confirmation_num_outlined,
      selectedIcon: Icons.confirmation_num,
      label: 'My Tickets',
    ),
    NavigationDestination(
      icon: Icons.favorite_outline,
      selectedIcon: Icons.favorite,
      label: 'Favorites',
    ),
    NavigationDestination(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  // Route mapping for each tab
  final List<String> _routes = [
    '/home-dashboard',
    '/search-booking',
    '/my-tickets',
    '/favorites',
    '/profile-settings',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    // Haptic feedback for better UX (2025 best practice)
    HapticFeedback.selectionClick();

    setState(() {
      _currentIndex = index;
    });

    // Navigate to respective route using pushNamed to maintain navigation stack
    Navigator.pushNamed(context, _routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      decoration: BoxDecoration(
        // Using exact Medium Turquoise color from my_tickets screen
        color: const Color(0xFF008B8B),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 10.h, // Thumb-friendly height
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_destinations.length, (index) {
                final destination = _destinations[index];
                final isSelected = index == _currentIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabTapped(index),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon with smooth transition
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isSelected
                                  ? destination.selectedIcon
                                  : destination.icon,
                              key: ValueKey(isSelected),
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.7),
                              size: isSelected ? 24 : 22,
                            ),
                          ),

                          SizedBox(height: 0.3.h),

                          // Label with smooth fade
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isSelected ? 1.0 : 0.7,
                            child: Text(
                              destination.label,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSelected ? 10.sp : 9.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// Navigation destination model following Material Design 3
class NavigationDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Helper method to get current route index
int getCurrentRouteIndex(String routeName) {
  switch (routeName) {
    case '/home-dashboard':
      return 0;
    case '/search-booking':
      return 1;
    case '/my-tickets':
      return 2;
    case '/favorites':
      return 3;
    case '/profile-settings':
      return 4;
    default:
      return 0;
  }
}
