import 'package:flutter/material.dart';

class AppPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  AppPageRoute({
    required this.child,
    super.settings,
  }) : super(
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curveAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final secondaryCurveAnimation = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            // Forward animation: Fade + Scale + Slide Up
            return FadeTransition(
              opacity: curveAnimation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1.0).animate(curveAnimation),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.04),
                    end: Offset.zero,
                  ).animate(curveAnimation),
                  child: ScaleTransition(
                    // Background exiting page slight shrink effect
                    scale: Tween<double>(begin: 1.0, end: 0.96).animate(secondaryCurveAnimation),
                    child: child,
                  ),
                ),
              ),
            );
          },
        );
}

class PremiumPageTransitionsBuilder extends PageTransitionsBuilder {
  const PremiumPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curveAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curveAnimation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.94, end: 1.0).animate(curveAnimation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.04),
            end: Offset.zero,
          ).animate(curveAnimation),
          child: child,
        ),
      ),
    );
  }
}
