import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onAllowPressed;
  final VoidCallback onSkipPressed;
  final bool isLoading;

  const ActionButtonsWidget({
    super.key,
    required this.onAllowPressed,
    required this.onSkipPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          // Primary action button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      onAllowPressed();
                    },
              style: AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.5);
                  }
                  return AppTheme.lightTheme.colorScheme.secondary;
                }),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.onSecondary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'location_on',
                          color: AppTheme.lightTheme.colorScheme.onSecondary,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            'Allow Location',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 2.h),
          // Secondary action button
          TextButton(
            onPressed: isLoading ? null : onSkipPressed,
            style: AppTheme.lightTheme.textButtonTheme.style?.copyWith(
              foregroundColor: WidgetStateProperty.all(
                Colors.white.withValues(alpha: 0.9),
              ),
            ),
            child: Text(
              'Skip for Now',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
