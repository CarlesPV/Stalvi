import 'package:flutter/widgets.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/recurrence_type.dart';

extension AutomaticTransactionStringGenerator on AutomaticTransaction {
  String formatRecurrence(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (recurrenceType == RecurrenceType.specificDayOfMonth) {
      return l10n.autoTxFormatSpecificDay(recurrenceDays.toString());
    } else {
      final days = recurrenceDays;
      if (days == 7) return l10n.autoTxFormatWeekly;
      if (days == 30) return l10n.autoTxFormatMonthly;
      if (days == 365) return l10n.autoTxFormatYearly;
      return l10n.autoTxFormatEveryDays(days);
    }
  }
}
