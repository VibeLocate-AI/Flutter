class PopularAreaModel {
  const PopularAreaModel({
    required this.id,
    required this.name,
    required this.propertiesCount,
  });

  final int id;
  final String name;
  final int propertiesCount;

  factory PopularAreaModel.fromJson(Map<String, dynamic> json) {
    return PopularAreaModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      propertiesCount:
      int.tryParse(json['properties_count'].toString()) ?? 0,
    );
  }
}