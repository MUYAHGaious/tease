import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/app_export.dart';

class PaymentMethodWidget extends StatefulWidget {
  final Function(String) onPaymentMethodSelected;
  final Function(Map<String, dynamic>) onPaymentDataChanged;

  const PaymentMethodWidget({
    Key? key,
    required this.onPaymentMethodSelected,
    required this.onPaymentDataChanged,
  }) : super(key: key);

  @override
  State<PaymentMethodWidget> createState() => _PaymentMethodWidgetState();
}

class _PaymentMethodWidgetState extends State<PaymentMethodWidget>
    with TickerProviderStateMixin {
  late AnimationController _selectionController;
  late Animation<double> _selectionAnimation;

  String _selectedMethod = 'mtn_momo';
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'mtn_momo',
      'name': 'MTN Mobile Money',
      'icon': 'images/mtn-logo.svg',
      'description': 'Mobile payment via MTN network',
    },
    {
      'id': 'orange_money',
      'name': 'Orange Money',
      'icon': 'images/orange-money-logo.svg',
      'description': 'Mobile payment via Orange network',
    },
    {
      'id': 'visa',
      'name': 'Visa Card',
      'icon': 'images/visa-logo.svg',
      'description': 'Pay with your Visa credit/debit card',
    },
    {
      'id': 'mastercard',
      'name': 'Mastercard',
      'icon': 'images/mastercard-logo.svg',
      'description': 'Pay with your Mastercard credit/debit card',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    );

    _selectionController.forward();
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _selectPaymentMethod(String methodId) {
    if (_selectedMethod != methodId) {
      setState(() {
        _selectedMethod = methodId;
      });
      widget.onPaymentMethodSelected(methodId);
      HapticFeedback.selectionClick();
      _selectionController.reset();
      _selectionController.forward();
    }
  }

  void _updatePaymentData() {
    widget.onPaymentDataChanged({
      'method': _selectedMethod,
      'cardNumber': _cardNumberController.text,
      'expiry': _expiryController.text,
      'cvv': _cvvController.text,
      'name': _nameController.text,
    });
  }

  IconData _getFallbackIcon(String methodId) {
    switch (methodId) {
      case 'mtn_momo':
        return Icons.phone_android;
      case 'orange_money':
        return Icons.phone_android;
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  Color _getBrandColor(String methodId) {
    switch (methodId) {
      case 'mtn_momo':
        return Colors.yellow[700]!;
      case 'orange_money':
        return Colors.orange;
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Payment Method',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildPaymentMethodsList(),
            SizedBox(height: 2.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedMethod == 'credit_card'
                  ? _buildCreditCardForm()
                  : _buildAlternativePaymentInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return Column(
      children: _paymentMethods.map((method) {
        bool isSelected = _selectedMethod == method['id'];
        return AnimatedBuilder(
          animation: _selectionAnimation,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(bottom: 1.h),
              child: InkWell(
                onTap: () => _selectPaymentMethod(method['id']),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primaryContainer
                            .withValues(alpha: 0.2)
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1)
                              : AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: method['icon'].endsWith('.svg')
                            ? Opacity(
                                opacity: isSelected ? 1.0 : 0.7,
                                child: SvgPicture.asset(
                                  'assets/${method['icon']}',
                                  width: 6.w,
                                  height: 6.w,
                                  placeholderBuilder: (context) => Container(
                                    width: 6.w,
                                    height: 6.w,
                                    decoration: BoxDecoration(
                                      color: _getBrandColor(method['id']).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      _getFallbackIcon(method['id']),
                                      color: _getBrandColor(method['id']),
                                      size: 4.w,
                                    ),
                                  ),
                                ),
                              )
                            : CustomIconWidget(
                                iconName: method['icon'],
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                size: 6.w,
                              ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method['name'],
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              method['description'],
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedScale(
                        scale: isSelected ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 5.w,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCreditCardForm() {
    return Container(
      key: const ValueKey('credit_card_form'),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Information',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            onChanged: (value) => _updatePaymentData(),
          ),
          SizedBox(height: 1.5.h),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'John Doe',
            ),
            onChanged: (value) => _updatePaymentData(),
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'MM/YY',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: (value) => _updatePaymentData(),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  onChanged: (value) => _updatePaymentData(),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'security',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Your payment information is encrypted and secure',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativePaymentInfo() {
    final selectedMethodData = _paymentMethods.firstWhere(
      (method) => method['id'] == _selectedMethod,
    );

    return Container(
      key: ValueKey('alternative_payment_$_selectedMethod'),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          selectedMethodData['icon'].endsWith('.svg')
              ? SvgPicture.asset(
                  'assets/${selectedMethodData['icon']}',
                  width: 12.w,
                  height: 12.w,
                )
              : CustomIconWidget(
                  iconName: selectedMethodData['icon'],
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 12.w,
                ),
          SizedBox(height: 2.h),
          Text(
            'You will be redirected to ${selectedMethodData['name']} to complete your payment securely.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'security',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Secure Payment',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
