import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/core/l10n/app_localizations.dart';
import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/infrastructure/services/biometric_auth_service.dart';
import 'package:konta/presentation/features/settings/profile_settings_controller.dart';
import 'package:konta/presentation/features/splash/splash_screen.dart';

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
    final currencies = ['EUR', '\$', '£', '¥'];
    String selected = currencies.contains(currentCurrency)
        ? currentCurrency
        : currencies.first;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Currency'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                initialValue: selected,
                items: currencies.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => selected = val);
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Default Currency',
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
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    int step = 0; // 0: Old PIN, 1: New PIN, 2: Confirm PIN

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            String title = l10n.oldPinLabel;
            TextEditingController currentController = oldPinController;
            if (step == 1) {
              title = l10n.newPinLabel;
              currentController = newPinController;
            } else if (step == 2) {
              title = l10n.confirmPinLabel;
              currentController = confirmPinController;
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
                  const SizedBox(height: 24),
                  TextField(
                    controller: currentController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(letterSpacing: 8, fontSize: 24),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 8,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: currentController.text.length >= 4
                        ? () async {
                            if (step == 0) {
                              try {
                                await ref
                                    .read(profileSettingsControllerProvider
                                        .notifier)
                                    .verifyOldPin(oldPinController.text);
                                if (context.mounted) {
                                  setState(() {
                                    step = 1;
                                  });
                                }
                              } on ValidationException catch (e) {
                                if (context.mounted) {
                                  String errorMessage = e.message;
                                  if (errorMessage == 'old_pin_incorrect' ||
                                      errorMessage == 'Incorrect Old PIN.') {
                                    errorMessage = l10n.incorrectOldPin;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(errorMessage)),
                                  );
                                  setState(() {
                                    oldPinController.clear();
                                  });
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            } else if (step == 1) {
                              setState(() {
                                step = 2;
                              });
                            } else if (step == 2) {
                              if (newPinController.text !=
                                  confirmPinController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.pinsDoNotMatch)),
                                );
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(l10n.pinUpdatedSuccessfully),
                                    ),
                                  );
                                }
                              } on ValidationException catch (e) {
                                if (context.mounted) {
                                  String errorMessage = e.message;
                                  if (errorMessage == 'old_pin_incorrect' ||
                                      errorMessage == 'Incorrect Old PIN.') {
                                    errorMessage = l10n.incorrectOldPin;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(errorMessage)),
                                  );
                                  // Reset
                                  setState(() {
                                    step = 0;
                                    oldPinController.clear();
                                    newPinController.clear();
                                    confirmPinController.clear();
                                  });
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            }
                          }
                        : null,
                    child: Text(step == 2 ? l10n.btnSave : l10n.btnNext),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteAllData(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            l10n.deleteAllDataButton,
            style: const TextStyle(color: Colors.red),
          ),
          content: Text(l10n.deleteAllDataWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.btnCancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(context).pop();

                final biometricService = ref.read(biometricAuthServiceProvider);
                final isBiometricsEnabled =
                    await biometricService.isBiometricsEnabled();
                if (isBiometricsEnabled) {
                  try {
                    final didAuthenticate = await biometricService.authenticate(
                      localizedReason: l10n.authVerifyMessage,
                      lockedOutMessage: l10n.authLockedTitle,
                      authFailedMessage: l10n.authError,
                      unknownErrorMessage: l10n.unexpectedError,
                    );
                    if (!didAuthenticate) {
                      return; // Cancelled
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                    return; // Abort
                  }
                }

                await ref
                    .read(profileSettingsControllerProvider.notifier)
                    .wipeAllData();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const SplashScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: Text(l10n.deleteAllDataButton),
            ),
          ],
        );
      },
    );
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
                    title: const Text('Default Currency'),
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
