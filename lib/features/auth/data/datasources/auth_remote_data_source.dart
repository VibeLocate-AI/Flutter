import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_tokens_model.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponseModel> register(
      RegisterRequestModel request,
      );

  Future<RegisterResponseModel> registerAgent({
    required RegisterRequestModel request,
    required String agencyName,
    required String licenseNumber,
  });

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

  Future<LoginResponseModel> loginWithGoogle({
    required String idToken,
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

  Future<AuthTokensModel> refreshToken(
      String refreshToken,
      );

  Future<void> rememberMe({
    required bool remember,
    required String refreshToken,
  });

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

    await TokenStorage.saveRole(request.roleSlug);
    return RegisterResponseModel.fromJson(
      response,
    );
  }

  @override
  Future<RegisterResponseModel> registerAgent({
    required RegisterRequestModel request,
    required String agencyName,
    required String licenseNumber,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.agentRegister,
      body: {
        'first_name': request.firstName,
        'last_name': request.lastName,
        'email': request.email,
        'phone': request.phone,
        'password': request.password,
        'password_confirmation': request.passwordConfirmation,
        'agency_name': agencyName,
        'license_number': licenseNumber,
      },
    );
    await TokenStorage.saveRole('agent');
    return RegisterResponseModel.fromJson(response);
  }

  @override
  Future<AuthTokensModel> verifyEmailOtp({
    required String email,
    required String otp,
    required String deviceUuid,
    required String deviceType,
  }) async {
    // Match the supplied Laravel/Postman contract exactly. Verification is
    // an email action; device fields are used by login/session endpoints.
    final response = await ApiClient.post(
      ApiEndpoints.verifyOtp,
      body: {
        'email': email,
        'otp': otp,
      },
    );

    final tokens = AuthTokensModel.fromJson(response);

    final nestedData = response['data'] is Map ? response['data'] as Map : null;
    final rawUser = response['user'] ?? nestedData?['user'] ?? response['profile'] ?? nestedData?['profile'];
    if (rawUser is Map) {
      final user = UserModel.fromJson(
        rawUser.map((key, value) => MapEntry(key.toString(), value)),
      );
      if (user.roleSlug != null && user.roleSlug!.trim().isNotEmpty) {
        await TokenStorage.saveRole(user.roleSlug!.trim());
      }
      if (user.id != null) {
        await TokenStorage.saveUserId(user.id!);
      }
    }

    // Some deployments return only a success/message from verify-otp. In
    // that case verification is still successful; keep the saved role/email
    // and let the user continue through Login. If tokens are returned, keep
    // the session as well.
    if (tokens.accessToken.isNotEmpty) {
      final currentRefresh = await TokenStorage.getRefreshToken();
      await TokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken.isNotEmpty
            ? tokens.refreshToken
            : (currentRefresh ?? ''),
      );
    }

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

    if (result.tokens.accessToken.isEmpty || result.tokens.refreshToken.isEmpty) {
      throw const FormatException(
        'Login succeeded but the server did not return valid session tokens.',
      );
    }

    await TokenStorage.saveTokens(
      accessToken: result.tokens.accessToken,
      refreshToken: result.tokens.refreshToken,
    );

    await TokenStorage.saveEmail(
      request.email,
    );

    // Keep the authenticated session across app restarts. The refresh token
    // is stored securely and StartupPage restores it before showing Home.
    await TokenStorage.saveRememberMe(true);

    final user = result.user;
    final userId = user?.id;
    if (userId != null) {
      await TokenStorage.saveUserId(userId);
    }
    if (user != null) {
      final name = [user.firstName, user.lastName]
          .whereType<String>()
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .join(' ');
      await TokenStorage.saveLocalProfile(
        name: name,
        phone: user.phone,
      );
    }
    final role = result.user?.roleSlug?.trim();
    await TokenStorage.saveRole(
      role != null && role.isNotEmpty ? role : 'tenant',
    );

    return result;
  }

  @override
  Future<LoginResponseModel> loginWithGoogle({
    required String idToken,
    required String deviceUuid,
    required String deviceType,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.googleLogin,
      body: {
        'id_token': idToken,
        'device_uuid': deviceUuid,
        'device_type': deviceType,
      },
    );

    final result =
    LoginResponseModel.fromJson(response);

    if (result.tokens.accessToken.isEmpty || result.tokens.refreshToken.isEmpty) {
      throw const FormatException(
        'Google login succeeded but the server did not return valid session tokens.',
      );
    }

    await TokenStorage.saveTokens(
      accessToken: result.tokens.accessToken,
      refreshToken: result.tokens.refreshToken,
    );

    final user = result.user;

    await TokenStorage.saveRememberMe(true);

    final googleEmail = user?.email;
    if (googleEmail != null && googleEmail.isNotEmpty) {
      await TokenStorage.saveEmail(googleEmail);
    }

    final googleUserId = user?.id;
    if (googleUserId != null) {
      await TokenStorage.saveUserId(googleUserId);
    }

    if (user != null) {
      final name = [user.firstName, user.lastName]
          .whereType<String>()
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .join(' ');
      await TokenStorage.saveLocalProfile(
        name: name,
        phone: user.phone,
      );
    }

    final role = user?.roleSlug?.trim();
    await TokenStorage.saveRole(
      role != null && role.isNotEmpty ? role : 'tenant',
    );

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

    // Laravel may return only a success/message from /remember-me.
    // Never overwrite a valid persisted session with empty tokens.
    if (tokens.accessToken.isNotEmpty) {
      final currentRefresh = await TokenStorage.getRefreshToken();
      await TokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken.isNotEmpty
            ? tokens.refreshToken
            : (currentRefresh ?? refreshToken),
      );
    }

    return tokens;
  }

  @override
  Future<void> rememberMe({
    required bool remember,
    required String refreshToken,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.rememberMe,
      authenticated: true,
      body: {
        'remember_me': remember,
        'refresh_token': refreshToken,
      },
    );

    final tokens =
    AuthTokensModel.fromJson(response);

    // /remember-me is allowed to return only {success,message}. In that case
    // keep the tokens created by /login. Saving empty strings here was the
    // reason the Add Property screen later believed the user was logged out.
    if (tokens.accessToken.isNotEmpty) {
      final currentRefresh = await TokenStorage.getRefreshToken();
      await TokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken.isNotEmpty
            ? tokens.refreshToken
            : (currentRefresh ?? refreshToken),
      );
    }

    await TokenStorage.saveRememberMe(remember);
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

    await TokenStorage.clearSession();
  }
}