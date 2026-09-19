import 'data/datasources/profile_remote_data_source.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/usecases/profile_usecases.dart';

class ProfileDependencies {
  ProfileDependencies._();

  static final ProfileRemoteDataSource
  remoteDataSource =
  ProfileRemoteDataSourceImpl();

  static final ProfileRepositoryImpl
  repository =
  ProfileRepositoryImpl(
    remoteDataSource:
    remoteDataSource,
  );

  static final GetProfile
  getProfile =
  GetProfile(repository);

  static final UpdateProfile
  updateProfile =
  UpdateProfile(repository);

  static final CompleteProfile
  completeProfile =
  CompleteProfile(repository);

  static final UploadAvatar
  uploadAvatar =
  UploadAvatar(repository);
}