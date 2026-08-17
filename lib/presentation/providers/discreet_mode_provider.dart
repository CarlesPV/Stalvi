import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A [Notifier] that manages the discreet mode state.
///
/// When true, sensitive financial information should be obfuscated.
class DiscreetModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    return true; // Default to true (obfuscated)
  }

  /// Toggles the discreet mode state between true and false.
  void toggle() {
    state = !state;
  }

  /// Explicitly sets the discreet mode state.
  void setDiscreet(bool value) {
    state = value;
  }
}

/// Global provider for the discreet mode state.
final discreetModeProvider = NotifierProvider<DiscreetModeNotifier, bool>(
  DiscreetModeNotifier.new,
);
