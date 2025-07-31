import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class BookingProgressWidget extends StatefulWidget {
  final int currentStep;
  final List<String> steps;

  const BookingProgressWidget({
    Key? key,
    required this.currentStep,
    required this.steps,
  }) : super(key: key);

  @override
  State<BookingProgressWidget> createState() => _BookingProgressWidgetState();
}

class _BookingProgressWidgetState extends State<BookingProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.currentStep / (widget.steps.length - 1),
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Progress',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.colorScheme.primary,
                    ),
                    minHeight: 6,
                  ),
                  SizedBox(height: 1.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: widget.steps.asMap().entries.map((entry) {
                      int index = entry.key;
                      String step = entry.value;
                      bool isCompleted = index <= widget.currentStep;
                      bool isCurrent = index == widget.currentStep;

                      return Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.3),
                                border: isCurrent
                                    ? Border.all(
                                        color: AppTheme
                                            .lightTheme.colorScheme.secondary,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: isCompleted
                                  ? CustomIconWidget(
                                      iconName: 'check',
                                      color: AppTheme
                                          .lightTheme.colorScheme.onPrimary,
                                      size: 4.w,
                                    )
                                  : null,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              step,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: isCompleted
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                fontWeight: isCurrent
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
