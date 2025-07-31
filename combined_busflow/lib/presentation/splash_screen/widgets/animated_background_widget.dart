import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AnimatedBackgroundWidget extends StatefulWidget {
  const AnimatedBackgroundWidget({Key? key}) : super(key: key);

  @override
  State<AnimatedBackgroundWidget> createState() =>
      _AnimatedBackgroundWidgetState();
}

class _AnimatedBackgroundWidgetState extends State<AnimatedBackgroundWidget>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _startAnimation();
  }

  void _initializeAnimation() {
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimation() {
    _gradientController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          width: 100.w,
          height: 100.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                _gradientAnimation.value * 0.5,
                1.0,
              ],
              colors: [
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
                AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.6),
                AppTheme.lightTheme.colorScheme.surface,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 10.h,
                left: -10.w,
                child: Transform.rotate(
                  angle: _gradientAnimation.value * 0.5,
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.lightTheme.colorScheme.secondary
                              .withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 15.h,
                right: -15.w,
                child: Transform.rotate(
                  angle: -_gradientAnimation.value * 0.3,
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
