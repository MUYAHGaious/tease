import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class NewCardForm extends StatefulWidget {
  final Function(Map<String, String>) onCardDataChanged;

  const NewCardForm({
    Key? key,
    required this.onCardDataChanged,
  }) : super(key: key);

  @override
  State<NewCardForm> createState() => _NewCardFormState();
}

class _NewCardFormState extends State<NewCardForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  String _cardType = 'unknown';
  bool _showCvvTooltip = false;

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_onCardNumberChanged);
    _expiryController.addListener(_onFormChanged);
    _cvvController.addListener(_onFormChanged);
    _nameController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onCardNumberChanged() {
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    setState(() {
      _cardType = _detectCardType(cardNumber);
    });
    _onFormChanged();
  }

  void _onFormChanged() {
    final cardData = {
      'cardNumber': _cardNumberController.text,
      'expiry': _expiryController.text,
      'cvv': _cvvController.text,
      'name': _nameController.text,
      'cardType': _cardType,
    };
    widget.onCardDataChanged(cardData);
  }

  String _detectCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'visa';
    if (cardNumber.startsWith('5') || cardNumber.startsWith('2'))
      return 'mastercard';
    if (cardNumber.startsWith('3')) return 'amex';
    if (cardNumber.startsWith('6')) return 'discover';
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Information',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildCardNumberField(),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(child: _buildExpiryField()),
                SizedBox(width: 4.w),
                Expanded(child: _buildCvvField()),
              ],
            ),
            SizedBox(height: 2.h),
            _buildNameField(),
            SizedBox(height: 2.h),
            _buildSecurityBadges(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(19),
        _CardNumberInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: 'Card Number',
        hintText: '1234 5678 9012 3456',
        suffixIcon: _buildCardTypeIcon(),
        prefixIcon: CustomIconWidget(
          iconName: 'credit_card',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter card number';
        }
        final cardNumber = value.replaceAll(' ', '');
        if (cardNumber.length < 13 || cardNumber.length > 19) {
          return 'Invalid card number';
        }
        return null;
      },
    );
  }

  Widget _buildExpiryField() {
    return TextFormField(
      controller: _expiryController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        _ExpiryDateInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: 'MM/YY',
        hintText: '12/25',
        prefixIcon: CustomIconWidget(
          iconName: 'calendar_today',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (value.length != 5) {
          return 'Invalid';
        }
        return null;
      },
    );
  }

  Widget _buildCvvField() {
    return TextFormField(
      controller: _cvvController,
      keyboardType: TextInputType.number,
      obscureText: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      decoration: InputDecoration(
        labelText: 'CVV',
        hintText: '123',
        prefixIcon: CustomIconWidget(
          iconName: 'security',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _showCvvTooltip = !_showCvvTooltip),
          child: CustomIconWidget(
            iconName: 'help_outline',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (value.length < 3 || value.length > 4) {
          return 'Invalid';
        }
        return null;
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Cardholder Name',
        hintText: 'John Doe',
        prefixIcon: CustomIconWidget(
          iconName: 'person',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter cardholder name';
        }
        if (value.length < 2) {
          return 'Name too short';
        }
        return null;
      },
    );
  }

  Widget _buildCardTypeIcon() {
    if (_cardType == 'unknown') return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.all(2.w),
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _cardType.toUpperCase(),
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.lightTheme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Widget _buildSecurityBadges() {
    return Row(
      children: [
        _buildSecurityBadge('SSL', 'Secure'),
        SizedBox(width: 3.w),
        _buildSecurityBadge('PCI', 'Compliant'),
        SizedBox(width: 3.w),
        _buildSecurityBadge('256-bit', 'Encryption'),
      ],
    );
  }

  Widget _buildSecurityBadge(String title, String subtitle) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.tertiary,
              fontWeight: FontWeight.w600,
              fontSize: 9.sp,
            ),
          ),
          Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.tertiary,
              fontSize: 8.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.length == 2 && oldValue.text.length == 1) {
      return TextEditingValue(
        text: '$text/',
        selection: TextSelection.collapsed(offset: 3),
      );
    }

    return newValue;
  }
}