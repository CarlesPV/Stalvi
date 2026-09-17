import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/utils/icon_helper.dart';
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
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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

  testWidgets('renders exactly 180 icon cells', (tester) async {
    await tester.pumpWidget(buildPicker(onIconSelected: (_) {}));

    // Every icon cell is wrapped in an InkWell whose key is
    // ValueKey('iconPicker_<name>'). Count them.
    final keys = CategoryIconPicker.icons
        .map((e) => find.byKey(ValueKey('iconPicker_${e.key}')))
        .toList();

    expect(keys.length, 180);

    // The picker must contain exactly 180 unique entries (no duplicates).
    final uniqueKeys = CategoryIconPicker.icons.map((e) => e.key).toSet();
    expect(uniqueKeys.length, 180);
  });

  // ---------------------------------------------------------------------------
  // Test 2 – Tapping an icon calls onIconSelected with the correct key
  // ---------------------------------------------------------------------------

  testWidgets('tapping an icon invokes onIconSelected with correct key', (
    tester,
  ) async {
    String? tappedKey;

    await tester.pumpWidget(
      buildPicker(onIconSelected: (key) => tappedKey = key),
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

  testWidgets('selected icon cell has primary-colored border / background', (
    tester,
  ) async {
    const selected = 'savings';

    await tester.pumpWidget(
      buildPicker(selectedIcon: selected, onIconSelected: (_) {}),
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

  testWidgets('no icon is highlighted when selectedIcon is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildPicker(
        onIconSelected: (_) {},
        // selectedIcon intentionally omitted → null
      ),
    );

    // All AnimatedContainers should have a transparent background.
    final allContainers = tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );

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
      Icons.category_rounded,
    );
  });

  test('getIconData resolves all category icon keys without fallback', () {
    for (final entry in CategoryIconPicker.icons) {
      if (entry.key == 'category') continue;
      final icon = getIconData(entry.key);
      expect(
        icon,
        isNot(equals(Icons.category_rounded)),
        reason: 'Key "${entry.key}" should be explicitly mapped in getIconData',
      );
    }
  });

  // ---------------------------------------------------------------------------
  // Test 8 – Localized semantic meanings for icons in EN, ES, CA
  // ---------------------------------------------------------------------------

  testWidgets('announces localized category meaning for icons in EN, ES, CA', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    // EN: Bank and Credit card
    await tester.pumpWidget(
      buildPicker(onIconSelected: (_) {}, locale: const Locale('en')),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Bank'), findsOneWidget);
    expect(find.bySemanticsLabel('Credit card'), findsOneWidget);

    // ES: Banco and Tarjeta de crédito
    await tester.pumpWidget(
      buildPicker(onIconSelected: (_) {}, locale: const Locale('es')),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Banco'), findsOneWidget);
    expect(find.bySemanticsLabel('Tarjeta de crédito'), findsOneWidget);

    // CA: Banc and Targeta de crèdit
    await tester.pumpWidget(
      buildPicker(onIconSelected: (_) {}, locale: const Locale('ca')),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Banc'), findsOneWidget);
    expect(find.bySemanticsLabel('Targeta de crèdit'), findsOneWidget);

    handle.dispose();
  });

  // ---------------------------------------------------------------------------
  // Test 9 – Localized color names for screen readers
  // ---------------------------------------------------------------------------

  testWidgets(
      'CategoryIconPicker.localizedColorName provides localized color names', (
    tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(CategoryIconPicker.localizedColorName(ctx, '#2196F3'), 'Blue');
    expect(CategoryIconPicker.localizedColorName(ctx, '#4CAF50'), 'Green');
    expect(CategoryIconPicker.localizedColorName(ctx, '#03A9F4'), 'Light blue');
    expect(CategoryIconPicker.localizedColorName(ctx, '#000000'), 'Black');
    expect(CategoryIconPicker.localizedColorName(ctx, '#FFFFFF'), 'White');

    // Spanish check
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(CategoryIconPicker.localizedColorName(ctx, '#2196F3'), 'Azul');
    expect(CategoryIconPicker.localizedColorName(ctx, '#4CAF50'), 'Verde');
    expect(CategoryIconPicker.localizedColorName(ctx, '#03A9F4'), 'Azul claro');
    expect(CategoryIconPicker.localizedColorName(ctx, '#000000'), 'Negro');
    expect(CategoryIconPicker.localizedColorName(ctx, '#FFFFFF'), 'Blanco');

    // Catalan check
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ca'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(CategoryIconPicker.localizedColorName(ctx, '#2196F3'), 'Blau');
    expect(CategoryIconPicker.localizedColorName(ctx, '#4CAF50'), 'Verd');
    expect(CategoryIconPicker.localizedColorName(ctx, '#03A9F4'), 'Blau clar');
    expect(CategoryIconPicker.localizedColorName(ctx, '#000000'), 'Negre');
    expect(CategoryIconPicker.localizedColorName(ctx, '#FFFFFF'), 'Blanc');
  });
}
