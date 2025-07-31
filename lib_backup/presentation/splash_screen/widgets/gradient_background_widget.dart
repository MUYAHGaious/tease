import 'package:flutter/material.dart';


class GradientBackgroundWidget extends StatelessWidget {
  final Widget child;

  const GradientBackgroundWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A4A47),
            Color(0xFF2A5D5A),
            Color(0xFF1A4A47),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.transparent,
              Color(0xFF1A4A47),
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}
