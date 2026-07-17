/// Describes how often an [AutomaticTransaction] recurs.
///
/// **Storage note**: Drift persists this as an integer index via `intEnum`.
/// Appending new variants (as done here) is safe — existing DB rows retain
/// their stored indices.
///
/// - [intervalDays]       Custom N-day interval (e.g. every 10 days).
/// - [specificDayOfMonth] Fires on a fixed calendar day each month (1–31),
///                        clamped to the month's last day when needed.
/// - [weekly]             Fires every 7 days (semantic sugar; no magic number).
/// - [monthly]            Fires on the same calendar day each month, advancing
///                        by one full calendar month (not just 30 days).
/// - [yearly]             Fires on the same calendar date each year, advancing
///                        by one full calendar year (leap-year aware).
enum RecurrenceType {
  intervalDays, // index 0
  specificDayOfMonth, // index 1
  weekly, // index 2
  monthly, // index 3
  yearly, // index 4
}
