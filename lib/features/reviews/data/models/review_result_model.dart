class ReviewResultModel {
  const ReviewResultModel({
    required this.propertyId,
    required this.rating,
    required this.totalReviews,
    required this.message,
  });

  final int propertyId;
  final double rating;
  final int totalReviews;
  final String message;

  factory ReviewResultModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReviewResultModel(
      propertyId: int.tryParse(
            json['property_id']?.toString() ?? '',
          ) ??
          0,
      rating: double.tryParse(
            json['rating']?.toString() ?? '',
          ) ??
          0,
      totalReviews: int.tryParse(
            json['total_reviews']?.toString() ?? '',
          ) ??
          0,
      message:
          json['message']?.toString() ?? '',
    );
  }
}
