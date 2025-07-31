import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime expirationTime;
  final VoidCallback onExpired;

  const CountdownTimerWidget({
    Key? key,
    required this.expirationTime,
    required this.onExpired,
  }) : super(key: key);

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        widget.onExpired();
      }
    });
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    final difference = widget.expirationTime.difference(now);
    setState(() {
      _remainingTime = difference.isNegative ? Duration.zero : difference;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes = 30; // Total duration in minutes
    final remainingMinutes = _remainingTime.inMinutes;
    final progress = remainingMinutes / totalMinutes;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondaryLight.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'timer',
                color: AppTheme.secondaryLight,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Code expires in',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            _formatDuration(_remainingTime),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.secondaryLight,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 1.5.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.3 ? AppTheme.secondaryLight : AppTheme.errorLight,
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
