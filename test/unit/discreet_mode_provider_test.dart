import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konta/presentation/providers/discreet_mode_provider.dart';

void main() {
  group('DiscreetModeNotifier', () {
    test('initial state is false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final isDiscreet = container.read(discreetModeProvider);
      expect(isDiscreet, isFalse);
    });

    test('toggle() switches the state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial state is false
      expect(container.read(discreetModeProvider), isFalse);

      // Toggle to true
      container.read(discreetModeProvider.notifier).toggle();
      expect(container.read(discreetModeProvider), isTrue);

      // Toggle back to false
      container.read(discreetModeProvider.notifier).toggle();
      expect(container.read(discreetModeProvider), isFalse);
    });
  });
}
