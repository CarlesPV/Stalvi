import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/core/l10n/app_localizations.dart';

import 'package:konta/core/theme/app_theme.dart';
import 'package:konta/presentation/features/splash/splash_screen.dart';
import 'package:konta/presentation/providers/locale_provider.dart';
import 'package:konta/presentation/widgets/lifecycle_blur_wrapper.dart';

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
/// - [localeProvider] to watch and dynamically change application language.
/// - [AppLocalizations.delegate] and other material/cupertino l10n delegates.
/// - [SplashScreen] as the initial route (Splash → Auth → Dashboard).
class KontaApp extends ConsumerWidget {
  const KontaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Konta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
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
