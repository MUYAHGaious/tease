import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bottom_toolbar_widget.dart';
import './widgets/camera_scanner_widget.dart';
import './widgets/manual_checkin_dialog_widget.dart';
import './widgets/route_header_widget.dart';
import './widgets/scan_result_overlay_widget.dart';
import './widgets/student_roster_widget.dart';

class DriverBoardingInterface extends StatefulWidget {
  const DriverBoardingInterface({Key? key}) : super(key: key);

  @override
  State<DriverBoardingInterface> createState() =>
      _DriverBoardingInterfaceState();
}

class _DriverBoardingInterfaceState extends State<DriverBoardingInterface> {
  bool _isScanning = false;
  bool _isOnline = true;
  int _pendingSync = 0;
  String? _scannedCode;
  bool _scanSuccess = false;
  String _scanMessage = '';
  String? _scannedStudentName;
  bool _showScanResult = false;

  // Mock route data
  final String _routeNumber = "R-101";
  final int _maxCapacity = 45;
  final String _currentStop = "Maple Street & Oak Avenue";
  final String _nextStop = "Lincoln Elementary School";

  // Mock student data
  final List<Map<String, dynamic>> _students = [
    {
      "id": "STU001",
      "studentId": "2024001",
      "name": "Emma Johnson",
      "grade": "5",
      "class": "5A",
      "profilePhoto":
          "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400",
      "pickupStop": "Maple Street & Oak Avenue",
      "dropoffStop": "Lincoln Elementary School",
      "boardingStatus": "pending",
      "boardingTime": null,
      "qrCode": "STU001_20250727_185930",
    },
    {
      "id": "STU002",
      "studentId": "2024002",
      "name": "Michael Chen",
      "grade": "4",
      "class": "4B",
      "profilePhoto":
          "https://images.pexels.com/photos/1674752/pexels-photo-1674752.jpeg?auto=compress&cs=tinysrgb&w=400",
      "pickupStop": "Maple Street & Oak Avenue",
      "dropoffStop": "Lincoln Elementary School",
      "boardingStatus": "boarded",
      "boardingTime": "07:45 AM",
      "qrCode": "STU002_20250727_185930",
    },
    {
      "id": "STU003",
      "studentId": "2024003",
      "name": "Sophia Rodriguez",
      "grade": "6",
      "class": "6A",
      "profilePhoto":
          "https://images.pexels.com/photos/1102341/pexels-photo-1102341.jpeg?auto=compress&cs=tinysrgb&w=400",
      "pickupStop": "Maple Street & Oak Avenue",
      "dropoffStop": "Lincoln Elementary School",
      "boardingStatus": "pending",
      "boardingTime": null,
      "qrCode": "STU003_20250727_185930",
    },
    {
      "id": "STU004",
      "studentId": "2024004",
      "name": "James Wilson",
      "grade": "3",
      "class": "3C",
      "profilePhoto":
          "https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=400",
      "pickupStop": "Maple Street & Oak Avenue",
      "dropoffStop": "Lincoln Elementary School",
      "boardingStatus": "absent",
      "boardingTime": null,
      "qrCode": "STU004_20250727_185930",
    },
    {
      "id": "STU005",
      "studentId": "2024005",
      "name": "Olivia Thompson",
      "grade": "5",
      "class": "5B",
      "profilePhoto":
          "https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400",
      "pickupStop": "Maple Street & Oak Avenue",
      "dropoffStop": "Lincoln Elementary School",
      "boardingStatus": "pending",
      "boardingTime": null,
      "qrCode": "STU005_20250727_185930",
    },
  ];

  @override
  void initState() {
    super.initState();
    _preventScreenLock();
    _setBrightness();
  }

  @override
  void dispose() {
    _restoreScreenSettings();
    super.dispose();
  }

  void _preventScreenLock() {
    // Keep screen awake during scanning
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void _setBrightness() {
    // Set maximum brightness for better QR scanning
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _restoreScreenSettings() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  int get _currentCapacity {
    return _students
        .where((student) => student['boardingStatus'] == 'boarded')
        .length;
  }

  bool get _canCompleteStop {
    final expectedStudents = _students
        .where((student) =>
            student['pickupStop'] == _currentStop ||
            student['dropoffStop'] == _currentStop)
        .toList();

    return expectedStudents.every((student) =>
        student['boardingStatus'] == 'boarded' ||
        student['boardingStatus'] == 'absent');
  }

  void _handleQRCodeScanned(String code) {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _scannedCode = code;
    });

    // Validate QR code
    _validateQRCode(code);
  }

  void _validateQRCode(String code) {
    // Find student by QR code
    final student = _students.firstWhere(
      (s) => s['qrCode'] == code,
      orElse: () => {},
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (student.isEmpty) {
        _showScanResultOverlay(
          success: false,
          message: 'Invalid QR code. Student not found on this route.',
          studentName: null,
        );
      } else if (student['boardingStatus'] == 'boarded') {
        _showScanResultOverlay(
          success: false,
          message: 'Student already boarded. Duplicate scan detected.',
          studentName: student['name'],
        );
      } else {
        _boardStudent(student, 'QR Code Scan');
        _showScanResultOverlay(
          success: true,
          message: 'Student successfully checked in via QR code.',
          studentName: student['name'],
        );
      }
    });
  }

  void _showScanResultOverlay({
    required bool success,
    required String message,
    String? studentName,
  }) {
    setState(() {
      _showScanResult = true;
      _scanSuccess = success;
      _scanMessage = message;
      _scannedStudentName = studentName;
    });
  }

  void _dismissScanResult() {
    setState(() {
      _showScanResult = false;
      _isScanning = false;
      _scannedCode = null;
      _scanMessage = '';
      _scannedStudentName = null;
    });
  }

  void _boardStudent(Map<String, dynamic> student, String method) {
    final now = DateTime.now();
    final timeString =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    setState(() {
      final index = _students.indexWhere((s) => s['id'] == student['id']);
      if (index != -1) {
        _students[index]['boardingStatus'] = 'boarded';
        _students[index]['boardingTime'] = timeString;
        _students[index]['boardingMethod'] = method;
      }
    });

    // Log boarding event for offline sync
    _logBoardingEvent(student, method);
  }

  void _logBoardingEvent(Map<String, dynamic> student, String method) {
    // In a real app, this would save to local SQLite database
    if (!_isOnline) {
      setState(() {
        _pendingSync++;
      });
    }

    debugPrint('Boarding logged: ${student['name']} via $method');
  }

  void _handleManualCheckIn(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => ManualCheckinDialogWidget(
        student: student,
        onConfirm: (student, reason) {
          _boardStudent(student, 'Manual Check-in: $reason');
          Fluttertoast.showToast(
            msg: '${student['name']} checked in manually',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppTheme.successLight,
            textColor: AppTheme.onPrimaryLight,
          );
        },
      ),
    );
  }

  void _handleCompleteStop() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Stop'),
        content: Text(
            'Are you sure you want to complete this stop and proceed to the next one?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _proceedToNextStop();
            },
            child: Text('Complete Stop'),
          ),
        ],
      ),
    );
  }

  void _proceedToNextStop() {
    Fluttertoast.showToast(
      msg: 'Stop completed. Proceeding to next stop.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successLight,
      textColor: AppTheme.onPrimaryLight,
    );

    // In a real app, this would navigate to next stop or route summary
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/admin-route-management');
    });
  }

  void _handleEmergencyContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.errorLight,
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'emergency',
              color: AppTheme.onErrorLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Emergency Contacts',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.onErrorLight,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEmergencyContact('School Office', '+237 6 12 34 56 78'),
            SizedBox(height: 1.h),
            _buildEmergencyContact('Transportation Dept', '+1 (555) 987-6543'),
            SizedBox(height: 1.h),
            _buildEmergencyContact('Emergency Services', '911'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: AppTheme.onErrorLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact(String name, String number) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.onErrorLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.onErrorLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  number,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onErrorLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // In a real app, this would initiate a phone call
              Fluttertoast.showToast(
                msg: 'Calling $name...',
                backgroundColor: AppTheme.successLight,
                textColor: AppTheme.onPrimaryLight,
              );
            },
            icon: CustomIconWidget(
              iconName: 'phone',
              color: AppTheme.onErrorLight,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryLight,
      body: Stack(
        children: [
          Column(
            children: [
              // Route Header
              RouteHeaderWidget(
                routeNumber: _routeNumber,
                currentCapacity: _currentCapacity,
                maxCapacity: _maxCapacity,
                currentStop: _currentStop,
                nextStop: _nextStop,
                isOnline: _isOnline,
                showBackButton: true,
                onBackTap: () => Navigator.pop(context),
              ),

              // Main Content Area
              Expanded(
                child: Container(
                  color: AppTheme.lightTheme.scaffoldBackgroundColor,
                  child: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Row(
                      children: [
                        // Camera Scanner (Left Side)
                        CameraScannerWidget(
                          onQRCodeScanned: _handleQRCodeScanned,
                          isScanning: _isScanning,
                        ),

                        SizedBox(width: 2.w),

                        // Student Roster (Right Side)
                        StudentRosterWidget(
                          students: _students,
                          onManualCheckIn: _handleManualCheckIn,
                          currentStop: _currentStop,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Toolbar
              BottomToolbarWidget(
                onCompleteStop: _handleCompleteStop,
                onEmergencyContact: _handleEmergencyContact,
                isOnline: _isOnline,
                pendingSync: _pendingSync,
                canCompleteStop: _canCompleteStop,
              ),
            ],
          ),

          // Scan Result Overlay
          if (_showScanResult)
            ScanResultOverlayWidget(
              scannedCode: _scannedCode,
              isSuccess: _scanSuccess,
              message: _scanMessage,
              studentName: _scannedStudentName,
              onDismiss: _dismissScanResult,
            ),
        ],
      ),
    );
  }
}
