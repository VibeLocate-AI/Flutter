class PopularAreaModel {
  const PopularAreaModel({
    required this.id,
    required this.name,
    required this.propertiesCount,
    this.imageUrl,
  });

  final int id;
  final String name;
  final int propertiesCount;
  final String? imageUrl;

  factory PopularAreaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PopularAreaModel(
      id: int.tryParse(
            json['id']?.toString() ?? '',
          ) ??
          0,
      name: json['name']?.toString() ?? '',
      propertiesCount:
          int.tryParse(
                json['properties_count']
                    ?.toString() ??
                    '',
              ) ??
              0,
      imageUrl:
          json['image_url']?.toString(),
    );
  }
}
