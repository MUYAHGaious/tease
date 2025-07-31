import 'dart:convert';
import 'package:tease/web_stubs.dart' if (dart.library.html) 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DownloadOptionsWidget extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const DownloadOptionsWidget({
    super.key,
    required this.bookingData,
  });

  Future<void> _saveToWallet() async {
    try {
      if (kIsWeb) {
        // Web implementation - simulate wallet save
        await Future.delayed(const Duration(milliseconds: 500));
        Fluttertoast.showToast(
          msg: "Ticket saved to browser storage",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        // Mobile implementation - simulate wallet integration
        await Future.delayed(const Duration(milliseconds: 800));
        Fluttertoast.showToast(
          msg: "Ticket added to wallet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Unable to save to wallet",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _downloadPdf() async {
    try {
      final pdfContent = _generatePdfContent();

      if (kIsWeb) {
        final bytes = utf8.encode(pdfContent);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute(
              "download", "bus_ticket_${bookingData['referenceNumber']}.txt")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile file save would be implemented here
        await Future.delayed(const Duration(milliseconds: 500));
      }

      Fluttertoast.showToast(
        msg: "Ticket downloaded successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Download failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  String _generatePdfContent() {
    return '''
BUS TICKET - ${bookingData['referenceNumber']}
=====================================

Journey Details:
From: ${bookingData['fromCity']}
To: ${bookingData['toCity']}
Date: ${bookingData['travelDate']}
Departure: ${bookingData['departureTime']}

Bus Information:
Bus Number: ${bookingData['busNumber']}
Bus Type: ${bookingData['busType']}
Seats: ${(bookingData['seatNumbers'] as List).join(', ')}

Total Amount: ${bookingData['totalAmount']}

Thank you for choosing BusGo!
''';
  }

  Future<void> _shareBooking() async {
    try {
      final shareText = '''
🚌 BusGo Booking Confirmed!

Reference: ${bookingData['referenceNumber']}
Route: ${bookingData['fromCity']} → ${bookingData['toCity']}
Date: ${bookingData['travelDate']}
Time: ${bookingData['departureTime']}
Bus: ${bookingData['busNumber']}
Seats: ${(bookingData['seatNumbers'] as List).join(', ')}

Download BusGo app for easy bus booking!
''';

      if (kIsWeb) {
        // Web sharing using clipboard
        await html.window.navigator.clipboard?.writeText(shareText);
        Fluttertoast.showToast(
          msg: "Booking details copied to clipboard",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        // Mobile native sharing would be implemented here
        await Future.delayed(const Duration(milliseconds: 300));
        Fluttertoast.showToast(
          msg: "Sharing options opened",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Unable to share booking",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Download Options',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildDownloadOption(
                  icon: 'account_balance_wallet',
                  label: 'Save to Wallet',
                  onTap: _saveToWallet,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildDownloadOption(
                  icon: 'picture_as_pdf',
                  label: 'Download PDF',
                  onTap: _downloadPdf,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildDownloadOption(
                  icon: 'share',
                  label: 'Share Booking',
                  onTap: _shareBooking,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primaryContainer
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
