import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';

class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;
  final String? errorMessage;

  const CustomErrorWidget({
    Key? key,
    this.errorDetails,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A4A47),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A4A47),
              Color(0xFF2A5D5A),
              Color(0xFF1A4A47),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    child: CustomIconWidget(
                      iconName: 'error_outline',
                      color: const Color(0xFFC8E53F),
                      size: 15.w,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Oops! Something went wrong",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'We encountered an issue while loading this page. Please try again or go back to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            bool canBeBack = Navigator.canPop(context);
                            if (canBeBack) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.pushNamed(context, AppRoutes.homeScreen);
                            }
                          },
                          icon: CustomIconWidget(
                            iconName: 'arrow_back',
                            color: const Color(0xFF1A4A47),
                            size: 5.w,
                          ),
                          label: Text(
                            'Go Back',
                            style: TextStyle(
                              color: const Color(0xFF1A4A47),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC8E53F),
                            foregroundColor: const Color(0xFF1A4A47),
                            padding: EdgeInsets.symmetric(vertical: 3.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.w),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context, 
                              AppRoutes.homeScreen, 
                              (route) => false
                            );
                          },
                          icon: CustomIconWidget(
                            iconName: 'home',
                            color: Colors.white,
                            size: 5.w,
                          ),
                          label: Text(
                            'Home',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 3.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.w),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
