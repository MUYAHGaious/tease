import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/theme_notifier.dart';

class ZoomControlsWidget extends StatelessWidget {
  final double zoomLevel;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;

  const ZoomControlsWidget({
    Key? key,
    required this.zoomLevel,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
  }) : super(key: key);

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: isEnabled
            ? const Color(0xFF008B8B)
            : ThemeNotifier().isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: ThemeNotifier().isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(3.w),
          child: Center(
            child: Icon(
              icon,
              color: isEnabled
                  ? Colors.white
                  : ThemeNotifier().isDarkMode
                  ? Colors.white60
                  : Colors.grey[600],
              size: 6.w,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: ThemeNotifier().isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: ThemeNotifier().isDarkMode
              ? Colors.white.withOpacity(0.2)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeNotifier().isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildZoomButton(
            icon: Icons.add,
            onTap: onZoomIn,
            isEnabled: zoomLevel < 2.0,
          ),
          SizedBox(height: 2.w),
          Container(
            width: 8.w,
            height: 0.5.w,
            decoration: BoxDecoration(
              color: ThemeNotifier().isDarkMode
                  ? Colors.white.withOpacity(0.3)
                  : Colors.grey[400],
              borderRadius: BorderRadius.circular(0.25.w),
            ),
          ),
          SizedBox(height: 2.w),
          _buildZoomButton(
            icon: Icons.remove,
            onTap: onZoomOut,
            isEnabled: zoomLevel > 0.5,
          ),
          SizedBox(height: 2.w),
          Container(
            width: 8.w,
            height: 0.5.w,
            decoration: BoxDecoration(
              color: ThemeNotifier().isDarkMode
                  ? Colors.white.withOpacity(0.3)
                  : Colors.grey[400],
              borderRadius: BorderRadius.circular(0.25.w),
            ),
          ),
          SizedBox(height: 2.w),
          _buildZoomButton(
            icon: Icons.center_focus_strong,
            onTap: onResetZoom,
            isEnabled: zoomLevel != 1.0,
          ),
        ],
      ),
    );
  }
}
