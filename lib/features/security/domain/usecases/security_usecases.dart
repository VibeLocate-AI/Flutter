import '../../data/models/session_model.dart';
import '../../data/models/two_factor_model.dart';
import '../repositories/security_repository.dart';

class GetSessions {
  const GetSessions(this.repository);

  final SecurityRepository repository;

  Future<List<SessionModel>> call() =>
      repository.getSessions();
}

class DeleteSession {
  const DeleteSession(this.repository);

  final SecurityRepository repository;

  Future<void> call(int deviceId) =>
      repository.deleteSession(deviceId);
}

class SendChangePasswordOtp {
  const SendChangePasswordOtp(this.repository);

  final SecurityRepository repository;

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) =>
      repository.sendChangePasswordOtp(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
}

class ChangePassword {
  const ChangePassword(this.repository);

  final SecurityRepository repository;

  Future<void> call({
    required String currentPassword,
    required String newPassword,
    required String otp,
  }) =>
      repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        otp: otp,
      );
}

class GetTwoFactor {
  const GetTwoFactor(this.repository);

  final SecurityRepository repository;

  Future<TwoFactorModel> call() =>
      repository.getTwoFactor();
}

class StartTwoFactor {
  const StartTwoFactor(this.repository);

  final SecurityRepository repository;

  Future<TwoFactorSetupModel> call() =>
      repository.startTwoFactor();
}

class VerifyTwoFactor {
  const VerifyTwoFactor(this.repository);

  final SecurityRepository repository;

  Future<void> call(String code) =>
      repository.verifyTwoFactor(code);
}

class DisableTwoFactor {
  const DisableTwoFactor(this.repository);

  final SecurityRepository repository;

  Future<void> call() =>
      repository.disableTwoFactor();
}
