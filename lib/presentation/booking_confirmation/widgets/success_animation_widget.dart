import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class SuccessAnimationWidget extends StatefulWidget {
  final VoidCallback onAnimationComplete;
  final Map<String, dynamic> bookingData;

  const SuccessAnimationWidget({
    Key? key,
    required this.onAnimationComplete,
    required this.bookingData,
  }) : super(key: key);

  @override
  State<SuccessAnimationWidget> createState() => _SuccessAnimationWidgetState();
}

class _SuccessAnimationWidgetState extends State<SuccessAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _checkController;
  late AnimationController _qrController;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _qrAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _qrController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _celebrationAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    _qrAnimation = CurvedAnimation(
      parent: _qrController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_celebrationAnimation);

    _startAnimation();
  }

  void _startAnimation() async {
    HapticFeedback.heavyImpact();
    await _celebrationController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _checkController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    await _qrController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    widget.onAnimationComplete();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _checkController.dispose();
    _qrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            AppTheme.lightTheme.colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _celebrationAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _checkAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _checkAnimation.value,
                            child: CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              size: 15.w,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 4.h),
              AnimatedBuilder(
                animation: _celebrationAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - _celebrationAnimation.value)),
                    child: Opacity(
                      opacity: _celebrationAnimation.value,
                      child: Column(
                        children: [
                          Text(
                            'Booking Confirmed!',
                            style: AppTheme.lightTheme.textTheme.headlineMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Your bus ticket has been successfully booked',
                            style: AppTheme.lightTheme.textTheme.bodyLarge
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 4.h),
              AnimatedBuilder(
                animation: _qrAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _qrAnimation.value,
                    child: Opacity(
                      opacity: _qrAnimation.value,
                      child: _buildQRCodeSection(),
                    ),
                  );
                },
              ),
              SizedBox(height: 4.h),
              AnimatedBuilder(
                animation: _qrAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - _qrAnimation.value)),
                    child: Opacity(
                      opacity: _qrAnimation.value,
                      child: _buildBookingDetails(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Digital Ticket',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // QR Code placeholder with animated grid pattern
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomPaint(
                    painter: QRCodePainter(),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Booking ID: ${widget.bookingData["bookingId"]}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    widget.bookingData["fromCity"] as String,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              CustomIconWidget(
                iconName: 'arrow_forward',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'To',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    widget.bookingData["toCity"] as String,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem('Date', widget.bookingData["date"] as String),
              _buildDetailItem(
                  'Time', widget.bookingData["departureTime"] as String),
              _buildDetailItem('Seats',
                  (widget.bookingData["selectedSeats"] as List).join(', ')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final blockSize = size.width / 10;

    // Create a simple QR-like pattern
    final pattern = [
      [1, 1, 1, 0, 0, 0, 1, 1, 1, 0],
      [1, 0, 1, 0, 1, 0, 1, 0, 1, 0],
      [1, 1, 1, 0, 0, 0, 1, 1, 1, 0],
      [0, 0, 0, 1, 1, 1, 0, 0, 0, 1],
      [1, 0, 1, 0, 1, 0, 1, 0, 1, 0],
      [0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
      [1, 1, 1, 0, 0, 0, 1, 1, 1, 0],
      [1, 0, 1, 0, 1, 0, 1, 0, 1, 0],
      [1, 1, 1, 0, 0, 0, 1, 1, 1, 0],
      [0, 0, 0, 1, 1, 1, 0, 0, 0, 1],
    ];

    for (int i = 0; i < pattern.length; i++) {
      for (int j = 0; j < pattern[i].length; j++) {
        if (pattern[i][j] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              j * blockSize,
              i * blockSize,
              blockSize,
              blockSize,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
