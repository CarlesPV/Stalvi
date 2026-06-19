import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/infrastructure/services/biometric_auth_service.dart';
import 'package:stalvi/presentation/features/settings/profile_settings_controller.dart';
import 'package:stalvi/presentation/features/splash/splash_screen.dart';
import 'package:stalvi/presentation/providers/auth_notifier.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';
import 'package:stalvi/presentation/providers/theme_provider.dart';
import 'package:stalvi/presentation/widgets/terms_and_conditions_viewer.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  void _editUsername(BuildContext context, String currentUsername) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentUsername);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.usernameLabel),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: l10n.usernameLabel,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.btnCancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ref
                      .read(profileSettingsControllerProvider.notifier)
                      .updateUsername(controller.text);
                }
                Navigator.of(context).pop();
              },
              child: Text(l10n.btnSave),
            ),
          ],
        );
      },
    );
  }

  void _editCurrency(BuildContext context, String currentCurrency) {
    final l10n = AppLocalizations.of(context)!;
    final currencies = {
      'EUR': l10n.currencyEUR,
      'USD': l10n.currencyUSD,
      'GBP': l10n.currencyGBP,
      'JPY': l10n.currencyJPY,
      'CHF': l10n.currencyCHF,
      'CAD': l10n.currencyCAD,
      'AUD': l10n.currencyAUD,
    };
    String selected = currencies.keys.contains(currentCurrency)
        ? currentCurrency
        : currencies.keys.first;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.labelSelectCurrency),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                initialValue: selected,
                items: currencies.entries.map((e) {
                  return DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => selected = val);
                  }
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.authSetupCurrencyLabel,
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.btnCancel),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(profileSettingsControllerProvider.notifier)
                    .updateCurrency(selected);
                Navigator.of(context).pop();
              },
              child: Text(l10n.btnSave),
            ),
          ],
        );
      },
    );
  }

  void _changePinFlow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentState = ref.read(profileSettingsControllerProvider);

    if (currentState.failedAttempts >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorMaxPinAttempts)),
      );
      return;
    }

    ref.read(profileSettingsControllerProvider.notifier).resetPinChangeState();

    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    int localStep = 0;
    String? localError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(profileSettingsControllerProvider);

                if (state.failedAttempts >= 6) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  });
                }

                String title = l10n.oldPinLabel;
                TextEditingController currentController = oldPinController;

                if (state.pinChangeStep == PinChangeStep.enterNew) {
                  if (localStep < 1) localStep = 1;
                  if (localStep == 1) {
                    title = l10n.newPinLabel;
                    currentController = newPinController;
                  } else if (localStep == 2) {
                    title = l10n.confirmPinLabel;
                    currentController = confirmPinController;
                  }
                }

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 24,
                    right: 24,
                    top: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: currentController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(letterSpacing: 8, fontSize: 24),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: 8,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          setState(() {
                            localError = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (state.error != null || localError != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  localError ??
                                      ((state.error!.contains(
                                                'old_pin_incorrect',
                                              ) ||
                                              state.error!.contains(
                                                'Incorrect Old PIN.',
                                              ))
                                          ? '${l10n.incorrectOldPin}\n${l10n.authPinAttemptsRemaining(6 - state.failedAttempts)}'
                                          : (state.error!.contains(
                                                    'maximum_pin_attempts',
                                                  ) ||
                                                  state.error!.contains(
                                                    'Maximum PIN attempts',
                                                  ))
                                              ? l10n.errorMaxPinAttempts
                                              : state.error!),
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      if (state.isLoading)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton(
                          onPressed: currentController.text.length >= 4
                              ? () async {
                                  if (state.pinChangeStep ==
                                      PinChangeStep.verifyOld) {
                                    try {
                                      await ref
                                          .read(
                                            profileSettingsControllerProvider
                                                .notifier,
                                          )
                                          .verifyOldPin(oldPinController.text);
                                    } catch (_) {
                                      oldPinController.clear();
                                      setState(() {});
                                    }
                                  } else {
                                    if (localStep == 1) {
                                      setState(() {
                                        localStep = 2;
                                      });
                                    } else if (localStep == 2) {
                                      if (newPinController.text !=
                                          confirmPinController.text) {
                                        setState(() {
                                          localError = l10n.pinsDoNotMatch;
                                          newPinController.clear();
                                          confirmPinController.clear();
                                          localStep = 1;
                                        });
                                        return;
                                      }
                                      try {
                                        await ref
                                            .read(
                                              profileSettingsControllerProvider
                                                  .notifier,
                                            )
                                            .changePin(
                                              oldPinController.text,
                                              newPinController.text,
                                            );
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                l10n.pinUpdatedSuccessfully,
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          final errorMsg = e.toString();
                                          String displayError = errorMsg;
                                          if (errorMsg.contains(
                                                'pin_length_invalid',
                                              ) ||
                                              errorMsg.contains(
                                                'between 4 and 8',
                                              )) {
                                            displayError = l10n
                                                .authSetupValidationErrorPinLength;
                                          } else if (errorMsg.contains(
                                                'pin_not_numeric',
                                              ) ||
                                              errorMsg.contains(
                                                'only numeric digits',
                                              )) {
                                            displayError =
                                                l10n.errorPinNotNumeric;
                                          } else if (errorMsg
                                                  .contains('no_pin_set') ||
                                              errorMsg.contains(
                                                'No PIN is currently set',
                                              )) {
                                            displayError = l10n.errorNoPinSet;
                                          }
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(displayError),
                                            ),
                                          );
                                          setState(() {
                                            localStep = 1;
                                            newPinController.clear();
                                            confirmPinController.clear();
                                          });
                                        }
                                      }
                                    }
                                  }
                                }
                              : null,
                          child: Text(
                            localStep == 2 ? l10n.btnSave : l10n.btnNext,
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ─── Local auth helper for sensitive actions ──────────────────────────────

  /// Runs the local authentication flow (biometric first, PIN fallback) and
  /// returns [true] if the user authenticated successfully.
  ///
  /// Shows an inline PIN entry bottom sheet when biometrics are unavailable or
  /// disabled.  The PIN is verified through [authNotifierProvider] so the
  /// brute-force lockout rules apply here too.
  Future<bool> _requireLocalAuth(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final biometricService = ref.read(biometricAuthServiceProvider);

    // 1. Try biometrics first.
    final isBioEnabled = await biometricService.isBiometricsEnabled();
    final isBioAvailable = await biometricService.isBiometricAvailable();

    if (isBioEnabled && isBioAvailable) {
      try {
        final didAuthenticate = await biometricService.authenticate(
          localizedReason: l10n.authVerifyMessage,
          lockedOutMessage: l10n.authLockedTitle,
          authFailedMessage: l10n.authError,
          unknownErrorMessage: l10n.unexpectedError,
          signInTitle: l10n.authSignInTitle,
          cancelButton: l10n.btnCancel,
        );
        if (didAuthenticate) {
          return true;
        }
      } catch (_) {
        // Biometrics failed / cancelled — fall through to PIN.
      }
    }

    // 2. PIN entry via modal bottom sheet.
    if (!context.mounted) return false;
    final pinVerified = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (sheetCtx) => _PinVerificationSheet(
        onVerified: () => Navigator.of(sheetCtx).pop(true),
        onCancelled: () => Navigator.of(sheetCtx).pop(false),
      ),
    );
    return pinVerified == true;
  }

  void _confirmDeleteAllData(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentState = ref.read(profileSettingsControllerProvider);

    if (currentState.failedDeleteAttempts >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorMaxPinAttempts)),
      );
      return;
    }

    ref.read(profileSettingsControllerProvider.notifier).resetDeleteDataState();

    // Require local auth BEFORE showing the destructive confirmation dialog.
    _requireLocalAuth(context).then((authenticated) {
      if (!context.mounted) return;
      if (!authenticated) {
        final updatedState = ref.read(profileSettingsControllerProvider);
        if (updatedState.failedDeleteAttempts >= 6) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorMaxPinAttempts)),
          );
        }
        return; // Auth cancelled or failed.
      }

      showDialog(
        context: context,
        builder: (dialogCtx) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colorScheme.error,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.deleteAllDataButton,
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              l10n.deleteAllDataWarning,
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text(
                  l10n.btnCancel,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  Navigator.of(dialogCtx).pop();

                  await ref
                      .read(profileSettingsControllerProvider.notifier)
                      .wipeAllData();

                  // Invalidate the auth notifier so it rebuilds from scratch.
                  // hasPin() will now return false, yielding setupRequired.
                  ref.invalidate(authNotifierProvider);

                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: Text(
                  l10n.deleteAllDataButton,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(profileSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileSettingsTitle),
      ),
      body: state.isLoading && state.profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // ── Profile & Security ────────────────────────────────────
                if (state.profile != null) ...[
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(l10n.usernameLabel),
                    subtitle: Text(state.profile!.username),
                    trailing: const Icon(Icons.edit),
                    onTap: () =>
                        _editUsername(context, state.profile!.username),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.currency_exchange),
                    title: Text(l10n.authSetupCurrencyLabel),
                    subtitle: Text(state.profile!.defaultCurrency),
                    trailing: const Icon(Icons.edit),
                    onTap: () =>
                        _editCurrency(context, state.profile!.defaultCurrency),
                  ),
                  const Divider(),
                ],
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: Text(l10n.changePinButton),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _changePinFlow(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.palette_rounded),
                  title: Text(l10n.settingsThemeMode),
                  trailing: DropdownButton<ThemeMode>(
                    value: ref.watch(themeProvider),
                    dropdownColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onChanged: (ThemeMode? newMode) {
                      if (newMode != null) {
                        ref.read(themeProvider.notifier).setThemeMode(newMode);
                      }
                    },
                    items: ThemeMode.values.map((ThemeMode mode) {
                      String label;
                      switch (mode) {
                        case ThemeMode.system:
                          label = l10n.themeModeSystem;
                          break;
                        case ThemeMode.light:
                          label = l10n.themeModeLight;
                          break;
                        case ThemeMode.dark:
                          label = l10n.themeModeDark;
                          break;
                      }
                      return DropdownMenuItem<ThemeMode>(
                        value: mode,
                        child: Text(
                          label,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(l10n.settingsLanguage),
                  trailing: DropdownButton<String>(
                    value: ref.watch(localeProvider).languageCode,
                    dropdownColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onChanged: (String? newLang) {
                      if (newLang != null) {
                        ref
                            .read(localeProvider.notifier)
                            .setLocale(Locale(newLang));
                      }
                    },
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'en',
                        child: Text('English', style: TextStyle(fontSize: 14)),
                      ),
                      DropdownMenuItem<String>(
                        value: 'es',
                        child: Text('Español', style: TextStyle(fontSize: 14)),
                      ),
                      DropdownMenuItem<String>(
                        value: 'ca',
                        child: Text('Català', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.description_rounded),
                  title: Text(l10n.termsAndConditions),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TermsAndConditionsViewer(
                          showPrivacyPolicy: false,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_rounded),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TermsAndConditionsViewer(
                          showPrivacyPolicy: true,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.delete_forever),
                  label: Text(l10n.deleteAllDataButton),
                  onPressed: () => _confirmDeleteAllData(context),
                ),
              ],
            ),
    );
  }
}

// ─── PIN Verification Sheet ───────────────────────────────────────────────────

/// A self-contained modal bottom sheet that presents a numeric PIN dial-pad.
/// It delegates PIN verification to [authNotifierProvider] so that the
/// brute-force lockout rules remain consistent across the whole app.
class _PinVerificationSheet extends ConsumerStatefulWidget {
  final VoidCallback onVerified;
  final VoidCallback onCancelled;

  const _PinVerificationSheet({
    required this.onVerified,
    required this.onCancelled,
  });

  @override
  ConsumerState<_PinVerificationSheet> createState() =>
      _PinVerificationSheetState();
}

class _PinVerificationSheetState extends ConsumerState<_PinVerificationSheet> {
  String _enteredPin = '';
  int _requiredPinLength = 4;
  bool _isVerifying = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadPinLength();
  }

  Future<void> _loadPinLength() async {
    final length =
        await ref.read(authNotifierProvider.notifier).getRequiredPinLength();
    if (mounted) setState(() => _requiredPinLength = length);
  }

  Future<void> _onDigitTapped(String digit) async {
    if (_isVerifying) return;
    if (_enteredPin.length >= _requiredPinLength) return;

    final newPin = _enteredPin + digit;
    setState(() {
      _enteredPin = newPin;
      _errorText = null;
    });

    if (newPin.length == _requiredPinLength) {
      await _verifyPin(newPin);
    }
  }

  Future<void> _verifyPin(String pin) async {
    setState(() => _isVerifying = true);
    final ok = await ref
        .read(profileSettingsControllerProvider.notifier)
        .verifyDeleteDataPin(pin);
    if (!mounted) return;
    if (ok) {
      widget.onVerified();
    } else {
      final remaining =
          6 - ref.read(profileSettingsControllerProvider).failedDeleteAttempts;
      setState(() {
        _isVerifying = false;
        _enteredPin = '';
        _errorText = remaining > 0
            ? AppLocalizations.of(context)!.authPinAttemptsRemaining(remaining)
            : null;
      });
    }
  }

  Widget _buildDot(int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFilled = index < _enteredPin.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 14,
      height: 14,
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
  }

  Widget _buildDialKey(String digit) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        margin: const EdgeInsets.all(6),
        child: InkWell(
          onTap: () => _onDigitTapped(digit),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Watch for lockout triggered by verifyPin
    final authState = ref.watch(authNotifierProvider);
    final isPinLockedOut = authState.valueOrNull == AuthStatus.pinLockedOut;
    final isBiometricLockedOut = authState.valueOrNull == AuthStatus.lockedOut;

    final settingsState = ref.watch(profileSettingsControllerProvider);
    final isDeleteLockedOut = settingsState.failedDeleteAttempts >= 6;

    if (isDeleteLockedOut) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(false);
        }
      });
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.authVerifyMessage,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          if (isPinLockedOut || isBiometricLockedOut) ...[
            Icon(Icons.lock_rounded, color: colorScheme.error, size: 40),
            const SizedBox(height: 12),
            Text(
              l10n.authLockedTitle,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onCancelled,
              child: Text(l10n.btnCancel),
            ),
          ] else ...[
            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _requiredPinLength,
                (i) => _buildDot(i),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorText != null)
              Text(
                _errorText!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            if (_isVerifying)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Table(
                children: [
                  TableRow(
                    children: [
                      _buildDialKey('1'),
                      _buildDialKey('2'),
                      _buildDialKey('3'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildDialKey('4'),
                      _buildDialKey('5'),
                      _buildDialKey('6'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildDialKey('7'),
                      _buildDialKey('8'),
                      _buildDialKey('9'),
                    ],
                  ),
                  TableRow(
                    children: [
                      // Cancel
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          child: TextButton(
                            onPressed: widget.onCancelled,
                            child: Text(
                              l10n.btnCancel,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _buildDialKey('0'),
                      // Backspace
                      AspectRatio(
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
                                  _enteredPin = _enteredPin.substring(
                                    0,
                                    _enteredPin.length - 1,
                                  );
                                  _errorText = null;
                                });
                              }
                            },
                            onLongPress: () {
                              setState(() {
                                _enteredPin = '';
                                _errorText = null;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
