import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_tokens_model.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponseModel> register(
      RegisterRequestModel request,
      );

  Future<AuthTokensModel> verifyEmailOtp({
    required String email,
    required String otp,
    required String deviceUuid,
    required String deviceType,
  });

  Future<void> resendOtp({
    required String email,
  });

  Future<LoginResponseModel> login(
      LoginRequestModel request,
      );

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

  Future<AuthTokensModel> refreshToken(
      String refreshToken,
      );

  Future<void> logout(
      String refreshToken,
      );
}

class AuthRemoteDataSourceImpl
    implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl();

  @override
  Future<RegisterResponseModel> register(
      RegisterRequestModel request,
      ) async {
    final response = await ApiClient.post(
      ApiEndpoints.register,
      body: request.toJson(),
    );

    return RegisterResponseModel.fromJson(
      response,
    );
  }

  @override
  Future<AuthTokensModel> verifyEmailOtp({
    required String email,
    required String otp,
    required String deviceUuid,
    required String deviceType,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.verifyOtp,
      body: {
        'email': email,
        'otp': otp,
        'device_uuid': deviceUuid,
        'device_type': deviceType,
      },
    );

    final tokens =
    AuthTokensModel.fromJson(response);

    await TokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    await TokenStorage.saveEmail(email);

    return tokens;
  }

  @override
  Future<void> resendOtp({
    required String email,
  }) async {
    await ApiClient.post(
      ApiEndpoints.resendOtp,
      body: {
        'email': email,
      },
    );
  }

  @override
  Future<LoginResponseModel> login(
      LoginRequestModel request,
      ) async {
    final response = await ApiClient.post(
      ApiEndpoints.login,
      body: request.toJson(),
    );

    final result =
    LoginResponseModel.fromJson(response);

    await TokenStorage.saveTokens(
      accessToken:
      result.tokens.accessToken,
      refreshToken:
      result.tokens.refreshToken,
    );

    await TokenStorage.saveEmail(
      request.email,
    );

    if (result.user?.id != null) {
      await TokenStorage.saveUserId(
        result.user!.id!,
      );
    }

    return result;
  }

  @override
  Future<void> forgotPassword({
    required String email,
  }) async {
    await ApiClient.post(
      ApiEndpoints.forgotPassword,
      body: {
        'email': email,
      },
    );
  }

  @override
  Future<String> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.verifyResetOtp,
      body: {
        'email': email,
        'otp': otp,
      },
    );

    final data =
    response['data'] is Map<String, dynamic>
        ? response['data']
    as Map<String, dynamic>
        : response;

    final resetToken =
    data['reset_token']?.toString();

    if (resetToken == null ||
        resetToken.isEmpty) {
      throw const FormatException(
        'Reset token was not returned by the server.',
      );
    }

    return resetToken;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    await ApiClient.post(
      ApiEndpoints.resetPassword,
      body: {
        'email': email,
        'token': token,
        'new_password': newPassword,
      },
    );
  }

  @override
  Future<AuthTokensModel> refreshToken(
      String refreshToken,
      ) async {
    final response = await ApiClient.post(
      ApiEndpoints.refreshToken,
      body: {
        'refresh_token': refreshToken,
      },
    );

    final tokens =
    AuthTokensModel.fromJson(response);

    await TokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    return tokens;
  }

  @override
  Future<void> logout(
      String refreshToken,
      ) async {
    await ApiClient.post(
      ApiEndpoints.logout,
      body: {
        'refresh_token': refreshToken,
      },
      authenticated: true,
    );

    await TokenStorage.clearTokens();
  }
}