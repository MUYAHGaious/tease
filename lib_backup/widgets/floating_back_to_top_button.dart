import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';

class FloatingBackToTopButton extends StatefulWidget {
  final ScrollController scrollController;
  final double showOffset;
  final Color? backgroundColor;
  final Color? iconColor;

  const FloatingBackToTopButton({
    Key? key,
    required this.scrollController,
    this.showOffset = 200.0,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  State<FloatingBackToTopButton> createState() => _FloatingBackToTopButtonState();
}

class _FloatingBackToTopButtonState extends State<FloatingBackToTopButton>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupScrollListener() {
    widget.scrollController.addListener(() {
      final shouldShow = widget.scrollController.offset > widget.showOffset;
      
      if (shouldShow != _isVisible) {
        setState(() {
          _isVisible = shouldShow;
        });
        
        if (_isVisible) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      }
    });
  }

  void _scrollToTop() {
    HapticFeedback.mediumImpact();
    
    // Calculate smooth scroll duration based on current position
    final currentOffset = widget.scrollController.offset;
    final scrollDuration = Duration(
      milliseconds: (currentOffset / 10).clamp(400, 1200).round(),
    );
    
    // Very smooth scroll with custom curve
    widget.scrollController.animateTo(
      0.0,
      duration: scrollDuration,
      curve: Curves.easeOutQuart,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        if (!_isVisible && _animationController.value == 0.0) {
          return const SizedBox.shrink();
        }

        return Positioned(
          right: 4.w,
          bottom: 12.h,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.w),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A4A47).withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFFC8E53F).withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.w),
                  child: Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A4A47),
                          const Color(0xFF2A5D5A),
                          const Color(0xFF1A4A47),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.1),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _scrollToTop,
                          borderRadius: BorderRadius.circular(4.w),
                          splashColor: const Color(0xFFC8E53F).withValues(alpha: 0.2),
                          highlightColor: const Color(0xFFC8E53F).withValues(alpha: 0.1),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.w),
                            ),
                            child: Stack(
                              children: [
                                // Glassmorphism effect
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.w),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.15),
                                        Colors.white.withValues(alpha: 0.05),
                                      ],
                                    ),
                                  ),
                                ),
                                // Content
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.all(1.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC8E53F).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(2.w),
                                    ),
                                    child: CustomIconWidget(
                                      iconName: 'keyboard_arrow_up',
                                      color: const Color(0xFFC8E53F),
                                      size: 6.w,
                                    ),
                                  ),
                                ),
                                // Shine effect
                                Positioned(
                                  top: 1.w,
                                  left: 1.w,
                                  right: 1.w,
                                  child: Container(
                                    height: 2.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(1.w),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withValues(alpha: 0.4),
                                          Colors.white.withValues(alpha: 0.1),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}