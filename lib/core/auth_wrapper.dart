import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/auth/login_screen.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;
  final bool requiresAuth;
  
  const AuthWrapper({
    Key? key,
    required this.child,
    this.requiresAuth = true,
  }) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await AppState().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, child) {
        final appState = AppState();

        // Show loading screen while initializing
        if (appState.isLoading) {
          return const SplashScreen();
        }

        // If authentication is required and user is not authenticated
        if (widget.requiresAuth && !appState.isAuthenticated) {
          return const LoginScreen();
        }

        // Show the requested screen
        return widget.child;
      },
    );
  }
}

// Extension to easily wrap routes with authentication
extension RouteAuth on Widget {
  Widget requiresAuth() => AuthWrapper(child: this);
  Widget noAuthRequired() => AuthWrapper(child: this, requiresAuth: false);
}