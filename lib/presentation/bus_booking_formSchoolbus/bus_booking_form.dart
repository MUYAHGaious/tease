import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/booking_button.dart';
import './widgets/date_picker_card.dart';
import './widgets/form_validation_message.dart';
import './widgets/loading_skeleton.dart';
import './widgets/route_selection_card.dart';
import './widgets/seat_preference_card.dart';
import './widgets/time_preference_card.dart';

class BusBookingForm extends StatefulWidget {
  const BusBookingForm({Key? key}) : super(key: key);

  @override
  State<BusBookingForm> createState() => _BusBookingFormState();
}

class _BusBookingFormState extends State<BusBookingForm> {
  // Form state variables
  DateTime? _selectedDate;
  String? _selectedPickupStop;
  String? _selectedDropOffStop;
  String? _selectedTimePreference;
  String? _selectedSeat;
  bool _isLoading = false;
  bool _isFormLoading = true;
  String? _validationError;

  // Mock data
  final List<Map<String, dynamic>> _mockRoutes = [
    {
      "id": "route_001",
      "name": "Main Campus Route",
      "pickupStops": [
        "Downtown Transit Center",
        "Oak Street & 5th Avenue",
        "Riverside Park Entrance",
        "Shopping Mall West Gate",
        "University District Hub"
      ],
      "dropOffStops": [
        "Main Campus - Building A",
        "Main Campus - Library",
        "Main Campus - Student Center",
        "Main Campus - Athletic Complex"
      ]
    },
    {
      "id": "route_002",
      "name": "North Campus Route",
      "pickupStops": [
        "North Station Plaza",
        "Maple Avenue & 12th Street",
        "Community Center",
        "Highland Shopping District"
      ],
      "dropOffStops": [
        "North Campus - Science Building",
        "North Campus - Dormitories",
        "North Campus - Cafeteria"
      ]
    }
  ];

  final List<String> _availableSeats = [
    "1A",
    "1B",
    "1C",
    "1D",
    "2A",
    "2B",
    "2C",
    "2D",
    "3A",
    "3B",
    "3C",
    "3D",
    "4A",
    "4B",
    "4C",
    "4D",
    "5A",
    "5B",
    "5C",
    "5D",
    "6A",
    "6B",
    "6C",
    "6D"
  ];

  final List<String> _occupiedSeats = ["2B", "3C", "4A", "5D"];

  List<String> _currentPickupStops = [];
  List<String> _currentDropOffStops = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    // Simulate loading routes data
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _currentPickupStops = _mockRoutes.first["pickupStops"] as List<String>;
      _currentDropOffStops = _mockRoutes.first["dropOffStops"] as List<String>;
      _isFormLoading = false;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return DatePickerTheme(
          data: DatePickerThemeData(
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            headerBackgroundColor: AppTheme.primaryLight,
            headerForegroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.lightTheme.colorScheme.onSecondary;
              }
              return AppTheme.lightTheme.colorScheme.onSurface;
            }),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.secondaryLight;
              }
              return Colors.transparent;
            }),
            todayForegroundColor:
                WidgetStateProperty.all(AppTheme.secondaryLight),
            todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
            todayBorder:
                const BorderSide(color: AppTheme.secondaryLight, width: 1.0),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _validateForm();
      });
    }
  }

  void _onPickupStopSelected(String? stop) {
    setState(() {
      _selectedPickupStop = stop;
      _selectedDropOffStop = null; // Reset drop-off when pickup changes
      _validateForm();
    });
  }

  void _onDropOffStopSelected(String? stop) {
    setState(() {
      _selectedDropOffStop = stop;
      _validateForm();
    });
  }

  void _onTimePreferenceSelected(String? time) {
    setState(() {
      _selectedTimePreference = time;
      _validateForm();
    });
  }

  void _onSeatSelected(String? seat) {
    setState(() {
      _selectedSeat = seat;
      _validateForm();
    });
  }

  void _validateForm() {
    String? error;

    if (_selectedDate == null) {
      error = "Please select a travel date";
    } else if (_selectedPickupStop == null) {
      error = "Please select a pickup location";
    } else if (_selectedDropOffStop == null) {
      error = "Please select a drop-off location";
    } else if (_selectedTimePreference == null) {
      error = "Please select a time preference";
    } else if (_selectedSeat == null) {
      error = "Please select a seat";
    } else {
      // Check for duplicate booking
      final bool isDuplicate = _checkDuplicateBooking();
      if (isDuplicate) {
        error = "You already have a booking for this date and route";
      }
    }

    setState(() {
      _validationError = error;
    });
  }

  bool _checkDuplicateBooking() {
    // Mock duplicate booking check
    // In real app, this would check against user's existing bookings
    return false;
  }

  bool get _isFormValid {
    return _selectedDate != null &&
        _selectedPickupStop != null &&
        _selectedDropOffStop != null &&
        _selectedTimePreference != null &&
        _selectedSeat != null &&
        _validationError == null;
  }

  Future<void> _bookTrip() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate booking process
      await Future.delayed(const Duration(seconds: 3));

      // Navigate to QR code display on success
      if (mounted) {
        Navigator.pushNamed(context, '/qr-code-display');
      }
    } catch (e) {
      // Handle booking error
      setState(() {
        _validationError = "Booking failed. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges()) {
      final bool? shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          title: Text(
            'Unsaved Changes',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            'You have unsaved changes. Are you sure you want to leave?',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Stay',
                style: TextStyle(color: AppTheme.primaryLight),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Leave',
                style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
              ),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  bool _hasUnsavedChanges() {
    return _selectedDate != null ||
        _selectedPickupStop != null ||
        _selectedDropOffStop != null ||
        _selectedTimePreference != null ||
        _selectedSeat != null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.primaryLight,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryLight,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.secondaryLight,
              size: 6.w,
            ),
          ),
          title: Text(
            'Book Trip',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                child: _isFormLoading
                    ? const LoadingSkeleton()
                    : SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: 2.h,
                          bottom: 12.h, // Space for sticky button
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date picker
                            DatePickerCard(
                              selectedDate: _selectedDate,
                              onTap: _selectDate,
                            ),

                            // Pickup location
                            RouteSelectionCard(
                              title: 'Pickup Location',
                              selectedStop: _selectedPickupStop,
                              availableStops: _currentPickupStops,
                              onStopSelected: _onPickupStopSelected,
                            ),

                            // Drop-off location
                            RouteSelectionCard(
                              title: 'Drop-off Location',
                              selectedStop: _selectedDropOffStop,
                              availableStops: _currentDropOffStops,
                              onStopSelected: _onDropOffStopSelected,
                              isDropOff: true,
                            ),

                            // Time preference
                            TimePreferenceCard(
                              selectedTime: _selectedTimePreference,
                              onTimeSelected: _onTimePreferenceSelected,
                            ),

                            // Seat preference
                            SeatPreferenceCard(
                              selectedSeat: _selectedSeat,
                              onSeatSelected: _onSeatSelected,
                              availableSeats: _availableSeats,
                              occupiedSeats: _occupiedSeats,
                            ),

                            // Validation message
                            FormValidationMessage(
                              errorMessage: _validationError,
                              isVisible: _validationError != null,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
        bottomSheet: BookingButton(
          isEnabled: _isFormValid,
          isLoading: _isLoading,
          onPressed: _bookTrip,
        ),
      ),
    );
  }
}
