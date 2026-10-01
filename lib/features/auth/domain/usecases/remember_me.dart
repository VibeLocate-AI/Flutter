import '../repositories/auth_repository.dart';

class RememberMe {
  const RememberMe(this.repository);

  final AuthRepository repository;

  Future<void> call({
    required bool remember,
    required String refreshToken,
  }) {
    return repository.rememberMe(
      remember: remember,
      refreshToken: refreshToken,
    );
  }
}
