import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class LoadingSkeletonWidget extends StatefulWidget {
  const LoadingSkeletonWidget({super.key});

  @override
  State<LoadingSkeletonWidget> createState() => _LoadingSkeletonWidgetState();
}

class _LoadingSkeletonWidgetState extends State<LoadingSkeletonWidget>
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ListView.builder(
          itemCount: 5,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          itemBuilder: (context, index) => _buildSkeletonCard(),
        );
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSkeletonHeader(),
              SizedBox(height: 2.h),
              _buildSkeletonTimeRow(),
              SizedBox(height: 2.h),
              _buildSkeletonAmenities(),
              SizedBox(height: 2.h),
              _buildSkeletonPriceRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonHeader() {
    return Row(
      children: [
        _buildShimmerBox(12.w, 6.h),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBox(40.w, 2.h),
              SizedBox(height: 1.h),
              _buildShimmerBox(25.w, 1.5.h),
            ],
          ),
        ),
        _buildShimmerBox(15.w, 3.h),
      ],
    );
  }

  Widget _buildSkeletonTimeRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBox(20.w, 2.5.h),
              SizedBox(height: 1.h),
              _buildShimmerBox(30.w, 1.5.h),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildShimmerBox(15.w, 1.5.h),
              SizedBox(height: 1.h),
              _buildShimmerBox(20.w, 0.5.h),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildShimmerBox(20.w, 2.5.h),
              SizedBox(height: 1.h),
              _buildShimmerBox(30.w, 1.5.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonAmenities() {
    return Row(
      children: [
        _buildShimmerBox(15.w, 3.h),
        SizedBox(width: 2.w),
        _buildShimmerBox(18.w, 3.h),
        SizedBox(width: 2.w),
        _buildShimmerBox(12.w, 3.h),
        SizedBox(width: 2.w),
        _buildShimmerBox(20.w, 3.h),
      ],
    );
  }

  Widget _buildSkeletonPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBox(25.w, 2.5.h),
            SizedBox(height: 1.h),
            _buildShimmerBox(20.w, 1.5.h),
          ],
        ),
        Row(
          children: [
            _buildShimmerBox(20.w, 4.h),
            SizedBox(width: 2.w),
            _buildShimmerBox(25.w, 4.h),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerBox(double width, double height) {
    return Opacity(
      opacity: _animation.value,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
