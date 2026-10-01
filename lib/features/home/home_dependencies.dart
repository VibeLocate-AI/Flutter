import 'data/datasources/ai_search_remote_data_source.dart';
import 'data/datasources/home_remote_data_source.dart';
import 'data/repositories/ai_search_repository_impl.dart';
import 'data/repositories/home_repository_impl.dart';
import 'domain/usecases/ai_contextual_search.dart';
import 'domain/usecases/get_home.dart';

class HomeDependencies {
  HomeDependencies._();

  static final HomeRemoteDataSource remoteDataSource =
  HomeRemoteDataSourceImpl();

  static final HomeRepositoryImpl repository =
  HomeRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );

  static final GetHome getHome =
  GetHome(repository);

  static final AiSearchRemoteDataSource aiSearchRemoteDataSource =
  AiSearchRemoteDataSourceImpl();

  static final AiSearchRepositoryImpl aiSearchRepository =
  AiSearchRepositoryImpl(
    remoteDataSource: aiSearchRemoteDataSource,
  );

  static final AiContextualSearch aiContextualSearch =
  AiContextualSearch(aiSearchRepository);
}