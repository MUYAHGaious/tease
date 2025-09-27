import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

const primaryGradient = LinearGradient(
  colors: [Color(0xFF008B8B), Color(0xFF008B8B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final List<IconData> icons = const [
    Icons.home,
    Icons.favorite,
    Icons.confirmation_num,
    Icons.person,
  ];

  final List<String> labels = const ["Home", "Favorites", "Tickets", "Profile"];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF008B8B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: BottomAppBar(
            height: 70, // Fixed height to prevent overflow
            color: const Color(0xFF008B8B).withOpacity(0.8),
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(icons.length, (index) {
                  final isSelected = currentIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTap(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: isSelected
                              ? Colors.white.withOpacity(0.15)
                              : Colors.transparent,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icons[index],
                              size: isSelected ? 24 : 22,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.7),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              labels[index],
                              style: TextStyle(
                                fontSize: 8,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
