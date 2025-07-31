import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class FareSummaryWidget extends StatefulWidget {
  final Map<String, dynamic> fareData;
  final int passengerCount;
  final bool isValid;
  final VoidCallback onContinuePressed;

  const FareSummaryWidget({
    Key? key,
    required this.fareData,
    required this.passengerCount,
    required this.isValid,
    required this.onContinuePressed,
  }) : super(key: key);

  @override
  State<FareSummaryWidget> createState() => _FareSummaryWidgetState();
}

class _FareSummaryWidgetState extends State<FareSummaryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get _baseFare => (widget.fareData['baseFare'] ?? 45.0).toDouble();
  double get _taxes => (widget.fareData['taxes'] ?? 5.0).toDouble();
  double get _serviceFee => (widget.fareData['serviceFee'] ?? 2.5).toDouble();
  double get _discount => (widget.fareData['discount'] ?? 0.0).toDouble();
  double get _subtotal =>
      (_baseFare + _taxes + _serviceFee) * widget.passengerCount;
  double get _totalAmount => _subtotal - _discount;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with expand/collapse
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'receipt',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 24,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fare Summary',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              '${widget.passengerCount} Passenger${widget.passengerCount > 1 ? 's' : ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${_totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(width: 2.w),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: CustomIconWidget(
                          iconName: 'expand_more',
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable fare breakdown
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _isExpanded ? null : 0,
                child: _isExpanded
                    ? Container(
                        padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
                        child: Column(
                          children: [
                            // Divider
                            Container(
                              height: 1,
                              margin: EdgeInsets.symmetric(vertical: 2.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            // Base fare
                            _buildFareRow(
                              'Base Fare',
                              '\$${_baseFare.toStringAsFixed(2)} × ${widget.passengerCount}',
                              '\$${(_baseFare * widget.passengerCount).toStringAsFixed(2)}',
                            ),

                            SizedBox(height: 1.h),

                            // Taxes
                            _buildFareRow(
                              'Taxes & Fees',
                              '\$${_taxes.toStringAsFixed(2)} × ${widget.passengerCount}',
                              '\$${(_taxes * widget.passengerCount).toStringAsFixed(2)}',
                            ),

                            SizedBox(height: 1.h),

                            // Service fee
                            _buildFareRow(
                              'Service Fee',
                              '\$${_serviceFee.toStringAsFixed(2)} × ${widget.passengerCount}',
                              '\$${(_serviceFee * widget.passengerCount).toStringAsFixed(2)}',
                            ),

                            if (_discount > 0) ...[
                              SizedBox(height: 1.h),
                              _buildFareRow(
                                'Discount',
                                'Applied',
                                '-\$${_discount.toStringAsFixed(2)}',
                                isDiscount: true,
                              ),
                            ],

                            SizedBox(height: 2.h),

                            // Subtotal divider
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 2.h),

                            // Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Text(
                                  '\$${_totalAmount.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Continue button
              Container(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    if (!widget.isValid)
                      Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.error
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.error
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'warning',
                              color: AppTheme.lightTheme.colorScheme.error,
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                'Please complete all required passenger details to continue.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          AppTheme.lightTheme.colorScheme.error,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 12.w,
                      child: ElevatedButton(
                        onPressed:
                            widget.isValid ? widget.onContinuePressed : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.isValid
                              ? AppTheme.lightTheme.colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          foregroundColor: widget.isValid
                              ? AppTheme.lightTheme.colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          elevation: widget.isValid ? 4 : 0,
                          shadowColor: widget.isValid
                              ? AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.3)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue to Payment',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: widget.isValid
                                        ? AppTheme
                                            .lightTheme.colorScheme.onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(width: 2.w),
                            CustomIconWidget(
                              iconName: 'arrow_forward',
                              color: widget.isValid
                                  ? AppTheme.lightTheme.colorScheme.onPrimary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFareRow(String label, String description, String amount,
      {bool isDiscount = false}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDiscount
                    ? AppTheme.lightTheme.colorScheme.tertiary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}