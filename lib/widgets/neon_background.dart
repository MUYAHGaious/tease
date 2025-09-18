import 'dart:ui';
import 'package:flutter/material.dart';

class NeonBackground extends StatelessWidget {
  final Widget child;
  const NeonBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFFE8FF96), Color(0xFFCAB8FF)],
        ),
      ),
      child: Stack(children: [
        Container(decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.black.withOpacity(.20), Colors.transparent],
            radius: 1.0, center: const Alignment(-.9, -.9),
          ),
        )),
        BackdropFilter(filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24), child: Container(color: cs.surface.withOpacity(.25))),
        child,
      ]),
    );
  }
}
