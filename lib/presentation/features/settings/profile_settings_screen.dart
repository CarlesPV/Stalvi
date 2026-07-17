import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/infrastructure/services/biometric_auth_service.dart';
import 'profile_settings_controller.dart';
import 'pin_verification_sheet.dart';
import '../splash/splash_screen.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/terms_and_conditions_viewer.dart';
import 'about_me_screen.dart' as stalvi_about_me;

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
          scrollable: true,
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(l10n.btnCancel),
              ),
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(l10n.btnSave),
              ),
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
      'CNY': l10n.currencyCNY,
    };
    String selected = currencies.keys.contains(currentCurrency)
        ? currentCurrency
        : currencies.keys.first;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: Text(l10n.labelSelectCurrency),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                isExpanded: true,
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(l10n.btnCancel),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(profileSettingsControllerProvider.notifier)
                    .updateCurrency(selected);
                Navigator.of(context).pop();
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(l10n.btnSave),
              ),
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

                return SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
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
                            style:
                                const TextStyle(letterSpacing: 8, fontSize: 24),
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
                                              .verifyOldPin(
                                                oldPinController.text,
                                              );
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
                                                displayError =
                                                    l10n.errorNoPinSet;
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
                    ),
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
      builder: (sheetCtx) => PinVerificationSheet(
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
            scrollable: true,
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.btnCancel,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.deleteAllDataButton,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
          : SafeArea(
              child: ListView(
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
                      onTap: () => _editCurrency(
                        context,
                        state.profile!.defaultCurrency,
                      ),
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
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: DropdownButton<ThemeMode>(
                        value: ref.watch(themeProvider),
                        dropdownColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onChanged: (ThemeMode? newMode) {
                          if (newMode != null) {
                            ref
                                .read(themeProvider.notifier)
                                .setThemeMode(newMode);
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
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: Text(l10n.settingsLanguage),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: DropdownButton<String>(
                        value: ref.watch(localeProvider).languageCode,
                        dropdownColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
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
                        items: [
                          DropdownMenuItem<String>(
                            value: 'en',
                            child: Text(
                              l10n.languageEnglish,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: 'es',
                            child: Text(
                              l10n.languageSpanish,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: 'ca',
                            child: Text(
                              l10n.languageCatalan,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
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
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(l10n.aboutMe),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const stalvi_about_me.AboutMeScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),

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
            ),
    );
  }
}
