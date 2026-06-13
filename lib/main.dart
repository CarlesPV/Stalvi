import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:konta/core/theme/app_theme.dart';
import 'package:konta/presentation/features/splash/splash_screen.dart';

/// Entry point for the Konta application.
///
/// [WidgetsFlutterBinding.ensureInitialized] is called to guarantee that all
/// Flutter engine bindings (required by plugins such as [local_auth] and
/// [flutter_secure_storage]) are set up before any async work begins.
///
/// The root [ProviderScope] enables Riverpod for the entire widget tree.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: KontaApp(),
    ),
  );
}

/// Root widget of the Konta application.
///
/// Configures:
/// - [AppTheme.lightTheme] / [AppTheme.darkTheme] from the design system.
/// - [ThemeMode.system] so the OS light/dark preference is respected.
/// - [SplashScreen] as the initial route (Splash → Auth → Dashboard).
class KontaApp extends StatelessWidget {
  const KontaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Konta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
