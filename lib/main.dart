import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'core/app_export.dart';
import 'widgets/custom_error_widget.dart';
// import 'core/api_client.dart'; // Disabled for frontend-only
// import 'services/auth_service.dart'; // Disabled for frontend-only
// import 'core/app_state.dart'; // Disabled for frontend-only

void main() async {
  // Ensure proper binding initialization for mobile APK
  WidgetsFlutterBinding.ensureInitialized();

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

    // Additional system UI configuration for mobile stability
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    runApp(MyApp());
  } catch (e) {
    debugPrint('Initialization error: $e');
    // Fallback - run app anyway
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'Tease Pro - Combined',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
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
            AppRoutes.welcome, // Start with the welcome screen
      );
    });
  }
}
