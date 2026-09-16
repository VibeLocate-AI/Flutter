import '../../data/models/ai_search_response_model.dart';
import '../repositories/ai_search_repository.dart';

class AiContextualSearch {
  const AiContextualSearch(
      this.repository,
      );

  final AiSearchRepository repository;

  Future<AiSearchResponseModel> call(
      String query,
      ) {
    return repository.search(query);
  }
}