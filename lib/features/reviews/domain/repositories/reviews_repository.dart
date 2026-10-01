import '../../data/models/review_result_model.dart';

abstract class ReviewsRepository {
  Future<ReviewResultModel> saveReview({
    required int propertyId,
    required double rating,
    String? review,
  });

  Future<ReviewResultModel> updateReview({
    required int propertyId,
    required double rating,
    String? review,
  });

  Future<ReviewResultModel> deleteReview(
    int propertyId,
  );
}
