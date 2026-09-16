class MapLocationModel {
  const MapLocationModel({required this.id, required this.latitude, required this.longitude, this.propertyId, this.title = '', this.address = '', this.price = '', this.imageUrl = ''});
  final int id; final int? propertyId; final double latitude, longitude; final String title, address, price, imageUrl;
  factory MapLocationModel.fromJson(Map<String, dynamic> json) => MapLocationModel(
    id: int.tryParse((json['id'] ?? json['property_id'] ?? '').toString()) ?? 0,
    propertyId: int.tryParse((json['property_id'] ?? '').toString()),
    latitude: double.tryParse((json['latitude'] ?? json['lat'] ?? '').toString()) ?? 0,
    longitude: double.tryParse((json['longitude'] ?? json['lng'] ?? json['lon'] ?? '').toString()) ?? 0,
    title: (json['title'] ?? json['name'] ?? json['property_title'] ?? '').toString(),
    address: (json['address'] ?? json['address_line_1'] ?? '').toString(),
    price: (json['price'] ?? '').toString(),
    imageUrl: (json['image_url'] ?? json['image'] ?? '').toString(),
  );
}
