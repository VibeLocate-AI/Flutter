import '../../domain/repositories/ai_search_repository.dart';
import '../datasources/ai_search_remote_data_source.dart';
import '../models/ai_search_response_model.dart';

class AiSearchRepositoryImpl
    implements AiSearchRepository {
  const AiSearchRepositoryImpl({
    required this.remoteDataSource,
  });

  final AiSearchRemoteDataSource remoteDataSource;

  @override
  Future<AiSearchResponseModel> search(
      String query,
      ) async {
    final response =
    await remoteDataSource.search(query);

    return AiSearchResponseModel.fromJson(
      response,
    );
  }
}