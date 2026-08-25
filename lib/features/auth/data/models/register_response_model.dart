class RegisterResponseModel {
  const RegisterResponseModel({
    this.userId,
    required this.message,
    this.success,
  });

  final int? userId;
  final String message;
  final bool? success;

  factory RegisterResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final id = json['user_id'];

    return RegisterResponseModel(
      userId: id is int
          ? id
          : int.tryParse(
        id?.toString() ?? '',
      ),
      message:
      json['message']?.toString() ?? '',
      success: json['success'] is bool
          ? json['success'] as bool
          : null,
    );
  }
}