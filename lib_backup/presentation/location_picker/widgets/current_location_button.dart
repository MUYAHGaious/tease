import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CurrentLocationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const CurrentLocationButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20.h,
      right: 4.w,
      child: FloatingActionButton(
        onPressed: isLoading ? null : onPressed,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        foregroundColor: AppTheme.lightTheme.colorScheme.secondary,
        elevation: 6,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.secondary,
                  ),
                ),
              )
            : CustomIconWidget(
                iconName: 'my_location',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 24,
              ),
      ),
    );
  }
}
