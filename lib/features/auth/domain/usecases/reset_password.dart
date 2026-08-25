import '../repositories/auth_repository.dart';

class ResetPassword {
  const ResetPassword(this.repository);

  final AuthRepository repository;

  Future<void> call({
    required String email,
    required String token,
    required String newPassword,
  }) {
    return repository.resetPassword(
      email: email,
      token: token,
      newPassword: newPassword,
    );
  }
}