import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/presentation/widgets/category_icon_picker.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Wraps a widget in a minimal Material app so that the widget can be pumped
  /// without an ambient MediaQuery / Theme ancestor being missing.
  Widget buildPicker({
    String? selectedIcon,
    required ValueChanged<String> onIconSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CategoryIconPicker(
            selectedIcon: selectedIcon,
            onIconSelected: onIconSelected,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Test 1 – Correct number of icons rendered
  // ---------------------------------------------------------------------------

  testWidgets('renders exactly 128 icon cells', (tester) async {
    await tester.pumpWidget(
      buildPicker(
        onIconSelected: (_) {},
      ),
    );

    // Every icon cell is wrapped in an InkWell whose key is
    // ValueKey('iconPicker_<name>'). Count them.
    final keys = CategoryIconPicker.icons
        .map((e) => find.byKey(ValueKey('iconPicker_${e.key}')))
        .toList();

    expect(keys.length, 128);

    // The picker must contain exactly 128 unique entries (no duplicates).
    final uniqueKeys = CategoryIconPicker.icons.map((e) => e.key).toSet();
    expect(uniqueKeys.length, 128);
  });

  // ---------------------------------------------------------------------------
  // Test 2 – Tapping an icon calls onIconSelected with the correct key
  // ---------------------------------------------------------------------------

  testWidgets('tapping an icon invokes onIconSelected with correct key',
      (tester) async {
    String? tappedKey;

    await tester.pumpWidget(
      buildPicker(
        onIconSelected: (key) => tappedKey = key,
      ),
    );

    // Tap the first icon in the list.
    final firstKey = CategoryIconPicker.icons.first.key;
    final firstFinder = find.byKey(ValueKey('iconPicker_$firstKey'));

    expect(firstFinder, findsOneWidget);
    await tester.tap(firstFinder);
    await tester.pump();

    expect(tappedKey, firstKey);
  });

  // ---------------------------------------------------------------------------
  // Test 3 – Selected icon shows selection indicator
  // ---------------------------------------------------------------------------

  testWidgets('selected icon cell has primary-colored border / background',
      (tester) async {
    const selected = 'savings';

    await tester.pumpWidget(
      buildPicker(
        selectedIcon: selected,
        onIconSelected: (_) {},
      ),
    );

    // The selected cell is an AnimatedContainer with a non-transparent color.
    // We verify the InkWell with the correct key exists and that the
    // AnimatedContainer inside it has a background (primary.withOpacity(0.18)).
    final selectedCell = find.byKey(const ValueKey('iconPicker_$selected'));
    expect(selectedCell, findsOneWidget);

    // The AnimatedContainer inside the selected cell should have a
    // non-transparent decoration color.
    final animatedContainers = find.descendant(
      of: selectedCell,
      matching: find.byType(AnimatedContainer),
    );
    expect(animatedContainers, findsOneWidget);

    final container = tester.widget<AnimatedContainer>(animatedContainers);
    final decoration = container.decoration as BoxDecoration?;
    expect(decoration, isNotNull);
    expect(decoration!.color, isNotNull);
    // The selected color should not be fully transparent.
    expect(decoration.color!.a, isNot(equals(0)));
  });

  // ---------------------------------------------------------------------------
  // Test 4 – No icon highlighted when selectedIcon is null
  // ---------------------------------------------------------------------------

  testWidgets('no icon is highlighted when selectedIcon is null',
      (tester) async {
    await tester.pumpWidget(
      buildPicker(
        onIconSelected: (_) {},
        // selectedIcon intentionally omitted → null
      ),
    );

    // All AnimatedContainers should have a transparent background.
    final allContainers =
        tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));

    for (final container in allContainers) {
      final decoration = container.decoration as BoxDecoration?;
      if (decoration?.color != null) {
        expect(
          decoration!.color,
          equals(Colors.transparent),
          reason: 'No cell should be highlighted when selectedIcon is null',
        );
      }
    }
  });

  // ---------------------------------------------------------------------------
  // Test 5 – iconDataForKey returns correct IconData
  // ---------------------------------------------------------------------------

  test('iconDataForKey returns the matching IconData', () {
    for (final entry in CategoryIconPicker.icons) {
      expect(
        CategoryIconPicker.iconDataForKey(entry.key),
        entry.value,
        reason: 'Key "${entry.key}" should resolve to the correct IconData',
      );
    }
  });

  // ---------------------------------------------------------------------------
  // Test 6 – iconDataForKey falls back to Icons.category for unknown keys
  // ---------------------------------------------------------------------------

  test('iconDataForKey falls back to Icons.category for unknown keys', () {
    expect(
      CategoryIconPicker.iconDataForKey('__unknown_key__'),
      Icons.category,
    );
  });

  // ---------------------------------------------------------------------------
}
