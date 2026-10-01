import 'package:get/get.dart';
import '../../features/favorites/data/models/favorite_property_model.dart';
import '../../features/favorites/favorites_dependencies.dart';

class FavoritesController extends GetxController {
  final items = <FavoritePropertyModel>[].obs;
  final favoriteIds = <int>{}.obs;
  final pendingIds = <int>{}.obs;
  final isLoading = false.obs;
  final hasLoaded = false.obs;
  final error = RxnString();

  bool isFavorite(int id) => favoriteIds.contains(id);
  bool isPending(int id) => pendingIds.contains(id);

  Future<void> initialize() async {
    if (hasLoaded.value) return;
    await reload(showLoader: false);
  }

  Future<void> reload({bool showLoader = true}) async {
    if (showLoader) isLoading.value = true;
    error.value = null;
    try {
      final result = await FavoritesDependencies.getFavorites();
      items.assignAll(result);
      favoriteIds
        ..clear()
        ..addAll(result.map((e) => e.id))
        ..refresh();
      hasLoaded.value = true;
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> toggle(int propertyId) async {
    if (pendingIds.contains(propertyId)) return isFavorite(propertyId);

    final wasFavorite = isFavorite(propertyId);
    pendingIds.add(propertyId);
    favoriteIds.refresh();
    _removeOrKeepLocal(propertyId, !wasFavorite);

    try {
      if (wasFavorite) {
        await FavoritesDependencies.removeFavorite(propertyId);
      } else {
        await FavoritesDependencies.addFavorite(propertyId);
      }
      if (!wasFavorite) {
        // Sync the full favorite card in the background; the heart is already
        // updated optimistically and does not wait for this request.
        reload(showLoader: false);
      }
      return !wasFavorite;
    } catch (e) {
      _removeOrKeepLocal(propertyId, wasFavorite);
      rethrow;
    } finally {
      pendingIds.remove(propertyId);
    }
  }

  void _removeOrKeepLocal(int id, bool shouldBeFavorite) {
    if (shouldBeFavorite) {
      favoriteIds.add(id);
    } else {
      favoriteIds.remove(id);
      items.removeWhere((e) => e.id == id);
    }
    favoriteIds.refresh();
    items.refresh();
  }

  void syncFromProperty(int id, bool favorite) {
    if (favorite) {
      favoriteIds.add(id);
    } else {
      favoriteIds.remove(id);
      items.removeWhere((e) => e.id == id);
    }
    favoriteIds.refresh();
    items.refresh();
  }
}
