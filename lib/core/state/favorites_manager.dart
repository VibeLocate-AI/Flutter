import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../features/favorites/data/models/favorite_property_model.dart';
import '../../features/favorites/favorites_dependencies.dart';
import '../controllers/favorites_controller.dart';

class FavoritesManager extends ChangeNotifier {
  FavoritesManager._();

  static final FavoritesManager instance = FavoritesManager._();

  FavoritesController get controller =>
      Get.isRegistered<FavoritesController>()
          ? Get.find<FavoritesController>()
          : Get.put(FavoritesController(), permanent: true);

  bool isFavorite(int propertyId) => controller.isFavorite(propertyId);
  bool isLoading(int propertyId) => controller.isPending(propertyId);
  bool get isLoaded => controller.hasLoaded.value;

  Future<void> load({bool force = false}) async {
    if (!force) {
      await controller.initialize();
    } else {
      await controller.reload(showLoader: false);
    }
    notifyListeners();
  }

  Future<bool> toggle(int propertyId) async {
    try {
      final value = await controller.toggle(propertyId);
      notifyListeners();
      return value;
    } finally {
      notifyListeners();
    }
  }

  void setFromProperty(int propertyId, bool favorite) {
    controller.syncFromProperty(propertyId, favorite);
    notifyListeners();
  }

  Future<List<FavoritePropertyModel>> getItems() async {
    if (!controller.hasLoaded.value) {
      await controller.initialize();
    }
    return controller.items.toList(growable: false);
  }

  Future<void> addDirect(int propertyId) =>
      FavoritesDependencies.addFavorite(propertyId);
}
