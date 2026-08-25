class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl =
      'https://vibelocate-laravel.onrender.com';

  // Authentication
  static const String register = '/api/register';
  static const String verifyOtp = '/api/verify-otp';
  static const String resendOtp = '/api/resend-otp';
  static const String login = '/api/login';

  // Tokens & Session
  static const String refreshToken = '/api/refresh-token';
  static const String rememberMe = '/api/remember-me';
  static const String logout = '/api/logout';

  // Password Management
  static const String forgotPassword =
      '/api/forgot-password';
  static const String verifyResetOtp =
      '/api/verify-reset-otp';
  static const String resetPassword =
      '/api/reset-password';

  // Profile
  static const String profile = '/api/profile';
  static const String completeProfile =
      '/api/complete-profile';

  // Sessions
  static const String sessions = '/api/sessions';

  // Two Factor Authentication
  static const String twoFactor = '/api/two-factor';
}