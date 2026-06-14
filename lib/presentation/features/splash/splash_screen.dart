import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/core/l10n/app_localizations.dart';
import 'package:konta/presentation/features/auth/auth_screen.dart';
import 'package:konta/presentation/providers/app_startup_provider.dart';

/// The app entry-point screen.
///
/// Displays an animated brand identity (logo + wordmark) while
/// [appStartupProvider] initialises the encrypted database and any other
/// critical services. Once startup resolves it performs a fade transition
/// to [AuthScreen]. On error it shows a retry surface.
///
/// **Minimum display duration**: 2.2 s to ensure the brand animation
/// completes even on very fast devices.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ────────────────────────────────────────────────
  late final AnimationController _controller;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _wordmarkSlide;
  late final Animation<double> _wordmarkFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _indicatorFade;

  // Guards against double-navigation (e.g. retry path race).
  bool _hasNavigated = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _kickoffSplash();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Logo: spring scale + soft fade-in
    _logoScale = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.elasticOut),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.30, curve: Curves.easeIn),
      ),
    );

    // Wordmark: slides up from below, fades in
    _wordmarkSlide = Tween<Offset>(
      begin: const Offset(0, 0.7),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.88, curve: Curves.easeOutCubic),
      ),
    );
    _wordmarkFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.78, curve: Curves.easeIn),
      ),
    );

    // Tagline: late reveal
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 1.0, curve: Curves.easeIn),
      ),
    );

    // Loading indicator: fades in after wordmark appears
    _indicatorFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.80, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  Future<void> _kickoffSplash() async {
    // Run animation + minimum branding display time concurrently.
    try {
      await Future.wait([
        _controller.forward().orCancel,
        Future.delayed(const Duration(milliseconds: 2200)),
      ]);
    } catch (_) {
      // TickerCanceled is thrown when the widget disposes mid-animation.
      return;
    }

    if (!mounted) return;

    try {
      // Wait for startup (already resolved if DB was fast).
      await ref.read(appStartupProvider.future);
      _navigateNext();
    } catch (_) {
      // Error is surfaced via [ref.watch] in [build] — no extra action needed.
    }
  }

  /// Called when the user taps "Try Again" after a startup failure.
  Future<void> _kickoffRetry() async {
    try {
      await ref.read(appStartupProvider.future);
      if (mounted) _navigateNext();
    } catch (_) {
      // Error shown automatically via build's [startupState.hasError] branch.
    }
  }

  void _navigateNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AuthScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final startupState = ref.watch(appStartupProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.35),
            radius: 1.5,
            colors: [
              colorScheme.primary.withValues(alpha: 0.14),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: startupState.hasError
                ? _ErrorBody(
                    key: const ValueKey('error'),
                    onRetry: () {
                      _hasNavigated = false;
                      ref.invalidate(appStartupProvider);
                      _kickoffRetry();
                    },
                  )
                : _SplashContent(
                    key: const ValueKey('content'),
                    theme: theme,
                    colorScheme: colorScheme,
                    logoScale: _logoScale,
                    logoFade: _logoFade,
                    wordmarkSlide: _wordmarkSlide,
                    wordmarkFade: _wordmarkFade,
                    taglineFade: _taglineFade,
                    indicatorFade: _indicatorFade,
                    isLoading: startupState.isLoading,
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SplashContent extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Animation<double> logoScale;
  final Animation<double> logoFade;
  final Animation<Offset> wordmarkSlide;
  final Animation<double> wordmarkFade;
  final Animation<double> taglineFade;
  final Animation<double> indicatorFade;
  final bool isLoading;

  const _SplashContent({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.logoScale,
    required this.logoFade,
    required this.wordmarkSlide,
    required this.wordmarkFade,
    required this.taglineFade,
    required this.indicatorFade,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        children: [
          const Spacer(flex: 5),

        // ── Logo Badge ───────────────────────────────────────────────────
        FadeTransition(
          opacity: logoFade,
          child: ScaleTransition(
            scale: logoScale,
            child: _LogoBadge(colorScheme: colorScheme),
          ),
        ),

        const SizedBox(height: 32),

        // ── Wordmark ─────────────────────────────────────────────────────
        SlideTransition(
          position: wordmarkSlide,
          child: FadeTransition(
            opacity: wordmarkFade,
            child: Text(
              'Konta',
              style: theme.textTheme.displayMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: -2.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── Tagline ──────────────────────────────────────────────────────
        FadeTransition(
          opacity: taglineFade,
          child: Text(
            AppLocalizations.of(context)!.splashTagline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
          ),
        ),

        const Spacer(flex: 5),

        // ── Progress indicator ────────────────────────────────────────────
        FadeTransition(
          opacity: indicatorFade,
          child: AnimatedOpacity(
            opacity: isLoading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 44),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}

/// The branded logo badge — square with rounded corners and a soft glow.
class _LogoBadge extends StatelessWidget {
  final ColorScheme colorScheme;

  const _LogoBadge({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.40),
            blurRadius: 36,
            spreadRadius: 0,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.account_balance_wallet_rounded,
        size: 54,
        color: colorScheme.onPrimary,
      ),
    );
  }
}

/// Shown when [appStartupProvider] throws — offers a retry action.
class _ErrorBody extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorBody({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.splashStartupFailed,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.splashSecureStorageError,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.tryAgain),
              style: FilledButton.styleFrom(
                minimumSize: const Size(180, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
