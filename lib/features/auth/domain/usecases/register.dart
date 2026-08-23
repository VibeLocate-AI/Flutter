import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Register {
  const Register(this._repository);

  final AuthRepository _repository;

  Future<User> call({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) {
    return _repository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }
}