import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingStepTwo extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingStepTwo({
    Key? key,
    required this.onNext,
    required this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          SizedBox(height: 4.h),
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
                    color: const Color(0xFFC8E53F).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(25.w),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'savings',
                      color: const Color(0xFFC8E53F),
                      size: 20.w,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                // Title
                Text(
                  'Save Money & Time',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                // Description
                Text(
                  'Get the best deals and offers on bus tickets. Track your bookings, manage your trips, and enjoy cashless payments with XFA currency.',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Fixed button area with SafeArea bottom padding
          Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 3.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Next button
                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: onNext,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            color: const Color(0xFF1A4A47),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        CustomIconWidget(
                          iconName: 'arrow_forward',
                          color: const Color(0xFF1A4A47),
                          size: 4.w,
                        ),
                      ],
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
}