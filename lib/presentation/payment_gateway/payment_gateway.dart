import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/booking_summary_card.dart';
import './widgets/card_input_form.dart';
import './widgets/pay_now_button.dart';
import './widgets/payment_method_card.dart';
import './widgets/saved_card_carousel.dart';
import './widgets/session_timer.dart';

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
  Map<String, String> _cardData = {};

  // Mock booking data
  final Map<String, dynamic> _bookingData = {
    'fromCity': 'New York',
    'toCity': 'Washington DC',
    'departureTime': '08:30 AM',
    'arrivalTime': '12:45 PM',
    'passengers': [
      {'name': 'John Smith', 'age': 32},
      {'name': 'Sarah Smith', 'age': 28},
    ],
    'baseFare': '\$180.00',
    'convenienceFee': '\$15.00',
    'serviceTax': '\$9.75',
    'gst': '\$36.85',
    'platformFee': '\$8.40',
    'totalAmount': '\$250.00',
  };

  // Mock payment methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'credit_card',
      'title': 'Credit/Debit Card',
      'subtitle': 'Visa, Mastercard, American Express',
      'icon': 'credit_card',
      'discount': null,
    },
    {
      'id': 'digital_wallet',
      'title': 'Digital Wallets',
      'subtitle': 'Apple Pay, Google Pay, PayPal',
      'icon': 'account_balance_wallet',
      'discount': '5% cashback',
    },
    {
      'id': 'upi',
      'title': 'UPI Payment',
      'subtitle': 'PhonePe, Google Pay, Paytm',
      'icon': 'qr_code',
      'discount': null,
    },
    {
      'id': 'net_banking',
      'title': 'Net Banking',
      'subtitle': 'All major banks supported',
      'icon': 'account_balance',
      'discount': null,
    },
    {
      'id': 'bnpl',
      'title': 'Buy Now Pay Later',
      'subtitle': 'Klarna, Afterpay, Affirm',
      'icon': 'schedule',
      'discount': '0% interest for 3 months',
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
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
      _selectedPaymentMethod = 'credit_card';
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

    if (_selectedPaymentMethod == 'credit_card' &&
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
    });

    // Show success and navigate
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.green,
              size: 28,
            ),
            SizedBox(width: 3.w),
            const Text('Payment Successful'),
          ],
        ),
        content: Text(
            'Your booking has been confirmed. Ticket details have been sent to your email.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/my-tickets');
            },
            child: const Text('View Tickets'),
          ),
        ],
      ),
    );
  }

  bool get _canProceedWithPayment {
    if (_selectedPaymentMethod.isEmpty) return false;
    if (_selectedPaymentMethod == 'credit_card') {
      return _cardData['cardNumber']?.isNotEmpty == true &&
          _cardData['holderName']?.isNotEmpty == true &&
          _cardData['expiryDate']?.isNotEmpty == true &&
          _cardData['cvv']?.isNotEmpty == true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
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
                          if (_selectedPaymentMethod == 'credit_card') ...[
                            SizedBox(height: 2.h),
                            SavedCardCarousel(
                              savedCards: _savedCards,
                              onCardSelected: _onCardSelected,
                              onCardDeleted: _onCardDeleted,
                            ),
                            SizedBox(height: 2.h),
                            CardInputForm(
                              onCardDataChanged: _onCardDataChanged,
                              isVisible:
                                  _selectedPaymentMethod == 'credit_card',
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
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
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
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
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
                        size: 24,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Payment',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'security',
                              color: Colors.green,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'SSL Encrypted',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SessionTimer(
                    initialDuration: const Duration(minutes: 15),
                    onTimeout: _onSessionTimeout,
                  ),
                ],
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
