import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeMode { light, dark, system }
enum AccentColor { blue, green, purple, orange, red, teal }

class AdaptiveThemeManager extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';
  static const String _useMaterialYouKey = 'use_material_you';

  ThemeMode _themeMode = ThemeMode.system;
  AccentColor _accentColor = AccentColor.green;
  bool _useMaterialYou = false;

  ThemeMode get themeMode => _themeMode;
  AccentColor get accentColor => _accentColor;
  bool get useMaterialYou => _useMaterialYou;

  // Get the current brightness based on theme mode
  Brightness getCurrentBrightness(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness;
    }
  }

  // Check if current theme is dark
  bool isDarkMode(BuildContext context) {
    return getCurrentBrightness(context) == Brightness.dark;
  }

  // Get accent color based on selection
  Color getAccentColor() {
    switch (_accentColor) {
      case AccentColor.blue:
        return const Color(0xFF007AFF);
      case AccentColor.green:
        return const Color(0xFF1a4d3a); // TEASE brand color
      case AccentColor.purple:
        return const Color(0xFF6C63FF);
      case AccentColor.orange:
        return const Color(0xFFFF6B35);
      case AccentColor.red:
        return const Color(0xFFFF3B30);
      case AccentColor.teal:
        return const Color(0xFF30D5C8);
    }
  }

  // Get tinted version of accent color for light themes
  Color getTintedAccentColor() {
    return getAccentColor().withOpacity(0.1);
  }

  // Get adaptive surface colors based on current theme
  AdaptiveSurfaceColors getSurfaceColors(BuildContext context) {
    final isDark = isDarkMode(context);
    final accent = getAccentColor();

    if (isDark) {
      return AdaptiveSurfaceColors(
        primary: accent,
        secondary: accent.withOpacity(0.8),
        surface: const Color(0xFF1C1C1E),
        background: const Color(0xFF000000),
        onSurface: Colors.white,
        onBackground: Colors.white,
        cardColor: const Color(0xFF2C2C2E),
        dividerColor: Colors.white.withOpacity(0.1),
      );
    } else {
      return AdaptiveSurfaceColors(
        primary: accent,
        secondary: accent.withOpacity(0.8),
        surface: const Color(0xFFFAFAFA),
        background: Colors.white,
        onSurface: Colors.black87,
        onBackground: Colors.black87,
        cardColor: Colors.white,
        dividerColor: Colors.black.withOpacity(0.1),
      );
    }
  }

  // Initialize theme from preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeModeString = prefs.getString(_themeModeKey) ?? 'system';
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == themeModeString,
      orElse: () => ThemeMode.system,
    );

    final accentColorString = prefs.getString(_accentColorKey) ?? 'green';
    _accentColor = AccentColor.values.firstWhere(
      (color) => color.name == accentColorString,
      orElse: () => AccentColor.green,
    );

    _useMaterialYou = prefs.getBool(_useMaterialYouKey) ?? false;
    
    notifyListeners();
  }

  // Update theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
    
    // Update system UI overlay style
    _updateSystemUIOverlayStyle();
  }

  // Update accent color
  Future<void> setAccentColor(AccentColor color) async {
    _accentColor = color;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accentColorKey, color.name);
  }

  // Toggle Material You (Android 12+ dynamic theming)
  Future<void> setMaterialYou(bool enabled) async {
    _useMaterialYou = enabled;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useMaterialYouKey, enabled);
  }

  // Update system UI overlay style based on current theme
  void _updateSystemUIOverlayStyle() {
    // This will be called when theme changes to update status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _themeMode == ThemeMode.dark 
            ? Brightness.light 
            : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: _themeMode == ThemeMode.dark 
            ? Brightness.light 
            : Brightness.dark,
      ),
    );
  }

  // Get theme data for MaterialApp
  ThemeData getLightTheme() {
    final accent = getAccentColor();
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: _createMaterialColor(accent),
      primaryColor: accent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: accent.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  ThemeData getDarkTheme() {
    final accent = getAccentColor();
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: _createMaterialColor(accent),
      primaryColor: accent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2C2C2E),
        shadowColor: Colors.black.withOpacity(0.3),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: accent.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // Create MaterialColor from Color
  MaterialColor _createMaterialColor(Color color) {
    final swatch = <int, Color>{};
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;

    for (int i = 1; i <= 9; i++) {
      final double opacity = i * 0.1;
      swatch[i * 100] = Color.fromRGBO(red, green, blue, opacity);
    }

    return MaterialColor(color.value, swatch);
  }
}

// Data class for adaptive surface colors
class AdaptiveSurfaceColors {
  final Color primary;
  final Color secondary;
  final Color surface;
  final Color background;
  final Color onSurface;
  final Color onBackground;
  final Color cardColor;
  final Color dividerColor;

  const AdaptiveSurfaceColors({
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.background,
    required this.onSurface,
    required this.onBackground,
    required this.cardColor,
    required this.dividerColor,
  });
}