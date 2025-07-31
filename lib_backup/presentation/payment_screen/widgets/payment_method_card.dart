import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PaymentMethodCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onTap(),
                activeColor: AppTheme.lightTheme.colorScheme.secondary,
              ),
              SizedBox(width: 3.w),
              _buildPaymentIcon(),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMethod["title"] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (paymentMethod["subtitle"] != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        paymentMethod["subtitle"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (paymentMethod["type"] == "saved_card" ||
                  paymentMethod["type"] == "digital_wallet")
                CustomIconWidget(
                  iconName: 'fingerprint',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentIcon() {
    final type = paymentMethod["type"] as String;

    switch (type) {
      case "saved_card":
        return Container(
          width: 12.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: CustomIconWidget(
            iconName: 'credit_card',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 20,
          ),
        );
      case "apple_pay":
        return Container(
          width: 12.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              'Pay',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      case "google_pay":
        return Container(
          width: 12.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: const Color(0xFF4285F4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: CustomIconWidget(
            iconName: 'account_balance_wallet',
            color: Colors.white,
            size: 20,
          ),
        );
      case "new_card":
        return Container(
          width: 12.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.secondary
                .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.secondary,
              style: BorderStyle.solid,
            ),
          ),
          child: CustomIconWidget(
            iconName: 'add_card',
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 20,
          ),
        );
      case "digital_wallet":
        return Container(
          width: 12.w,
          height: 8.w,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: CustomIconWidget(
            iconName: 'account_balance_wallet',
            color: AppTheme.lightTheme.colorScheme.tertiary,
            size: 20,
          ),
        );
      default:
        return Container(
          width: 12.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: CustomIconWidget(
            iconName: 'payment',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        );
    }
  }
}
