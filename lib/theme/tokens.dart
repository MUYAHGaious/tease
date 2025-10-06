import 'package:flutter/material.dart';

/// Design tokens for consistent spacing, sizing, and styling
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens();

  // Spacing tokens
  static const double s1 = 4.0;
  static const double s2 = 8.0;
  static const double s3 = 12.0;
  static const double s4 = 16.0;
  static const double s5 = 20.0;
  static const double s6 = 24.0;
  static const double s8 = 32.0;
  static const double s10 = 40.0;
  static const double s12 = 48.0;
  static const double s16 = 64.0;
  static const double s20 = 80.0;
  static const double s24 = 96.0;

  // Border radius tokens
  static const double rSm = 4.0;
  static const double rMd = 8.0;
  static const double rLg = 12.0;
  static const double rXl = 16.0;
  static const double r2Xl = 24.0;
  static const double r3Xl = 32.0;

  // Font size tokens
  static const double textXs = 12.0;
  static const double textSm = 14.0;
  static const double textBase = 16.0;
  static const double textLg = 18.0;
  static const double textXl = 20.0;
  static const double text2Xl = 24.0;
  static const double text3Xl = 30.0;
  static const double text4Xl = 36.0;

  // Font weight tokens
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Shadow tokens
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x24000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  @override
  AppTokens copyWith() {
    return const AppTokens();
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return const AppTokens();
  }

  @override
  bool operator ==(Object other) {
    return other is AppTokens;
  }

  @override
  int get hashCode => 0;
}
