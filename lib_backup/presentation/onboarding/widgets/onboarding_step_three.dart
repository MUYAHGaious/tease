import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingStepThree extends StatelessWidget {
  final VoidCallback onLocationPermission;
  final VoidCallback onSkip;
  final bool isLoading;

  const OnboardingStepThree({
    Key? key,
    required this.onLocationPermission,
    required this.onSkip,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          SizedBox(height: 3.h),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Illustration
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25.w),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      size: 20.w,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                // Title
                Text(
                  'Enable Location',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                // Description
                Text(
                  'Allow location access to find nearby bus stops, get accurate departure times, and receive real-time updates about your journey.',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                // Benefits
                _buildBenefit('Find nearby bus stops', 'location_on'),
                SizedBox(height: 1.h),
                _buildBenefit('Real-time arrival updates', 'schedule'),
                SizedBox(height: 1.h),
                _buildBenefit('Auto-fill departure location', 'my_location'),
              ],
            ),
          ),
          // Fixed button area with SafeArea bottom padding
          Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 2.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Allow Location button
                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            onLocationPermission();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC8E53F),
                      foregroundColor: const Color(0xFF1A4A47),
                      elevation: 8,
                      shadowColor: const Color(0xFFC8E53F).withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF1A4A47),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Allow Location',
                                style: TextStyle(
                                  color: const Color(0xFF1A4A47),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              CustomIconWidget(
                                iconName: 'location_on',
                                color: const Color(0xFF1A4A47),
                                size: 4.w,
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 2.h),
                // Skip button
                TextButton(
                  onPressed: isLoading ? null : onSkip,
                  child: Text(
                    'Skip for Now',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(String text, String iconName) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 4.w,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            text,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}