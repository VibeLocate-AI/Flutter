class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.image,
    this.referenceType,
    this.referenceId,
    this.actionUrl,
    required this.isRead,
    this.readAt,
    this.createdAt,
  });

  final int id;
  final String type;
  final String title;
  final String message;
  final String? image;
  final String? referenceType;
  final int? referenceId;
  final String? actionUrl;
  final bool isRead;
  final String? readAt;
  final String? createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final reference = _asMap(json['reference']);

    return NotificationModel(
      id: _toInt(json['id']),
      type: _text(json['type']),
      title: _text(json['title']),
      message: _text(json['message'] ?? json['body']),
      image: _nullableText(json['image'] ?? json['image_url']),
      referenceType: _nullableText(reference?['type']),
      referenceId: _nullableInt(reference?['id']),
      actionUrl: _nullableText(json['action_url'] ?? json['url']),
      isRead: _toBool(
        json['is_read'] ?? json['read'] ?? json['read_at'] != null,
      ),
      readAt: _nullableText(json['read_at']),
      createdAt: _nullableText(json['created_at'] ?? json['date']),
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      message: message,
      image: image,
      referenceType: referenceType,
      referenceId: referenceId,
      actionUrl: actionUrl,
      isRead: isRead ?? this.isRead,
      readAt: readAt,
      createdAt: createdAt,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return null;
  }

  static String _text(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static String? _nullableText(dynamic value) {
    final text = _text(value);
    return text.isEmpty ? null : text;
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim();
    return text == '1' || text == 'true' || text == 'yes' || text == 'read';
  }
}

class NotificationsResult {
  const NotificationsResult({
    required this.items,
    required this.unreadCount,
  });

  final List<NotificationModel> items;
  final int unreadCount;
}
