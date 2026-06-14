import 'package:flutter/material.dart';
import 'package:konta/core/l10n/app_localizations.dart';

/// A premium, reusable presentation widget designed to prevent "blank page syndrome".
///
/// It displays an engaging message, a status illustration/icon, and an optional
/// call to action button to guide the user towards their next steps.
///
/// Supports native Light and Dark theme styling dynamically using [Theme.of].
class EmptyStateWidget extends StatelessWidget {
  /// The icon to display at the top of the empty state.
  final IconData? icon;

  /// The SVG or asset image path to display if [icon] is null.
  final String? svgAssetPath;

  /// The primary title text (bold, distinct).
  final String title;

  /// The secondary subtitle text providing helpful context or instruction.
  final String subtitle;

  /// The label for the optional call-to-action button.
  final String? actionLabel;

  /// The callback triggered when the call-to-action button is tapped.
  final VoidCallback? onActionPressed;

  const EmptyStateWidget({
    super.key,
    this.icon,
    this.svgAssetPath,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onActionPressed,
  }) : assert(
          icon != null || svgAssetPath != null,
          'Either an icon or a svgAssetPath must be provided to render an EmptyStateWidget.',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative Graphic/Icon Container
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: _buildGraphic(colorScheme),
              ),
            ),
            const SizedBox(height: 28),

            // Title Text
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subtitle / Description Text
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 290),
              child: Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Action button (if callback is provided)
            if (onActionPressed != null) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  actionLabel ??
                      (AppLocalizations.of(context)?.getStarted ??
                          'Get Started'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.1,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGraphic(ColorScheme colorScheme) {
    if (icon != null) {
      return Icon(
        icon,
        size: 38,
        color: colorScheme.primary,
      );
    } else if (svgAssetPath != null) {
      return Image.asset(
        svgAssetPath!,
        width: 38,
        height: 38,
        color: colorScheme.primary,
        errorBuilder: (context, error, stackTrace) {
          // Graceful fallback for missing assets during testing/development
          return Icon(
            Icons.broken_image_rounded,
            size: 38,
            color: colorScheme.primary,
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
