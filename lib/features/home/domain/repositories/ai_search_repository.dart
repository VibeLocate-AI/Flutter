import '../../data/models/ai_search_response_model.dart';

abstract class AiSearchRepository {
  Future<AiSearchResponseModel> search(String query);
}