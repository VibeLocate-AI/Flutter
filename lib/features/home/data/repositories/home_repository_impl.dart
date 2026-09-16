import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/home_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required this.remoteDataSource,
  });

  final HomeRemoteDataSource remoteDataSource;

  @override
  Future<HomeModel> getHome() async {
    final response = await remoteDataSource.getHome();

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid home response format.',
      );
    }

    return HomeModel.fromJson(data);
  }
}