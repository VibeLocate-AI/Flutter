import 'package:flutter/foundation.dart';
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl =
      'https://vibelocate-laravel.onrender.com';

  // Authentication
  static const String register = '/api/register';
  static const String verifyOtp = '/api/verify-otp';
  static const String verifyEmail = '/api/verify-email';
  static const String resendOtp = '/api/resend-otp';
  static const String resendVerification = '/api/resend-verification';
  static const String login = '/api/login';
  static const String googleLogin = '/api/auth/google';

  // Tokens & Session Auth
  static const String refreshToken = '/api/refresh-token';
  static const String rememberMe = '/api/remember-me';
  static const String logout = '/api/logout';

  // Password
  static const String forgotPassword = '/api/forgot-password';
  static const String verifyResetOtp = '/api/verify-reset-otp';
  static const String resetPassword = '/api/reset-password';
  static const String changePassword = '/api/change-password';

  // Profile
  static const String profile = '/api/profile';
  static const String completeProfile = '/api/complete-profile';
  static const String profileAvatar = '/api/profile/avatar';
  static const String profileLocation = '/api/profile/location';

  // Sessions
  static const String sessions = '/api/sessions';

  // Two Factor Authentication
  static const String twoFactor = '/api/two-factor';

  // Home
  static String home(String language) => '/api/home?lang=$language';

  static String homeFeaturedProperties(String language) =>
      '/api/home/$language/featured-properties';

  static String homeRecommendedProperties(String language) =>
      '/api/home/$language/recommended-properties';

  static String homePopularAreas(String language) =>
      '/api/home/$language/popular-areas';

  static String homeTopAgents(String language) =>
      '/api/home/$language/top-agents';

  // Properties
  static const String properties = '/api/properties';

  static String propertiesPage(int page) =>
      '/api/properties/$page';

  static String propertyDetails(int id) =>
      '/api/properties/$id';

  static const String myProperties = '/api/my-properties';

  static String myProperty(int id) =>
      '/api/my-properties/$id';

  static String nearbyProperties(int propertyId) =>
      '/api/properties/$propertyId/nearby';

  static String propertyReview(int propertyId) =>
      '/api/properties/$propertyId/review';

  // AI Contextual Search is served by the separate Python AI service.
  // Android emulators reach the host machine through 10.0.2.2.
  static const String aiContextualSearchLocal =
      'http://127.0.0.1:8000/api/ai/contextual-search';
  static const String aiContextualSearchAndroid =
      'http://10.0.2.2:8000/api/ai/contextual-search';

  static String get aiContextualSearch {
    if (kIsWeb) return aiContextualSearchLocal;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return aiContextualSearchAndroid;
    }
    return aiContextualSearchLocal;
  }

  // Map
  static const String map = '/api/map';

  // Favorites
  static const String favorites = '/api/favorites';

  static String favorite(int propertyId) =>
      '/api/favorites/$propertyId';

  // Notifications
  static const String notifications = '/api/notifications';
  static const String notificationsUnreadCount =
      '/api/notifications/unread-count';
  static const String notificationsReadAll =
      '/api/notifications/read-all';

  static String notificationRead(int id) =>
      '/api/notifications/$id/read';

  static String notificationDelete(int id) =>
      '/api/notifications/$id';
}
