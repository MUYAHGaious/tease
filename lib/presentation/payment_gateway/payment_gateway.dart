import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/app_export.dart';
import './widgets/booking_summary_card.dart';
import './widgets/card_input_form.dart';
import './widgets/pay_now_button.dart';
import './widgets/payment_method_card.dart';
import './widgets/saved_card_carousel.dart';
import './widgets/session_timer.dart';
import '../booking_confirmation/widgets/professional_success_widget.dart';

class PaymentGateway extends StatefulWidget {
  const PaymentGateway({Key? key}) : super(key: key);

  @override
  State<PaymentGateway> createState() => _PaymentGatewayState();
}

class _PaymentGatewayState extends State<PaymentGateway>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _selectedPaymentMethod = '';
  bool _isProcessingPayment = false;
  bool _showSuccess = false;
  Map<String, String> _cardData = {};

  // Mock booking data with XAF currency and Cameroon cities
  final Map<String, dynamic> _bookingData = {
    'fromCity': 'Douala',
    'toCity': 'Yaoundé',
    'departureTime': '08:30 AM',
    'arrivalTime': '12:45 PM',
    'passengers': [
      {'name': 'John Doe', 'age': 32},
      {'name': 'Jane Smith', 'age': 28},
    ],
    'baseFare': '7,500 XAF',
    'convenienceFee': '200 XAF',
    'serviceTax': '0 XAF',
    'gst': '0 XAF',
    'platformFee': '0 XAF',
    'totalAmount': '7,700 XAF',
  };

  // Mock payment methods matching booking confirmation screen
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'mtn_momo',
      'title': 'MTN Mobile Money',
      'subtitle': 'Mobile payment via MTN network',
      'icon': 'phone_android',
      'logo': 'images/mtn-logo.svg',
      'discount': null,
    },
    {
      'id': 'orange_money',
      'title': 'Orange Money',
      'subtitle': 'Mobile payment via Orange network',
      'icon': 'phone_android',
      'logo': 'images/orange-money-logo.svg',
      'discount': null,
    },
    {
      'id': 'visa',
      'title': 'Visa Card',
      'subtitle': 'Pay with your Visa credit/debit card',
      'icon': 'credit_card',
      'logo': 'images/visa-logo.svg',
      'discount': null,
    },
    {
      'id': 'mastercard',
      'title': 'Mastercard',
      'subtitle': 'Pay with your Mastercard credit/debit card',
      'icon': 'credit_card',
      'logo': 'images/mastercard-logo.svg',
      'discount': null,
    },
  ];

  // Mock saved cards
  final List<Map<String, dynamic>> _savedCards = [
    {
      'id': 1,
      'cardNumber': '4532123456789012',
      'holderName': 'JOHN SMITH',
      'expiryDate': '12/26',
      'type': 'Visa',
      'bankName': 'Chase Bank',
    },
    {
      'id': 2,
      'cardNumber': '5555123456789012',
      'holderName': 'JOHN SMITH',
      'expiryDate': '08/25',
      'type': 'Mastercard',
      'bankName': 'Bank of America',
    },
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check if we should show success state immediately
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments?['showSuccess'] == true) {
      _showSuccess = true;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onSuccessAnimationComplete() {
    // Get the previous route from arguments, default to home dashboard
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final previousRoute = arguments?['previousRoute'] ?? '/home-dashboard';
    
    // Navigate back to the previous route
    Navigator.pushNamedAndRemoveUntil(
      context,
      previousRoute,
      (route) => false,
    );
  }

  void _onPaymentMethodSelected(String methodId) {
    setState(() {
      _selectedPaymentMethod = methodId;
    });

    // Haptic feedback
    HapticFeedback.selectionClick();
  }

  void _onCardSelected(Map<String, dynamic> card) {
    setState(() {
      _selectedPaymentMethod = 'visa'; // Default to visa when card is selected
      _cardData = {
        'cardNumber': card['cardNumber'],
        'holderName': card['holderName'],
        'expiryDate': card['expiryDate'],
        'cardType': card['type'],
      };
    });

    HapticFeedback.selectionClick();
  }

  void _onCardDeleted(Map<String, dynamic> card) {
    setState(() {
      _savedCards.removeWhere((c) => c['id'] == card['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Card ending in ${card['cardNumber'].toString().substring(card['cardNumber'].toString().length - 4)} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _savedCards.add(card);
            });
          },
        ),
      ),
    );
  }

  void _onCardDataChanged(Map<String, String> cardData) {
    setState(() {
      _cardData = cardData;
    });
  }

  void _onSessionTimeout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text(
            'Your booking session has expired. Please start a new booking.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/home-dashboard');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    if ((_selectedPaymentMethod == 'visa' ||
            _selectedPaymentMethod == 'mastercard') &&
        (_cardData['cardNumber']?.isEmpty ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter card details')),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isProcessingPayment = false;
      _showSuccess = true; // Show success state directly
    });

    HapticFeedback.heavyImpact();
  }

  bool get _canProceedWithPayment {
    if (_selectedPaymentMethod.isEmpty) return false;
    if (_selectedPaymentMethod == 'visa' ||
        _selectedPaymentMethod == 'mastercard') {
      return _cardData['cardNumber']?.isNotEmpty == true &&
          _cardData['holderName']?.isNotEmpty == true &&
          _cardData['expiryDate']?.isNotEmpty == true &&
          _cardData['cvv']?.isNotEmpty == true;
    }
    return true; // MTN MoMo and Orange Money don't require card details
  }

  @override
  Widget build(BuildContext context) {
    // Show success state if needed
    if (_showSuccess) {
      return Scaffold(
        body: ProfessionalSuccessWidget(
          onContinue: _onSuccessAnimationComplete,
          bookingData: _bookingData,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildBackgroundGradient(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: 2.h),
                          BookingSummaryCard(bookingData: _bookingData),
                          SizedBox(height: 3.h),
                          _buildPaymentMethodsSection(),
                          if (_selectedPaymentMethod == 'visa' ||
                              _selectedPaymentMethod == 'mastercard') ...[
                            SizedBox(height: 2.h),
                            SavedCardCarousel(
                              savedCards: _savedCards,
                              onCardSelected: _onCardSelected,
                              onCardDeleted: _onCardDeleted,
                            ),
                            SizedBox(height: 2.h),
                            CardInputForm(
                              onCardDataChanged: _onCardDataChanged,
                              isVisible: _selectedPaymentMethod == 'visa' ||
                                  _selectedPaymentMethod == 'mastercard',
                            ),
                          ],
                          SizedBox(height: 3.h),
                          PayNowButton(
                            amount: _bookingData['totalAmount'],
                            isEnabled: _canProceedWithPayment,
                            isLoading: _isProcessingPayment,
                            onPressed: _processPayment,
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppTheme.darkTheme.scaffoldBackgroundColor,
                  AppTheme.darkTheme.scaffoldBackgroundColor
                      .withValues(alpha: 0.8),
                ]
              : [
                  AppTheme.lightTheme.scaffoldBackgroundColor,
                  AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.9),
                ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 3.w),

              // Title and subtitle
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Secure Payment',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'security',
                          color: Colors.green,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            'SSL Encrypted',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11.sp,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Session timer
              Flexible(
                child: SessionTimer(
                  initialDuration: const Duration(minutes: 15),
                  onTimeout: _onSessionTimeout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Text(
            'Choose Payment Method',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        SizedBox(height: 2.h),
        ..._paymentMethods
            .map((method) => PaymentMethodCard(
                  paymentMethod: method,
                  isSelected: _selectedPaymentMethod == method['id'],
                  onTap: () => _onPaymentMethodSelected(method['id'] as String),
                ))
            .toList(),
      ],
    );
  }
}
