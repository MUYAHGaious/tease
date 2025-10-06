import 'package:flutter/material.dart';
import 'tokens.dart';

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF008B8B), // Teal - same as bottom nav
    brightness: brightness,
  ).copyWith(
    surface: brightness == Brightness.dark
        ? const Color(0xFF14161C)
        : const Color(0xFFF7F8FA),
    onSurface:
        brightness == Brightness.dark ? Colors.white : const Color(0xFF16181D),
    primary: const Color(0xFF008B8B), // Teal - same as bottom nav
  );

  final text =
      ThemeData(brightness: brightness).textTheme.apply(fontFamily: 'Inter');

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: text,
    scaffoldBackgroundColor: scheme.surface,
    extensions: const [AppTokens()],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      indicatorColor: scheme.primary.withValues(alpha: 0.12),
      backgroundColor: scheme.surface.withValues(alpha: 0.85),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface.withValues(alpha: 0.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.rMd),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      contentPadding: const EdgeInsets.all(AppTokens.s3),
    ),
  );
}
