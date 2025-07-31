import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({Key? key}) : super(key: key);

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
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
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              // Date picker skeleton
              _buildSkeletonCard(),
              SizedBox(height: 2.h),
              
              // Route selection skeletons
              _buildSkeletonCard(),
              SizedBox(height: 2.h),
              _buildSkeletonCard(),
              SizedBox(height: 2.h),
              
              // Time preference skeleton
              _buildSkeletonCard(height: 20.h),
              SizedBox(height: 2.h),
              
              // Seat selection skeleton
              _buildSkeletonCard(height: 30.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCard({double? height}) {
    return Container(
      width: double.infinity,
      height: height ?? 8.h,
      decoration: BoxDecoration(
        color: Colors.grey[300]?.withOpacity(_animation.value),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}