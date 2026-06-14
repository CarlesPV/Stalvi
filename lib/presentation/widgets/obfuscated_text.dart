import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/presentation/providers/discreet_mode_provider.dart';

/// A widget that displays text which can be obfuscated based on [discreetModeProvider].
class ObfuscatedText extends ConsumerWidget {
  /// The actual text to display when discreet mode is off.
  final String text;

  /// The character(s) to display when discreet mode is on.
  final String obfuscationString;

  /// The text style to apply.
  final TextStyle? style;

  const ObfuscatedText(
    this.text, {
    super.key,
    this.obfuscationString = '***',
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDiscreet = ref.watch(discreetModeProvider);

    return Text(
      isDiscreet ? obfuscationString : text,
      style: style,
    );
  }
}
