import 'package:flutter/material.dart';
import 'tokens.dart';

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF8763FF),
    brightness: brightness,
  ).copyWith(
    surface: brightness == Brightness.dark ? const Color(0xFF14161C) : const Color(0xFFF7F8FA),
    onSurface: brightness == Brightness.dark ? Colors.white : const Color(0xFF16181D),
    primary: const Color(0xFF8763FF),
  );

  final text = ThemeData(brightness: brightness).textTheme.apply(fontFamily: 'Inter');

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
      indicatorColor: scheme.primary.withOpacity(.12),
      backgroundColor: scheme.surface.withOpacity(.85),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface.withOpacity(.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(const AppTokens().rMd),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      contentPadding: EdgeInsets.all(const AppTokens().s3),
    ),
  );
}
