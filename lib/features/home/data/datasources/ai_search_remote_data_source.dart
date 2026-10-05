import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/network/api_client.dart';

abstract class AiSearchRemoteDataSource {
  Future<Map<String, dynamic>> search(String query);
}

class AiSearchRemoteDataSourceImpl
    implements AiSearchRemoteDataSource {
  const AiSearchRemoteDataSourceImpl();

  @override
  Future<Map<String, dynamic>> search(String query) async {
    final language =
    LocaleManager.instance.isArabic ? 'ar' : 'en';

    final body = <String, dynamic>{
      'query': query.trim(),
      'language': language,
    };

    try {
      return await ApiClient.post(
        ApiEndpoints.aiContextualSearch,
        body: body,
      );
    } catch (_) {
      // Some deployments may require authentication for AI Search.
      // Retry once using the current access token.
      return await ApiClient.post(
        ApiEndpoints.aiContextualSearch,
        authenticated: true,
        body: body,
      );
    }
  }
}