import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class LoadingIndicatorWidget extends StatefulWidget {
  const LoadingIndicatorWidget({Key? key}) : super(key: key);

  @override
  State<LoadingIndicatorWidget> createState() => _LoadingIndicatorWidgetState();
}

class _LoadingIndicatorWidgetState extends State<LoadingIndicatorWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _dotControllers;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _dotControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _dotAnimations = _dotControllers.map((controller) {
      return Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    while (mounted) {
      for (int i = 0; i < _dotControllers.length; i++) {
        if (mounted) {
          _dotControllers[i].forward();
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      await Future.delayed(const Duration(milliseconds: 400));

      for (int i = 0; i < _dotControllers.length; i++) {
        if (mounted) {
          _dotControllers[i].reverse();
        }
      }

      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  @override
  void dispose() {
    for (var controller in _dotControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _dotAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _dotAnimations[index].value,
          child: Container(
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.colorScheme.secondary,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(0),
            SizedBox(width: 2.w),
            _buildDot(1),
            SizedBox(width: 2.w),
            _buildDot(2),
          ],
        ),
        SizedBox(height: 3.h),
        Text(
          'Initializing Premium Experience...',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
