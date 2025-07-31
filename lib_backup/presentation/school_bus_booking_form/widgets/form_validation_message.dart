import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FormValidationMessage extends StatelessWidget {
  final String? errorMessage;
  final bool isVisible;

  const FormValidationMessage({
    Key? key,
    required this.errorMessage,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible || errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF44336).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFF44336).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: const Color(0xFFF44336),
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFFF44336),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}