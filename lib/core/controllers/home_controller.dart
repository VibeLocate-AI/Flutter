import 'package:get/get.dart';
import '../../features/home/data/models/ai_search_response_model.dart';
import '../../features/home/data/models/home_model.dart';
import '../../features/home/data/models/property_model.dart';
import '../../features/home/home_dependencies.dart';
import '../../features/properties/properties_dependencies.dart';
import '../errors/exceptions.dart';
import '../storage/token_storage.dart';

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

  Future<void> initialize({int? highlightPropertyId}) async {
    if (_initialized && highlightPropertyId == null) return;
    await load(force: !_initialized, highlightPropertyId: highlightPropertyId);
  }

  Future<void> load({bool force = false, int? highlightPropertyId}) {
    if (_loadingFuture != null && !force) return _loadingFuture!;
    if (_initialized && !force && highlightPropertyId == null) return Future.value();

    final future = _loadInternal(highlightPropertyId);
    _loadingFuture = future;
    return future.whenComplete(() => _loadingFuture = null);
  }

  Future<void> _loadInternal(int? highlightPropertyId) async {
    isLoading = home == null;
    errorMessage = null;

    try {
      final result = await HomeDependencies.getHome();
      PropertyModel? highlighted;
      if (highlightPropertyId != null) {
        try {
          highlighted =
              await PropertiesDependencies.getPropertyDetails(highlightPropertyId);
        } catch (_) {}
      }
      home = result;
      highlightedProperty = highlighted;
      _initialized = true;
      } on UnauthorizedException {
      await TokenStorage.clearTokens();
      errorMessage = 'unauthorized';
      rethrow;
    } catch (e) {
      if (home == null) errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      }
  }

  Future<void> searchAi(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      aiSearchResponse = null;
      aiSearchError = null;
      isAiSearching = false;
  
      return;
    }

    isAiSearching = true;
    aiSearchError = null;

    try {
      aiSearchResponse = await HomeDependencies.aiContextualSearch(q);
    } catch (e) {
      aiSearchResponse = _localFallback(q);
      aiSearchError = null;
    } finally {
      isAiSearching = false;
      }
  }

  void clearSearch() {
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
    ];
    final seen = <int>{};
    final tokens = query.toLowerCase().split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty).toList();
    final matches = <AiSearchPropertyModel>[];

    for (final p in source) {
      if (!seen.add(p.id)) continue;
      final haystack = [
        p.displayTitle, p.displayDescription, p.title, p.description, p.slug,
        p.location?.addressLine1 ?? '', p.location?.neighborhoodName ?? '',
        p.location?.neighborhoodEn ?? '', p.location?.neighborhoodAr ?? '',
      ].join(' ').toLowerCase();
      final matched = tokens.where(haystack.contains).toList();
      if (matched.isEmpty) continue;
      final score = ((matched.length / tokens.length) * 100).round().clamp(1, 100);
      matches.add(AiSearchPropertyModel(
        property: p,
        matchScore: score,
        matched: matched,
        missing: const [],
        isExactMatch: matched.length == tokens.length,
      ));
    }
    matches.sort((a,b) => b.matchScore.compareTo(a.matchScore));
    return AiSearchResponseModel(
      success: true, query: query, searchMode: 'local_fallback',
      understood: const AiSearchUnderstandingModel(),
      exactMatches: matches.where((e) => e.isExactMatch).length,
      totalResults: matches.length, properties: matches,
    );
  }
}
