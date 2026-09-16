import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/network/api_client.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> getHome();
}

class HomeRemoteDataSourceImpl
    implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl();

  @override
  Future<Map<String, dynamic>> getHome() {
    return ApiClient.get(
      ApiEndpoints.home,
      queryParameters: {
        'lang': LocaleManager.instance.languageCode,
      },
      authenticated: true,
    );
  }
}