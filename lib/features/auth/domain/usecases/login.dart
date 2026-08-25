import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Login {
  const Login(this.repository);

  final AuthRepository repository;

  Future<User?> call({
    required String email,
    required String password,
    required bool rememberMe,
    required String deviceUuid,
    required String deviceType,
  }) {
    return repository.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
      deviceUuid: deviceUuid,
      deviceType: deviceType,
    );
  }
}