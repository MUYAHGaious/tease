import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';

class AuthDemoScreen extends StatelessWidget {
  const AuthDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryLight,
                ),
                child: Icon(
                  Icons.directions_bus,
                  color: Colors.white,
                  size: 10.w,
                ),
              ),

              SizedBox(height: 4.h),

              // Title
              Text(
                'TEASE Bus Booking',
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 2.h),

              Text(
                'Enhanced UI/UX Demo',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),

              SizedBox(height: 8.h),

              // Demo buttons
              _buildDemoButton(
                context: context,
                title: 'Hi! Screen',
                subtitle: 'Initial entry point',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/hi');
                },
              ),

              SizedBox(height: 3.h),

              _buildDemoButton(
                context: context,
                title: 'Sign Up Screen',
                subtitle: 'Registration flow',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/signup');
                },
              ),

              SizedBox(height: 3.h),

              _buildDemoButton(
                context: context,
                title: 'Log In Screen',
                subtitle: 'Authentication flow',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/login');
                },
              ),

              SizedBox(height: 6.h),

              // Instructions
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryLight,
                      size: 6.w,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Design Notes',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '• Dark theme with vibrant green accents\n'
                      '• Hero image section at top\n'
                      '• Clean white input fields\n'
                      '• Smooth animations and transitions\n'
                      '• Modern typography with Inter font',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
