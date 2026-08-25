import '../entities/auth_tokens.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<int?> register({
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String roleSlug = 'tenant',
  });

  Future<AuthTokens> verifyEmailOtp({
    required String email,
    required String otp,
    required String deviceUuid,
    required String deviceType,
  });

  Future<void> resendOtp({
    required String email,
  });

  Future<User?> login({
    required String email,
    required String password,
    required bool rememberMe,
    required String deviceUuid,
    required String deviceType,
  });

  Future<void> forgotPassword({
    required String email,
  });

  Future<String> verifyResetOtp({
    required String email,
    required String otp,
  });

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  });

  Future<AuthTokens> refreshToken({
    required String refreshToken,
  });

  Future<void> logout();
}