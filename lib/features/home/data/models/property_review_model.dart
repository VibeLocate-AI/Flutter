class PropertyReviewModel {
  const PropertyReviewModel({
    this.id,
    this.userId,
    required this.rating,
    required this.comment,
    this.authorName = '',
    this.authorAvatarUrl,
    this.createdAt,
    this.isMine = false,
    this.canEdit = false,
    this.canDelete = false,
  });

  final int? id;
  final int? userId;
  final double rating;
  final String comment;
  final String authorName;
  final String? authorAvatarUrl;
  final String? createdAt;
  final bool isMine;
  final bool canEdit;
  final bool canDelete;


  PropertyReviewModel copyWith({
    int? id,
    int? userId,
    double? rating,
    String? comment,
    String? authorName,
    String? authorAvatarUrl,
    String? createdAt,
    bool? isMine,
    bool? canEdit,
    bool? canDelete,
  }) {
    return PropertyReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      createdAt: createdAt ?? this.createdAt,
      isMine: isMine ?? this.isMine,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
    );
  }

  factory PropertyReviewModel.fromJson(
    Map<String, dynamic> json, {
    int? currentUserId,
  }) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    final userId = _toNullableInt(
      json['user_id'] ?? user['id'],
    );

    final authorName = (
      json['user_name'] ??
      json['author_name'] ??
      user['full_name'] ??
      user['name'] ??
      [
        user['first_name'],
        user['last_name'],
      ].where((v) => v != null && v.toString().trim().isNotEmpty)
        .join(' ')
    ).toString().trim();

    return PropertyReviewModel(
      id: _toNullableInt(json['id']),
      userId: userId,
      rating: double.tryParse(
            (json['rating'] ?? 0).toString(),
          ) ??
          0,
      comment: (
        json['review'] ??
        json['comment'] ??
        json['content'] ??
        ''
      ).toString(),
      authorName: authorName,
      authorAvatarUrl: (
        json['avatar_url'] ??
        json['avatar'] ??
        user['avatar_url'] ??
        user['avatar']
      )?.toString(),
      createdAt: json['created_at']?.toString(),
      isMine: _toBool(json['is_mine']) ||
          (currentUserId != null &&
              userId != null &&
              currentUserId == userId),
      canEdit: _toBool(
        json['can_edit'] ?? json['editable'],
      ),
      canDelete: _toBool(
        json['can_delete'] ?? json['deletable'],
      ),
    );
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    final text = value?.toString().toLowerCase();
    return text == '1' || text == 'true' || text == 'yes';
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }
}
