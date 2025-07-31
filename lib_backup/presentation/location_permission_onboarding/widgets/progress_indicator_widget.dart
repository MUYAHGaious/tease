import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressIndicatorWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps, (index) {
              final isActive = index < currentStep;
              final isCurrent = index == currentStep - 1;

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 8.w : 2.w,
                  height: 1.h,
                  decoration: BoxDecoration(
                    color: isActive || isCurrent
                        ? AppTheme.lightTheme.colorScheme.secondary
                        : AppTheme.lightTheme.colorScheme.surface
                            .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 1.h),
          // Step counter text
          Text(
            'Step $currentStep of $totalSteps',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
