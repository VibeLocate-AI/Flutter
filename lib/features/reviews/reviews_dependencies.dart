import 'data/datasources/reviews_remote_data_source.dart';
import 'data/repositories/reviews_repository_impl.dart';
import 'domain/usecases/reviews_usecases.dart';

class ReviewsDependencies {
  ReviewsDependencies._();

  static final ReviewsRemoteDataSource remoteDataSource =
      const ReviewsRemoteDataSourceImpl();

  static final ReviewsRepositoryImpl repository =
      ReviewsRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );

  static final SaveReview saveReview =
      SaveReview(repository);

  static final UpdateReview updateReview =
      UpdateReview(repository);

  static final DeleteReview deleteReview =
      DeleteReview(repository);
}
