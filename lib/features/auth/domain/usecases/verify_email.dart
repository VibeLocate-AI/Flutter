import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

class VerifyEmail {
  const VerifyEmail(this.repository);

  final AuthRepository repository;

  Future<AuthTokens> call({
    required String email,
    required String otp,
    required String deviceUuid,
    required String deviceType,
  }) {
    return repository.verifyEmailOtp(
      email: email,
      otp: otp,
      deviceUuid: deviceUuid,
      deviceType: deviceType,
    );
  }
}