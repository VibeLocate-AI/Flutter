import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/session_model.dart';
import '../models/two_factor_model.dart';

abstract class SecurityRemoteDataSource {
  Future<List<SessionModel>> getSessions();

  Future<void> deleteSession(int deviceId);

  Future<void> sendChangePasswordOtp({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String otp,
  });

  Future<TwoFactorModel> getTwoFactor();

  Future<TwoFactorSetupModel> startTwoFactor();

  Future<void> verifyTwoFactor(String code);

  Future<void> disableTwoFactor();
}

class SecurityRemoteDataSourceImpl
    implements SecurityRemoteDataSource {
  const SecurityRemoteDataSourceImpl();

  @override
  Future<List<SessionModel>> getSessions() async {
    final response = await ApiClient.get(
      ApiEndpoints.sessions,
      authenticated: true,
    );

    dynamic sessions = response['sessions'] ?? response['data'];
    if (sessions is Map) {
      sessions = sessions['sessions'] ?? sessions['items'] ?? sessions['data'];
    }

    if (sessions is! List) {
      return const [];
    }

    return sessions
        .whereType<Map<String, dynamic>>()
        .map(SessionModel.fromJson)
        .toList();
  }

  @override
  Future<void> deleteSession(int deviceId) async {
    await ApiClient.delete(
      ApiEndpoints.sessions,
      authenticated: true,
      body: {
        'device_id': deviceId,
      },
    );
  }

  @override
  Future<void> sendChangePasswordOtp({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ApiClient.post(
      ApiEndpoints.changePassword,
      authenticated: true,
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String otp,
  }) async {
    await ApiClient.post(
      ApiEndpoints.changePassword,
      authenticated: true,
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'otp': otp,
      },
    );
  }

  @override
  Future<TwoFactorModel> getTwoFactor() async {
    final response = await ApiClient.get(
      ApiEndpoints.twoFactor,
      authenticated: true,
    );

    dynamic data = response['two_factor'] ?? response['data'] ?? response;
    if (data is Map) {
      data = data['two_factor'] ?? data['data'] ?? data;
    }

    return TwoFactorModel.fromJson(
      data is Map
          ? data.map((key, value) => MapEntry(key.toString(), value))
          : const {},
    );
  }

  @override
  Future<TwoFactorSetupModel> startTwoFactor() async {
    final response = await ApiClient.post(
      ApiEndpoints.twoFactor,
      authenticated: true,
      body: {'action': 'start'},
    );

    dynamic data = response['data'] ?? response;
    if (data is Map) {
      data = data['two_factor'] ?? data['setup'] ?? data;
    }
    return TwoFactorSetupModel.fromJson(
      data is Map
          ? data.map((key, value) => MapEntry(key.toString(), value))
          : const {},
    );
  }

  @override
  Future<void> verifyTwoFactor(String code) async {
    await ApiClient.post(
      ApiEndpoints.twoFactor,
      authenticated: true,
      body: {
        'action': 'verify',
        'code': code,
      },
    );
  }

  @override
  Future<void> disableTwoFactor() async {
    await ApiClient.delete(
      ApiEndpoints.twoFactor,
      authenticated: true,
    );
  }
}
