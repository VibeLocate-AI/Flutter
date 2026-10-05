import 'package:get/get.dart';

import '../../../core/state/favorites_manager.dart';
import '../../../core/state/location_manager.dart';

class MainNavigationController extends GetxController {
  final currentIndex = 0.obs;

  void selectTab(int index) {
    if (index == currentIndex.value) return;

    currentIndex.value = index;

    if (index == 0) {
      LocationManager.instance.updateCurrentLocation();
    }

    if (index == 3) {
      FavoritesManager.instance.load(force: true);
    }
  }

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() async {
      await FavoritesManager.instance.load(force: true);
    });
  }
}
