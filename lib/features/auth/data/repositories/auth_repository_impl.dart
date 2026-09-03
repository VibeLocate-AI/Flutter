import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

class AuthRepositoryImpl
    implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  final AuthRemoteDataSource remoteDataSource;

  @override
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
  }) async {
    final result =
    await remoteDataSource.register(
      RegisterRequestModel(
        firstName: firstName,
        lastName: lastName,
        city: city,
        country: country,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation:
        passwordConfirmation,
        roleSlug: roleSlug,
      ),
    );

    return result.userId;
  }

  @override
  Future<AuthTokens> verifyEmailOtp({
    required String email,
    required String otp,
    required String deviceUuid,
    required String deviceType,
  }) {
    return remoteDataSource.verifyEmailOtp(
      email: email,
      otp: otp,
      deviceUuid: deviceUuid,
      deviceType: deviceType,
    );
  }

  @override
  Future<void> resendOtp({
    required String email,
  }) {
    return remoteDataSource.resendOtp(
      email: email,
    );
  }

  @override
  Future<User?> login({
    required String email,
    required String password,
    required bool rememberMe,
    required String deviceUuid,
    required String deviceType,
  }) async {
    final result =
    await remoteDataSource.login(
      LoginRequestModel(
        email: email,
        password: password,
        rememberMe: rememberMe,
        deviceUuid: deviceUuid,
        deviceType: deviceType,
      ),
    );

    return result.user;
  }

  @override
  Future<AuthTokens> loginWithGoogle({
    required String idToken,
    required String deviceUuid,
    required String deviceType,
  }) async {
    final result =
    await remoteDataSource.loginWithGoogle(
      idToken: idToken,
      deviceUuid: deviceUuid,
      deviceType: deviceType,
    );

    return result.tokens;
  }

  @override
  Future<void> forgotPassword({
    required String email,
  }) {
    return remoteDataSource.forgotPassword(
      email: email,
    );
  }

  @override
  Future<String> verifyResetOtp({
    required String email,
    required String otp,
  }) {
    return remoteDataSource.verifyResetOtp(
      email: email,
      otp: otp,
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) {
    return remoteDataSource.resetPassword(
      email: email,
      token: token,
      newPassword: newPassword,
    );
  }

  @override
  Future<AuthTokens> refreshToken({
    required String refreshToken,
  }) {
    return remoteDataSource.refreshToken(
      refreshToken,
    );
  }

  @override
  Future<void> logout() async {
    final refreshToken =
    await TokenStorage.getRefreshToken();

    if (refreshToken == null ||
        refreshToken.isEmpty) {
      return;
    }

    await remoteDataSource.logout(
      refreshToken,
    );
  }
}