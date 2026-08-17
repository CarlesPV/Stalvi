import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/core/utils/input_sanitizer.dart';

void main() {
  group('InputSanitizer.sanitizeToPlainText', () {
    test('strips HTML tags', () {
      expect(InputSanitizer.sanitizeToPlainText('<p>Hello</p>'), 'Hello');
      expect(
        InputSanitizer.sanitizeToPlainText('<b>Bold</b> and <i>Italic</i>'),
        'Bold and Italic',
      );
    });

    test('strips script tags (XSS prevention)', () {
      expect(
        InputSanitizer.sanitizeToPlainText(
          '<script>alert("XSS")</script>Safe text',
        ),
        'Safe text',
      );
      expect(
        InputSanitizer.sanitizeToPlainText(
          '<SCRIPT>alert("XSS")</SCRIPT>Safe text',
        ),
        'Safe text',
      );
    });

    test('strips Markdown', () {
      expect(InputSanitizer.sanitizeToPlainText('**Bold** text'), 'Bold text');
      expect(
        InputSanitizer.sanitizeToPlainText('[Link](http://example.com)'),
        'Link',
      );
      expect(InputSanitizer.sanitizeToPlainText('# Header'), 'Header');
    });

    test('strips SQL injection patterns', () {
      expect(
        InputSanitizer.sanitizeToPlainText('Notes SELECT * FROM users;'),
        'Notes * FROM users',
      );
      expect(InputSanitizer.sanitizeToPlainText('Notes --'), 'Notes');
      expect(InputSanitizer.sanitizeToPlainText('admin OR 1=1'), 'admin');
    });
  });

  group('InputSanitizer.containsEmoji', () {
    test(
      'detects emojis and special characters correctly while accepting accents',
      () {
        expect(InputSanitizer.containsEmoji('Carles'), false);
        expect(InputSanitizer.containsEmoji('Carles Peña'), false);
        expect(InputSanitizer.containsEmoji('María-José.1'), false);
        expect(InputSanitizer.containsEmoji('Françoise_Lluís'), false);
        expect(InputSanitizer.containsEmoji('Carles 😀'), true);
        expect(InputSanitizer.containsEmoji('🚀 User'), true);
        expect(InputSanitizer.containsEmoji('Test ❤️'), true);
        expect(InputSanitizer.containsEmoji('<script>'), true);
        expect(InputSanitizer.containsEmoji('User@Name'), true);
        expect(InputSanitizer.containsEmoji(''), false);
      },
    );
  });
}
