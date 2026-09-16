import '../../data/models/map_location_model.dart';
import '../repositories/map_repository.dart';
class GetMapLocations { const GetMapLocations(this.repository); final MapRepository repository; Future<List<MapLocationModel>> call() => repository.getLocations(); }
