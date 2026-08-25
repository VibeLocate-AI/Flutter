import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

class RefreshToken {
  const RefreshToken(this.repository);

  final AuthRepository repository;

  Future<AuthTokens> call({
    required String refreshToken,
  }) {
    return repository.refreshToken(
      refreshToken: refreshToken,
    );
  }
}