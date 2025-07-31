import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/additional_passengers_widget.dart';
import './widgets/contact_information_widget.dart';
import './widgets/emergency_contact_widget.dart';
import './widgets/fare_summary_widget.dart';
import './widgets/primary_passenger_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/route_summary_widget.dart';

class PassengerDetails extends StatefulWidget {
  const PassengerDetails({Key? key}) : super(key: key);

  @override
  State<PassengerDetails> createState() => _PassengerDetailsState();
}

class _PassengerDetailsState extends State<PassengerDetails>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  // Mock data for route and booking details
  final Map<String, dynamic> _routeData = {
    'busOperator': 'Tease Express',
    'busType': 'AC Sleeper',
    'fromCity': 'New York',
    'toCity': 'Boston',
    'departureTime': '08:30 AM',
    'arrivalTime': '03:00 PM',
    'duration': '6h 30m',
    'journeyDate': 'Jul 28, 2025',
  };

  final List<String> _selectedSeats = ['A1', 'A2', 'B1'];

  final Map<String, dynamic> _fareData = {
    'baseFare': 45.0,
    'taxes': 5.0,
    'serviceFee': 2.5,
    'discount': 7.5,
  };

  final List<String> _bookingSteps = [
    'Search',
    'Select Seats',
    'Passenger Details',
    'Payment',
    'Confirmation',
  ];

  // Form data
  Map<String, dynamic> _primaryPassengerData = {};
  List<Map<String, dynamic>> _additionalPassengersData = [];
  Map<String, dynamic> _contactData = {};
  Map<String, dynamic> _emergencyContactData = {};

  bool get _isFormValid {
    final primaryValid = _primaryPassengerData['isValid'] ?? false;
    final contactValid = _contactData['isValid'] ?? false;
    final additionalValid = _additionalPassengersData.isEmpty ||
        _additionalPassengersData
            .every((passenger) => passenger['isValid'] ?? false);
    final emergencyValid = _emergencyContactData['isValid'] ?? true; // Optional

    return primaryValid && contactValid && additionalValid && emergencyValid;
  }

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _headerAnimationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScroll);
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final threshold = 10.h;

    if (offset > threshold && _headerAnimationController.value == 1.0) {
      _headerAnimationController.reverse();
    } else if (offset <= threshold && _headerAnimationController.value == 0.0) {
      _headerAnimationController.forward();
    }
  }

  void _onPrimaryPassengerChanged(Map<String, dynamic> data) {
    setState(() {
      _primaryPassengerData = data;
    });
  }

  void _onAdditionalPassengersChanged(List<Map<String, dynamic>> data) {
    setState(() {
      _additionalPassengersData = data;
    });
  }

  void _onContactChanged(Map<String, dynamic> data) {
    setState(() {
      _contactData = data;
    });
  }

  void _onEmergencyContactChanged(Map<String, dynamic> data) {
    setState(() {
      _emergencyContactData = data;
    });
  }

  void _onContinuePressed() {
    if (_isFormValid) {
      // Navigate to payment screen
      Navigator.pushNamed(context, '/payment-gateway');
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header with Route Summary
            AnimatedBuilder(
              animation: _headerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -10.h * (1 - _headerAnimation.value)),
                  child: Opacity(
                    opacity: _headerAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .shadowColor
                                .withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // App Bar
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 2.h),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: EdgeInsets.all(2.w),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .shadowColor
                                              .withValues(alpha: 0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CustomIconWidget(
                                      iconName: 'arrow_back',
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    'Passenger Details',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _scrollToTop,
                                  child: Container(
                                    padding: EdgeInsets.all(2.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: CustomIconWidget(
                                      iconName: 'keyboard_arrow_up',
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Progress Indicator
                          ProgressIndicatorWidget(
                            progress: 0.6,
                            steps: _bookingSteps,
                            currentStep: 2,
                          ),

                          // Route Summary
                          RouteSummaryWidget(
                            routeData: _routeData,
                            selectedSeats: _selectedSeats,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),

                    // Primary Passenger Section
                    PrimaryPassengerWidget(
                      onDataChanged: _onPrimaryPassengerChanged,
                      initialData: _primaryPassengerData.isNotEmpty
                          ? _primaryPassengerData
                          : null,
                    ),

                    // Additional Passengers Section
                    if (_selectedSeats.length > 1)
                      AdditionalPassengersWidget(
                        seatCount: _selectedSeats.length,
                        onDataChanged: _onAdditionalPassengersChanged,
                        initialData: _additionalPassengersData.isNotEmpty
                            ? _additionalPassengersData
                            : null,
                      ),

                    // Contact Information Section
                    ContactInformationWidget(
                      onDataChanged: _onContactChanged,
                      initialData:
                          _contactData.isNotEmpty ? _contactData : null,
                    ),

                    // Emergency Contact Section
                    EmergencyContactWidget(
                      onDataChanged: _onEmergencyContactChanged,
                      initialData: _emergencyContactData.isNotEmpty
                          ? _emergencyContactData
                          : null,
                    ),

                    SizedBox(height: 10.h), // Space for bottom sheet
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Sheet with Fare Summary
      bottomSheet: FareSummaryWidget(
        fareData: _fareData,
        passengerCount: _selectedSeats.length,
        isValid: _isFormValid,
        onContinuePressed: _onContinuePressed,
      ),
    );
  }
}
