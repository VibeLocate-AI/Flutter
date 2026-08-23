import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  });

  Future<void> logout();

  Future<void> forgotPassword({
    required String email,
  });
}