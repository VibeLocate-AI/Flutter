import '../repositories/auth_repository.dart';

class ForgotPassword {
  const ForgotPassword(this.repository);

  final AuthRepository repository;

  Future<void> call({
    required String email,
  }) {
    return repository.forgotPassword(
      email: email,
    );
  }
}