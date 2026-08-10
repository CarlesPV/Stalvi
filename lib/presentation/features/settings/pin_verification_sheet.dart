import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'profile_settings_controller.dart';
import '../../providers/auth_notifier.dart';

class PinVerificationSheet extends ConsumerStatefulWidget {
  final VoidCallback onVerified;
  final VoidCallback onCancelled;

  const PinVerificationSheet({
    super.key,
    required this.onVerified,
    required this.onCancelled,
  });

  @override
  ConsumerState<PinVerificationSheet> createState() =>
      _PinVerificationSheetState();
}

class _PinVerificationSheetState extends ConsumerState<PinVerificationSheet> {
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
    final isPinLockedOut = authState.value == AuthStatus.pinLockedOut;
    final isBiometricLockedOut = authState.value == AuthStatus.lockedOut;

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
      child: SingleChildScrollView(
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
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
      ),
    );
  }
}
