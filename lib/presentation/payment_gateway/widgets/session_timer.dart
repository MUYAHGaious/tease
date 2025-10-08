import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class SessionTimer extends StatefulWidget {
  final Duration initialDuration;
  final VoidCallback onTimeout;

  const SessionTimer({
    Key? key,
    required this.initialDuration,
    required this.onTimeout,
  }) : super(key: key);

  @override
  State<SessionTimer> createState() => _SessionTimerState();
}

class _SessionTimerState extends State<SessionTimer>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.initialDuration;

    _timerController = AnimationController(
      duration: widget.initialDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startTimer();
  }

  void _startTimer() {
    _timerController.addListener(() {
      final elapsed = _timerController.value * widget.initialDuration.inSeconds;
      final remaining = widget.initialDuration.inSeconds - elapsed.round();

      setState(() {
        _remainingTime = Duration(seconds: remaining);
      });

      // Start pulsing when less than 2 minutes remaining
      if (remaining <= 120 && !_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }

      // Call timeout callback when timer reaches zero
      if (remaining <= 0) {
        widget.onTimeout();
      }
    });

    _timerController.forward();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    final isUrgent = _remainingTime.inSeconds <= 120;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isUrgent ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isUrgent
                  ? Colors.red.withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isUrgent
                    ? Colors.red.withValues(alpha: 0.3)
                    : AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'timer',
                  color: isUrgent
                      ? Colors.red
                      : AppTheme.lightTheme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Payment gateway closes in ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isUrgent
                            ? Colors.red
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                        fontSize: 10.sp,
                      ),
                ),
                Text(
                  '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isUrgent
                        ? Colors.red
                        : AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
