class InputSanitizer {
  /// Returns true if [input] contains emojis or prohibited special characters/code.
  /// Standard letters (including accents/tildes: á, é, í, ó, ú, ñ, ç, etc.), numbers,
  /// spaces, dots, hyphens, and underscores are permitted.
  static bool containsEmoji(String input) {
    if (input.isEmpty) return false;
    final invalidRegex = RegExp(r'[^\p{L}\p{N}\s._\-]', unicode: true);
    return invalidRegex.hasMatch(input);
  }

  static String sanitizeToPlainText(String input) {
    if (input.isEmpty) return input;

    String sanitized = input;

    // Strip script tags
    sanitized = sanitized.replaceAll(
      RegExp(
        r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>',
        caseSensitive: false,
      ),
      '',
    );
    // Strip HTML tags
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');

    // Strip basic Markdown patterns (e.g., links, bold, italics)
    // Links: [text](url) -> text
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^\)]+\)'),
      (match) => match.group(1) ?? '',
    );
    // Bold/Italics: **text**, *text*, __text__, _text_
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'(\*\*|__)(.*?)\1'),
      (match) => match.group(2) ?? '',
    );
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'(\*|_)(.*?)\1'),
      (match) => match.group(2) ?? '',
    );
    // Headers: # Header
    sanitized = sanitized.replaceAll(RegExp(r'#{1,6}\s'), '');

    // Strip common SQL injection patterns
    sanitized = sanitized.replaceAll(
      RegExp(
        r'\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|OR 1=1)\b|--|;',
        caseSensitive: false,
      ),
      '',
    );

    return sanitized.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
