import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PaymentProcessingOverlay extends StatefulWidget {
  final bool isVisible;
  final String status;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const PaymentProcessingOverlay({
    Key? key,
    required this.isVisible,
    this.status = 'Processing payment...',
    this.onSuccess,
    this.onError,
  }) : super(key: key);

  @override
  State<PaymentProcessingOverlay> createState() =>
      _PaymentProcessingOverlayState();
}

class _PaymentProcessingOverlayState extends State<PaymentProcessingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _successController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _successAnimation;

  bool _showSuccess = false;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
      _simulatePaymentProcess();
    }
  }

  @override
  void didUpdateWidget(PaymentProcessingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _animationController.forward();
      _simulatePaymentProcess();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _animationController.reverse();
    }
  }

  void _simulatePaymentProcess() async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    // 90% success rate simulation
    final isSuccess = DateTime.now().millisecond % 10 != 0;

    if (isSuccess) {
      setState(() => _showSuccess = true);
      _successController.forward();
      await Future.delayed(const Duration(seconds: 2));
      widget.onSuccess?.call();
    } else {
      setState(() => _showError = true);
      await Future.delayed(const Duration(seconds: 2));
      widget.onError?.call();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusIcon(),
                          SizedBox(height: 3.h),
                          _buildStatusText(),
                          SizedBox(height: 2.h),
                          if (!_showSuccess && !_showError)
                            _buildProgressIndicator(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon() {
    if (_showSuccess) {
      return AnimatedBuilder(
        animation: _successAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _successAnimation.value,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check',
                color: AppTheme.lightTheme.colorScheme.onTertiary,
                size: 40,
              ),
            ),
          );
        },
      );
    } else if (_showError) {
      return Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.error,
          shape: BoxShape.circle,
        ),
        child: CustomIconWidget(
          iconName: 'close',
          color: AppTheme.lightTheme.colorScheme.onError,
          size: 40,
        ),
      );
    } else {
      return Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: CustomIconWidget(
          iconName: 'payment',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 40,
        ),
      );
    }
  }

  Widget _buildStatusText() {
    String title;
    String subtitle;
    Color titleColor;

    if (_showSuccess) {
      title = 'Payment Successful!';
      subtitle = 'Your booking has been confirmed';
      titleColor = AppTheme.lightTheme.colorScheme.tertiary;
    } else if (_showError) {
      title = 'Payment Failed';
      subtitle = 'Please try again or use a different payment method';
      titleColor = AppTheme.lightTheme.colorScheme.error;
    } else {
      title = 'Processing Payment';
      subtitle = widget.status;
      titleColor = AppTheme.lightTheme.colorScheme.primary;
    }

    return Column(
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          subtitle,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 8.w,
          height: 8.w,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Please do not close this screen',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
