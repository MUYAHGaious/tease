import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class LoadingIndicatorWidget extends StatefulWidget {
  final String loadingText;

  const LoadingIndicatorWidget({
    Key? key,
    this.loadingText = 'Initializing...',
  }) : super(key: key);

  @override
  State<LoadingIndicatorWidget> createState() => _LoadingIndicatorWidgetState();
}

class _LoadingIndicatorWidgetState extends State<LoadingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 8.w,
          height: 8.w,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CircularProgressIndicator(
                value: null,
                strokeWidth: 3.0,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFC8E53F),
                ),
                backgroundColor: const Color(0xFFC8E53F).withValues(alpha: 0.3),
              );
            },
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          widget.loadingText,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: 0.3,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
