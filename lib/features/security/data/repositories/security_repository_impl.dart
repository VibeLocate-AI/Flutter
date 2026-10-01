import '../../domain/repositories/security_repository.dart';
import '../datasources/security_remote_data_source.dart';
import '../models/session_model.dart';
import '../models/two_factor_model.dart';

class SecurityRepositoryImpl
    implements SecurityRepository {
  const SecurityRepositoryImpl({
    required this.remoteDataSource,
  });

  final SecurityRemoteDataSource remoteDataSource;

  @override
  Future<List<SessionModel>> getSessions() =>
      remoteDataSource.getSessions();

  @override
  Future<void> deleteSession(int deviceId) =>
      remoteDataSource.deleteSession(deviceId);

  @override
  Future<void> sendChangePasswordOtp({
    required String currentPassword,
    required String newPassword,
  }) =>
      remoteDataSource.sendChangePasswordOtp(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String otp,
  }) =>
      remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        otp: otp,
      );

  @override
  Future<TwoFactorModel> getTwoFactor() =>
      remoteDataSource.getTwoFactor();

  @override
  Future<TwoFactorSetupModel> startTwoFactor() =>
      remoteDataSource.startTwoFactor();

  @override
  Future<void> verifyTwoFactor(String code) =>
      remoteDataSource.verifyTwoFactor(code);

  @override
  Future<void> disableTwoFactor() =>
      remoteDataSource.disableTwoFactor();
}
