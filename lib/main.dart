import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';

import 'package:stalvi/core/utils/navigator_key.dart';
import 'package:stalvi/core/theme/app_theme.dart';
import 'package:stalvi/presentation/features/splash/splash_screen.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';
import 'package:stalvi/presentation/providers/theme_provider.dart';
import 'package:stalvi/presentation/widgets/lifecycle_blur_wrapper.dart';

/// Entry point for the Stalvi application.
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
      child: StalviApp(),
    ),
  );
}

/// Configures:
/// - [AppTheme.lightTheme] / [AppTheme.darkTheme] from the design system.
/// - [themeProvider] to watch and dynamically change the application theme mode (light, dark, system).
/// - [localeProvider] to watch and dynamically change application language.
/// - [AppLocalizations.delegate] and other material/cupertino l10n delegates.
/// - [SplashScreen] as the initial route (Splash → Auth → Dashboard).
class StalviApp extends ConsumerWidget {
  const StalviApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);
    final activeThemeMode = ref.watch(themeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Stalvi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: activeThemeMode,
      locale: activeLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return LifecycleBlurWrapper(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
