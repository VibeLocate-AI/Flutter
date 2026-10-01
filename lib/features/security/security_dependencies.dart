import 'data/datasources/security_remote_data_source.dart';
import 'data/repositories/security_repository_impl.dart';
import 'domain/usecases/security_usecases.dart';

class SecurityDependencies {
  SecurityDependencies._();

  static final SecurityRemoteDataSource remoteDataSource =
      const SecurityRemoteDataSourceImpl();

  static final SecurityRepositoryImpl repository =
      SecurityRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );

  static final GetSessions getSessions =
      GetSessions(repository);

  static final DeleteSession deleteSession =
      DeleteSession(repository);

  static final SendChangePasswordOtp
      sendChangePasswordOtp =
      SendChangePasswordOtp(repository);

  static final ChangePassword changePassword =
      ChangePassword(repository);

  static final GetTwoFactor getTwoFactor =
      GetTwoFactor(repository);

  static final StartTwoFactor startTwoFactor =
      StartTwoFactor(repository);

  static final VerifyTwoFactor verifyTwoFactor =
      VerifyTwoFactor(repository);

  static final DisableTwoFactor disableTwoFactor =
      DisableTwoFactor(repository);
}
