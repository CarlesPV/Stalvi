// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';

/// Tests for the background task scheduling anchor logic extracted from
/// [BackgroundTasks.registerPeriodicTasks].
///
/// The function targets 22:00 UTC (= 00:00 UTC+2 for both CET and CEST)
/// and always picks the *next* occurrence — either today or tomorrow.
///
/// We test the pure scheduling arithmetic here without spinning up WorkManager.

/// Mirrors the production algorithm used in BackgroundTasks.registerPeriodicTasks.
({DateTime target, Duration initialDelay}) _computeNextMidnightUtcPlus2(
  DateTime nowUtc,
) {
  var target = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, 22, 0, 0);
  if (!nowUtc.isBefore(target)) {
    target = target.add(const Duration(days: 1));
  }
  return (target: target, initialDelay: target.difference(nowUtc));
}

void main() {
  group('BackgroundTasks scheduling — next 22:00 UTC anchor', () {
    test('selects today 22:00 UTC when current time is before 22:00 UTC', () {
      // Simulates the device clock reading 10:00 UTC.
      final now = DateTime.utc(2026, 7, 15, 10, 0, 0);
      final result = _computeNextMidnightUtcPlus2(now);

      expect(result.target, equals(DateTime.utc(2026, 7, 15, 22, 0, 0)));
      expect(result.initialDelay, equals(const Duration(hours: 12)));
    });

    test('selects tomorrow 22:00 UTC when current time is exactly 22:00 UTC',
        () {
      // Exactly at the target — must advance to tomorrow.
      final now = DateTime.utc(2026, 7, 15, 22, 0, 0);
      final result = _computeNextMidnightUtcPlus2(now);

      expect(result.target, equals(DateTime.utc(2026, 7, 16, 22, 0, 0)));
      expect(result.initialDelay, equals(const Duration(hours: 24)));
    });

    test('selects tomorrow 22:00 UTC when current time is past 22:00 UTC', () {
      // Simulates the device clock reading 23:30 UTC.
      final now = DateTime.utc(2026, 7, 15, 23, 30, 0);
      final result = _computeNextMidnightUtcPlus2(now);

      expect(result.target, equals(DateTime.utc(2026, 7, 16, 22, 0, 0)));
      // From 23:30 UTC today to 22:00 UTC tomorrow = 22.5 hours.
      expect(
          result.initialDelay, equals(const Duration(hours: 22, minutes: 30)));
    });

    test('crosses year boundary correctly (31 Dec 23:00 UTC → 1 Jan 22:00 UTC)',
        () {
      final now = DateTime.utc(2026, 12, 31, 23, 0, 0);
      final result = _computeNextMidnightUtcPlus2(now);

      expect(result.target, equals(DateTime.utc(2027, 1, 1, 22, 0, 0)));
      expect(result.initialDelay, equals(const Duration(hours: 23)));
    });

    test(
        'crosses month boundary correctly (31 Jan 22:01 UTC → 1 Feb 22:00 UTC)',
        () {
      final now = DateTime.utc(2026, 1, 31, 22, 1, 0);
      final result = _computeNextMidnightUtcPlus2(now);

      expect(result.target, equals(DateTime.utc(2026, 2, 1, 22, 0, 0)));
      expect(
        result.initialDelay,
        equals(const Duration(hours: 23, minutes: 59)),
      );
    });

    test('initialDelay is always positive', () {
      // Exhaustive sweep: for every hour and minute of the day the delay
      // must be > 0 and ≤ 24 h.
      for (int h = 0; h < 24; h++) {
        for (int m = 0; m < 60; m++) {
          final now = DateTime.utc(2026, 6, 15, h, m, 0);
          final result = _computeNextMidnightUtcPlus2(now);
          expect(
            result.initialDelay.inSeconds,
            greaterThan(0),
            reason:
                'Failed for ${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} UTC',
          );
          expect(
            result.initialDelay.inSeconds,
            lessThanOrEqualTo(const Duration(hours: 24).inSeconds),
          );
        }
      }
    });
  });
}
