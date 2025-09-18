import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_export.dart';

class CameraScannerWidget extends StatefulWidget {
  final Function(String) onQRCodeScanned;
  final bool isScanning;

  const CameraScannerWidget({
    Key? key,
    required this.onQRCodeScanned,
    required this.isScanning,
  }) : super(key: key);

  @override
  State<CameraScannerWidget> createState() => _CameraScannerWidgetState();
}

class _CameraScannerWidgetState extends State<CameraScannerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryLight,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 15.w,
            color: AppTheme.primaryLight,
          ),
          SizedBox(height: 2.h),
          Text(
            'QR Code Scanner',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Camera functionality disabled\nfor frontend development',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              // Simulate QR code scan for demo
              widget.onQRCodeScanned('DEMO_QR_CODE_12345');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLight,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Simulate Scan',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
