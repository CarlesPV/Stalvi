import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import '../dashboard/dashboard_screen.dart';
import 'biometric_opt_in_screen.dart';
import 'package:stalvi/infrastructure/services/biometric_auth_service.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/terms_and_conditions_viewer.dart';
import 'package:stalvi/core/utils/input_sanitizer.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _hasNavigated = false;
  bool _biometricsAvailable = false;

  // Text inputs for setup
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _pinFocusNode = FocusNode();
  final _confirmPinFocusNode = FocusNode();
  bool _acceptTerms = false;
  String _selectedCurrency = 'EUR';

  // Entered PIN state for login
  String _enteredPin = '';
  int _requiredPinLength = 4; // default, loaded asynchronously

  // Pulsing animation for the biometric icon
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Determine if biometrics are available to show the icon on the dialpad
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).isBiometricAvailable().then((
        available,
      ) {
        if (mounted) {
          setState(() {
            _biometricsAvailable = available;
          });
        }
      });
      _loadPinLength();
    });
  }

  Future<void> _loadPinLength() async {
    final length =
        await ref.read(authNotifierProvider.notifier).getRequiredPinLength();
    if (mounted) {
      setState(() {
        _requiredPinLength = length;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _nameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DashboardScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToBiometricOptIn() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const BiometricOptInScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // React to authentication state changes
    ref.listen<AsyncValue<AuthStatus>>(authNotifierProvider, (_, next) {
      next.whenOrNull(
        data: (status) {
          if (status == AuthStatus.authenticated) {
            _navigateToDashboard();
            return;
          }
          if (status == AuthStatus.biometricOptIn) {
            _navigateToBiometricOptIn();
            return;
          }
          if (status == AuthStatus.unauthenticated) {
            _loadPinLength();
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
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _BrandHeader(colorScheme: colorScheme, theme: theme),
                  const SizedBox(height: 36),
                  _GlassCard(
                    colorScheme: colorScheme,
                    child: authState.when(
                      loading: () => const _SpinnerContent(),
                      error: (err, _) {
                        final errorText = _getLocalizedAuthError(context, err);
                        // Determine where the error came from
                        final status = authState.value;
                        if (status == AuthStatus.setupRequired ||
                            status == AuthStatus.setupSubmitting) {
                          // Error in setup
                          return _buildSetupForm(
                            context,
                            theme,
                            colorScheme,
                            l10n,
                            error: errorText,
                          );
                        } else {
                          // Error in login
                          return _buildLoginForm(
                            context,
                            theme,
                            colorScheme,
                            l10n,
                            error: errorText,
                          );
                        }
                      },
                      data: (status) {
                        if (status == AuthStatus.setupRequired ||
                            status == AuthStatus.setupSubmitting) {
                          return _buildSetupForm(
                            context,
                            theme,
                            colorScheme,
                            l10n,
                          );
                        } else if (status == AuthStatus.lockedOut) {
                          return _LockedOutContent(
                            colorScheme: colorScheme,
                            theme: theme,
                          );
                        } else if (status == AuthStatus.pinLockedOut) {
                          return _PinLockoutContent(
                            colorScheme: colorScheme,
                            theme: theme,
                            secondsRemaining: ref
                                .read(authNotifierProvider.notifier)
                                .pinLockoutSecondsRemaining,
                          );
                        } else {
                          return _buildLoginForm(
                            context,
                            theme,
                            colorScheme,
                            l10n,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedAuthError(BuildContext context, Object error) {
    final l10n = AppLocalizations.of(context)!;
    final String errorStr;
    if (error is AppException) {
      errorStr = error.message;
    } else {
      errorStr = error.toString();
    }

    if (errorStr.contains('between 4 and 8')) {
      return l10n.authSetupValidationErrorPinLength;
    }
    if (errorStr.contains('only numeric digits') ||
        errorStr.contains('digits only') ||
        errorStr.contains('digits-only') ||
        errorStr.contains('pin_not_numeric')) {
      return l10n.errorPinNotNumeric;
    }
    if (errorStr.contains('do not match') || errorStr.contains('match')) {
      return l10n.authSetupValidationErrorPinMatch;
    }
    if (errorStr.contains('accept the Terms') ||
        errorStr.contains('accept Terms') ||
        errorStr.contains('accept_terms')) {
      return l10n.authSetupValidationErrorTerms;
    }
    if (errorStr.contains('Name cannot exceed 25')) {
      return l10n.authSetupValidationErrorNameLength;
    }
    if (errorStr.contains('Name cannot contain emojis')) {
      return l10n.authSetupValidationErrorNameEmoji;
    }
    if (errorStr.contains('Username cannot exceed 25')) {
      return l10n.authSetupValidationErrorUsernameLength;
    }
    if (errorStr.contains('Username cannot contain emojis')) {
      return l10n.authSetupValidationErrorUsernameEmoji;
    }
    if (errorStr.contains('enter a name') ||
        errorStr.contains('Name cannot be empty') ||
        errorStr.contains('name_empty')) {
      return l10n.authSetupValidationErrorName;
    }
    if (errorStr.contains('enter a username') ||
        errorStr.contains('Username cannot be empty') ||
        errorStr.contains('username_empty')) {
      return l10n.authSetupValidationErrorUsername;
    }
    if (errorStr.contains('Incorrect PIN.')) {
      final remaining =
          ref.read(authNotifierProvider.notifier).remainingPinAttempts;
      return '${l10n.authPinIncorrect}\n${l10n.authPinAttemptsRemaining(remaining)}';
    }
    if (errorStr.contains('Maximum PIN attempts') ||
        errorStr.contains('attempts reached') ||
        errorStr.contains('maximum_pin_attempts')) {
      return l10n.errorMaxPinAttempts;
    }
    return errorStr;
  }

  // ─── Profile Setup Form View ───────────────────────────────────────────────

  Widget _buildSetupForm(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n, {
    String? error,
  }) {
    final activeLocale = ref.watch(localeProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.authSetupTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.authSetupSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          if (error != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: colorScheme.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      error,
                      maxLines: null,
                      overflow: TextOverflow.visible,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Language Selector
          Text(
            l10n.authSetupLanguageLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: activeLocale.languageCode,
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: 'en',
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.languageEnglish),
                ),
              ),
              DropdownMenuItem(
                value: 'es',
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.languageSpanish),
                ),
              ),
              DropdownMenuItem(
                value: 'ca',
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.languageCatalan),
                ),
              ),
            ],
            onChanged: (langCode) {
              if (langCode != null) {
                ref.read(localeProvider.notifier).setLocale(Locale(langCode));
              }
            },
          ),
          const SizedBox(height: 16),

          // Currency Selector
          Text(
            l10n.authSetupCurrencyLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _selectedCurrency,
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: 'EUR',
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.currencyEUR),
                ),
              ),
              DropdownMenuItem(
                value: 'USD',
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.currencyUSD),
                ),
              ),
              DropdownMenuItem(
                value: 'GBP',
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.currencyGBP),
                ),
              ),
              DropdownMenuItem(
                value: 'JPY',
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.currencyJPY),
                ),
              ),
              DropdownMenuItem(
                value: 'CHF',
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.currencyCHF),
                ),
              ),
              DropdownMenuItem(
                value: 'CAD',
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.currencyCAD),
                ),
              ),
              DropdownMenuItem(
                value: 'AUD',
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.currencyAUD),
                ),
              ),
              DropdownMenuItem(
                value: 'CNY',
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.currencyCNY),
                ),
              ),
            ],
            validator: (val) => (val == null || val.isEmpty)
                ? l10n.errorCurrencyRequired
                : null,
            onChanged: (currency) {
              if (currency != null) {
                setState(() {
                  _selectedCurrency = currency;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Name Input
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _usernameFocusNode.requestFocus();
            },
            textCapitalization: TextCapitalization.words,
            maxLength: 25,
            decoration: InputDecoration(
              labelText: l10n.authSetupNameLabel,
              prefixIcon: const Icon(Icons.person_outline),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return l10n.authSetupValidationErrorName;
              }
              if (val.trim().length > 25) {
                return l10n.authSetupValidationErrorNameLength;
              }
              if (InputSanitizer.containsEmoji(val)) {
                return l10n.authSetupValidationErrorNameEmoji;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Username Input
          TextFormField(
            controller: _usernameController,
            focusNode: _usernameFocusNode,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _pinFocusNode.requestFocus();
            },
            maxLength: 25,
            decoration: InputDecoration(
              labelText: l10n.authSetupUsernameLabel,
              prefixIcon: const Icon(Icons.alternate_email),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return l10n.authSetupValidationErrorUsername;
              }
              if (val.trim().length > 25) {
                return l10n.authSetupValidationErrorUsernameLength;
              }
              if (InputSanitizer.containsEmoji(val)) {
                return l10n.authSetupValidationErrorUsernameEmoji;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // PIN Input
          TextFormField(
            controller: _pinController,
            focusNode: _pinFocusNode,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _confirmPinFocusNode.requestFocus();
            },
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 8,
            decoration: InputDecoration(
              labelText: l10n.authSetupPinLabel,
              prefixIcon: const Icon(Icons.lock_outline),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: '',
            ),
            validator: (val) {
              if (val == null || val.length < 4 || val.length > 8) {
                return l10n.authSetupValidationErrorPinLength;
              }
              if (int.tryParse(val) == null) {
                return l10n.errorPinNotNumeric;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm PIN Input
          TextFormField(
            controller: _confirmPinController,
            focusNode: _confirmPinFocusNode,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              _confirmPinFocusNode.unfocus();
            },
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 8,
            decoration: InputDecoration(
              labelText: l10n.authSetupConfirmPinLabel,
              prefixIcon: const Icon(Icons.lock_outline),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: '',
            ),
            validator: (val) {
              if (val != _pinController.text) {
                return l10n.authSetupValidationErrorPinMatch;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Terms Checkbox
          FormField<bool>(
            initialValue: _acceptTerms,
            validator: (val) =>
                (val != true) ? l10n.authSetupValidationErrorTerms : null,
            builder: (formFieldState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        activeColor: colorScheme.primary,
                        onChanged: (checked) {
                          setState(() {
                            _acceptTerms = checked ?? false;
                          });
                          formFieldState.didChange(checked);
                        },
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                            children: [
                              TextSpan(text: l10n.authSetupAcceptPrefix),
                              TextSpan(
                                text: l10n.termsAndConditions,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        pageBuilder: (_, animation, __) =>
                                            const TermsAndConditionsViewer(
                                          showPrivacyPolicy: false,
                                        ),
                                        transitionsBuilder:
                                            (_, animation, __, child) =>
                                                FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                        transitionDuration: const Duration(
                                          milliseconds: 300,
                                        ),
                                      ),
                                    );
                                  },
                              ),
                              TextSpan(text: l10n.authSetupAcceptAnd),
                              TextSpan(
                                text: l10n.privacyPolicy,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        pageBuilder: (_, animation, __) =>
                                            const TermsAndConditionsViewer(
                                          showPrivacyPolicy: true,
                                        ),
                                        transitionsBuilder:
                                            (_, animation, __, child) =>
                                                FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                        transitionDuration: const Duration(
                                          milliseconds: 300,
                                        ),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (formFieldState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Text(
                        formFieldState.errorText ?? '',
                        maxLines: null,
                        overflow: TextOverflow.visible,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (error != null) {
                  ref.read(authNotifierProvider.notifier).resetStatus();
                }
                if (_formKey.currentState!.validate()) {
                  ref.read(authNotifierProvider.notifier).setupProfile(
                        name: _nameController.text,
                        username: _usernameController.text,
                        pin: _pinController.text,
                        confirmPin: _confirmPinController.text,
                        acceptTerms: _acceptTerms,
                        defaultCurrency: _selectedCurrency,
                      );
                }
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.authSetupCreateButton,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PIN Dial-pad / Login View ─────────────────────────────────────────────

  Widget _buildLoginForm(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n, {
    String? error,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.authPinEnter,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 20),

        // Display Dots for Entered PIN digits (dynamic length)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_requiredPinLength, (index) {
            final isFilled = index < _enteredPin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled
                    ? colorScheme.primary
                    : colorScheme.primary.withValues(alpha: 0.12),
                border: Border.all(
                  color: isFilled
                      ? colorScheme.primary
                      : colorScheme.outlineVariant.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        if (error != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Custom Numeric Dial-pad
        Table(
          children: [
            TableRow(children: [_dialKey('1'), _dialKey('2'), _dialKey('3')]),
            TableRow(children: [_dialKey('4'), _dialKey('5'), _dialKey('6')]),
            TableRow(children: [_dialKey('7'), _dialKey('8'), _dialKey('9')]),
            TableRow(
              children: [
                _bottomLeftKey(colorScheme),
                _dialKey('0'),
                _backspaceKey(colorScheme),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _dialKey(String digit) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        margin: const EdgeInsets.all(6),
        child: InkWell(
          onTap: () {
            if (_enteredPin.length < _requiredPinLength) {
              setState(() {
                if (ref.read(authNotifierProvider).hasError) {
                  ref.read(authNotifierProvider.notifier).resetStatus();
                }
                _enteredPin += digit;
              });

              // Auto-submit if PIN hits required length
              if (_enteredPin.length == _requiredPinLength) {
                _submitPin();
              }
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              digit,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomLeftKey(ColorScheme colorScheme) {
    if (_biometricsAvailable) {
      return AspectRatio(
        aspectRatio: 1.5,
        child: Container(
          margin: const EdgeInsets.all(6),
          child: ScaleTransition(
            scale: _pulseScale,
            child: IconButton(
              icon: Icon(
                Icons.fingerprint_rounded,
                size: 36,
                color: colorScheme.primary,
              ),
              onPressed: () async {
                ref.read(authNotifierProvider.notifier).resetStatus();
                final biometricService = ref.read(biometricAuthServiceProvider);
                final isEnabled = await biometricService.isBiometricsEnabled();
                if (!isEnabled) {
                  if (!mounted) return;
                  final l10n = AppLocalizations.of(context)!;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.authBiometricOptInTitle),
                      content: Text(l10n.authBiometricOptInSubtitle),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(l10n.authBiometricOptInSkip),
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ref
                                .read(authNotifierProvider.notifier)
                                .enableBiometricsOptIn();
                          },
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(l10n.authBiometricOptInEnable),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  ref.read(authNotifierProvider.notifier).authenticate();
                }
              },
            ),
          ),
        ),
      );
    }

    return const AspectRatio(aspectRatio: 1.5, child: SizedBox());
  }

  Widget _backspaceKey(ColorScheme colorScheme) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        margin: const EdgeInsets.all(6),
        child: IconButton(
          icon: Icon(
            Icons.backspace_outlined,
            size: 24,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () {
            if (_enteredPin.isNotEmpty) {
              setState(() {
                if (ref.read(authNotifierProvider).hasError) {
                  ref.read(authNotifierProvider.notifier).resetStatus();
                }
                _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
              });
            }
          },
          onLongPress: () {
            if (_enteredPin.isNotEmpty) {
              setState(() {
                if (ref.read(authNotifierProvider).hasError) {
                  ref.read(authNotifierProvider.notifier).resetStatus();
                }
                _enteredPin = '';
              });
            }
          },
        ),
      ),
    );
  }

  void _submitPin() {
    final pin = _enteredPin;
    setState(() {
      _enteredPin = '';
    });
    ref.read(authNotifierProvider.notifier).verifyPin(pin);
  }

  @override
  void didUpdateWidget(covariant AuthScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If PIN entry length meets verification, submit PIN on a checkmark dial-key or verify
    // But since we clear or auto-trigger, let's keep it simple: we trigger verification when
    // the user clicks or wait for auto-triggers. In this custom UI, let's also trigger PIN
    // verification when it changes between 4 and 8 and user pauses, or we can just add a verification
    // action. Wait, since PIN can be 4-8 digits, we don't know if they want 4 or more digits.
    // So if the user enters a PIN, we should verify when they tap a checkmark OR if they enter 8 digits.
    // Wait, let's look at the dial-pad. We have an empty key if biometrics is not supported.
    // Let's add a "Verify" key or automatically submit when they enter 4 digits or more and stop,
    // or let's use the checkmark key instead of empty biometric.
    // Wait! Let's make the third column bottom key a "Checkmark" (Verify) button if they have 4+ digits!
    // That way, for 4-to-7 digit PINs, they can tap "Checkmark" to submit. For 8 digits, we can auto-submit.
    // This is a great user experience! Let's check how we can implement this:
    // If they have entered >= 4 digits, we can show a checkmark key in the bottom-left instead of biometric,
    // or we can keep biometric and put checkmark key as a float action/checkmark elsewhere.
    // Wait, let's look at the bottom row:
    // Column 1: Biometric button (if supported), or Checkmark button (if they entered >= 4 digits).
    // Let's do that! If they have entered >= 4 digits, we can show a Checkmark button. If not, and biometrics are supported, show biometric button. If neither, show empty.
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.50),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.16),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
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
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Image.asset(
                  'assets/icon/app_icon.png',
                  fit: BoxFit.contain,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Stalvi',
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

class _SpinnerContent extends StatelessWidget {
  const _SpinnerContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.authProcessing,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _LockedOutContent extends StatelessWidget {
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _LockedOutContent({required this.colorScheme, required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent,
          ),
          child: const Icon(Icons.lock_rounded, size: 32, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.authLockedTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.authLockedMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.error.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_rounded, size: 14, color: colorScheme.error),
              const SizedBox(width: 6),
              Text(
                l10n.authLockoutActive,
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

// ─── PIN Brute-force Lockout Content (with countdown timer) ──────────────────

class _PinLockoutContent extends StatefulWidget {
  final ColorScheme colorScheme;
  final ThemeData theme;
  final int secondsRemaining;

  const _PinLockoutContent({
    required this.colorScheme,
    required this.theme,
    required this.secondsRemaining,
  });

  @override
  State<_PinLockoutContent> createState() => _PinLockoutContentState();
}

class _PinLockoutContentState extends State<_PinLockoutContent> {
  late int secondsRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    secondsRemaining = widget.secondsRemaining;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCountingDown = secondsRemaining > 0;
    final colorScheme = widget.colorScheme;
    final theme = widget.theme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lock icon with animated pulse using an opacity effect
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.error.withValues(alpha: 0.15),
            border: Border.all(
              color: colorScheme.error.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: Icon(Icons.timer_rounded, size: 32, color: colorScheme.error),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.authPinLockedTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          l10n.authPinLockedMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (isCountingDown) ...[
          // Countdown ring
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: secondsRemaining / 30,
                  strokeWidth: 5,
                  backgroundColor: colorScheme.error.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.error),
                ),
                Center(
                  child: Text(
                    '$secondsRemaining',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.authPinLockedCountdown,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.authPinLockedRetry,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
