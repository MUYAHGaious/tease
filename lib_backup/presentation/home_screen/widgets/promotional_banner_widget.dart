import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PromotionalBannerWidget extends StatefulWidget {
  final List<Map<String, dynamic>> banners;
  final Function(Map<String, dynamic>)? onBannerTap;

  const PromotionalBannerWidget({
    Key? key,
    required this.banners,
    this.onBannerTap,
  }) : super(key: key);

  @override
  State<PromotionalBannerWidget> createState() =>
      _PromotionalBannerWidgetState();
}

class _PromotionalBannerWidgetState extends State<PromotionalBannerWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.banners.isNotEmpty) {
      // Auto-scroll banners every 5 seconds
      Future.delayed(const Duration(seconds: 5), _autoScroll);
    }
  }

  void _autoScroll() {
    if (mounted && widget.banners.isNotEmpty) {
      final nextPage = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(seconds: 5), _autoScroll);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Special Offers',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 20.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                child: _buildBannerCard(context, banner),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBannerCard(BuildContext context, Map<String, dynamic> banner) {
    return GestureDetector(
      onTap: () => widget.onBannerTap?.call(banner),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.primaryColor,
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -10.w,
              top: -5.h,
              child: Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              right: -5.w,
              bottom: -10.h,
              child: Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (banner['discount'] != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              banner['discount'] as String,
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme.onSecondaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                        ],
                        Text(
                          banner['title'] as String? ?? '',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          banner['description'] as String? ?? '',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (banner['validUntil'] != null) ...[
                          SizedBox(height: 1.h),
                          Text(
                            'Valid until ${banner['validUntil'] as String}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (banner['imageUrl'] != null)
                          CustomImageWidget(
                            imageUrl: banner['imageUrl'] as String,
                            width: 20.w,
                            height: 10.h,
                            fit: BoxFit.contain,
                          )
                        else
                          Container(
                            width: 20.w,
                            height: 10.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIconWidget(
                              iconName: 'local_offer',
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Claim Now',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme.onSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
