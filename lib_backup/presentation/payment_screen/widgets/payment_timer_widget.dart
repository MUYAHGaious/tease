import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PaymentTimerWidget extends StatefulWidget {
  final int initialMinutes;
  final VoidCallback? onTimerExpired;

  const PaymentTimerWidget({
    Key? key,
    this.initialMinutes = 15,
    this.onTimerExpired,
  }) : super(key: key);

  @override
  State<PaymentTimerWidget> createState() => _PaymentTimerWidgetState();
}

class _PaymentTimerWidgetState extends State<PaymentTimerWidget> {
  late Timer _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        widget.onTimerExpired?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    if (_remainingSeconds > 300) {
      // > 5 minutes
      return AppTheme.lightTheme.colorScheme.tertiary;
    } else if (_remainingSeconds > 120) {
      // > 2 minutes
      return AppTheme.warningLight;
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: _getTimerColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getTimerColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'timer',
            color: _getTimerColor(),
            size: 18,
          ),
          SizedBox(width: 2.w),
          Text(
            'Complete payment in ${_formatTime(_remainingSeconds)}',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: _getTimerColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
