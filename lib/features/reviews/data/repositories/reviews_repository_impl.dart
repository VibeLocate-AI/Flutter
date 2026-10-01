import '../../domain/repositories/reviews_repository.dart';
import '../datasources/reviews_remote_data_source.dart';
import '../models/review_result_model.dart';

class ReviewsRepositoryImpl
    implements ReviewsRepository {
  const ReviewsRepositoryImpl({
    required this.remoteDataSource,
  });

  final ReviewsRemoteDataSource remoteDataSource;

  @override
  Future<ReviewResultModel> saveReview({
    required int propertyId,
    required double rating,
    String? review,
  }) {
    return remoteDataSource.saveReview(
      propertyId: propertyId,
      rating: rating,
      review: review,
    );
  }

  @override
  Future<ReviewResultModel> updateReview({
    required int propertyId,
    required double rating,
    String? review,
  }) {
    return remoteDataSource.updateReview(
      propertyId: propertyId,
      rating: rating,
      review: review,
    );
  }

  @override
  Future<ReviewResultModel> deleteReview(
    int propertyId,
  ) {
    return remoteDataSource.deleteReview(
      propertyId,
    );
  }
}
