import '../../data/models/profile_model.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  const GetProfile(
      this.repository,
      );

  final ProfileRepository repository;

  Future<ProfileModel> call() {
    return repository.getProfile();
  }
}

class UpdateProfile {
  const UpdateProfile(
      this.repository,
      );

  final ProfileRepository repository;

  Future<ProfileModel> call({
    required String fullName,
    required String email,
    required String phone,
    required String city,
    required String country,
    required String bio,
  }) {
    return repository.updateProfile(
      fullName: fullName,
      email: email,
      phone: phone,
      city: city,
      country: country,
      bio: bio,
    );
  }
}

class CompleteProfile {
  const CompleteProfile(
      this.repository,
      );

  final ProfileRepository repository;

  Future<ProfileModel> call({
    required String preferredLanguage,
    required String currency,
  }) {
    return repository.completeProfile(
      preferredLanguage:
      preferredLanguage,
      currency: currency,
    );
  }
}

class UploadAvatar {
  const UploadAvatar(
      this.repository,
      );

  final ProfileRepository repository;

  Future<ProfileModel> call(
      String filePath,
      ) {
    return repository.uploadAvatar(
      filePath,
    );
  }
}