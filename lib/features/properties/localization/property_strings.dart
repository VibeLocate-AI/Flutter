import '../../../core/localization/localization.dart';

abstract final class PropertyStrings {
  static String get tryAgain => AppLocalization.t('property_try_again');
  static String get propertyNotFound => AppLocalization.t('property_not_found');
  static String get action => AppLocalization.t('property_action_label');
  static String get condition => AppLocalization.t('property_condition');
  static String get virtualTour => AppLocalization.t('virtual_tour');
  static String get description => AppLocalization.t('description');
  static String get noDescription => AppLocalization.t('no_description');
  static String get features => AppLocalization.t('features');
  static String get reviews => AppLocalization.t('reviews');
  static String get noReviews => AppLocalization.t('no_reviews');
  static String get rateProperty => AppLocalization.t('rate_property');
  static String get writeReview => AppLocalization.t('write_review');
  static String get submitReview => AppLocalization.t('submit_review');
  static String get furnished => AppLocalization.t('furnished');
  static String get unfurnished => AppLocalization.t('unfurnished');
  static String beds(int value) => AppLocalization.t('beds').replaceFirst('{count}', value.toString());
  static String baths(int value) => AppLocalization.t('baths').replaceFirst('{count}', value.toString());
  static String area(int value) => AppLocalization.t('area_sqft').replaceFirst('{count}', value.toString());
}
