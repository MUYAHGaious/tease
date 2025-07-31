import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the bus travel booking application.
class AppTheme {
  AppTheme._();

  // Custom Brand Palette - Color specifications
  static const Color primaryLight =
      Color(0xFF1A4A47); // Deep brand teal #1a4a47
  static const Color primaryVariantLight =
      Color(0xFF2A5D5A); // Secondary brand teal #2a5d5a
  static const Color secondaryLight =
      Color(0xFFC8E53F); // Brand lime green #c8e53f
  static const Color secondaryVariantLight =
      Color(0xFFA3C635); // Darker lime for hover states
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure white #fff
  static const Color surfaceLight =
      Color(0xFF2A5D5A); // Secondary brand teal for card backgrounds
  static const Color errorLight =
      Color(0xFFE74C3C); // Clear red for validation errors
  static const Color successLight =
      Color(0xFF27AE60); // Clean green for confirmations
  static const Color onPrimaryLight =
      Color(0xFFFFFFFF); // High contrast white text
  static const Color onSecondaryLight = Color(0xFF1A4A47);
  static const Color onBackgroundLight = Color(0xFF1A4A47);
  static const Color onSurfaceLight = Color(0xFFFFFFFF);
  static const Color onErrorLight = Color(0xFFFFFFFF);

  static const Color primaryDark =
      Color(0xFF1A4A47); // Deep brand teal maintained for dark theme
  static const Color primaryVariantDark =
      Color(0xFF0F3A37); // Darker teal for elevated surfaces  
  static const Color secondaryDark =
      Color(0xFFC8E53F); // Brand lime green maintained
  static const Color secondaryVariantDark =
      Color(0xFFA3C635); // Darker lime maintained
  static const Color backgroundDark =
      Color(0xFF0F3A37); // Darker teal background
  static const Color surfaceDark = Color(0xFF1A4A47); // Deep brand teal for surfaces
  static const Color errorDark = Color(0xFFE74C3C); // Clear red maintained
  static const Color successDark = Color(0xFF27AE60); // Clean green maintained
  static const Color onPrimaryDark =
      Color(0xFFFFFFFF); // High contrast white text
  static const Color onSecondaryDark = Color(0xFF1A4A47);
  static const Color onBackgroundDark = Color(0xFFFFFFFF);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onErrorDark = Color(0xFFFFFFFF);

  // Additional theme colors
  static const Color cardLight = Color(0xFFF5F5F5);
  static const Color cardDark = Color(0xFF2A5D5A);
  static const Color dialogLight = Color(0xFFFFFFFF);
  static const Color dialogDark = Color(0xFF1A4A47);

  // Shadow colors - subtle elevation
  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowDark = Color(0x1FFFFFFF);

  // Border and divider colors
  static const Color borderLight = Color(0xFF2A5D5A); // Secondary brand teal border
  static const Color borderDark = Color(0xFF2A5D5A);
  static const Color dividerLight = Color(0x1F2A5D5A);
  static const Color dividerDark = Color(0x1F2A5D5A);

  // Text colors with proper emphasis levels
  static const Color textPrimaryLight =
      Color(0xFF1A4A47); // Brand teal for primary text on light backgrounds
  static const Color textSecondaryLight = Color(0xFF2A5D5A); // Secondary brand teal
  static const Color textDisabledLight = Color(0x612A5D5A); // 38% opacity

  static const Color textPrimaryDark = Color(0xFFFFFFFF); // High contrast white
  static const Color textSecondaryDark = Color(0xFFB8C5C2); // Muted teal-gray
  static const Color textDisabledDark = Color(0x61B8C5C2); // 38% opacity

  // Warning colors
  static const Color warningLight = Color(0xFFFF9800); // Orange for warnings
  static const Color warningDark = Color(0xFFFF9800); // Orange for warnings

  /// Light theme with Professional Transit Palette
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: onPrimaryLight,
      primaryContainer: primaryVariantLight,
      onPrimaryContainer: onPrimaryLight,
      secondary: secondaryLight,
      onSecondary: onSecondaryLight,
      secondaryContainer: secondaryVariantLight,
      onSecondaryContainer: onSecondaryLight,
      tertiary: successLight,
      onTertiary: onPrimaryLight,
      tertiaryContainer: successLight,
      onTertiaryContainer: onPrimaryLight,
      error: errorLight,
      onError: onErrorLight,
      surface: surfaceLight,
      onSurface: onSurfaceLight,
      onSurfaceVariant: textSecondaryLight,
      outline: borderLight,
      outlineVariant: dividerLight,
      shadow: shadowLight,
      scrim: shadowLight,
      inverseSurface: surfaceDark,
      onInverseSurface: onSurfaceDark,
      inversePrimary: primaryDark,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    dividerColor: dividerLight,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryLight,
      foregroundColor: onPrimaryLight,
      elevation: 4.0,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onPrimaryLight,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      shadowColor: shadowLight,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: secondaryLight,
      unselectedItemColor: textSecondaryLight,
      elevation: 8.0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: secondaryLight,
      foregroundColor: onSecondaryLight,
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onSecondaryLight,
        backgroundColor: secondaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: BorderSide(color: borderLight, width: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: true),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: backgroundLight,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: borderLight, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: borderLight, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: secondaryLight, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorLight, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorLight, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondaryLight,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textDisabledLight,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: textSecondaryLight,
      suffixIconColor: textSecondaryLight,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryLight;
        }
        return textSecondaryLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryLight.withValues(alpha: 0.3);
        }
        return textSecondaryLight.withValues(alpha: 0.3);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onSecondaryLight),
      side: BorderSide(color: borderLight, width: 1.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryLight;
        }
        return textSecondaryLight;
      }),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: secondaryLight,
      linearTrackColor: textSecondaryLight.withValues(alpha: 0.3),
      circularTrackColor: textSecondaryLight.withValues(alpha: 0.3),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: secondaryLight,
      thumbColor: secondaryLight,
      overlayColor: secondaryLight.withValues(alpha: 0.2),
      inactiveTrackColor: textSecondaryLight.withValues(alpha: 0.3),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: secondaryLight,
      unselectedLabelColor: textSecondaryLight,
      indicatorColor: secondaryLight,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: primaryLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.inter(
        color: onPrimaryLight,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryLight,
      contentTextStyle: GoogleFonts.inter(
        color: onPrimaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: secondaryLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 6.0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      elevation: 8.0,
    ),
    dialogTheme: DialogThemeData(backgroundColor: dialogLight),
  );

  /// Dark theme with Professional Transit Palette
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: onPrimaryDark,
      primaryContainer: primaryVariantDark,
      onPrimaryContainer: onPrimaryDark,
      secondary: secondaryDark,
      onSecondary: onSecondaryDark,
      secondaryContainer: secondaryVariantDark,
      onSecondaryContainer: onSecondaryDark,
      tertiary: successDark,
      onTertiary: onPrimaryDark,
      tertiaryContainer: successDark,
      onTertiaryContainer: onPrimaryDark,
      error: errorDark,
      onError: onErrorDark,
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      onSurfaceVariant: textSecondaryDark,
      outline: borderDark,
      outlineVariant: dividerDark,
      shadow: shadowDark,
      scrim: shadowDark,
      inverseSurface: surfaceLight,
      onInverseSurface: onSurfaceLight,
      inversePrimary: primaryLight,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardDark,
    dividerColor: dividerDark,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: onSurfaceDark,
      elevation: 4.0,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurfaceDark,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      shadowColor: shadowDark,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: secondaryDark,
      unselectedItemColor: textSecondaryDark,
      elevation: 8.0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: secondaryDark,
      foregroundColor: onSecondaryDark,
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onSecondaryDark,
        backgroundColor: secondaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: onSurfaceDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: BorderSide(color: borderDark, width: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: onSurfaceDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: false),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: backgroundDark,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: borderDark, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: borderDark, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: secondaryDark, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorDark, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorDark, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondaryDark,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textDisabledDark,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: textSecondaryDark,
      suffixIconColor: textSecondaryDark,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryDark;
        }
        return textSecondaryDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryDark.withValues(alpha: 0.3);
        }
        return textSecondaryDark.withValues(alpha: 0.3);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryDark;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onSecondaryDark),
      side: BorderSide(color: borderDark, width: 1.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryDark;
        }
        return textSecondaryDark;
      }),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: secondaryDark,
      linearTrackColor: textSecondaryDark.withValues(alpha: 0.3),
      circularTrackColor: textSecondaryDark.withValues(alpha: 0.3),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: secondaryDark,
      thumbColor: secondaryDark,
      overlayColor: secondaryDark.withValues(alpha: 0.2),
      inactiveTrackColor: textSecondaryDark.withValues(alpha: 0.3),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: secondaryDark,
      unselectedLabelColor: textSecondaryDark,
      indicatorColor: secondaryDark,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: onSurfaceDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.inter(
        color: surfaceDark,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: onSurfaceDark,
      contentTextStyle: GoogleFonts.inter(
        color: surfaceDark,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: secondaryDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 6.0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: backgroundDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      elevation: 8.0,
    ),
    dialogTheme: DialogThemeData(backgroundColor: dialogDark),
  );

  /// Helper method to build text theme based on brightness using Inter font family
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textPrimary = isLight ? textPrimaryLight : textPrimaryDark;
    final Color textSecondary =
        isLight ? textSecondaryLight : textSecondaryDark;
    final Color textDisabled = isLight ? textDisabledLight : textDisabledDark;

    return TextTheme(
      // Display styles - Inter Medium/SemiBold for headings
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),

      // Headline styles - Inter SemiBold for main headings
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),

      // Title styles - Inter Medium for section titles
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.1,
      ),

      // Body styles - Inter Regular/Medium for body text
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0.4,
      ),

      // Label styles - Inter Regular for captions and labels
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: textDisabled,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Helper method to get monospace text style for data display
  static TextStyle getDataTextStyle({
    required bool isLight,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    final Color textColor = isLight ? textPrimaryLight : textPrimaryDark;
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: textColor,
      letterSpacing: 0,
    );
  }

  /// Helper method to get success color based on theme
  static Color getSuccessColor(bool isLight) {
    return isLight ? successLight : successDark;
  }

  /// Helper method to get warning color based on theme
  static Color getWarningColor(bool isLight) {
    return isLight ? secondaryVariantLight : secondaryVariantDark;
  }

  /// Helper method to get monospace style for booking references and codes
  static TextStyle getMonospaceStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimaryLight,
      letterSpacing: 0,
    );
  }
}
