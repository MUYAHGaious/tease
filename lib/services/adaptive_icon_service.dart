import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppIconTheme {
  auto,    // Follows system theme
  light,   // Light theme icon
  dark,    // Dark theme icon  
  tinted,  // Branded/tinted icon
}

class AdaptiveIconService {
  static const String _iconThemeKey = 'app_icon_theme';
  static const MethodChannel _channel = MethodChannel('adaptive_icons');

  // Current icon theme
  static AppIconTheme _currentIconTheme = AppIconTheme.auto;
  
  // Callbacks for theme changes
  static final List<VoidCallback> _listeners = [];

  static AppIconTheme get currentIconTheme => _currentIconTheme;

  /// Initialize the service and load saved preferences
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_iconThemeKey) ?? 'auto';
    
    _currentIconTheme = AppIconTheme.values.firstWhere(
      (theme) => theme.name == savedTheme,
      orElse: () => AppIconTheme.auto,
    );

    // Apply the saved theme
    await _applyIconTheme(_currentIconTheme);
  }

  /// Set the app icon theme
  static Future<bool> setIconTheme(AppIconTheme theme) async {
    try {
      final success = await _applyIconTheme(theme);
      
      if (success) {
        _currentIconTheme = theme;
        
        // Save preference
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_iconThemeKey, theme.name);
        
        // Notify listeners
        for (final listener in _listeners) {
          listener();
        }
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error setting icon theme: $e');
      return false;
    }
  }

  /// Apply icon theme based on system or user preference
  static Future<bool> _applyIconTheme(AppIconTheme theme) async {
    String? iconName;
    
    switch (theme) {
      case AppIconTheme.auto:
        // Detect system theme and apply appropriate icon
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        iconName = brightness == Brightness.dark ? 'AppIcon-Dark' : 'AppIcon-Light';
        break;
      case AppIconTheme.light:
        iconName = 'AppIcon-Light';
        break;
      case AppIconTheme.dark:
        iconName = 'AppIcon-Dark';
        break;
      case AppIconTheme.tinted:
        iconName = 'AppIcon-Tinted';
        break;
    }

    try {
      // For iOS
      if (Theme.of(WidgetsBinding.instance.rootElement!).platform == TargetPlatform.iOS) {
        await _channel.invokeMethod('setAlternateIconName', iconName == 'AppIcon-Light' ? null : iconName);
        return true;
      }
      
      // For Android - handled by system automatically with adaptive icons
      // We can add custom logic here if needed
      return true;
    } catch (e) {
      debugPrint('Error applying icon theme: $e');
      return false;
    }
  }

  /// Add listener for icon theme changes
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Get available icon themes for the current platform
  static List<AppIconTheme> getAvailableThemes() {
    return AppIconTheme.values;
  }

  /// Check if dynamic icons are supported on this platform
  static Future<bool> isSupported() async {
    try {
      if (Theme.of(WidgetsBinding.instance.rootElement!).platform == TargetPlatform.iOS) {
        return await _channel.invokeMethod('supportsAlternateIcons') ?? false;
      }
      
      // Android supports adaptive icons on API 26+
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get current system theme
  static Brightness getCurrentSystemTheme() {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  /// Listen to system theme changes and auto-update icon if needed
  static void startSystemThemeListener() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (_currentIconTheme == AppIconTheme.auto) {
        _applyIconTheme(AppIconTheme.auto);
      }
    };
  }
}

// Widget for icon theme selection UI
class IconThemeSelector extends StatefulWidget {
  final Function(AppIconTheme)? onThemeChanged;

  const IconThemeSelector({
    Key? key,
    this.onThemeChanged,
  }) : super(key: key);

  @override
  State<IconThemeSelector> createState() => _IconThemeSelectorState();
}

class _IconThemeSelectorState extends State<IconThemeSelector> {
  AppIconTheme _selectedTheme = AdaptiveIconService.currentIconTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Icon Theme',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...AppIconTheme.values.map((theme) {
          return RadioListTile<AppIconTheme>(
            title: Text(_getThemeName(theme)),
            subtitle: Text(_getThemeDescription(theme)),
            value: theme,
            groupValue: _selectedTheme,
            onChanged: (AppIconTheme? value) async {
              if (value != null) {
                final success = await AdaptiveIconService.setIconTheme(value);
                if (success && mounted) {
                  setState(() {
                    _selectedTheme = value;
                  });
                  widget.onThemeChanged?.call(value);
                }
              }
            },
          );
        }).toList(),
      ],
    );
  }

  String _getThemeName(AppIconTheme theme) {
    switch (theme) {
      case AppIconTheme.auto:
        return 'Automatic';
      case AppIconTheme.light:
        return 'Light';
      case AppIconTheme.dark:
        return 'Dark';
      case AppIconTheme.tinted:
        return 'Tinted';
    }
  }

  String _getThemeDescription(AppIconTheme theme) {
    switch (theme) {
      case AppIconTheme.auto:
        return 'Matches system appearance';
      case AppIconTheme.light:
        return 'Light colored icon for all themes';
      case AppIconTheme.dark:
        return 'Dark colored icon for all themes';
      case AppIconTheme.tinted:
        return 'Branded TEASE colored icon';
    }
  }
}

// Icon theme preview widget
class IconThemePreview extends StatelessWidget {
  final AppIconTheme theme;
  final bool isSelected;
  final VoidCallback? onTap;

  const IconThemePreview({
    Key? key,
    required this.theme,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _getIconBackgroundColor(theme),
              ),
              child: Icon(
                Icons.directions_bus, // Placeholder - replace with actual icon
                color: _getIconForegroundColor(theme),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getThemeName(theme),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconBackgroundColor(AppIconTheme theme) {
    switch (theme) {
      case AppIconTheme.auto:
      case AppIconTheme.light:
        return Colors.white;
      case AppIconTheme.dark:
        return const Color(0xFF1C1C1E);
      case AppIconTheme.tinted:
        return const Color(0xFF1a4d3a);
    }
  }

  Color _getIconForegroundColor(AppIconTheme theme) {
    switch (theme) {
      case AppIconTheme.auto:
      case AppIconTheme.light:
        return const Color(0xFF1a4d3a);
      case AppIconTheme.dark:
        return Colors.white;
      case AppIconTheme.tinted:
        return Colors.white;
    }
  }

  String _getThemeName(AppIconTheme theme) {
    switch (theme) {
      case AppIconTheme.auto:
        return 'Auto';
      case AppIconTheme.light:
        return 'Light';
      case AppIconTheme.dark:
        return 'Dark';
      case AppIconTheme.tinted:
        return 'Tinted';
    }
  }
}