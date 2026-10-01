import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../models/nearby_poi_model.dart';

class NearbyPoiService {
  NearbyPoiService._();

  static final NearbyPoiService instance = NearbyPoiService._();

  static const _assetPath = 'assets/data/dubai_pois.json';
  static const _radiusKm = 2.0;
  static const _maxResults = 8;

  List<NearbyPoiModel>? _cache;
  Future<List<NearbyPoiModel>>? _loading;

  Future<List<NearbyPoiModel>> load() {
    final cached = _cache;
    if (cached != null) return Future.value(cached);
    return _loading ??= _loadFromAsset();
  }

  Future<List<NearbyPoiModel>> _loadFromAsset() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      final parsed = decoded
          .whereType<Map>()
          .map(
            (item) => NearbyPoiModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .where((poi) =>
              poi.latitude != 0 && poi.longitude != 0 && poi.name.isNotEmpty)
          .toList(growable: false);

      _cache = parsed;
      return parsed;
    } catch (_) {
      _loading = null;
      return const [];
    }
  }

  Future<List<NearbyPoiModel>> nearby(
    double latitude,
    double longitude, {
    double radiusKm = _radiusKm,
    int limit = _maxResults,
  }) async {
    final all = await load();
    if (all.isEmpty) return const [];

    final center = LatLng(latitude, longitude);
    final distance = Distance();
    final results = <({NearbyPoiModel poi, double km})>[];

    for (final poi in all) {
      final km = distance.as(
        LengthUnit.Kilometer,
        center,
        LatLng(poi.latitude, poi.longitude),
      );
      if (km <= radiusKm) {
        results.add((poi: poi, km: km));
      }
    }

    results.sort((a, b) => a.km.compareTo(b.km));
    return results
        .take(limit)
        .map((entry) => entry.poi)
        .toList(growable: false);
  }
}
