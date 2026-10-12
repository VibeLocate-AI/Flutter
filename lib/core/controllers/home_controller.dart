import 'package:get/get.dart';
import '../../features/home/data/models/ai_search_response_model.dart';
import '../../features/home/data/models/home_model.dart';
import '../../features/home/data/models/property_model.dart';
import '../../features/home/home_dependencies.dart';
import '../../features/properties/properties_dependencies.dart';
import '../errors/exceptions.dart';
import 'property_details_controller.dart';

class HomeController extends GetxController {
  HomeModel? home;
  PropertyModel? highlightedProperty;
  AiSearchResponseModel? aiSearchResponse;
  String? errorMessage;
  String? aiSearchError;
  bool isLoading = false;
  bool isAiSearching = false;
  int? selectedTypeId;

  bool _initialized = false;
  Future<void>? _loadingFuture;
  int _searchGeneration = 0;
  List<PropertyModel>? _allPropertiesForSearch;
  Future<List<PropertyModel>>? _allPropertiesFuture;

  /// Restores the last normalized Home payload without waiting for the network.
  /// The UI calls this before the refresh request so cached cards are visible
  /// immediately after app start.
  Future<void> restoreCached() async {
    if (home != null) return;
    try {
      final cached = await HomeDependencies.getCachedHome();
      if (cached != null) {
        home = cached;
        errorMessage = null;
        isLoading = false;
        _seedPropertyDetailsCache(home);
      }
    } catch (_) {
      // Corrupt/old cache must never block a fresh network request.
    }
  }

  Future<void> initialize({int? highlightPropertyId}) async {
    if (_initialized && highlightPropertyId == null) return;
    await load(
      force: !_initialized,
      highlightPropertyId: highlightPropertyId,
    );
  }

  Future<void> load({
    bool force = false,
    int? highlightPropertyId,
  }) {
    if (_loadingFuture != null && !force) {
      return _loadingFuture!;
    }

    if (_initialized && !force && highlightPropertyId == null) {
      return Future.value();
    }

    final future = _loadInternal(highlightPropertyId);
    _loadingFuture = future;
    return future.whenComplete(() => _loadingFuture = null);
  }

  Future<void> _loadInternal(int? highlightPropertyId) async {
    errorMessage = null;

    // Cache-first: the previous successful Home payload is rendered before
    // waiting for the network. This also means a slow/failing API cannot turn
    // an already usable Home screen into an error screen.
    if (home == null) {
      try {
        home = await HomeDependencies.getCachedHome();
      } catch (_) {}
    }

    isLoading = home == null;

    try {
      final result = await HomeDependencies.getHome();

      // Never replace useful cached data with an empty response. This protects
      // the UI from a temporary Laravel/Render response with no payload.
      if (_hasUsefulData(result) || home == null) {
        home = result;
      }

      PropertyModel? highlighted;
      if (highlightPropertyId != null) {
        try {
          highlighted = await PropertiesDependencies.getPropertyDetails(
            highlightPropertyId,
          );
        } catch (_) {}
      }
      if (highlighted != null) {
        highlightedProperty = highlighted;
      }

      _seedPropertyDetailsCache(home);
      _initialized = true;
      errorMessage = null;
    } on UnauthorizedException {
      // A real authenticated request can still fail after the startup refresh.
      // Keep cached Home visible instead of replacing it with a login/error
      // screen. ApiClient handles its own single refresh attempt.
      if (home != null) {
        errorMessage = null;
        _seedPropertyDetailsCache(home);
      } else {
        errorMessage = 'unauthorized';
      }
      if (home == null) rethrow;
    } catch (e) {
      // If cache exists, silently keep it and refresh again later. Do not show
      // "Unable to load home data" over valid cached content.
      if (home != null) {
        errorMessage = null;
        _seedPropertyDetailsCache(home);
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      isLoading = false;
    }
  }

  bool _hasUsefulData(HomeModel model) {
    return model.properties.isNotEmpty ||
        model.featuredProperties.isNotEmpty ||
        model.recommendedProperties.isNotEmpty ||
        model.popularAreas.isNotEmpty ||
        model.topAgents.isNotEmpty;
  }

  void _seedPropertyDetailsCache(HomeModel? value) {
    if (value == null) return;

    final detailsController = Get.isRegistered<PropertyDetailsController>()
        ? Get.find<PropertyDetailsController>()
        : Get.put(PropertyDetailsController(), permanent: true);

    final properties = <PropertyModel>[
      ...value.featuredProperties,
      ...value.recommendedProperties,
      ...value.properties,
    ];

    final seen = <int>{};
    for (final property in properties) {
      if (seen.add(property.id)) {
        detailsController.setProperty(property);
      }
    }

    if (highlightedProperty != null) {
      detailsController.setProperty(highlightedProperty!);
    }
  }

  Future<void> searchAi(String query) async {
    final generation = ++_searchGeneration;
    final q = query.trim();

    if (q.isEmpty) {
      if (generation != _searchGeneration) return;
      aiSearchResponse = null;
      aiSearchError = null;
      isAiSearching = false;
      return;
    }

    // Search the full properties collection, not only the handful of cards
    // rendered on Home. Cache the collection so subsequent searches are fast.
    isAiSearching = true;
    aiSearchError = null;
    aiSearchResponse = _localFallback(q);
    try {
      if (_allPropertiesForSearch == null) {
        _allPropertiesFuture ??= PropertiesDependencies.loadProperties();
        try {
          _allPropertiesForSearch = await _allPropertiesFuture!
              .timeout(const Duration(seconds: 18));
        } catch (_) {
          _allPropertiesFuture = null;
        }
      }
      aiSearchResponse = _localFallback(q);

      // AI is an optional refinement; local results remain usable if it fails.
      final response = await HomeDependencies.aiContextualSearch(q)
          .timeout(const Duration(seconds: 12));
      if (generation != _searchGeneration) return;

      // Keep semantic AI results, but never let an empty/partial AI payload
      // make a valid local search look broken. Merge unique local matches in
      // when the backend returns no properties.
      final local = _localFallback(q);
      if (response.properties.isEmpty && local.properties.isNotEmpty) {
        aiSearchResponse = local;
      } else if (response.properties.isNotEmpty && local.properties.isNotEmpty) {
        final seen = response.properties.map((item) => item.property.id).toSet();
        final merged = <AiSearchPropertyModel>[...response.properties];
        for (final item in local.properties) {
          if (seen.add(item.property.id)) merged.add(item);
        }
        aiSearchResponse = AiSearchResponseModel(
          success: response.success || merged.isNotEmpty,
          query: response.query.isEmpty ? q : response.query,
          searchMode: response.searchMode,
          understood: response.understood,
          exactMatches: response.exactMatches,
          totalResults: merged.length,
          properties: merged,
        );
      } else {
        aiSearchResponse = response;
      }
    } catch (_) {
      if (generation != _searchGeneration) return;
      aiSearchResponse = _localFallback(q);
      aiSearchError = null;
    } finally {
      if (generation == _searchGeneration) {
        isAiSearching = false;
      }
    }
  }

  List<String> _expandSearchTerms(String query) {
    const aliases = <String, List<String>>{
      'شقة': ['شقة', 'apartment', 'flat'],
      'شقق': ['شقق', 'apartment', 'apartments', 'flat'],
      'فيلا': ['فيلا', 'villa'],
      'فلل': ['فلل', 'villa', 'villas'],
      'بنتهاوس': ['بنتهاوس', 'penthouse'],
      'تاون هاوس': ['تاون هاوس', 'townhouse', 'town house'],
      'بيت': ['بيت', 'house', 'home'],
      'مكتب': ['مكتب', 'office'],
      'أرض': ['أرض', 'land', 'plot'],
      'مطعم': ['مطعم', 'restaurant'],
      'فندق': ['فندق', 'hotel'],
      'للبيع': ['للبيع', 'sale', 'for sale', 'buy'],
      'بيع': ['بيع', 'sale', 'for sale', 'buy'],
      'للايجار': ['للايجار', 'إيجار', 'rent', 'rental', 'for rent'],
      'للإيجار': ['للإيجار', 'إيجار', 'rent', 'rental', 'for rent'],
      'ايجار': ['ايجار', 'إيجار', 'rent', 'rental', 'for rent'],
    };
    const stopWords = <String>{
      'بدي', 'اريد', 'أريد', 'بدّي', 'في', 'من', 'الى', 'إلى',
      'the', 'a', 'an', 'i', 'want', 'with', 'in', 'for', 'to',
    };

    final raw = query
        .toLowerCase()
        .replaceAll(RegExp(r'[,،.!؟?]'), ' ')
        .split(RegExp(r'\s+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !stopWords.contains(e))
        .toList();

    final terms = <String>[];
    for (final token in raw) {
      final expanded = aliases[token];
      if (expanded != null) {
        terms.addAll(expanded);
      } else {
        terms.add(token);
      }
    }

    return terms.map((e) => e.toLowerCase()).toSet().toList(growable: false);
  }

  void clearSearch() {
    ++_searchGeneration;
    aiSearchResponse = null;
    aiSearchError = null;
    isAiSearching = false;
    selectedTypeId = null;
  }

  AiSearchResponseModel _localFallback(String query) {
    final source = <PropertyModel>[
      ...(home?.featuredProperties ?? const <PropertyModel>[]),
      ...(home?.recommendedProperties ?? const <PropertyModel>[]),
      ...(home?.properties ?? const <PropertyModel>[]),
      ...(_allPropertiesForSearch ?? const <PropertyModel>[]),
    ];

    final seen = <int>{};
    final tokens = _expandSearchTerms(query);
    if (tokens.isEmpty) {
      return AiSearchResponseModel(
        success: true,
        query: query,
        searchMode: 'local_fallback',
        understood: const AiSearchUnderstandingModel(),
        exactMatches: 0,
        totalResults: 0,
        properties: const [],
      );
    }
    final matches = <AiSearchPropertyModel>[];

    for (final property in source) {
      if (!seen.add(property.id)) continue;

      final haystack = [
        property.displayTitle,
        property.displayDescription,
        property.title,
        property.description,
        property.slug,
        property.location?.addressLine1 ?? '',
        property.location?.neighborhoodName ?? '',
        property.location?.neighborhoodEn ?? '',
        property.location?.neighborhoodAr ?? '',
        property.propertyCondition ?? '',
        property.listingType,
        property.actionType ?? '',
      ].join(' ').toLowerCase();

      final matched = tokens
          .where((term) => haystack.contains(term))
          .toSet()
          .toList();
      if (matched.isEmpty) continue;

      final score = ((matched.length / tokens.length) * 100)
          .round()
          .clamp(1, 100);

      matches.add(
        AiSearchPropertyModel(
          property: property,
          matchScore: score,
          matched: matched,
          missing: const [],
          isExactMatch: matched.length == tokens.length,
        ),
      );
    }

    matches.sort(
      (a, b) => b.matchScore.compareTo(a.matchScore),
    );

    return AiSearchResponseModel(
      success: true,
      query: query,
      searchMode: 'local_fallback',
      understood: const AiSearchUnderstandingModel(),
      exactMatches: matches.where((e) => e.isExactMatch).length,
      totalResults: matches.length,
      properties: matches,
    );
  }
}
