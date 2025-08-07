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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [
                0.0,
                0.3 + (_gradientAnimation.value * 0.2),
                0.7 + (_gradientAnimation.value * 0.1),
                1.0,
              ],
              colors: [
                // Premium deep gradient like Apple/Samsung
                const Color(0xFF1a4d3a), // Deep forest green (top)
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.9),
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.7),
                const Color(0xFF0d2921), // Darker green (bottom)
              ],
            ),
          ),
          child: Stack(
            children: [
              // Floating orbs with subtle movement - Apple style
              Positioned(
                top: 8.h + (_gradientAnimation.value * 2.h),
                left: 10.w + (_gradientAnimation.value * 5.w),
                child: Transform.scale(
                  scale: 0.8 + (_gradientAnimation.value * 0.3),
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1.2,
                        colors: [
                          AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.15),
                          AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Second floating orb
              Positioned(
                bottom: 12.h - (_gradientAnimation.value * 3.h),
                right: 5.w - (_gradientAnimation.value * 8.w),
                child: Transform.scale(
                  scale: 1.0 + (_gradientAnimation.value * 0.2),
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.bottomRight,
                        radius: 1.0,
                        colors: [
                          AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.12),
                          AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Third subtle orb for depth
              Positioned(
                top: 35.h + (_gradientAnimation.value * 1.5.h),
                right: 20.w + (_gradientAnimation.value * 3.w),
                child: Transform.scale(
                  scale: 0.6 + (_gradientAnimation.value * 0.4),
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.02),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Noise texture overlay for premium feel
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.03),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.05),
                    ],
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
