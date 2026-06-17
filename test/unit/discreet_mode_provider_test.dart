import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/presentation/providers/discreet_mode_provider.dart';

void main() {
  group('DiscreetModeNotifier', () {
    test('initial state is true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final isDiscreet = container.read(discreetModeProvider);
      expect(isDiscreet, isTrue);
    });

    test('toggle() switches the state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial state is true
      expect(container.read(discreetModeProvider), isTrue);

      // Toggle to false
      container.read(discreetModeProvider.notifier).toggle();
      expect(container.read(discreetModeProvider), isFalse);

      // Toggle back to true
      container.read(discreetModeProvider.notifier).toggle();
      expect(container.read(discreetModeProvider), isTrue);
    });

    test('setDiscreet() sets the state explicitly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial state is true
      expect(container.read(discreetModeProvider), isTrue);

      // Set to false
      container.read(discreetModeProvider.notifier).setDiscreet(false);
      expect(container.read(discreetModeProvider), isFalse);

      // Set to true
      container.read(discreetModeProvider.notifier).setDiscreet(true);
      expect(container.read(discreetModeProvider), isTrue);
    });
  });
}
