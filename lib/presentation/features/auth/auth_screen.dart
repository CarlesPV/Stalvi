import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/core/l10n/app_localizations.dart';
import 'package:konta/presentation/features/dashboard/dashboard_screen.dart';
import 'package:konta/presentation/providers/auth_notifier.dart';

/// Handles biometric authentication before granting access to the dashboard.
///
/// ### State machine (driven by [authNotifierProvider])
/// ```
/// AsyncLoading  → spinner while provider initialises
/// unauthenticated → biometric prompt auto-triggered (once), then manual retry
/// authenticating  → spinner overlay on the card
/// authenticated   → fade to [DashboardScreen]
/// unavailable     → immediate fade to [DashboardScreen] (no biometrics)
/// lockedOut       → hard-block card; no bypass offered
/// AsyncError      → generic error card with retry
/// ```
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _hasNavigated = false;

  // Ensures we auto-trigger the biometric prompt only once per screen visit.
  bool _hasTriggeredInitialAuth = false;

  // Pulsing animation for the biometric icon
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _navigateToDashboard() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DashboardScreen(),
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // React to state changes: navigate on success, auto-trigger on first load.
    ref.listen<AsyncValue<AuthStatus>>(authNotifierProvider, (_, next) {
      next.whenOrNull(
        data: (status) {
          if (status == AuthStatus.authenticated ||
              status == AuthStatus.unavailable) {
            _navigateToDashboard();
            return;
          }
          // Auto-present the biometric prompt once the provider first resolves
          // to [unauthenticated] (avoids making the user tap a button cold).
          if (status == AuthStatus.unauthenticated &&
              !_hasTriggeredInitialAuth) {
            _hasTriggeredInitialAuth = true;
            ref.read(authNotifierProvider.notifier).authenticate();
          }
        },
      );
    });

    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.35),
            radius: 1.5,
            colors: [
              colorScheme.primary.withValues(alpha: 0.10),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Small brand header ──────────────────────────────────
                _BrandHeader(colorScheme: colorScheme, theme: theme),

                const SizedBox(height: 48),

                // ── Auth card (state-driven) ────────────────────────────
                _GlassCard(
                  colorScheme: colorScheme,
                  child: authState.when(
                    loading: () => const _SpinnerContent(),
                    error: (err, _) => _ErrorContent(
                      message: err is String
                          ? err
                          : AppLocalizations.of(context)!.unexpectedError,
                      onRetry: () => ref
                          .read(authNotifierProvider.notifier)
                          .authenticate(),
                    ),
                    data: (status) => _buildDataContent(
                      context,
                      status,
                      colorScheme,
                      theme,
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Branding footer ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    AppLocalizations.of(context)!.authProtectedBy,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataContent(
    BuildContext context,
    AuthStatus status,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    if (status == AuthStatus.lockedOut) {
      return _LockedOutContent(colorScheme: colorScheme, theme: theme);
    }

    // unauthenticated | authenticating | authenticated (pre-navigation flash)
    return _BiometricContent(
      colorScheme: colorScheme,
      theme: theme,
      pulseScale: _pulseScale,
      isAuthenticating: status == AuthStatus.authenticating,
      onAuthenticate: () =>
          ref.read(authNotifierProvider.notifier).authenticate(),
      onSkip: () => ref.read(authNotifierProvider.notifier).skip(),
    );
  }
}

// ─── Glass card container ─────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final Widget child;

  const _GlassCard({required this.colorScheme, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.07),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Brand header ─────────────────────────────────────────────────────────────

class _BrandHeader extends StatelessWidget {
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _BrandHeader({required this.colorScheme, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            size: 32,
            color: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Konta',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// ─── Card content states ──────────────────────────────────────────────────────

/// Generic loading spinner — shown while [authNotifierProvider] is building.
class _SpinnerContent extends StatelessWidget {
  const _SpinnerContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.authCheckingBiometrics,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// Shown when [authNotifierProvider] emits [AsyncValue.error].
class _ErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorContent({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            size: 32,
            color: colorScheme.onErrorContainer,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.authError,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(AppLocalizations.of(context)!.tryAgain),
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          ),
        ),
      ],
    );
  }
}

/// Shown when the biometric sensor is locked out. No bypass is offered.
class _LockedOutContent extends StatelessWidget {
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _LockedOutContent({
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.errorContainer,
          ),
          child: Icon(
            Icons.lock_rounded,
            size: 36,
            color: colorScheme.onErrorContainer,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.authLockedTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(context)!.authLockedMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Informational chip — no action, reinforces that there's no bypass.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.error.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_rounded,
                size: 14,
                color: colorScheme.error,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.authLockoutActive,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The main biometric prompt UI — pulsing icon, description, and action buttons.
class _BiometricContent extends StatelessWidget {
  final ColorScheme colorScheme;
  final ThemeData theme;
  final Animation<double> pulseScale;
  final bool isAuthenticating;
  final VoidCallback onAuthenticate;
  final VoidCallback onSkip;

  const _BiometricContent({
    required this.colorScheme,
    required this.theme,
    required this.pulseScale,
    required this.isAuthenticating,
    required this.onAuthenticate,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing biometric icon
        ScaleTransition(
          scale: pulseScale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.10),
                ),
              ),
              // Inner ring
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.14),
                ),
              ),
              // Icon
              Icon(
                Icons.fingerprint_rounded,
                size: 52,
                color: isAuthenticating
                    ? colorScheme.primary.withValues(alpha: 0.5)
                    : colorScheme.primary,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          AppLocalizations.of(context)!.authVerifyIdentity,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          AppLocalizations.of(context)!.authVerifyMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Primary: Authenticate
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isAuthenticating ? null : onAuthenticate,
            icon: isAuthenticating
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                  )
                : const Icon(Icons.fingerprint_rounded, size: 18),
            label: Text(
              isAuthenticating
                  ? AppLocalizations.of(context)!.authVerifying
                  : AppLocalizations.of(context)!.authAuthenticate,
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary: Skip for now
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: isAuthenticating ? null : onSkip,
            child: Text(
              AppLocalizations.of(context)!.authSkip,
              style: TextStyle(
                color: isAuthenticating
                    ? colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
