import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AnimatedToggleWidget extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  const AnimatedToggleWidget({
    Key? key,
    required this.value,
    required this.onChanged,
    this.label,
  }) : super(key: key);

  @override
  State<AnimatedToggleWidget> createState() => _AnimatedToggleWidgetState();
}

class _AnimatedToggleWidgetState extends State<AnimatedToggleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
      widget.onChanged(!widget.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 12.w,
              height: 6.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.w),
                color: widget.value
                    ? AppTheme.primaryLight
                    : AppTheme.surfaceVariantLight,
                boxShadow: [
                  BoxShadow(
                    color: widget.value
                        ? AppTheme.primaryLight.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: widget.value ? 6.5.w : 0.5.w,
                    top: 0.5.w,
                    child: Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
