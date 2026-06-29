import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/discreet_mode_provider.dart';

/// A widget that displays text which can be obfuscated based on [discreetModeProvider].
class ObfuscatedText extends ConsumerWidget {
  /// The actual text to display when discreet mode is off.
  final String text;

  /// The character(s) to display when discreet mode is on.
  final String obfuscationString;

  /// The text style to apply.
  final TextStyle? style;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// An optional maximum number of lines for the text to span.
  final int? maxLines;

  /// Whether the text should break at soft line breaks.
  final bool? softWrap;

  const ObfuscatedText(
    this.text, {
    super.key,
    this.obfuscationString = '***',
    this.style,
    this.overflow,
    this.maxLines,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDiscreet = ref.watch(discreetModeProvider);

    return Text(
      isDiscreet ? obfuscationString : text,
      style: style,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
    );
  }
}
