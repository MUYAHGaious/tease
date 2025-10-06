import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ScanResultOverlayWidget extends StatefulWidget {
  final String? scannedCode;
  final bool isSuccess;
  final String message;
  final String? studentName;
  final VoidCallback onDismiss;

  const ScanResultOverlayWidget({
    Key? key,
    required this.scannedCode,
    required this.isSuccess,
    required this.message,
    this.studentName,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<ScanResultOverlayWidget> createState() =>
      _ScanResultOverlayWidgetState();
}

class _ScanResultOverlayWidgetState extends State<ScanResultOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    // Trigger haptic feedback
    if (widget.isSuccess) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }

    // Start animations
    _fadeController.forward();
    _scaleController.forward();

    // Auto dismiss after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismissOverlay();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _dismissOverlay() async {
    await _fadeController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            color: scheme.scrim.withOpacity(0.6),
            child: Center(
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildResultCard(),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultCard() {
    final scheme = Theme.of(context).colorScheme;
    final backgroundColor = widget.isSuccess ? scheme.primary : scheme.error;
    final textColor = widget.isSuccess ? scheme.onPrimary : scheme.onError;
    final iconName = widget.isSuccess ? 'check_circle' : 'error';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success/Error Icon
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: textColor,
              size: 48,
            ),
          ),
          SizedBox(height: 3.h),

          // Student Name (if success)
          if (widget.isSuccess && widget.studentName != null) ...[
            Text(
              widget.studentName!,
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
          ],

          // Status Message
          Text(
            widget.isSuccess ? 'Successfully Boarded!' : 'Scan Failed',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),

          // Detailed Message
          Text(
            widget.message,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: textColor.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          // QR Code Info (if available)
          if (widget.scannedCode != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'QR Code:',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    widget.scannedCode!,
                    style: AppTheme.dataTextStyle(
                      isLight: true,
                      fontSize: 12.sp,
                    ).copyWith(
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 3.h),

          // Dismiss Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _dismissOverlay,
              style: TextButton.styleFrom(
                foregroundColor: textColor,
                backgroundColor: textColor.withValues(alpha: 0.1),
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Continue Scanning',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
