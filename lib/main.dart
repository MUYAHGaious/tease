import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_export.dart';
import 'widgets/custom_error_widget.dart';
import 'theme/theme_notifier.dart';
// import 'core/api_client.dart'; // Disabled for frontend-only
// import 'services/auth_service.dart'; // Disabled for frontend-only
// import 'core/app_state.dart'; // Disabled for frontend-only

void main() async {
  // Ensure proper binding initialization for mobile APK
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme notifier
  await ThemeNotifier().initialize();

  // Services disabled for frontend-only development
  debugPrint('Frontend-only mode: Backend services disabled');

  // Enhanced error handling for release builds
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack Trace: ${details.stack}');
    // Don't crash the app in release mode
  };

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(
      errorDetails: details,
    );
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  try {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    // Update status bar to contrast with the current theme
    updateStatusBarTheme(ThemeNotifier().isDarkMode);

    runApp(MyApp());
  } catch (e) {
    debugPrint('Initialization error: $e');
    // Fallback - run app anyway
    runApp(MyApp());
  }
}

void updateStatusBarTheme(bool isDarkMode) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: isDarkMode 
          ? const Color(0xFF121212) // Dark background for dark theme
          : const Color(0xFFf8f9fa), // Light background for light theme
      statusBarIconBrightness: isDarkMode 
          ? Brightness.light // Light icons for dark status bar
          : Brightness.dark,  // Dark icons for light status bar
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    ThemeNotifier().addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    // Update status bar when theme changes
    updateStatusBarTheme(ThemeNotifier().isDarkMode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'Tease Pro - Combined',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeNotifier().isDarkMode ? ThemeMode.dark : ThemeMode.light,
        // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        // 🚨 END CRITICAL SECTION
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute:
            AppRoutes.initial, // Start with the splash screen
      );
    });
  }
}
