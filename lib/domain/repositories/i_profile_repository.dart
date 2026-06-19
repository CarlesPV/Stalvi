import '../entities/profile.dart';

abstract class IProfileRepository {
  Future<Profile> createProfile(Profile profile);
  Future<Profile?> getProfileById(String id);
  Future<Profile?> getFirstProfile();
  Future<Profile> updateProfile(Profile profile);
  Future<void> deleteProfile(String id);
}
