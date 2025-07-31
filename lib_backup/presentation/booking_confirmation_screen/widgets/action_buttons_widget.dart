import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  const ActionButtonsWidget({super.key});

  void _addToCalendar() {
    Fluttertoast.showToast(
      msg: "Journey added to calendar",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      textColor: AppTheme.lightTheme.colorScheme.onPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add to Calendar Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addToCalendar,
                icon: CustomIconWidget(
                  iconName: 'event',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 5.w,
                ),
                label: Text(
                  'Add to Calendar',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            // Primary Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/my-bookings-screen');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.lightTheme.colorScheme.secondary,
                      foregroundColor:
                          AppTheme.lightTheme.colorScheme.onSecondary,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                    child: Text(
                      'View My Bookings',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.onSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home-screen',
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Book Another Trip',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
