import 'package:flutter/material.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/theme/app_theme.dart';

/// A reusable visual progress bar widget designed with Stalvi brand aesthetics.
///
/// Takes [currentAmount] and [targetAmount] (in cents or any consistent unit),
/// calculates the progress percentage, and renders an animated bar.
///
/// Features:
/// - Smooth progress animation on mount/update using [TweenAnimationBuilder].
/// - Dynamic colors: If [currentAmount] exceeds [targetAmount], it defaults to the
///   theme's negative financial color (pastel coral red) to indicate warning/overspent.
///   Otherwise, it uses [activeColor] or the theme's positive financial color (pastel mint green).
/// - Clean capsule design matching light/dark surfaces.
class ProgressBarWidget extends StatelessWidget {
  final int currentAmount;
  final int targetAmount;
  final Color? activeColor;
  final Color? backgroundColor;
  final double height;
  final String? semanticLabel;

  const ProgressBarWidget({
    super.key,
    required this.currentAmount,
    required this.targetAmount,
    this.activeColor,
    this.backgroundColor,
    this.height = 8.0,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final financialColors = context.financialColors;

    // Calculate progress ratio
    final double progress =
        targetAmount > 0 ? currentAmount / targetAmount : 0.0;
    final double clampedProgress = progress.clamp(0.0, 1.0);

    final l10n = AppLocalizations.of(context);
    final int percentage = targetAmount > 0 ? (progress * 100).round() : 0;
    final String semanticLabelText = semanticLabel != null
        ? '$semanticLabel, ${l10n?.a11yProgressBar('$percentage') ?? 'Progress: $percentage percent'}'
        : (l10n?.a11yProgressBar('$percentage') ??
            'Progress: $percentage percent');

    // Determine colors
    final isExceeded = currentAmount > targetAmount;
    final Color resolvedActiveColor = isExceeded
        ? financialColors.negative
        : (activeColor ?? financialColors.positive);

    final Color resolvedBgColor = backgroundColor ??
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);

    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: resolvedBgColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Semantics(
                    value: '$percentage%',
                    label: semanticLabelText,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: clampedProgress),
                      duration: disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedValue, child) {
                        return FractionallySizedBox(
                          widthFactor: animatedValue,
                          child: Container(
                            decoration: BoxDecoration(
                              color: resolvedActiveColor,
                              borderRadius: BorderRadius.circular(height / 2),
                              boxShadow: [
                                if (animatedValue > 0.02)
                                  BoxShadow(
                                    color: resolvedActiveColor.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
