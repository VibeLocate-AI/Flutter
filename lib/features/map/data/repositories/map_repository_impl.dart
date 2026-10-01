import '../../domain/repositories/map_repository.dart';
import '../datasources/map_remote_data_source.dart';
import '../models/map_location_model.dart';
import '../../../properties/properties_dependencies.dart';

class MapRepositoryImpl implements MapRepository {
  const MapRepositoryImpl({required this.remoteDataSource});

  final MapRemoteDataSource remoteDataSource;

  @override
  Future<List<MapLocationModel>> getLocations() async {
    final response = await remoteDataSource.getMap();
    dynamic value = response['data'];

    if (value is Map<String, dynamic>) {
      value = value['locations'] ??
          value['properties'] ??
          value['markers'] ??
          value['data'];
    }

    value ??= response['locations'] ??
        response['properties'] ??
        response['markers'];

    if (value is List) {
      final locations = value
          .whereType<Map>()
          .map((item) => MapLocationModel.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ))
          .where((location) =>
              location.latitude != 0 && location.longitude != 0)
          .toList();
      if (locations.isNotEmpty) return locations;
    }

    // Some backend deployments may return an empty map payload while the
    // properties endpoint is populated. Keep the map useful by falling back
    // to property coordinates instead of showing a blank map.
    try {
      final properties = await PropertiesDependencies.loadProperties();
      return properties
          .where((p) =>
              p.location?.latitude != null &&
              p.location?.longitude != null &&
              p.location!.latitude != 0 &&
              p.location!.longitude != 0)
          .map(
            (p) {
              final location = p.location!;
              final addressParts = <String>[
                location.addressLine1,
                if ((location.buildingName ?? '').trim().isNotEmpty)
                  location.buildingName!.trim(),
                if ((location.neighborhoodName ?? '').trim().isNotEmpty)
                  location.neighborhoodName!.trim(),
              ].where((value) => value.trim().isNotEmpty).toList();
              final address = addressParts.join(', ');
              final price = p.price.toStringAsFixed(0);
              return MapLocationModel(
                id: p.id,
                propertyId: p.id,
                latitude: location.latitude!,
                longitude: location.longitude!,
                title: p.displayTitle,
                address: address,
                price: '$price ${p.currency}',
                currency: p.currency,
                priceAmount: p.price,
                imageUrl: p.primaryImage?.imageUrl ?? '',
                typeId: p.typeId,
              );
            },
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
