import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BookingReferenceWidget extends StatelessWidget {
  final String referenceNumber;

  const BookingReferenceWidget({
    super.key,
    required this.referenceNumber,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: referenceNumber));
    Fluttertoast.showToast(
      msg: "Booking reference copied to clipboard",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      textColor: AppTheme.lightTheme.colorScheme.onPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Reference',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  referenceNumber,
                  style: AppTheme.getMonospaceStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _copyToClipboard(context),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'content_copy',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
