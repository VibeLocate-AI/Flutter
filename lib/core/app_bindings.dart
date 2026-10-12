import 'package:get/get.dart';

import 'controllers/favorites_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/map_controller_x.dart';
import 'controllers/my_properties_controller.dart';
import 'controllers/property_details_controller.dart';
import '../features/settings/settings_controller.dart';
import '../app/navigation/app_bar_actions.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<FavoritesController>(FavoritesController(), permanent: true);
    Get.put<MyPropertiesController>(MyPropertiesController(), permanent: true);
    Get.put<MapControllerX>(MapControllerX(), permanent: true);
    Get.put<PropertyDetailsController>(PropertyDetailsController(), permanent: true);
    Get.put<SettingsController>(SettingsController(), permanent: true);
    Get.put<NotificationBadgeController>(NotificationBadgeController(), permanent: true);
  }
}
