import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/review_result_model.dart';

abstract class ReviewsRemoteDataSource {
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

class ReviewsRemoteDataSourceImpl
    implements ReviewsRemoteDataSource {
  const ReviewsRemoteDataSourceImpl();

  @override
  Future<ReviewResultModel> saveReview({
    required int propertyId,
    required double rating,
    String? review,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.propertyReview(propertyId),
      authenticated: true,
      body: {
        'rating': rating,
        'review': review,
      },
    );

    return ReviewResultModel.fromJson(
      response,
    );
  }

  @override
  Future<ReviewResultModel> updateReview({
    required int propertyId,
    required double rating,
    String? review,
  }) async {
    // Laravel's ReviewController intentionally uses POST for both create
    // and update: if the authenticated user already has a review for this
    // property, store() updates that review.
    final response = await ApiClient.post(
      ApiEndpoints.propertyReview(propertyId),
      authenticated: true,
      body: {
        'rating': rating,
        'review': review,
      },
    );

    return ReviewResultModel.fromJson(response);
  }

  @override
  Future<ReviewResultModel> deleteReview(
    int propertyId,
  ) async {
    final response = await ApiClient.delete(
      ApiEndpoints.propertyReview(propertyId),
      authenticated: true,
    );

    return ReviewResultModel.fromJson(
      response,
    );
  }
}
