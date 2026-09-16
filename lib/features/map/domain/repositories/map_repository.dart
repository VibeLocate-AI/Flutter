import '../../data/models/map_location_model.dart';
abstract class MapRepository { Future<List<MapLocationModel>> getLocations(); }
