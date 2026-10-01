import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/map_controller_x.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/state/location_manager.dart';
import '../../../../core/widgets/currency_price.dart';
import '../../data/models/map_location_model.dart';

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
  final TextEditingController _searchController = TextEditingController();
  MapLocationModel? _selected;

  MapControllerX get controller => Get.find<MapControllerX>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    controller.initialize().then((_) {
      if (!mounted) return;
      final locations = controller.locations.toList(growable: false);
      MapLocationModel? initial;
      for (final location in locations) {
        if (location.propertyId == widget.initialPropertyId) {
          initial = location;
          break;
        }
      }
      setState(() => _selected = initial);
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

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    controller.setQuery(_searchController.text);
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
    return const LatLng(25.2048, 55.2708);
  }

  void _selectLocation(MapLocationModel location) {
    setState(() => _selected = location);
    _mapController.move(
      LatLng(location.latitude, location.longitude),
      14,
    );
  }

  Future<void> _goToCurrentLocation() async {
    final localization = AppLocalization.of(context);
    final manager = LocationManager.instance;

    final success = await manager.updateCurrentLocation();
    if (!mounted) return;

    final latitude = manager.latitude;
    final longitude = manager.longitude;

    if (!success || latitude == null || longitude == null) {
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

              markers.addAll(
                locations.map((location) {
                  final selected = _selected?.id == location.id;

                  return Marker(
                    point: LatLng(
                      location.latitude,
                      location.longitude,
                    ),
                    width: selected ? 58 : 48,
                    height: selected ? 58 : 48,
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
                          size: selected ? 28 : 24,
                        ),
                      ),
                    ),
                  );
                }),
              );

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
                    if (mounted) setState(() => _selected = null);
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
            start: 16,
            end: 16,
            top: 14,
            child: _MapSearchBar(
              controller: _searchController,
              hintText: localization.translate('map_search_hint'),
            ),
          ),

          if (loading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.12),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          if (!loading &&
              _searchController.text.trim().isNotEmpty &&
              locations.isEmpty)
            PositionedDirectional(
              start: 24,
              end: 24,
              top: 88,
              child: _MapMessageCard(
                icon: Icons.search_off_rounded,
                message: localization.translate('map_no_results'),
              ),
            ),

          if (!loading &&
              error == null &&
              _searchController.text.trim().isEmpty &&
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
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: _navigationOverlayInset(context) + 4,
        ),
        child: FloatingActionButton.small(
          tooltip: localization.translate('map_current_location'),
          onPressed: _goToCurrentLocation,
          child: const Icon(Icons.my_location_rounded),
        ),
      ),
      );
    });
  }
}

class _MapSearchBar extends StatelessWidget {
  const _MapSearchBar({
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      color: theme.colorScheme.surface,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: AppLocalization.of(context).translate('clear'),
                  onPressed: controller.clear,
                  icon: const Icon(Icons.close_rounded),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
        ),
      ),
    );
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
            const SizedBox(width: 12),
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
  });

  final MapLocationModel location;
  final double? userLatitude;
  final double? userLongitude;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    final width = Responsive.width(context);
    final imageSize = width < 370 ? 76.0 : 88.0;

    return Card(
      elevation: 10,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: InkWell(
        onTap: location.propertyId == null
            ? null
            : () {
                Navigator.pushNamed(
                  context,
                  AppRouter.propertyDetails,
                  arguments: location.propertyId,
                );
              },
        child: Padding(
          padding: EdgeInsets.all(width < 370 ? 10 : 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: location.imageUrl.isNotEmpty
                    ? Image.network(
                        location.imageUrl,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (_, _, _) => _fallback(
                          theme,
                          imageSize,
                        ),
                      )
                    : _fallback(theme, imageSize),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            location.title.isEmpty
                                ? localization.translate('map_property')
                                : location.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (location.propertyId != null)
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                    if (location.address.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (location.price.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      location.priceAmount != null
                          ? CurrencyPrice(
                              amount: location.priceAmount!,
                              sourceCurrency: location.currency,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : Text(
                              location.price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ],
                    if (userLatitude != null &&
                        userLongitude != null &&
                        location.latitude != 0 &&
                        location.longitude != 0) ...[
                      const SizedBox(height: 7),
                      _TravelInfo(
                        distanceKm: _distanceKm(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _distanceKm() {
    final distance = Distance();
    return distance.as(
      LengthUnit.Kilometer,
      LatLng(userLatitude!, userLongitude!),
      LatLng(location.latitude, location.longitude),
    );
  }

  Widget _fallback(ThemeData theme, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.home_work_outlined,
        color: theme.colorScheme.onSurfaceVariant,
        size: 30,
      ),
    );
  }
}

class _TravelInfo extends StatelessWidget {
  const _TravelInfo({required this.distanceKm});

  final double distanceKm;

  String _minutes(double km, double speedKmh) {
    final minutes = (km / speedKmh * 60).round().clamp(1, 999);
    return minutes.toString();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final theme = Theme.of(context);
    final distance = distanceKm < 1
        ? '${(distanceKm * 1000).round()} m'
        : '${distanceKm.toStringAsFixed(1)} km';

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _TravelChip(
          icon: Icons.straighten_rounded,
          text: '${localization.translate('approximate')} ${localization.translate('distance_away').replaceFirst('{distance}', distance)}',
          theme: theme,
        ),
        _TravelChip(
          icon: Icons.directions_walk_rounded,
          text:
              '${localization.translate('walking')} ${_minutes(distanceKm, 4.8)} ${localization.translate('minutes')}',
          theme: theme,
        ),
        _TravelChip(
          icon: Icons.directions_car_rounded,
          text:
              '${localization.translate('driving')} ${_minutes(distanceKm, 32)} ${localization.translate('minutes')}',
          theme: theme,
        ),
      ],
    );
  }
}

class _TravelChip extends StatelessWidget {
  const _TravelChip({
    required this.icon,
    required this.text,
    required this.theme,
  });

  final IconData icon;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
