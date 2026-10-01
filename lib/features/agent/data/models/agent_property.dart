import '../../../../core/constants/api_endpoints.dart';

class AgentProperty {
  const AgentProperty({
    required this.id,
    required this.title,
    required this.status,
    this.imageUrl = '',
    this.price = '',
    this.address = '',
  });

  final int id;
  final String title;
  final String status;
  final String imageUrl;
  final String price;
  final String address;

  factory AgentProperty.fromJson(Map<String, dynamic> json) {
    final image = json['primary_image'] ??
        json['cover_image'] ??
        json['image_url'] ??
        json['image'];

    return AgentProperty(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      title: (json['title'] ?? json['name'] ?? '').toString(),
      status: (json['status'] ?? json['approval_status'] ?? '').toString(),
      imageUrl: _normalizeImage(image),
      price: (json['price'] ?? '').toString(),
      address: (json['address'] ?? json['address_line_1'] ?? '').toString(),
    );
  }

  static String _normalizeImage(dynamic value) {
    final raw = value is Map
        ? (value['image_url'] ?? value['url'] ?? value['path'] ?? '').toString()
        : value?.toString() ?? '';
    final url = raw.trim();
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('/')) return '${ApiEndpoints.baseUrl}$url';
    if (url.startsWith('storage/')) return '${ApiEndpoints.baseUrl}/$url';
    return url;
  }
}
