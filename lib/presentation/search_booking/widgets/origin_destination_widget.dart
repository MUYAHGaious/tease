import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OriginDestinationWidget extends StatefulWidget {
  final String? origin;
  final String? destination;
  final Function(String) onOriginChanged;
  final Function(String) onDestinationChanged;
  final VoidCallback onSwap;

  const OriginDestinationWidget({
    super.key,
    this.origin,
    this.destination,
    required this.onOriginChanged,
    required this.onDestinationChanged,
    required this.onSwap,
  });

  @override
  State<OriginDestinationWidget> createState() =>
      _OriginDestinationWidgetState();
}

class _OriginDestinationWidgetState extends State<OriginDestinationWidget>
    with TickerProviderStateMixin {
  late AnimationController _swapController;
  late Animation<double> _swapAnimation;

  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _swapController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _swapAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _swapController,
      curve: Curves.elasticOut,
    ));

    _originController.text = widget.origin ?? '';
    _destinationController.text = widget.destination ?? '';
  }

  @override
  void dispose() {
    _swapController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _handleSwap() {
    _swapController.forward().then((_) {
      final temp = _originController.text;
      _originController.text = _destinationController.text;
      _destinationController.text = temp;

      widget.onOriginChanged(_originController.text);
      widget.onDestinationChanged(_destinationController.text);
      widget.onSwap();

      _swapController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Origin Input
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _originController,
              onChanged: widget.onOriginChanged,
              decoration: InputDecoration(
                hintText: 'From',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'location_on',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
                hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                ),
              ),
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          SizedBox(height: 1.h),

          // Swap Button
          Center(
            child: GestureDetector(
              onTap: _handleSwap,
              child: AnimatedBuilder(
                animation: _swapAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _swapAnimation.value * 3.14159,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowLight,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CustomIconWidget(
                        iconName: 'swap_vert',
                        color: AppTheme.lightTheme.colorScheme.onSecondary,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 1.h),

          // Destination Input
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _destinationController,
              onChanged: widget.onDestinationChanged,
              decoration: InputDecoration(
                hintText: 'To',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'location_on',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
                hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                ),
              ),
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
