import 'package:get/get.dart';

import '../../features/home/data/models/property_model.dart';
import '../../features/favorites/data/models/favorite_property_model.dart';
import '../../features/favorites/favorites_dependencies.dart';
import '../storage/favorites_cache_storage.dart';

class FavoritesController extends GetxController {
  final items = <FavoritePropertyModel>[].obs;
  final favoriteIds = <int>{}.obs;
  final pendingIds = <int>{}.obs;
  final isLoading = false.obs;
  final hasLoaded = false.obs;
  final error = RxnString();

  /// Durable local decisions.
  /// true  => the user explicitly added this property.
  /// false => the user explicitly removed this property.
  ///
  /// These survive a background GET so an eventually-consistent backend cannot
  /// make a freshly-added favorite disappear from another screen.
  final Map<int, bool> _overrides = <int, bool>{};

  /// Desired state while a request is currently in flight.
  final Map<int, bool> _pendingDesired = <int, bool>{};

  bool isFavorite(int id) => favoriteIds.contains(id);
  bool isPending(int id) => pendingIds.contains(id);

  Future<void> initialize() async {
    if (hasLoaded.value || isLoading.value) return;
    await _restoreCache();
    // Paint cache first; never block the screen on the network.
    unawaitedReload();
  }

  void unawaitedReload() {
    reload(showLoader: false);
  }

  Future<void> _restoreCache() async {
    try {
      final cached = await FavoritesCacheStorage.read();
      if (cached == null) return;

      final ids = (cached['ids'] as List?)
          ?.map((e) => int.tryParse(e.toString()) ?? 0)
          .where((id) => id > 0)
          .toSet();

      final cachedItems = (cached['items'] as List?)
              ?.whereType<Map>()
              .map((item) => FavoritePropertyModel.fromJson(
                    item.map((key, value) => MapEntry(key.toString(), value)),
                  ))
              .where((item) => item.id > 0)
              .toList(growable: false) ??
          const <FavoritePropertyModel>[];

      final rawOverrides = cached['overrides'];
      if (rawOverrides is Map) {
        _overrides.clear();
        rawOverrides.forEach((key, value) {
          final id = int.tryParse(key.toString());
          if (id != null && id > 0 && value is bool) {
            _overrides[id] = value;
          }
        });
      }

      if (ids != null) {
        favoriteIds
          ..clear()
          ..addAll(ids)
          ..refresh();
      }
      if (cachedItems.isNotEmpty) {
        items.assignAll(cachedItems);
      }

      // Apply explicit local decisions on top of the cached snapshot.
      for (final entry in _overrides.entries) {
        if (entry.value) {
          favoriteIds.add(entry.key);
        } else {
          favoriteIds.remove(entry.key);
          items.removeWhere((item) => item.id == entry.key);
        }
      }
      favoriteIds.refresh();
      items.refresh();

      if (favoriteIds.isNotEmpty || items.isNotEmpty || _overrides.isNotEmpty) {
        hasLoaded.value = true;
      }
    } catch (_) {
      // Corrupt cache must never block the Favorites screen.
    }
  }

  Future<void> _saveCache() async {
    try {
      await FavoritesCacheStorage.save(
        ids: favoriteIds.toList(growable: false),
        items: items.map(_toCacheJson).toList(growable: false),
        overrides: Map<int, bool>.from(_overrides),
      );
    } catch (_) {}
  }

  Map<String, dynamic> _toCacheJson(FavoritePropertyModel item) {
    return {
      'id': item.id,
      'title': item.title,
      'slug': item.slug,
      'price': item.price,
      'currency': item.currency,
      'bedrooms': item.bedrooms,
      'bathrooms': item.bathrooms,
      'area_sqft': item.areaSqft,
      'listing_type': item.actionType,
      'type_id': item.typeId,
      'property_type': item.propertyType,
      'category_id': item.categoryId,
      'category_name': item.categoryName,
      'latitude': item.latitude,
      'longitude': item.longitude,
      'address': item.address,
      'neighborhood_id': item.neighborhoodId,
      'neighborhood': item.neighborhood,
      'image_url': item.imageUrl,
      'favorited_at': item.favoritedAt,
      'is_favorite': item.isFavorite,
      'is_furnished': item.isFurnished,
      'rent_frequency': item.rentFrequency,
      'is_featured': item.isFeatured,
    };
  }

  Future<void> reload({bool showLoader = true}) async {
    if (isLoading.value) return;
    if (showLoader) isLoading.value = true;
    error.value = null;

    try {
      final result = await FavoritesDependencies.getFavorites();
      final serverById = <int, FavoritePropertyModel>{
        for (final item in result) item.id: item,
      };

      // Once the backend confirms our explicit choice, the temporary local
      // override is no longer needed. If the backend is still eventually
      // consistent, keep the override and protect the UI from the stale GET.
      final confirmedOverrides = <int>[];
      for (final entry in _overrides.entries) {
        final serverHasFavorite = serverById.containsKey(entry.key);
        if ((entry.value && serverHasFavorite) ||
            (!entry.value && !serverHasFavorite)) {
          confirmedOverrides.add(entry.key);
        }
      }
      for (final id in confirmedOverrides) {
        _overrides.remove(id);
      }

      // Start from the server snapshot, then apply durable local decisions.
      // This is the key fix for the disappearing-favorite bug.
      final merged = <int, FavoritePropertyModel>{...serverById};
      final nextIds = <int>{...serverById.keys};

      for (final entry in _overrides.entries) {
        if (entry.value) {
          nextIds.add(entry.key);
          final local = items.firstWhereOrNull((item) => item.id == entry.key);
          if (local != null) {
            merged[entry.key] = local;
          }
        } else {
          nextIds.remove(entry.key);
          merged.remove(entry.key);
        }
      }

      // In-flight operations always win over a just-returned GET.
      for (final entry in _pendingDesired.entries) {
        if (entry.value) {
          nextIds.add(entry.key);
          final local = items.firstWhereOrNull((item) => item.id == entry.key);
          if (local != null) merged[entry.key] = local;
        } else {
          nextIds.remove(entry.key);
          merged.remove(entry.key);
        }
      }

      items.assignAll(merged.values);
      favoriteIds
        ..clear()
        ..addAll(nextIds)
        ..refresh();
      hasLoaded.value = true;
      await _saveCache();
    } catch (e) {
      // Never erase working cache because a refresh failed.
      if (items.isEmpty && favoriteIds.isEmpty) {
        error.value = e.toString().replaceFirst('Exception: ', '');
      } else {
        error.value = null;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> toggle(int propertyId) async {
    if (pendingIds.contains(propertyId)) return isFavorite(propertyId);

    final wasFavorite = isFavorite(propertyId);
    final desired = !wasFavorite;
    pendingIds.add(propertyId);
    _pendingDesired[propertyId] = desired;
    _overrides[propertyId] = desired;
    _setLocalFavorite(propertyId, desired);
    await _saveCache();

    try {
      if (desired) {
        await FavoritesDependencies.addFavorite(propertyId);
      } else {
        await FavoritesDependencies.removeFavorite(propertyId);
      }
      _pendingDesired.remove(propertyId);
      await _saveCache();
      return desired;
    } catch (e) {
      _pendingDesired.remove(propertyId);
      _overrides[propertyId] = wasFavorite;
      _setLocalFavorite(propertyId, wasFavorite);
      await _saveCache();
      rethrow;
    } finally {
      pendingIds.remove(propertyId);
    }
  }

  Future<bool> toggleProperty(PropertyModel property) async {
    final propertyId = property.id;
    if (pendingIds.contains(propertyId)) return isFavorite(propertyId);

    final wasFavorite = isFavorite(propertyId);
    final desired = !wasFavorite;
    pendingIds.add(propertyId);
    _pendingDesired[propertyId] = desired;
    _overrides[propertyId] = desired;

    if (desired) {
      favoriteIds.add(propertyId);
      final local = FavoritePropertyModel.fromProperty(property);
      items.removeWhere((item) => item.id == propertyId);
      items.insert(0, local);
    } else {
      favoriteIds.remove(propertyId);
      items.removeWhere((item) => item.id == propertyId);
    }
    favoriteIds.refresh();
    items.refresh();
    await _saveCache();

    try {
      if (desired) {
        await FavoritesDependencies.addFavorite(propertyId);
      } else {
        await FavoritesDependencies.removeFavorite(propertyId);
      }
      _pendingDesired.remove(propertyId);
      await _saveCache();
      return desired;
    } catch (e) {
      _pendingDesired.remove(propertyId);
      _overrides[propertyId] = wasFavorite;
      _setLocalFavorite(propertyId, wasFavorite, property: property);
      await _saveCache();
      rethrow;
    } finally {
      pendingIds.remove(propertyId);
    }
  }

  void _setLocalFavorite(int id, bool favorite, {PropertyModel? property}) {
    if (favorite) {
      favoriteIds.add(id);
      if (property != null) {
        final local = FavoritePropertyModel.fromProperty(property);
        items.removeWhere((item) => item.id == id);
        items.insert(0, local);
      }
    } else {
      favoriteIds.remove(id);
      items.removeWhere((item) => item.id == id);
    }
    favoriteIds.refresh();
    items.refresh();
  }

  void syncFromProperty(int id, bool favorite) {
    if (pendingIds.contains(id)) return;

    // A property-details response can be stale immediately after a favorite
    // mutation. Never let that response overwrite an explicit local choice.
    if (_overrides.containsKey(id)) {
      _setLocalFavorite(id, _overrides[id] == true);
      return;
    }

    // This is only a server observation, not a durable user decision. Keep it
    // out of `_overrides` so future server changes can still be accepted.
    _setLocalFavorite(id, favorite);
    _saveCache();
  }
}
