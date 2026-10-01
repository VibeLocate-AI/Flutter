import '../../data/models/session_model.dart';
import '../../data/models/two_factor_model.dart';

abstract class SecurityRepository {
  Future<List<SessionModel>> getSessions();

  Future<void> deleteSession(int deviceId);

  Future<void> sendChangePasswordOtp({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String otp,
  });

  Future<TwoFactorModel> getTwoFactor();

  Future<TwoFactorSetupModel> startTwoFactor();

  Future<void> verifyTwoFactor(String code);

  Future<void> disableTwoFactor();
}
