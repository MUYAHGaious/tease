import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool filled;

  const AppButton(
      {super.key, required this.text, this.onPressed, this.filled = true});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rLg)),
      backgroundColor: filled ? cs.primary : Colors.transparent,
      foregroundColor: filled ? cs.onPrimary : cs.onSurface,
      side: filled ? null : BorderSide(color: cs.outline),
    );
    return ElevatedButton(
        onPressed: onPressed, style: style, child: Text(text));
  }
}
