import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class GlassmorphismOverlayWidget extends StatefulWidget {
  const GlassmorphismOverlayWidget({Key? key}) : super(key: key);

  @override
  State<GlassmorphismOverlayWidget> createState() =>
      _GlassmorphismOverlayWidgetState();
}

class _GlassmorphismOverlayWidgetState extends State<GlassmorphismOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late List<AnimationController> _cardControllers;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSequentialAnimation();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _cardAnimations = _cardControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ));
    }).toList();
  }

  void _startSequentialAnimation() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _fadeController.forward();

    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      _cardControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildGlassCard({
    required double top,
    required double left,
    required double width,
    required double height,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _cardAnimations[index],
      builder: (context, child) {
        return Positioned(
          top: top,
          left: left,
          child: Transform.scale(
            scale: _cardAnimations[index].value,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.lightTheme.colorScheme.surface
                              .withValues(alpha: 0.2),
                          AppTheme.lightTheme.colorScheme.surface
                              .withValues(alpha: 0.1),
                        ],
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: SizedBox(
        width: 100.w,
        height: 100.h,
        child: Stack(
          children: [
            _buildGlassCard(
              top: 15.h,
              left: 10.w,
              width: 25.w,
              height: 12.h,
              index: 0,
            ),
            _buildGlassCard(
              top: 20.h,
              left: 65.w,
              width: 20.w,
              height: 10.h,
              index: 1,
            ),
            _buildGlassCard(
              top: 65.h,
              left: 15.w,
              width: 22.w,
              height: 8.h,
              index: 2,
            ),
            _buildGlassCard(
              top: 70.h,
              left: 70.w,
              width: 18.w,
              height: 9.h,
              index: 3,
            ),
          ],
        ),
      ),
    );
  }
}
