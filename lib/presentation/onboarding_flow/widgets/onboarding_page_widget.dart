import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final double parallaxOffset;
  final bool isLastPage;

  const OnboardingPageWidget({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.parallaxOffset,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.h,
      child: Stack(
        children: [
          // Parallax background
          Positioned(
            top: -parallaxOffset * 0.5,
            left: -parallaxOffset * 0.3,
            right: -parallaxOffset * 0.3,
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.05),
                    AppTheme.lightTheme.colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),

          // Floating glassmorphism card
          Positioned(
            top: 15.h,
            left: 5.w,
            right: 5.w,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Feature mockup image
                  Container(
                    width: 80.w,
                    height: 35.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowLight,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomImageWidget(
                        imageUrl: imageUrl,
                        width: 80.w,
                        height: 35.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Title with animated appearance
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 600),
                    style:
                        AppTheme.lightTheme.textTheme.headlineMedium!.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Description
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodyLarge!.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Interactive elements overlay for demonstration
          if (!isLastPage)
            Positioned(
              bottom: 20.h,
              left: 10.w,
              right: 10.w,
              child: _buildInteractiveDemo(),
            ),
        ],
      ),
    );
  }

  Widget _buildInteractiveDemo() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDemoButton("Search", 'search'),
          _buildDemoButton("Select", 'event_seat'),
          _buildDemoButton("Book", 'confirmation_number'),
        ],
      ),
    );
  }

  Widget _buildDemoButton(String label, String iconName) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelMedium!.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
