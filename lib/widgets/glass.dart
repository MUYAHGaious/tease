import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const Glass({super.key, required this.child, this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.rLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(AppTokens.rLg),
              border:
                  Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Padding(
                padding: padding ?? const EdgeInsets.all(AppTokens.s4),
                child: child),
          ),
        ),
      ),
    );
  }
}
