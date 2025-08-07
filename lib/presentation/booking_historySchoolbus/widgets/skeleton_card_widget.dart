import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SkeletonCardWidget extends StatefulWidget {
  const SkeletonCardWidget({Key? key}) : super(key: key);

  @override
  State<SkeletonCardWidget> createState() => _SkeletonCardWidgetState();
}

class _SkeletonCardWidgetState extends State<SkeletonCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1 * _animation.value),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 2.h,
                              width: 60.w,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.3 * _animation.value),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Container(
                              height: 1.5.h,
                              width: 30.w,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.2 * _animation.value),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 3.h,
                        width: 20.w,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(alpha: 0.3 * _animation.value),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 1.5.h,
                              width: 40.w,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.2 * _animation.value),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Container(
                              height: 1.5.h,
                              width: 35.w,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.2 * _animation.value),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 4.h,
                        width: 25.w,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(alpha: 0.3 * _animation.value),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    height: 1.h,
                    width: 50.w,
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.2 * _animation.value),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
