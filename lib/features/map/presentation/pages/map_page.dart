import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/map_controller_x.dart';
import '../../../../core/controllers/property_details_controller.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/state/location_manager.dart';
import '../../../../core/widgets/currency_price.dart';
import '../../data/models/map_location_model.dart';
import '../../data/models/nearby_poi_model.dart';
import '../../data/services/nearby_poi_service.dart';
import '../../../home/presentation/widgets/property_filter_sheet.dart';
import '../../../home/presentation/widgets/property_categories.dart';

class MapPage extends StatefulWidget {
  const MapPage({
    super.key,
    this.initialPropertyId,
  });

  final int? initialPropertyId;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  PropertyFilterValues _filters = const PropertyFilterValues();
  MapLocationModel? _selected;
  List<NearbyPoiModel> _nearbyPois = const [];
  List<MapLocationModel> _nearbyProperties = const [];

  MapControllerX get controller => Get.find<MapControllerX>();

  @override
  void initState() {
    super.initState();
    controller.initialize().then((_) async {
      final locationManager = LocationManager.instance;
      if (!locationManager.hasCurrentLocation && !locationManager.isUpdating) {
        await locationManager.updateCurrentLocation();
      }
      if (!mounted) return;
      final locations = controller.locations.toList(growable: false);
      MapLocationModel? initial;
      for (final location in locations) {
        if (location.propertyId == widget.initialPropertyId) {
          initial = location;
          break;
        }
      }
      if (widget.initialPropertyId != null && initial == null) {
        await controller.reload();
        if (!mounted) return;
        final refreshed = controller.locations.toList(growable: false);
        for (final location in refreshed) {
          if (location.propertyId == widget.initialPropertyId) {
            initial = location;
            break;
          }
        }
      }
      setState(() {
        _selected = initial;
        _nearbyProperties = initial == null ? const [] : _findNearbyProperties(initial);
      });
      if (initial != null) {
        _loadNearbyPois(initial);
      } else {
        final manager = LocationManager.instance;
        if (manager.hasCurrentLocation &&
            manager.latitude != null &&
            manager.longitude != null) {
          _loadNearbyPoisAt(
            manager.latitude!,
            manager.longitude!,
          );
        }
      }
      // The Map tab is a property-discovery map: on entry it must focus
      // the properties already loaded from the Home/API, not the user's GPS.
      // The user's GPS is only used by the explicit "my location" action.
      final focus = initial ?? (locations.isNotEmpty ? locations.first : null);
      if (focus != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _mapController.move(
            LatLng(focus.latitude, focus.longitude),
            initial == null ? 11 : 15,
          );
        });
      }
    });
  }

  Future<void> _showFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SizedBox(
        height: MediaQuery.sizeOf(context).height * .90,
        child: PropertyFilterSheet(
          initialValues: _filters,
          onApply: (value) {
            setState(() => _filters = value);
            controller.setFilters(value);
          },
        ),
      ),
    );
  }

  List<MapLocationModel> get _filteredLocations => controller.filtered;

  Future<void> _load() async {
    await controller.reload();
    if (mounted) setState(() {});
  }

  LatLng get _center {
    final locations = _filteredLocations;
    if (locations.isNotEmpty) {
      final location = locations.first;
      return LatLng(location.latitude, location.longitude);
    }
    final all = controller.locations;
    if (all.isNotEmpty) {
      final location = all.first;
      return LatLng(location.latitude, location.longitude);
    }
    final manager = LocationManager.instance;
    if (manager.hasCurrentLocation &&
        manager.latitude != null &&
        manager.longitude != null) {
      return LatLng(manager.latitude!, manager.longitude!);
    }
    return const LatLng(25.2048, 55.2708);
  }

  List<MapLocationModel> _visiblePropertyLocations(List<MapLocationModel> source) {
    if (source.length <= 50) return source;
    final center = _selected == null ? _center : LatLng(_selected!.latitude, _selected!.longitude);
    final distance = Distance();
    final sorted = source
        .where((item) => item.latitude != 0 && item.longitude != 0)
        .map((item) => (
              item: item,
              km: distance.as(LengthUnit.Kilometer, center, LatLng(item.latitude, item.longitude)),
            ))
        .toList()
      ..sort((a, b) => a.km.compareTo(b.km));
    return sorted.take(30).map((entry) => entry.item).toList(growable: false);
  }

  void _selectLocation(MapLocationModel location) {
    setState(() {
      _selected = location;
      _nearbyPois = const [];
      _nearbyProperties = _findNearbyProperties(location);
    });
    _loadNearbyPois(location);
    _mapController.move(
      LatLng(location.latitude, location.longitude),
      14,
    );
  }


  List<MapLocationModel> _findNearbyProperties(MapLocationModel selected) {
    final distance = Distance();
    final nearby = controller.locations
        .where((item) => item.id != selected.id && item.latitude != 0 && item.longitude != 0)
        .map((item) => (
              item: item,
              km: distance.as(
                LengthUnit.Kilometer,
                LatLng(selected.latitude, selected.longitude),
                LatLng(item.latitude, item.longitude),
              ),
            ))
        .where((entry) => entry.km <= 3)
        .toList()
      ..sort((a, b) => a.km.compareTo(b.km));
    return nearby.take(5).map((entry) => entry.item).toList(growable: false);
  }

  Future<void> _loadNearbyPoisAt(
    double latitude,
    double longitude,
  ) async {
    final pois = await NearbyPoiService.instance.nearby(
      latitude,
      longitude,
    );
    if (!mounted) return;
    setState(() => _nearbyPois = pois);
  }

  Future<void> _loadNearbyPois(MapLocationModel property) async {
    // POIs are loaded independently from the property API, so they never
    // block the map or property cards from appearing.
    final pois = await NearbyPoiService.instance.nearby(
      property.latitude,
      property.longitude,
    );
    if (!mounted || _selected?.id != property.id) return;
    setState(() => _nearbyPois = pois);
  }

  Future<void> _goToCurrentLocation() async {
    final localization = AppLocalization.of(context);
    final manager = LocationManager.instance;

    final success = await manager.updateCurrentLocation();
    if (!mounted) return;

    // A GPS refresh can legitimately time out while the map already has a
    // valid cached/current coordinate. In that case, focus the map on the
    // coordinate we have instead of showing a misleading unavailable snack.
    final latitude = manager.latitude;
    final longitude = manager.longitude;
    final usableCoordinates = latitude != null &&
        longitude != null &&
        latitude >= -90 && latitude <= 90 &&
        longitude >= -180 && longitude <= 180;

    if (!usableCoordinates) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localization.translate('location_unavailable'),
          ),
        ),
      );
      return;
    }

    _mapController.move(
      LatLng(latitude, longitude),
      14.5,
    );
    await _loadNearbyPoisAt(latitude, longitude);

    if (!success && mounted) {
      // No error toast: the requested focus operation succeeded using the
      // cached coordinate, which is exactly what the user asked for.
    }
  }

  void _focusProperties() {
    final locations = controller.locations;
    if (locations.isEmpty) return;
    final valid = locations.where((item) => item.latitude != 0 && item.longitude != 0).toList(growable: false);
    if (valid.isEmpty) return;
    final lat = valid.map((e) => e.latitude).reduce((a, b) => a + b) / valid.length;
    final lng = valid.map((e) => e.longitude).reduce((a, b) => a + b) / valid.length;
    _mapController.move(LatLng(lat, lng), 10.8);
    if (mounted) setState(() => _selected = null);
  }

  void _openProperty(MapLocationModel location) {
    final id = location.propertyId;
    if (id == null) return;
    final details = Get.isRegistered<PropertyDetailsController>()
        ? Get.find<PropertyDetailsController>()
        : Get.put(PropertyDetailsController(), permanent: true);
    details.seedFromMap(location);
    Navigator.pushNamed(context, AppRouter.propertyDetails, arguments: id);
  }

  double _navigationOverlayInset(BuildContext context) {
    final width = Responsive.width(context);
    final navigationHeight = width < 370 ? 96.0 : 104.0;
    return MediaQuery.paddingOf(context).bottom + navigationHeight;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    return Obx(() {
      final locations = _filteredLocations;
      final loading = controller.isLoading.value;
      final error = controller.error.value;

      return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('map_title')),
        actions: [
          IconButton(
            tooltip: localization.translate('map_refresh'),
            onPressed: loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: LocationManager.instance,
            builder: (context, _) {
              final manager = LocationManager.instance;
              final currentLatitude = manager.hasCurrentLocation
                  ? manager.latitude
                  : null;
              final currentLongitude = manager.hasCurrentLocation
                  ? manager.longitude
                  : null;

              final markers = <Marker>[];

              final visibleLocations = _visiblePropertyLocations(locations);
              markers.addAll(
                visibleLocations.map((location) {
                  final selected = _selected?.id == location.id;

                  return Marker(
                    point: LatLng(
                      location.latitude,
                      location.longitude,
                    ),
                    width: selected ? 58 : 42,
                    height: selected ? 58 : 42,
                    child: GestureDetector(
                      onTap: () => _selectLocation(location),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: selected
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.20),
                              blurRadius: 9,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: theme.colorScheme.onPrimary,
                          size: selected ? 28 : 21,
                        ),
                      ),
                    ),
                  );
                }),
              );

              if (_selected != null && _nearbyProperties.isNotEmpty) {
                markers.addAll(
                  _nearbyProperties.map(
                    (location) => Marker(
                      point: LatLng(location.latitude, location.longitude),
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onTap: () => _selectLocation(location),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.colorScheme.primary, width: 2),
                            boxShadow: const [BoxShadow(blurRadius: 7, offset: Offset(0, 3), color: Colors.black26)],
                          ),
                          child: Icon(Icons.home_work_rounded, color: theme.colorScheme.primary, size: 20),
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (_selected != null && _nearbyPois.isNotEmpty) {
                markers.addAll(
                  _nearbyPois.map(
                    (poi) => Marker(
                      point: LatLng(poi.latitude, poi.longitude),
                      width: 40,
                      height: 40,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.secondary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .16),
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          poi.icon,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (currentLatitude != null && currentLongitude != null) {
                markers.add(
                  Marker(
                    point: LatLng(currentLatitude, currentLongitude),
                    width: 42,
                    height: 42,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.my_location_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                );
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 11,
                  minZoom: 3,
                  maxZoom: 19,
                  onTap: (_, _) {
                    if (mounted) setState(() { _selected = null; _nearbyProperties = const []; _nearbyPois = const []; });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.vibelocate.ai',
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            },
          ),

          PositionedDirectional(
            start: 0,
            end: 0,
            top: 8,
            child: PropertyCategories(
              onCategorySelected: (typeId) {
                controller.setTypeId(typeId);
                final next = _filters.copyWith(clearCategoryId: true);
                if (next != _filters) {
                  setState(() => _filters = next);
                  controller.setFilters(next);
                }
              },
              onMoreFilters: _showFilters,
            ),
          ),

          if (loading && locations.isEmpty)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          if (!loading &&
              error == null &&
              locations.isEmpty)
            PositionedDirectional(
              start: 24,
              end: 24,
              top: 92,
              child: _MapMessageCard(
                icon: Icons.location_off_rounded,
                message: localization.translate('map_empty'),
                action: IconButton(
                  onPressed: _load,
                  tooltip: localization.translate('map_refresh'),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
            ),

          if (error != null)
            PositionedDirectional(
              start: 16,
              end: 16,
              bottom: _navigationOverlayInset(context),
              child: _MapMessageCard(
                icon: Icons.error_outline_rounded,
                message: error,
                action: TextButton(
                  onPressed: _load,
                  child: Text(localization.translate('map_retry')),
                ),
              ),
            ),

          if (_selected != null && error == null)
            PositionedDirectional(
              start: 16,
              end: 16,
              bottom: _navigationOverlayInset(context),
              child: AnimatedBuilder(
                animation: LocationManager.instance,
                builder: (context, _) {
                  final manager = LocationManager.instance;
                  return _SelectedPropertyCard(
                    location: _selected!,
                    userLatitude: manager.hasCurrentLocation
                        ? manager.latitude
                        : null,
                    userLongitude: manager.hasCurrentLocation
                        ? manager.longitude
                        : null,
                    nearbyPois: _nearbyPois,
                    nearbyProperties: _nearbyProperties,
                    onPropertyTap: _openProperty,
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: _navigationOverlayInset(context) + 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: 'focus-properties',
              tooltip: localization.translate('map_focus_properties'),
              onPressed: _focusProperties,
              child: const Icon(Icons.home_work_rounded),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'focus-user',
              tooltip: localization.translate('map_current_location'),
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location_rounded),
            ),
          ],
        ),
      ),
      );
    });
  }
}

class _MapMessageCard extends StatelessWidget {
  const _MapMessageCard({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}

class _SelectedPropertyCard extends StatelessWidget {
  const _SelectedPropertyCard({
    required this.location,
    this.userLatitude,
    this.userLongitude,
    this.nearbyPois = const [],
    this.nearbyProperties = const [],
    required this.onPropertyTap,
  });

  final MapLocationModel location;
  final double? userLatitude;
  final double? userLongitude;
  final List<NearbyPoiModel> nearbyPois;
  final List<MapLocationModel> nearbyProperties;
  final ValueChanged<MapLocationModel> onPropertyTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    final width = Responsive.width(context);
    final imageSize = width < 370 ? 64.0 : 76.0;

    return Card(
      elevation: 10,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: location.propertyId == null ? null : () => onPropertyTap(location),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: location.imageUrl.isNotEmpty
                    ? Image.network(
                        location.imageUrl,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _fallback(theme, imageSize),
                      )
                    : _fallback(theme, imageSize),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.title.isEmpty
                          ? localization.translate('map_property')
                          : location.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (location.address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              location.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        if (location.price.isNotEmpty)
                          _basicChip(
                            context,
                            location.priceAmount != null
                                ? CurrencyPrice(
                                    amount: location.priceAmount!,
                                    sourceCurrency: location.currency,
                                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900),
                                  )
                                : Text(
                                    location.price,
                                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                          ),
                        if (location.bedrooms > 0)
                          _basicChipText(context, '${location.bedrooms} ${localization.translate('bedrooms')}'),
                        if (location.bathrooms > 0)
                          _basicChipText(context, '${location.bathrooms} ${localization.translate('bathrooms')}'),
                        if (location.areaSqft > 0)
                          _basicChipText(context, '${location.areaSqft.round()} ${localization.translate('area_unit')}'),
                      ],
                    ),
                  ],
                ),
              ),
              if (location.propertyId != null)
                Icon(Icons.arrow_forward_ios_rounded, size: 15, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _basicChip(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  Widget _basicChipText(BuildContext context, String text) => _basicChip(
        context,
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      );

  Widget _fallback(ThemeData theme, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.home_work_outlined,
        color: theme.colorScheme.onSurfaceVariant,
        size: 30,
      ),
    );
  }
}
