import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/theme_notifier.dart';

class SeatLegendWidget extends StatelessWidget {
  const SeatLegendWidget({Key? key}) : super(key: key);

  Widget _buildCompactLegendItem({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: ThemeNotifier().isDarkMode
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(1.5.w),
        border: Border.all(
          color: ThemeNotifier().isDarkMode
              ? Colors.white.withOpacity(0.15)
              : Colors.grey.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(0.8.w),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 2.5.w,
            ),
          ),
          SizedBox(width: 1.5.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8.sp,
              color:
                  ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: ThemeNotifier().isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: ThemeNotifier().isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCompactLegendItem(
            label: 'Available',
            color: const Color(0xFF008B8B),
            icon: Icons.event_seat,
          ),
          _buildCompactLegendItem(
            label: 'Selected',
            color: const Color(0xFF4CAF50),
            icon: Icons.check_circle,
          ),
          _buildCompactLegendItem(
            label: 'Occupied',
            color: const Color(0xFF757575),
            icon: Icons.block,
          ),
        ],
      ),
    );
  }
}
