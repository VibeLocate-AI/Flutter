import '../../../core/localization/localization.dart';

abstract final class FavoritesStrings {
  static String get title => AppLocalization.t('favorites_title');
  static String get searchHint => AppLocalization.t('favorites_search_hint');
  static String savedCount(int count) => AppLocalization.t('favorites_saved_count').replaceFirst('{count}', count.toString());
  static String resultsCount(int count) => AppLocalization.t('favorites_results_count').replaceFirst('{count}', count.toString());
  static String get clear => AppLocalization.t('favorites_clear');
  static String get retry => AppLocalization.t('favorites_retry');
  static String get remove => AppLocalization.t('favorites_remove');
  static String get removed => AppLocalization.t('favorites_removed');
  static String get noFavoritesTitle => AppLocalization.t('favorites_no_title');
  static String get noFavoritesBody => AppLocalization.t('favorites_no_body');
  static String get noResults => AppLocalization.t('favorites_no_results');
  static String get noResultsBody => AppLocalization.t('favorites_no_results_body');
  static String get clearSearch => AppLocalization.t('favorites_clear_search');
  static String get property => AppLocalization.t('property');
  static String get forRent => AppLocalization.t('for_rent');
  static String get forSale => AppLocalization.t('for_sale');
  static String get buy => AppLocalization.t('for_sale');
}
