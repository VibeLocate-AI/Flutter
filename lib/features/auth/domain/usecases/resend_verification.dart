import '../repositories/auth_repository.dart';

class ResendVerification {
  const ResendVerification(this.repository);

  final AuthRepository repository;

  Future<void> call({
    required String email,
  }) {
    return repository.resendOtp(
      email: email,
    );
  }
}