import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

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
    required String iconName,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: isEnabled
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.2),
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
            child: CustomIconWidget(
              iconName: iconName,
              color: isEnabled
                  ? AppTheme.lightTheme.colorScheme.onPrimary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildZoomButton(
            iconName: 'add',
            onTap: onZoomIn,
            isEnabled: zoomLevel < 2.0,
          ),
          SizedBox(height: 2.w),
          Container(
            width: 8.w,
            height: 0.5.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(0.25.w),
            ),
          ),
          SizedBox(height: 2.w),
          _buildZoomButton(
            iconName: 'remove',
            onTap: onZoomOut,
            isEnabled: zoomLevel > 0.5,
          ),
          SizedBox(height: 2.w),
          Container(
            width: 8.w,
            height: 0.5.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(0.25.w),
            ),
          ),
          SizedBox(height: 2.w),
          _buildZoomButton(
            iconName: 'center_focus_strong',
            onTap: onResetZoom,
            isEnabled: zoomLevel != 1.0,
          ),
        ],
      ),
    );
  }
}
