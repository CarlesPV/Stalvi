import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/data/database/app_database.dart' as db;
import 'package:stalvi/data/mappers/profile_mapper.dart';

void main() {
  group('ProfileMapper', () {
    final now = DateTime.now();

    final domainProfile = Profile(
      id: 'test-id',
      name: 'John Doe',
      username: 'johndoe',
      password: 'hashedpassword',
      defaultCurrency: 'USD',
      createdAt: now,
      modifiedAt: now,
    );

    final dbProfile = db.Profile(
      id: 'test-id',
      name: 'John Doe',
      username: 'johndoe',
      password: 'hashedpassword',
      defaultCurrency: 'USD',
      createdAt: now,
      modifiedAt: now,
    );

    test('toDb() converts domain Profile to db Profile correctly', () {
      final result = domainProfile.toDb();

      expect(result.id, dbProfile.id);
      expect(result.name, dbProfile.name);
      expect(result.username, dbProfile.username);
      expect(result.password, dbProfile.password);
      expect(result.defaultCurrency, dbProfile.defaultCurrency);
      expect(result.createdAt, dbProfile.createdAt);
      expect(result.modifiedAt, dbProfile.modifiedAt);
    });

    test('toDomain() converts db Profile to domain Profile correctly', () {
      final result = dbProfile.toDomain();

      expect(result.id, domainProfile.id);
      expect(result.name, domainProfile.name);
      expect(result.username, domainProfile.username);
      expect(result.password, domainProfile.password);
      expect(result.defaultCurrency, domainProfile.defaultCurrency);
      expect(result.createdAt, domainProfile.createdAt);
      expect(result.modifiedAt, domainProfile.modifiedAt);
    });
  });
}
