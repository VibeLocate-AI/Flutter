import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required this.remoteDataSource});

  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<ProfileModel> getProfile() async {
    final profile = ProfileModel.fromJson(
      await remoteDataSource.getProfile(),
    );
    return _mergeLocal(profile);
  }

  @override
  Future<ProfileModel> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    required String city,
    required String country,
    required String bio,
  }) async {
    final profile = ProfileModel.fromJson(
      await remoteDataSource.updateProfile({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'city': city,
        'country': country,
        'bio': bio,
      }),
    );
    return _mergeLocal(profile);
  }

  @override
  Future<ProfileModel> completeProfile({
    required String preferredLanguage,
    required String currency,
  }) async {
    final profile = ProfileModel.fromJson(
      await remoteDataSource.completeProfile({
        'preferred_language': preferredLanguage,
        'currency': currency,
      }),
    );
    return _mergeLocal(profile);
  }

  @override
  Future<ProfileModel> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final profile = ProfileModel.fromJson(
      await remoteDataSource.updateLocation(
        latitude: latitude,
        longitude: longitude,
      ),
    );
    return _mergeLocal(profile);
  }

  @override
  Future<ProfileModel> uploadAvatar(String filePath) async {
    final profile = ProfileModel.fromJson(
      await remoteDataSource.uploadAvatar(filePath),
    );
    return _mergeLocal(profile);
  }

  Future<ProfileModel> _mergeLocal(ProfileModel profile) async {
    final localId = await TokenStorage.getUserId();
    final localEmail = await TokenStorage.getEmail();
    final localName = await TokenStorage.getLocalProfileName();
    final localPhone = await TokenStorage.getLocalProfilePhone();
    final localCity = await TokenStorage.getLocalProfileCity();
    final localCountry = await TokenStorage.getLocalProfileCountry();
    final localRole = await TokenStorage.getRole();

    final resolved = profile.copyWith(
      id: profile.id != 0 ? profile.id : localId,
      fullName: profile.fullName.isNotEmpty ? profile.fullName : localName,
      email: profile.email.isNotEmpty ? profile.email : localEmail,
      phone: profile.phone.isNotEmpty ? profile.phone : localPhone,
      city: profile.city.isNotEmpty ? profile.city : localCity,
      country: profile.country.isNotEmpty ? profile.country : localCountry,
      role: profile.role.isNotEmpty ? profile.role : localRole,
    );

    if (resolved.id != 0) await TokenStorage.saveUserId(resolved.id);
    if (resolved.email.isNotEmpty) await TokenStorage.saveEmail(resolved.email);
    if (resolved.role.isNotEmpty) await TokenStorage.saveRole(resolved.role);

    await TokenStorage.saveLocalProfile(
      name: resolved.fullName,
      phone: resolved.phone,
      city: resolved.city,
      country: resolved.country,
    );

    return resolved;
  }
}
