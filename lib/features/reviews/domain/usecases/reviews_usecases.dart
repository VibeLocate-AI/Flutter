import '../../data/models/review_result_model.dart';
import '../repositories/reviews_repository.dart';

class SaveReview {
  const SaveReview(this.repository);

  final ReviewsRepository repository;

  Future<ReviewResultModel> call({
    required int propertyId,
    required double rating,
    String? review,
  }) {
    return repository.saveReview(
      propertyId: propertyId,
      rating: rating,
      review: review,
    );
  }
}

class UpdateReview {
  const UpdateReview(this.repository);

  final ReviewsRepository repository;

  Future<ReviewResultModel> call({
    required int propertyId,
    required double rating,
    String? review,
  }) {
    return repository.updateReview(
      propertyId: propertyId,
      rating: rating,
      review: review,
    );
  }
}

class DeleteReview {
  const DeleteReview(this.repository);

  final ReviewsRepository repository;

  Future<ReviewResultModel> call(
    int propertyId,
  ) {
    return repository.deleteReview(propertyId);
  }
}
