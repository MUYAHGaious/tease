import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class PaymentMethodCard extends StatefulWidget {
  final Map<String, dynamic> paymentMethod;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    Key? key,
    required this.paymentMethod,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _borderColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: AppTheme.lightTheme.colorScheme.secondary,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(PaymentMethodCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: 90.w,
              margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkTheme.colorScheme.surface
                        .withValues(alpha: 0.9)
                    : AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isSelected
                      ? _borderColorAnimation.value ??
                          AppTheme.lightTheme.colorScheme.secondary
                      : (isDark
                          ? AppTheme.darkTheme.colorScheme.outline
                              .withValues(alpha: 0.2)
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2)),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.2)
                        : (isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.05)),
                    blurRadius: widget.isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Row(
                    children: [
                      _buildPaymentIcon(),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: _buildPaymentInfo(),
                      ),
                      _buildSelectionIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentIcon() {
    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: widget.paymentMethod['icon'] as String,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.paymentMethod['title'] as String,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 0.5.h),
        Text(
          widget.paymentMethod['subtitle'] as String,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        if (widget.paymentMethod['discount'] != null) ...[
          SizedBox(height: 0.5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.paymentMethod['discount'] as String,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectionIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 6.w,
      height: 6.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isSelected
            ? AppTheme.lightTheme.colorScheme.secondary
            : Colors.transparent,
        border: Border.all(
          color: widget.isSelected
              ? AppTheme.lightTheme.colorScheme.secondary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: widget.isSelected
          ? Center(
              child: CustomIconWidget(
                iconName: 'check',
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                size: 16,
              ),
            )
          : null,
    );
  }
}