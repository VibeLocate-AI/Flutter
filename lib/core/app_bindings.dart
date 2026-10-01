import 'package:get/get.dart';
import 'controllers/favorites_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/map_controller_x.dart';
import 'controllers/my_properties_controller.dart';
import 'controllers/property_details_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<FavoritesController>(FavoritesController(), permanent: true);
    Get.put<MyPropertiesController>(MyPropertiesController(), permanent: true);
    Get.put<MapControllerX>(MapControllerX(), permanent: true);
    Get.put<PropertyDetailsController>(PropertyDetailsController(), permanent: true);
  }
}
