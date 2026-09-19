import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl
    implements ProfileRepository {
  const ProfileRepositoryImpl({
    required this.remoteDataSource,
  });

  final ProfileRemoteDataSource
  remoteDataSource;

  @override
  Future<ProfileModel> getProfile() async {
    final response =
    await remoteDataSource.getProfile();

    return ProfileModel.fromJson(
      _extractData(response),
    );
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
    final response =
    await remoteDataSource.updateProfile(
      {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'city': city,
        'country': country,
        'bio': bio,
      },
    );

    return ProfileModel.fromJson(
      _extractData(response),
    );
  }

  @override
  Future<ProfileModel> completeProfile({
    required String preferredLanguage,
    required String currency,
  }) async {
    final response =
    await remoteDataSource.completeProfile(
      {
        'preferred_language':
        preferredLanguage,
        'currency': currency,
      },
    );

    return ProfileModel.fromJson(
      _extractData(response),
    );
  }

  @override
  Future<ProfileModel> uploadAvatar(
      String filePath,
      ) async {
    final response =
    await remoteDataSource.uploadAvatar(
      filePath,
    );

    return ProfileModel.fromJson(
      _extractData(response),
    );
  }

  Map<String, dynamic> _extractData(
      Map<String, dynamic> response,
      ) {
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return response;
  }
}