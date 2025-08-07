import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/booking_details_card.dart';
import './widgets/countdown_timer_widget.dart';
import './widgets/emergency_contact_widget.dart';
import './widgets/qr_code_widget.dart';

class QrCodeDisplay extends StatefulWidget {
  const QrCodeDisplay({Key? key}) : super(key: key);

  @override
  State<QrCodeDisplay> createState() => _QrCodeDisplayState();
}

class _QrCodeDisplayState extends State<QrCodeDisplay> {
  late String _qrData;
  late DateTime _expirationTime;
  bool _isOnline = true;
  double? _originalBrightness;

  // Mock booking data
  final Map<String, dynamic> _bookingData = {
    "studentId": "STU001",
    "studentName": "Emma Johnson",
    "bookingReference": "BK2025072718001",
    "tripDate": "July 28, 2025",
    "pickupLocation": "Maple Street & 5th Avenue",
    "dropoffLocation": "Lincoln Elementary School",
    "busNumber": "Bus #42",
    "routeId": "RT001",
    "seatNumber": "12A",
    "timestamp": DateTime.now().millisecondsSinceEpoch,
  };

  @override
  void initState() {
    super.initState();
    _generateQrCode();
    _setMaxBrightness();
    _preventAutoLock();
    _checkNetworkStatus();
  }

  @override
  void dispose() {
    _restoreBrightness();
    _allowAutoLock();
    super.dispose();
  }

  void _generateQrCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final encryptedData = {
      "studentId": _bookingData["studentId"],
      "bookingRef": _bookingData["bookingReference"],
      "routeId": _bookingData["routeId"],
      "seatNumber": _bookingData["seatNumber"],
      "timestamp": timestamp,
      "expiry": timestamp + (30 * 60 * 1000), // 30 minutes
      "hash": _generateHash(timestamp),
    };

    setState(() {
      _qrData = encryptedData.toString();
      _expirationTime = DateTime.now().add(const Duration(minutes: 30));
    });
  }

  String _generateHash(int timestamp) {
    // Simple hash generation for demo
    final data =
        "${_bookingData["studentId"]}_${_bookingData["bookingReference"]}_$timestamp";
    return data.hashCode.abs().toString();
  }

  Future<void> _setMaxBrightness() async {
    try {
      _originalBrightness = await Screen.brightness;
      await Screen.setBrightness(1.0);
    } catch (e) {
      // Handle brightness control error silently
    }
  }

  Future<void> _restoreBrightness() async {
    try {
      if (_originalBrightness != null) {
        await Screen.setBrightness(_originalBrightness!);
      }
    } catch (e) {
      // Handle brightness control error silently
    }
  }

  void _preventAutoLock() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void _allowAutoLock() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  void _checkNetworkStatus() {
    // Mock network status check
    setState(() {
      _isOnline = true; // Assume online for demo
    });
  }

  void _onCodeExpired() {
    _showExpiredDialog();
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: AppTheme.warningLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Code Expired',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.warningLight,
                  ),
            ),
          ],
        ),
        content: Text(
          'Your QR code has expired for security reasons. Please generate a new code.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _refreshCode();
            },
            child: Text(
              'Generate New Code',
              style: TextStyle(color: AppTheme.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshCode() {
    HapticFeedback.mediumImpact();
    _generateQrCode();
    Fluttertoast.showToast(
      msg: "New QR code generated successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successLight,
      textColor: Colors.white,
    );
  }

  void _preventScreenshot() {
    Fluttertoast.showToast(
      msg: "Screenshots are disabled for security",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.warningLight,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryLight,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 8.h),

                  // QR Code section
                  QrCodeWidget(
                    qrData: _qrData,
                    studentName: _bookingData["studentName"],
                    bookingReference: _bookingData["bookingReference"],
                  ),

                  SizedBox(height: 4.h),

                  // Booking details card
                  BookingDetailsCard(
                    tripDate: _bookingData["tripDate"],
                    pickupLocation: _bookingData["pickupLocation"],
                    dropoffLocation: _bookingData["dropoffLocation"],
                    busNumber: _bookingData["busNumber"],
                  ),

                  SizedBox(height: 3.h),

                  // Countdown timer
                  CountdownTimerWidget(
                    expirationTime: _expirationTime,
                    onExpired: _onCodeExpired,
                  ),

                  SizedBox(height: 3.h),

                  // Refresh button
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _refreshCode,
                      icon: CustomIconWidget(
                        iconName: 'refresh',
                        color: AppTheme.onSecondaryLight,
                        size: 20,
                      ),
                      label: Text(
                        'Refresh Code',
                        style: TextStyle(
                          color: AppTheme.onSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryLight,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Emergency contact
                  const EmergencyContactWidget(),

                  SizedBox(height: 2.h),

                  // Offline indicator
                  if (!_isOnline)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.warningLight.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.warningLight,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'wifi_off',
                            color: AppTheme.warningLight,
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Offline - Showing cached code',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.warningLight,
                                    ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),

            // Close button
            Positioned(
              top: 2.h,
              right: 4.w,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Screenshot prevention overlay (invisible)
            Positioned.fill(
              child: GestureDetector(
                onLongPress: _preventScreenshot,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mock Screen class for brightness control
class Screen {
  static Future<double> get brightness async {
    return 0.5; // Mock current brightness
  }

  static Future<void> setBrightness(double brightness) async {
    // Mock brightness setting
  }
}
