import 'package:flutter/material.dart';

class AppPageTransitions {
  // Standard transition duration for consistency
  static const Duration defaultDuration = Duration(milliseconds: 350);
  
  // Fade transition for replacing pages
  static PageRouteBuilder<T> fadeTransition<T>({
    required Widget page,
    Duration duration = defaultDuration,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      maintainState: maintainState,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }

  // Slide transition for navigating forward
  static PageRouteBuilder<T> slideTransition<T>({
    required Widget page,
    Duration duration = defaultDuration,
    Offset begin = const Offset(1.0, 0.0),
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      maintainState: maintainState,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  // Scale transition for modal-like pages
  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget page,
    Duration duration = defaultDuration,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      maintainState: maintainState,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          ),
        );
      },
    );
  }

  // Combined fade and slide for onboarding flows
  static PageRouteBuilder<T> fadeSlideTransition<T>({
    required Widget page,
    Duration duration = defaultDuration,
    Offset begin = const Offset(0.0, 0.3),
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      maintainState: maintainState,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          ),
        );
      },
    );
  }
}

// Extension method for easy navigation with custom transitions
extension NavigatorExtensions on NavigatorState {
  Future<T?> pushWithTransition<T extends Object?>(
    Widget page, {
    PageRouteBuilder<T> Function(Widget)? transition,
  }) {
    final route = transition?.call(page) ?? 
        AppPageTransitions.slideTransition<T>(page: page);
    return push(route);
  }

  Future<T?> pushReplacementWithTransition<T extends Object?, TO extends Object?>(
    Widget page, {
    TO? result,
    PageRouteBuilder<T> Function(Widget)? transition,
  }) {
    final route = transition?.call(page) ?? 
        AppPageTransitions.fadeTransition<T>(page: page);
    return pushReplacement(route, result: result);
  }
}