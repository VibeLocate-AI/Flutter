class CreatePropertyRequest {
  const CreatePropertyRequest({
    required this.title,
    required this.typeId,
    required this.listingType,
    required this.price,
    required this.currency,
    required this.description,
    required this.neighborhoodId,
    required this.addressLine1,
    this.addressLine2,
    this.buildingName,
    required this.latitude,
    required this.longitude,
    required this.areaSqft,
    required this.bedrooms,
    required this.bathrooms,
    required this.propertyCondition,
    this.featureIds = const [],
    this.coverImagePath,
    this.detailImagePaths = const {},
  });

  final String title;

  final int typeId;

  final String listingType;

  final double price;

  final String currency;

  final String description;

  final int neighborhoodId;

  final String addressLine1;

  final String? addressLine2;

  final String? buildingName;

  final double latitude;

  final double longitude;

  final double areaSqft;

  final int bedrooms;

  final int bathrooms;

  final String propertyCondition;

  final List<int> featureIds;

  final String? coverImagePath;

  final Map<String, String> detailImagePaths;
}