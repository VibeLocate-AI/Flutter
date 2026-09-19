import '../../data/models/profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileModel> getProfile();

  Future<ProfileModel> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    required String city,
    required String country,
    required String bio,
  });

  Future<ProfileModel> completeProfile({
    required String preferredLanguage,
    required String currency,
  });

  Future<ProfileModel> uploadAvatar(
      String filePath,
      );
}