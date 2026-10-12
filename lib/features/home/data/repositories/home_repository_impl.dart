import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/home_model.dart';

class HomeRepositoryImpl
    implements HomeRepository {
  const HomeRepositoryImpl({
    required this.remoteDataSource,
  });

  final HomeRemoteDataSource remoteDataSource;

  Future<HomeModel?> getCachedHome() async {
    final data = await remoteDataSource.getCachedHome();
    if (data == null) return null;
    return HomeModel.fromJson(data);
  }

  @override
  Future<HomeModel> getHome() async {
    final response =
    await remoteDataSource.getHome();

    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return HomeModel.fromJson(data);
    }

    return HomeModel.fromJson(response);
  }
}