import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class CouponSection extends StatefulWidget {
  final Function(Map<String, dynamic>?) onCouponApplied;

  const CouponSection({
    Key? key,
    required this.onCouponApplied,
  }) : super(key: key);

  @override
  State<CouponSection> createState() => _CouponSectionState();
}

class _CouponSectionState extends State<CouponSection> {
  bool _isExpanded = false;
  final _couponController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _appliedCoupon;
  String? _errorMessage;

  // Mock coupon data
  final List<Map<String, dynamic>> _availableCoupons = [
    {
      "code": "SAVE20",
      "title": "20% Off",
      "description": "Get 20% off on your booking",
      "discount": 0.20,
      "type": "percentage",
      "minAmount": 50.0,
      "maxDiscount": 25.0,
    },
    {
      "code": "FIRST10",
      "title": "First Ride",
      "description": "\$10 off for first-time users",
      "discount": 10.0,
      "type": "fixed",
      "minAmount": 30.0,
      "maxDiscount": 10.0,
    },
    {
      "code": "WEEKEND15",
      "title": "Weekend Special",
      "description": "15% off on weekend bookings",
      "discount": 0.15,
      "type": "percentage",
      "minAmount": 40.0,
      "maxDiscount": 20.0,
    },
  ];

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final coupon = _availableCoupons.firstWhere(
      (c) => (c["code"] as String).toUpperCase() == code,
      orElse: () => {},
    );

    setState(() {
      _isLoading = false;
      if (coupon.isNotEmpty) {
        _appliedCoupon = coupon;
        _errorMessage = null;
        widget.onCouponApplied(coupon);
      } else {
        _appliedCoupon = null;
        _errorMessage = 'Invalid coupon code';
        widget.onCouponApplied(null);
      }
    });
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponController.clear();
      _errorMessage = null;
    });
    widget.onCouponApplied(null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (_isExpanded) _buildExpandedContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'local_offer',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _appliedCoupon != null ? 'Coupon Applied' : 'Apply Coupon',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_appliedCoupon != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      '${_appliedCoupon!["code"]} - ${_appliedCoupon!["title"]}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      'Save money with promo codes',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_appliedCoupon != null)
              IconButton(
                onPressed: _removeCoupon,
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 20,
                ),
              )
            else
              CustomIconWidget(
                iconName:
                    _isExpanded ? 'keyboard_arrow_up' : 'keyboard_arrow_down',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppTheme.lightTheme.dividerColor),
          SizedBox(height: 2.h),
          _buildCouponInput(),
          if (_errorMessage != null) ...[
            SizedBox(height: 1.h),
            _buildErrorMessage(),
          ],
          SizedBox(height: 3.h),
          _buildAvailableCoupons(),
        ],
      ),
    );
  }

  Widget _buildCouponInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _couponController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Promo Code',
              hintText: 'Enter coupon code',
              prefixIcon: CustomIconWidget(
                iconName: 'confirmation_number',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            ),
            onFieldSubmitted: (_) => _applyCoupon(),
          ),
        ),
        SizedBox(width: 3.w),
        ElevatedButton(
          onPressed: _isLoading ? null : _applyCoupon,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
            foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.colorScheme.onSecondary,
                    ),
                  ),
                )
              : Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'error_outline',
            color: AppTheme.lightTheme.colorScheme.error,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            _errorMessage!,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableCoupons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Coupons',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        ...(_availableCoupons
            .map((coupon) => _buildCouponCard(coupon))
            .toList()),
      ],
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color:
            AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.2),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              coupon["code"] as String,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon["title"] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  coupon["description"] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              _couponController.text = coupon["code"] as String;
              _applyCoupon();
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }
}
