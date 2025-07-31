import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ProgressIndicatorWidget extends StatefulWidget {
  final double progress;
  final List<String> steps;
  final int currentStep;

  const ProgressIndicatorWidget({
    Key? key,
    required this.progress,
    required this.steps,
    required this.currentStep,
  }) : super(key: key);

  @override
  State<ProgressIndicatorWidget> createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation =
        Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(ProgressIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(
            parent: _progressController, curve: Curves.easeOutCubic),
      );
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          // Progress Bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.lightTheme.colorScheme.primary,
                              AppTheme.lightTheme.colorScheme.secondary,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: 2.h),

          // Step Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.steps.length, (index) {
              final isCompleted = index < widget.currentStep;
              final isCurrent = index == widget.currentStep;
              final isUpcoming = index > widget.currentStep;

              return Expanded(
                child: Column(
                  children: [
                    // Step Circle
                    AnimatedBuilder(
                      animation: isCurrent
                          ? _pulseAnimation
                          : const AlwaysStoppedAnimation(1.0),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isCurrent ? _pulseAnimation.value : 1.0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted || isCurrent
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                              border: Border.all(
                                color: isCurrent
                                    ? AppTheme.lightTheme.colorScheme.secondary
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: isCompleted
                                  ? CustomIconWidget(
                                      iconName: 'check',
                                      color: AppTheme
                                          .lightTheme.colorScheme.onPrimary,
                                      size: 16,
                                    )
                                  : isCurrent
                                      ? Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppTheme.lightTheme
                                                .colorScheme.onPrimary,
                                          ),
                                        )
                                      : Text(
                                          '${index + 1}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 1.h),

                    // Step Label
                    Text(
                      widget.steps[index],
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isCompleted || isCurrent
                                ? AppTheme.lightTheme.colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            fontWeight: isCompleted || isCurrent
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
            }),
          ),

          SizedBox(height: 2.h),

          // Progress Percentage
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${(_progressAnimation.value * 100).toInt()}% Complete',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
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
