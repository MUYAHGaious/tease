import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/booking_progress_widget.dart';
import './widgets/booking_summary_card_widget.dart';
import './widgets/confirm_booking_button_widget.dart';
import './widgets/payment_method_widget.dart';
import './widgets/success_animation_widget.dart';

class BookingConfirmation extends StatefulWidget {
  const BookingConfirmation({Key? key}) : super(key: key);

  @override
  State<BookingConfirmation> createState() => _BookingConfirmationState();
}

class _BookingConfirmationState extends State<BookingConfirmation>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _showSuccess = false;
  String _selectedPaymentMethod = 'credit_card';
  Map<String, dynamic> _paymentData = {};

  // Mock booking data
  final Map<String, dynamic> _bookingData = {
    "bookingId":
        "BF${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
    "fromCity": "Douala",
    "toCity": "Yaoundé",
    "date": "July 28, 2025",
    "departureTime": "09:30 AM",
    "arrivalTime": "01:45 PM",
    "selectedSeats": ["A1", "A2"],
    "totalPrice": "13,000 XAF",
    "passengers": [
      {
        "name": "John Smith",
        "age": 32,
        "gender": "Male",
      },
      {
        "name": "Sarah Smith",
        "age": 28,
        "gender": "Female",
      },
    ],
    "priceBreakdown": {
      "Base Fare (2 seats)": "11,000 XAF",
      "Service Fee": "1,200 XAF",
      "Taxes": "800 XAF",
    },
  };

  final List<String> _progressSteps = [
    'Search',
    'Select Seats',
    'Payment',
    'Confirmation',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    ));

    _pageController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPaymentMethodSelected(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  void _onPaymentDataChanged(Map<String, dynamic> data) {
    setState(() {
      _paymentData = data;
    });
  }

  bool _isFormValid() {
    if (_selectedPaymentMethod == 'credit_card') {
      return _paymentData['cardNumber']?.isNotEmpty == true &&
          _paymentData['expiry']?.isNotEmpty == true &&
          _paymentData['cvv']?.isNotEmpty == true &&
          _paymentData['name']?.isNotEmpty == true;
    }
    return true; // Other payment methods don't require form validation
  }

  Future<void> _processPayment() async {
    if (!_isFormValid()) {
      _showErrorMessage('Please fill in all required payment information');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    // Simulate payment success (90% success rate)
    final isSuccess = DateTime.now().millisecond % 10 != 0;

    if (isSuccess) {
      setState(() {
        _isLoading = false;
        _showSuccess = true;
      });
      HapticFeedback.heavyImpact();
    } else {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage(
          'Payment failed. Please try again or use a different payment method.');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppTheme.lightTheme.colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _onSuccessAnimationComplete() {
    // Navigate to home or ticket view after success animation
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home-dashboard',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return Scaffold(
        body: SuccessAnimationWidget(
          onAnimationComplete: _onSuccessAnimationComplete,
          bookingData: _bookingData,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Booking Confirmation',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        backgroundColor:
            AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.95),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Secure',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 2.h),
              BookingProgressWidget(
                currentStep: 2,
                steps: _progressSteps,
              ),
              SizedBox(height: 2.h),
              BookingSummaryCardWidget(
                bookingData: _bookingData,
              ),
              SizedBox(height: 2.h),
              PaymentMethodWidget(
                onPaymentMethodSelected: _onPaymentMethodSelected,
                onPaymentDataChanged: _onPaymentDataChanged,
              ),
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Secure Payment Processing',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Your payment information is encrypted with 256-bit SSL security. We never store your card details.',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color:
              AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _bookingData["totalPrice"] as String,
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(_bookingData["selectedSeats"] as List).length} Passenger${(_bookingData["selectedSeats"] as List).length > 1 ? 's' : ''}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ConfirmBookingButtonWidget(
                onPressed: _processPayment,
                isEnabled: _isFormValid() && !_isLoading,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
