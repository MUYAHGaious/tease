import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/billing_address_section.dart';
import './widgets/booking_summary_card.dart';
import './widgets/coupon_section.dart';
import './widgets/new_card_form.dart';
import './widgets/payment_method_card.dart';
import './widgets/payment_processing_overlay.dart';
import './widgets/payment_timer_widget.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = '';
  Map<String, String> _cardData = {};
  Map<String, dynamic>? _appliedCoupon;
  Map<String, String> _billingAddress = {};
  bool _acceptTerms = false;
  bool _isProcessingPayment = false;
  String _processingStatus = 'Processing payment...';
  
  Map<String, dynamic> _bookingData = {};
  bool _dataLoaded = false;

  // Mock payment methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      "id": "mtn_momo",
      "type": "mobile_money",
      "title": "MTN Mobile Money",
      "subtitle": "237 6XX XXX XXX",
      "icon": "mtn_momo",
      "processingFee": 2.0,
    },
    {
      "id": "orange_money",
      "type": "mobile_money",
      "title": "Orange Money",
      "subtitle": "237 6XX XXX XXX",
      "icon": "orange_money",
      "processingFee": 2.5,
    },
    {
      "id": "saved_card_1",
      "type": "saved_card",
      "title": "Visa •••• 4532",
      "subtitle": "Expires 12/26",
      "icon": "visa",
      "processingFee": 3.5,
    },
    {
      "id": "saved_card_2",
      "type": "saved_card",
      "title": "Mastercard •••• 8901",
      "subtitle": "Expires 08/27",
      "icon": "mastercard",
      "processingFee": 3.5,
    },
    {
      "id": "new_card",
      "type": "new_card",
      "title": "Add New Card",
      "subtitle": "Credit or Debit Card",
      "icon": "credit_card",
      "processingFee": 3.5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = _paymentMethods.first["id"];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookingData();
    });
  }

  void _loadBookingData() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        _bookingData = args;
        _dataLoaded = true;
      });
    } else {
      // Fallback data if no arguments passed
      setState(() {
        _bookingData = {
          "busNumber": "GE 203",
          "fromCity": "Douala",
          "toCity": "Yaoundé",
          "departureTime": "08:30 AM",
          "date": "July 20, 2025",
          "selectedSeats": ["A12", "A13"],
          "totalPrice": 7000.0,
          "currency": "XFA",
          "addOns": [],
          "basePrice": 3500.0,
        };
        _dataLoaded = true;
      });
    }
  }

  double _calculateFinalAmount() {
    if (!_dataLoaded || _bookingData.isEmpty) return 0.0;
    
    final selectedSeats = _bookingData["selectedSeats"] as List? ?? [];
    final addOns = _bookingData["addOns"] as List? ?? [];
    final totalPrice = _bookingData["totalPrice"] as double? ?? 0.0;
    
    // If totalPrice is already calculated, use it
    if (totalPrice > 0) {
      var total = totalPrice;
      
      if (_appliedCoupon != null) {
        final coupon = _appliedCoupon!;
        if (coupon["type"] == "percentage") {
          final discount = total * (coupon["discount"] as double);
          final maxDiscount = coupon["maxDiscount"] as double;
          total -= discount > maxDiscount ? maxDiscount : discount;
        } else {
          total -= coupon["discount"] as double;
        }
      }
      
      return total;
    }
    
    // Fallback calculation
    final basePrice = _bookingData["basePrice"] as double? ?? 3500.0;
    final addOnTotal = addOns.fold<double>(
        0, (sum, addOn) => sum + (addOn["price"] as double));
    final subtotal = (basePrice * selectedSeats.length) + addOnTotal;
    final taxes = subtotal * 0.12;
    var total = subtotal + taxes;

    if (_appliedCoupon != null) {
      final coupon = _appliedCoupon!;
      if (coupon["type"] == "percentage") {
        final discount = total * (coupon["discount"] as double);
        final maxDiscount = coupon["maxDiscount"] as double;
        total -= discount > maxDiscount ? maxDiscount : discount;
      } else {
        total -= coupon["discount"] as double;
      }
    }

    return total;
  }

  void _onPaymentMethodSelected(String methodId) {
    setState(() {
      _selectedPaymentMethod = methodId;
    });
  }

  void _onCardDataChanged(Map<String, String> cardData) {
    setState(() {
      _cardData = cardData;
    });
  }

  void _onCouponApplied(Map<String, dynamic>? coupon) {
    setState(() {
      _appliedCoupon = coupon;
    });
  }

  void _onAddressChanged(Map<String, String> address) {
    setState(() {
      _billingAddress = address;
    });
  }

  void _onTimerExpired() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment session expired. Please try again.'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  bool _canProcessPayment() {
    if (!_acceptTerms) return false;

    if (_selectedPaymentMethod == 'new_card') {
      return _cardData.isNotEmpty &&
          _cardData['cardNumber']?.isNotEmpty == true &&
          _cardData['expiry']?.isNotEmpty == true &&
          _cardData['cvv']?.isNotEmpty == true &&
          _cardData['name']?.isNotEmpty == true;
    }

    return true;
  }

  Future<void> _processPayment() async {
    if (!_canProcessPayment()) return;

    // Haptic feedback
    HapticFeedback.mediumImpact();

    setState(() {
      _isProcessingPayment = true;
      _processingStatus = 'Validating payment details...';
    });

    // Simulate different processing steps
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _processingStatus = 'Connecting to payment gateway...');

    await Future.delayed(const Duration(seconds: 1));
    setState(() => _processingStatus = 'Processing payment...');
  }

  void _onPaymentSuccess() {
    setState(() => _isProcessingPayment = false);
    
    // Prepare booking confirmation data
    final confirmationData = Map<String, dynamic>.from(_bookingData);
    confirmationData['referenceNumber'] = 'TE${DateTime.now().millisecondsSinceEpoch}';
    confirmationData['qrCode'] = '${confirmationData['referenceNumber']}_QR_DATA';
    confirmationData['seatNumbers'] = _bookingData['selectedSeats'] ?? [];
    confirmationData['baseFare'] = 'XFA ${(_bookingData['basePrice'] as double? ?? 3500.0) * (_bookingData['selectedSeats'] as List? ?? []).length}';
    confirmationData['taxes'] = 'XFA ${((_bookingData['totalPrice'] as double? ?? 0.0) * 0.12).toInt()}';
    confirmationData['addOns'] = 'XFA 0';
    confirmationData['totalAmount'] = 'XFA ${(_bookingData['totalPrice'] as double? ?? 0.0).toInt()}';
    
    // Generate passenger data based on selected seats
    final selectedSeats = _bookingData['selectedSeats'] as List? ?? [];
    confirmationData['passengers'] = selectedSeats.map((seat) => {
      'name': 'Passager ${selectedSeats.indexOf(seat) + 1}',
      'age': 30,
      'gender': 'Male'
    }).toList();
    
    Navigator.pushReplacementNamed(
      context, 
      AppRoutes.bookingConfirmationScreen,
      arguments: confirmationData,
    );
  }

  void _onPaymentError() {
    setState(() => _isProcessingPayment = false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Failed'),
        content: Text(
            'Your payment could not be processed. Please check your payment details and try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isProcessingPayment,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            _buildBody(),
            PaymentProcessingOverlay(
              isVisible: _isProcessingPayment,
              status: _processingStatus,
              onSuccess: _onPaymentSuccess,
              onError: _onPaymentError,
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Payment'),
      leading: IconButton(
        onPressed:
            _isProcessingPayment ? null : () => Navigator.of(context).pop(),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 4.w),
          child: PaymentTimerWidget(
            initialMinutes: 15,
            onTimerExpired: _onTimerExpired,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    // Debug: Print booking data to see what's being passed
    print('Payment Screen - Data loaded: $_dataLoaded');
    print('Payment Screen - Booking Data: $_bookingData');
    print('Payment Screen - Data keys: ${_bookingData.keys.toList()}');
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          // Add detailed error handling
          Builder(
            builder: (context) {
              try {
                if (!_dataLoaded) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Loading booking details...',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  );
                }
                
                if (_bookingData.isEmpty) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      'No booking data found. Please go back and select seats again.',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  );
                }
                
                // Check required fields
                final requiredFields = ['from', 'to', 'selectedSeats', 'totalPrice'];
                for (String field in requiredFields) {
                  if (!_bookingData.containsKey(field) || _bookingData[field] == null) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Text(
                        'Missing booking information: $field. Please go back and try again.',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                      ),
                    );
                  }
                }
                
                return BookingSummaryCard(bookingData: _bookingData);
              } catch (e, stackTrace) {
                print('Error in payment screen: $e');
                print('Stack trace: $stackTrace');
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error loading booking summary:',
                        style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        e.toString(),
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          SizedBox(height: 2.h),
          _buildPaymentMethodsSection(),
          // Temporarily disable form widgets to isolate GlobalKey issue
          /*if (_selectedPaymentMethod == 'new_card') ...[
            SizedBox(height: 2.h),
            NewCardForm(
              key: const ValueKey('new_card_form'),
              onCardDataChanged: _onCardDataChanged,
            ),
          ],
          SizedBox(height: 2.h),
          BillingAddressSection(
            key: const ValueKey('billing_address_section'),
            onAddressChanged: _onAddressChanged,
          ),
          SizedBox(height: 2.h),
          CouponSection(
            key: const ValueKey('coupon_section'),
            onCouponApplied: _onCouponApplied,
          ),*/
          SizedBox(height: 2.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Form sections temporarily disabled for debugging',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
          SizedBox(height: 2.h),
          _buildTermsSection(),
          SizedBox(height: 10.h), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Payment Method',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _paymentMethods.length,
          itemBuilder: (context, index) {
            final method = _paymentMethods[index];
            return PaymentMethodCard(
              paymentMethod: method,
              isSelected: _selectedPaymentMethod == method["id"],
              onTap: () => _onPaymentMethodSelected(method["id"] as String),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTermsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (value) =>
                    setState(() => _acceptTerms = value ?? false),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                  child: Padding(
                    padding: EdgeInsets.only(top: 2.w),
                    child: RichText(
                      text: TextSpan(
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                        children: [
                          TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.tertiary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.tertiary
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Your payment information is encrypted and secure. We never store your card details.',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final finalAmount = _calculateFinalAmount();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'XFA ${finalAmount.toStringAsFixed(0)}',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canProcessPayment() && !_isProcessingPayment
                    ? _processPayment
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                  foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Pay Now - XFA ${finalAmount.toStringAsFixed(0)}',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
