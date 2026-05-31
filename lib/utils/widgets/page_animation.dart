import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

/// Custom page with transition
Page<dynamic> buildAnimatedPage(
    BuildContext context,
    GoRouterState state,
    Widget child, {
      Duration transitionDuration = const Duration(milliseconds: 300),
      Duration reverseTransitionDuration = const Duration(milliseconds: 300),
    }) {
  // Choose your favorite animation here.

  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // === Slide from Right (most common & recommended) ===
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );



    },
  );
}