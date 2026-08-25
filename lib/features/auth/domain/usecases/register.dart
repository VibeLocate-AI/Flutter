import '../repositories/auth_repository.dart';

class Register {
  const Register(this.repository);

  final AuthRepository repository;

  Future<int?> call({
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) {
    return repository.register(
      firstName: firstName,
      lastName: lastName,
      city: city,
      country: country,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation:
      passwordConfirmation,
    );
  }
}