import 'package:get/get.dart';
import '../../features/home/data/models/property_model.dart';
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
    if (hasLoaded.value || isLoading.value) return;
    // Never block the Favorites screen on a slow Render cold start.
    // Data is assigned reactively as soon as the request completes.
    reload(showLoader: false);
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
      // A Render cold start must not replace an already usable Favorites UI
      // with a timeout error. Keep optimistic/local data and retry silently.
      if (items.isEmpty) error.value = null;
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

  Future<bool> toggleProperty(PropertyModel property) async {
    final wasFavorite = isFavorite(property.id);
    if (wasFavorite) {
      return toggle(property.id);
    }

    pendingIds.add(property.id);
    favoriteIds.add(property.id);
    items.removeWhere((item) => item.id == property.id);
    items.insert(0, FavoritePropertyModel.fromProperty(property));
    favoriteIds.refresh();
    items.refresh();
    try {
      await FavoritesDependencies.addFavorite(property.id);
      reload(showLoader: false);
      return true;
    } catch (e) {
      favoriteIds.remove(property.id);
      items.removeWhere((item) => item.id == property.id);
      favoriteIds.refresh();
      items.refresh();
      rethrow;
    } finally {
      pendingIds.remove(property.id);
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
