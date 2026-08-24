import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBackNavigationGuardWidget extends StatefulWidget {
  final Widget child;

  const AppBackNavigationGuardWidget({super.key, required this.child});

  @override
  State<AppBackNavigationGuardWidget> createState() => _AppBackNavigationGuardWidgetState();
}

class _AppBackNavigationGuardWidgetState extends State<AppBackNavigationGuardWidget> {
  DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        try {
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
            return;
          }

          final String currentLocation = GoRouterState.of(context).uri.toString();
          if (currentLocation != '/' && currentLocation != '/home') {
            context.go('/');
            return;
          }

          // At root / home screen. Show double-tap confirmation snackbar so user does not accidentally exit app/site.
          final now = DateTime.now();
          if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
            _lastBackPressTime = now;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.touch_app_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Press back again to exit Cosmyra', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                backgroundColor: const Color(0xFF1E293B),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        } catch (_) {}
      },
      child: widget.child,
    );
  }
}
