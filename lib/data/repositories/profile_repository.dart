import 'package:konta/data/database/app_database.dart' as db;
import 'package:konta/data/mappers/profile_mapper.dart';
import 'package:konta/domain/entities/profile.dart';
import 'package:konta/domain/repositories/i_profile_repository.dart';

/// Concrete implementation of [IProfileRepository] backed by Drift.
class ProfileRepository implements IProfileRepository {
  final db.AppDatabase _db;

  ProfileRepository(this._db);

  @override
  Future<Profile> createProfile(Profile profile) async {
    final dbProfile = profile.toDb();
    await _db.into(_db.profiles).insert(dbProfile);
    return profile;
  }

  @override
  Future<Profile?> getProfileById(String id) async {
    final query = _db.select(_db.profiles)..where((p) => p.id.equals(id));
    final row = await query.getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<Profile?> getFirstProfile() async {
    final query = _db.select(_db.profiles)..limit(1);
    final row = await query.getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final dbProfile = profile.toDb();
    await (_db.update(_db.profiles)..where((p) => p.id.equals(profile.id)))
        .write(dbProfile.toCompanion(true));
    return profile;
  }

  @override
  Future<void> deleteProfile(String id) async {
    // Hard delete profile, or we can soft delete if needed, but profiles table
    // does not have an is_deleted column. Let's do a delete query.
    await (_db.delete(_db.profiles)..where((p) => p.id.equals(id))).go();
  }
}
