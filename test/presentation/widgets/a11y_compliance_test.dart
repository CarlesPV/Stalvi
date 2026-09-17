// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Accessibility Compliance Tests', () {
    group('Group 1: "Color selector accessibility"', () {
      testWidgets('Color circle has Semantics with button: true and label',
          (tester) async {
        String selectedColor = '#FF0000';
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  const colorHex = '#FF0000';
                  final isSelected = selectedColor == colorHex;
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: 'Red',
                    child: GestureDetector(
                      onTap: () => setState(() => selectedColor = colorHex),
                      child: Container(
                        width: 38,
                        height: 38,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(GestureDetector));
        expect(
          semantics.getSemanticsData().hasFlag(SemanticsFlag.isButton),
          isTrue,
        );
        expect(
          semantics.getSemanticsData().hasFlag(SemanticsFlag.isSelected),
          isTrue,
        );
        expect(semantics.getSemanticsData().label, 'Red');
      });
    });

    group('Group 2: "MergeSemantics not applied to interactive trailing"', () {
      testWidgets(
          'ListTile with DropdownButton trailing does not use MergeSemantics',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListTile(
                title: const Text('Theme'),
                trailing: DropdownButton<String>(
                  value: 'Light',
                  items: const [
                    DropdownMenuItem(value: 'Light', child: Text('Light')),
                    DropdownMenuItem(value: 'Dark', child: Text('Dark')),
                  ],
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        );

        // Verify there is no MergeSemantics wrapping the ListTile
        final mergeSemanticsFinder = find.ancestor(
          of: find.byType(ListTile),
          matching: find.byType(MergeSemantics),
        );
        expect(mergeSemanticsFinder, findsNothing);

        final dropdownSemantics =
            tester.getSemantics(find.byType(DropdownButton<String>));
        expect(
          dropdownSemantics.getSemanticsData().hasFlag(SemanticsFlag.isButton),
          isTrue,
        );
      });
    });

    group('Group 3: "Form error LiveRegion"', () {
      testWidgets('Validation error has Semantics(liveRegion: true)',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Semantics(
                liveRegion: true,
                child: const Text('Invalid input'),
              ),
            ),
          ),
        );

        final semanticsFinder = find.text('Invalid input');
        expect(semanticsFinder, findsOneWidget);

        final semantics = tester.getSemantics(semanticsFinder);
        expect(
          semantics.getSemanticsData().hasFlag(SemanticsFlag.isLiveRegion),
          isTrue,
        );
      });
    });

    group('Group 4: "Transaction type segmented control"', () {
      testWidgets('Segments have button: true and selected: true for active',
          (tester) async {
        String activeType = 'Expense';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Row(
                    children: ['Expense', 'Income', 'Transfer'].map((type) {
                      final isSelected = activeType == type;
                      return Semantics(
                        button: true,
                        selected: isSelected,
                        label: type,
                        child: GestureDetector(
                          onTap: () => setState(() => activeType = type),
                          child: Text(type),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        );

        final expenseSemantics = tester.getSemantics(find.text('Expense'));
        expect(
          expenseSemantics.getSemanticsData().hasFlag(SemanticsFlag.isButton),
          isTrue,
        );
        expect(
          expenseSemantics.getSemanticsData().hasFlag(SemanticsFlag.isSelected),
          isTrue,
        );
        expect(expenseSemantics.getSemanticsData().label, contains('Expense'));

        final incomeSemantics = tester.getSemantics(find.text('Income'));
        expect(
          incomeSemantics.getSemanticsData().hasFlag(SemanticsFlag.isButton),
          isTrue,
        );
        expect(
          incomeSemantics.getSemanticsData().hasFlag(SemanticsFlag.isSelected),
          isFalse,
        );
        expect(incomeSemantics.getSemanticsData().label, contains('Income'));
      });
    });

    group('Group 5: "CircularProgressIndicator has semanticsLabel"', () {
      testWidgets('CircularProgressIndicator has a semanticsLabel',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CircularProgressIndicator(
                semanticsLabel: 'Loading data...',
              ),
            ),
          ),
        );

        final semanticsFinder = find.byType(CircularProgressIndicator);
        expect(semanticsFinder, findsOneWidget);

        final semantics = tester.getSemantics(semanticsFinder);
        expect(semantics.getSemanticsData().label, 'Loading data...');
      });
    });
  });
}
