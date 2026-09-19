import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<LocationPickerPage> createState() =>
      _LocationPickerPageState();
}

class _LocationPickerPageState
    extends State<LocationPickerPage> {
  static const double _defaultLatitude =
  25.2048;

  static const double _defaultLongitude =
  55.2708;

  final MapController _mapController =
  MapController();

  LatLng? _selectedLocation;

  bool get _isArabic =>
      Localizations.localeOf(
        context,
      ).languageCode ==
          'ar';

  LatLng get _initialCenter {
    final latitude =
        widget.initialLatitude;

    final longitude =
        widget.initialLongitude;

    if (latitude != null &&
        longitude != null &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180) {
      return LatLng(
        latitude,
        longitude,
      );
    }

    return const LatLng(
      _defaultLatitude,
      _defaultLongitude,
    );
  }

  @override
  void initState() {
    super.initState();

    final latitude =
        widget.initialLatitude;

    final longitude =
        widget.initialLongitude;

    if (latitude != null &&
        longitude != null &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180) {
      _selectedLocation =
          LatLng(
            latitude,
            longitude,
          );
    }
  }

  void _selectLocation(
      LatLng location,
      ) {
    setState(() {
      _selectedLocation =
          location;
    });
  }

  void _confirmLocation() {
    final location =
        _selectedLocation;

    if (location == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            _isArabic
                ? 'اضغطي على الخريطة لتحديد موقع العقار أولًا.'
                : 'Tap on the map to select the property location first.',
          ),
        ),
      );

      return;
    }

    Navigator.pop(
      context,
      location,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final center =
        _initialCenter;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isArabic
              ? 'تحديد موقع العقار'
              : 'Select Property Location',
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController:
            _mapController,
            options: MapOptions(
              initialCenter:
              center,
              initialZoom: 12,
              minZoom: 4,
              maxZoom: 19,
              onTap: (
                  _,
                  latLng,
                  ) {
                _selectLocation(
                  latLng,
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                'com.example.vibe_locate_ai',
              ),
              if (_selectedLocation !=
                  null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point:
                      _selectedLocation!,
                      width: 56,
                      height: 64,
                      child:
                      Column(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration:
                            BoxDecoration(
                              color: theme
                                  .colorScheme
                                  .primary,
                              shape:
                              BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors
                                      .black
                                      .withValues(
                                    alpha:
                                    0.22,
                                  ),
                                  blurRadius:
                                  10,
                                  offset:
                                  const Offset(
                                    0,
                                    4,
                                  ),
                                ),
                              ],
                            ),
                            child:
                            Icon(
                              Icons
                                  .location_on_rounded,
                              color: theme
                                  .colorScheme
                                  .onPrimary,
                              size: 25,
                            ),
                          ),
                          Icon(
                            Icons
                                .arrow_drop_down_rounded,
                            color: theme
                                .colorScheme
                                .primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration:
              BoxDecoration(
                color: theme
                    .colorScheme
                    .surface
                    .withValues(
                  alpha: 0.96,
                ),
                borderRadius:
                BorderRadius.circular(
                  16,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    Colors.black.withValues(
                      alpha: 0.10,
                    ),
                    blurRadius: 14,
                    offset:
                    const Offset(
                      0,
                      4,
                    ),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons
                        .touch_app_rounded,
                    color: theme
                        .colorScheme
                        .primary,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      _isArabic
                          ? 'اضغطي على المكان الذي تريدين وضع العقار فيه'
                          : 'Tap anywhere on the map to place your property',
                      style: theme
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_selectedLocation !=
              null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: SafeArea(
                child:
                Container(
                  padding:
                  const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                  BoxDecoration(
                    color: theme
                        .colorScheme
                        .surface,
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .black
                            .withValues(
                          alpha: 0.16,
                        ),
                        blurRadius:
                        20,
                        offset:
                        const Offset(
                          0,
                          6,
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration:
                            BoxDecoration(
                              color: theme
                                  .colorScheme
                                  .primary
                                  .withValues(
                                alpha:
                                0.10,
                              ),
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),
                            child:
                            Icon(
                              Icons
                                  .location_on_rounded,
                              color: theme
                                  .colorScheme
                                  .primary,
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child:
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  _isArabic
                                      ? 'الموقع المحدد'
                                      : 'Selected location',
                                  style: theme
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                    fontWeight:
                                    FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                  style: theme
                                      .textTheme
                                      .bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      SizedBox(
                        width:
                        double.infinity,
                        child:
                        FilledButton.icon(
                          onPressed:
                          _confirmLocation,
                          icon:
                          const Icon(
                            Icons
                                .check_rounded,
                          ),
                          label:
                          Text(
                            _isArabic
                                ? 'استخدام هذا الموقع'
                                : 'Use this location',
                          ),
                          style:
                          FilledButton
                              .styleFrom(
                            minimumSize:
                            const Size
                                .fromHeight(
                              52,
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}