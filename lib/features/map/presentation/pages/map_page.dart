import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/map_location_model.dart';
import '../../map_dependencies.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  List<MapLocationModel> _locations = const [];
  MapLocationModel? _selected;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final locations = await MapDependencies.getLocations();
      if (!mounted) return;
      setState(() {
        _locations = locations;
        _error = null;
      });

      if (locations.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _mapController.move(
            LatLng(
              locations.first.latitude,
              locations.first.longitude,
            ),
            11,
          );
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  LatLng get _center {
    if (_locations.isNotEmpty) {
      final location = _locations.first;
      return LatLng(location.latitude, location.longitude);
    }

    return const LatLng(25.2048, 55.2708);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 11,
              minZoom: 3,
              maxZoom: 19,
              onTap: (_, _) {
                setState(() {
                  _selected = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.vibelocate.ai',
              ),
              MarkerLayer(
                markers: _locations.map((location) {
                  final selected = _selected?.id == location.id;
                  return Marker(
                    point: LatLng(
                      location.latitude,
                      location.longitude,
                    ),
                    width: selected ? 56 : 48,
                    height: selected ? 56 : 48,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selected = location;
                        });
                        _mapController.move(
                          LatLng(
                            location.latitude,
                            location.longitude,
                          ),
                          14,
                        );
                      },
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: selected
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.home_rounded,
                          color: theme.colorScheme.onPrimary,
                          size: selected ? 25 : 22,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          if (_loading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.12),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          if (_error != null)
            PositionedDirectional(
              start: 16,
              end: 16,
              bottom: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_error!)),
                      TextButton(
                        onPressed: _load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_selected != null)
            PositionedDirectional(
              start: 16,
              end: 16,
              bottom: 16,
              child: _SelectedPropertyCard(
                location: _selected!,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          _mapController.move(_center, 11);
        },
        child: const Icon(Icons.my_location_rounded),
      ),
    );
  }
}

class _SelectedPropertyCard extends StatelessWidget {
  const _SelectedPropertyCard({required this.location});

  final MapLocationModel location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            if (location.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  location.imageUrl,
                  width: 76,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return _fallback(theme);
                  },
                ),
              )
            else
              _fallback(theme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.title.isEmpty
                        ? 'Property'
                        : location.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (location.address.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      location.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (location.price.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      location.price,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (location.propertyId != null)
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/property-details',
                    arguments: location.propertyId,
                  );
                },
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(ThemeData theme) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.home_work_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
