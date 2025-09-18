import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int? currentStep;
  final int? totalSteps;
  final bool? isResuming;

  const ProgressIndicatorWidget({
    super.key,
    this.currentPage = 1,
    this.totalPages = 1,
    this.currentStep,
    this.totalSteps,
    this.isResuming,
  });

  int get _currentValue => currentStep ?? currentPage;
  int get _totalValue => totalSteps ?? totalPages;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: 0.8.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            width: (80.w * _currentValue) / _totalValue,
            height: 0.8.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightTheme.colorScheme.secondary,
                  AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
