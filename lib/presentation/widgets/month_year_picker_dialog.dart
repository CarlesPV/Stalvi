import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';

/// A Material 3 dialog that allows the user to select a month and year.
///
/// Year range is constrained between 2021 and the current system year.
/// When the current year is selected, months are restricted to avoid
/// selecting a future month.
class MonthYearPickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? now;
  final String? title;

  const MonthYearPickerDialog({
    super.key,
    this.initialDate,
    this.now,
    this.title,
  });

  /// Helper method to display the dialog.
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? now,
    String? title,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (context) => MonthYearPickerDialog(
        initialDate: initialDate,
        now: now,
        title: title,
      ),
    );
  }

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  DateTime get _currentTime => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    final now = _currentTime;
    final maxYear = now.year >= 2021 ? now.year : 2021;
    final initial = widget.initialDate ?? now;
    _selectedYear = initial.year.clamp(2021, maxYear);
    final maxMonth = (_selectedYear == now.year) ? now.month : 12;
    _selectedMonth = initial.month.clamp(1, maxMonth);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = _currentTime;
    final maxYear = now.year >= 2021 ? now.year : 2021;

    String locale;
    try {
      locale = Localizations.localeOf(context).toString();
    } catch (_) {
      locale = 'en';
    }
    final monthFormat = DateFormat.MMMM(locale);

    final years = [
      for (int y = 2021; y <= maxYear; y++) y,
    ];

    final maxMonth = (_selectedYear == now.year) ? now.month : 12;
    if (_selectedMonth > maxMonth) {
      _selectedMonth = maxMonth;
    }

    final months = [
      for (int m = 1; m <= maxMonth; m++) m,
    ];

    return AlertDialog(
      title: Text(widget.title ?? l10n.exportPdfSelectMonth),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Semantics(
                label: l10n.a11ySelectYear,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    key: const ValueKey('yearDropdown'),
                    value: _selectedYear,
                    isExpanded: true,
                    items: years.map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (year) {
                      if (year == null) return;
                      setState(() {
                        _selectedYear = year;
                        final newMaxMonth =
                            (_selectedYear == now.year) ? now.month : 12;
                        if (_selectedMonth > newMaxMonth) {
                          _selectedMonth = newMaxMonth;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Semantics(
                label: l10n.a11ySelectMonth,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    key: const ValueKey('monthDropdown'),
                    value: _selectedMonth,
                    isExpanded: true,
                    items: months.map((month) {
                      final date = DateTime(2020, month);
                      final name = monthFormat.format(date);
                      final capitalized = name.isNotEmpty
                          ? '${name[0].toUpperCase()}${name.substring(1)}'
                          : name;
                      return DropdownMenuItem<int>(
                        value: month,
                        child: Text(
                          capitalized,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (month) {
                      if (month == null) return;
                      setState(() {
                        _selectedMonth = month;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          key: const ValueKey('cancelButton'),
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.btnCancel),
        ),
        TextButton(
          key: const ValueKey('selectButton'),
          onPressed: () => Navigator.of(context).pop(
            DateTime(_selectedYear, _selectedMonth),
          ),
          child: Text(l10n.btnSelect),
        ),
      ],
    );
  }
}
