import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class PayNowButton extends StatefulWidget {
  final String amount;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const PayNowButton({
    Key? key,
    required this.amount,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<PayNowButton> createState() => _PayNowButtonState();
}

class _PayNowButtonState extends State<PayNowButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _loadingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));
  }

  @override
  void didUpdateWidget(PayNowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
        _loadingController.reset();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _scaleController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.isEnabled && !widget.isLoading) {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.isEnabled && !widget.isLoading
                  ? widget.onPressed
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 7.h,
                decoration: BoxDecoration(
                  gradient: widget.isEnabled
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.lightTheme.colorScheme.secondary,
                            AppTheme.lightTheme.colorScheme.secondary
                                .withValues(alpha: 0.8),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3),
                            Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.2),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: widget.isEnabled
                      ? [
                          BoxShadow(
                            color: AppTheme.lightTheme.colorScheme.secondary
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: widget.isLoading
                            ? _buildLoadingContent()
                            : _buildButtonContent(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconWidget(
          iconName: 'payment',
          color: widget.isEnabled
              ? AppTheme.lightTheme.colorScheme.onSecondary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          size: 24,
        ),
        SizedBox(width: 3.w),
        Text(
          'Pay ${widget.amount}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: widget.isEnabled
                    ? AppTheme.lightTheme.colorScheme.onSecondary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
        ),
        SizedBox(width: 3.w),
        CustomIconWidget(
          iconName: 'arrow_forward',
          color: widget.isEnabled
              ? AppTheme.lightTheme.colorScheme.onSecondary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          size: 20,
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                size: 24,
              ),
            );
          },
        ),
        SizedBox(width: 3.w),
        Text(
          'Processing Payment...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}