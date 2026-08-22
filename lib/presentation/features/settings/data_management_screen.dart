import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/infrastructure/services/biometric_auth_service.dart';
import 'package:stalvi/domain/usecases/pdf_export_date_range.dart';
import 'profile_settings_controller.dart';
import 'pin_verification_sheet.dart';

class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key});

  @override
  ConsumerState<DataManagementScreen> createState() =>
      _DataManagementScreenState();
}

class _DataManagementScreenState extends ConsumerState<DataManagementScreen> {
  Future<bool> _requireLocalAuth(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final biometricService = ref.read(biometricAuthServiceProvider);

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
      } catch (_) {}
    }

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

  Future<String?> _askExportPassword(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final passController = TextEditingController();
    final confirmController = TextEditingController();
    final passFocusNode = FocusNode();
    final confirmFocusNode = FocusNode();
    String? dialogError;
    bool obscurePass = true;
    bool obscureConfirm = true;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              scrollable: true,
              title: Text(l10n.exportPasswordDialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.exportPasswordDialogSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passController,
                      focusNode: passFocusNode,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) =>
                          FocusScope.of(ctx).requestFocus(confirmFocusNode),
                      obscureText: obscurePass,
                      decoration: InputDecoration(
                        labelText: l10n.exportPasswordLabel,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePass
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setDialogState(() => obscurePass = !obscurePass),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmController,
                      focusNode: confirmFocusNode,
                      textInputAction: TextInputAction.done,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: l10n.exportPasswordConfirmLabel,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setDialogState(
                            () => obscureConfirm = !obscureConfirm,
                          ),
                        ),
                      ),
                    ),
                    if (dialogError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        dialogError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text(l10n.btnCancel),
                ),
                FilledButton(
                  onPressed: () {
                    final pass = passController.text;
                    final confirm = confirmController.text;
                    if (pass.length < 6) {
                      setDialogState(
                        () => dialogError = l10n.exportPasswordTooShort,
                      );
                      return;
                    }
                    if (pass != confirm) {
                      setDialogState(
                        () => dialogError = l10n.exportPasswordMismatch,
                      );
                      return;
                    }
                    Navigator.of(ctx).pop(pass);
                  },
                  child: Text(l10n.btnExport),
                ),
              ],
            );
          },
        );
      },
    );

    passController.dispose();
    confirmController.dispose();
    passFocusNode.dispose();
    confirmFocusNode.dispose();
    return result;
  }

  Future<String?> _askImportPassword(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final passController = TextEditingController();
    final passFocusNode = FocusNode();
    bool obscure = true;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              scrollable: true,
              title: Text(l10n.importPasswordDialogTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.importPasswordDialogSubtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passController,
                    focusNode: passFocusNode,
                    textInputAction: TextInputAction.done,
                    obscureText: obscure,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: l10n.exportPasswordLabel,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () =>
                            setDialogState(() => obscure = !obscure),
                      ),
                    ),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text(l10n.btnCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(passController.text),
                  child: Text(l10n.btnRestore),
                ),
              ],
            );
          },
        );
      },
    );

    passController.dispose();
    passFocusNode.dispose();
    return result;
  }

  void _showExportSuccess(
    BuildContext context,
    String? filePath,
    String successMsg, {
    bool showOpenAction = false,
  }) {
    if (!context.mounted) return;
    final hasFilePath = filePath != null && filePath.isNotEmpty;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasFilePath
              ? AppLocalizations.of(context)!.exportSavedTo(filePath)
              : successMsg,
        ),
        duration: const Duration(seconds: 6),
        action: (hasFilePath && showOpenAction)
            ? SnackBarAction(
                label: AppLocalizations.of(context)!.btnOpen,
                onPressed: () async {
                  try {
                    await OpenFilex.open(filePath);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.errorOpenFileFailed,
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
              )
            : null,
      ),
    );
  }

  Future<void> _handleExportEncryptedBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final authenticated = await _requireLocalAuth(context);
    if (!authenticated || !context.mounted) return;

    final password = await _askExportPassword(context);
    if (password == null || !context.mounted) return;

    try {
      final result = await ref
          .read(profileSettingsControllerProvider.notifier)
          .exportEncryptedBackup(password: password);
      if (!context.mounted) return;

      if (!context.mounted) return;
      _showExportSuccess(context, result.filePath, l10n.exportSuccess);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleImportEncryptedBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final authenticated = await _requireLocalAuth(context);
    if (!authenticated || !context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.importConfirmTitle)),
          ],
        ),
        content: Text(l10n.importConfirmMessage),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.btnRestore),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final pickerResult = await FilePickerPlatform.instance.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withData: true,
    );
    if (pickerResult == null || pickerResult.files.isEmpty) return;
    final fileBytes = await pickerResult.files.first.readAsBytes();
    if (!context.mounted) return;

    final password = await _askImportPassword(context);
    if (password == null || password.isEmpty || !context.mounted) return;

    try {
      await ref
          .read(profileSettingsControllerProvider.notifier)
          .importEncryptedBackup(fileBytes, password: password);

      // Completely close/exit the app process for a clean restart.
      if (Platform.isIOS) {
        exit(0);
      } else {
        try {
          await SystemNavigator.pop();
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 300));
        exit(0);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleExportCsv(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await ref
          .read(profileSettingsControllerProvider.notifier)
          .exportTransactionsCsv();
      if (!context.mounted) return;

      if (!context.mounted) return;
      _showExportSuccess(
        context,
        result.filePath,
        l10n.exportSuccess,
        showOpenAction: true,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleExportMonthlyPdf(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final selectedRange = await showModalBottomSheet<PdfExportDateRange>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today_rounded),
              title: Text(l10n.exportPdfCurrentMonth),
              onTap: () =>
                  Navigator.of(ctx).pop(PdfExportDateRange.currentMonth),
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: Text(l10n.exportPdfLast30Days),
              onTap: () => Navigator.of(ctx).pop(PdfExportDateRange.last30Days),
            ),
          ],
        ),
      ),
    );

    if (selectedRange == null || !context.mounted) return;

    try {
      final result = await ref
          .read(profileSettingsControllerProvider.notifier)
          .exportMonthlyPdf(
            dateRange: selectedRange,
            customMonthLabel: selectedRange == PdfExportDateRange.last30Days
                ? l10n.pdfExportLast30Days
                : null,
          );
      if (!context.mounted) return;

      if (!context.mounted) return;
      _showExportSuccess(
        context,
        result.filePath,
        l10n.exportSuccess,
        showOpenAction: true,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(profileSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsDataManagement)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ListTile(
                  leading: const Icon(Icons.backup_rounded),
                  title: Text(l10n.exportEncryptedBackup),
                  subtitle: Text(
                    l10n.exportEncryptedBackupSubtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.save_alt_rounded),
                  onTap: state.isLoading
                      ? null
                      : () => _handleExportEncryptedBackup(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.restore_rounded),
                  title: Text(l10n.importRestoreBackup),
                  subtitle: Text(
                    l10n.importRestoreBackupSubtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.folder_open_rounded),
                  onTap: state.isLoading
                      ? null
                      : () => _handleImportEncryptedBackup(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.table_chart_rounded),
                  title: Text(l10n.exportTransactionsCsv),
                  subtitle: Text(
                    l10n.exportTransactionsCsvSubtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.save_alt_rounded),
                  onTap:
                      state.isLoading ? null : () => _handleExportCsv(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded),
                  title: Text(l10n.exportMonthlyPdf),
                  subtitle: Text(
                    l10n.exportMonthlyPdfSubtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.save_alt_rounded),
                  onTap: state.isLoading
                      ? null
                      : () => _handleExportMonthlyPdf(context),
                ),
              ],
            ),
    );
  }
}
