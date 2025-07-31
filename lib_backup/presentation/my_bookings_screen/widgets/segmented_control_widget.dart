import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SegmentedControlWidget extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final Function(int) onSegmentChanged;

  const SegmentedControlWidget({
    Key? key,
    required this.segments,
    required this.selectedIndex,
    required this.onSegmentChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(1.w),
        child: Row(
          children: segments.asMap().entries.map((entry) {
            final int index = entry.key;
            final String segment = entry.value;
            final bool isSelected = index == selectedIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () => onSegmentChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppTheme.primaryLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color:
                                  AppTheme.primaryLight.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? AppTheme.onPrimaryLight
                                : AppTheme.textSecondaryLight,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ) ??
                          const TextStyle(),
                      child: Text(segment),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
