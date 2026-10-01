import '../../../core/localization/localization.dart';

abstract final class SecurityStrings {
  static String get changePassword => AppLocalization.t('security_change_password');
  static String get currentPassword => AppLocalization.t('security_current_password');
  static String get newPassword => AppLocalization.t('security_new_password');
  static String get confirmPassword => AppLocalization.t('security_confirm_password');
  static String get sendCode => AppLocalization.t('security_send_code');
  static String get emailCode => AppLocalization.t('security_email_code');
  static String get confirmChange => AppLocalization.t('security_confirm_change');
  static String get completeFields => AppLocalization.t('security_complete_fields');
  static String get passwordsMismatch => AppLocalization.t('security_passwords_mismatch');
  static String get codeSent => AppLocalization.t('security_code_sent');
  static String get passwordChanged => AppLocalization.t('security_password_changed');
  static String get enterCode => AppLocalization.t('security_enter_code');
  static String get sessions => AppLocalization.t('security_sessions');
  static String get noSessions => AppLocalization.t('security_no_sessions');
  static String get terminate => AppLocalization.t('security_terminate');
  static String get activeTokens => AppLocalization.t('security_active_tokens');
  static String get retry => AppLocalization.t('security_retry');
  static String get twoFactor => AppLocalization.t('security_two_factor');
  static String get authenticator => AppLocalization.t('security_authenticator');
  static String get enabled => AppLocalization.t('security_enabled');
  static String get notEnabled => AppLocalization.t('security_not_enabled');
  static String get setup => AppLocalization.t('security_setup');
  static String get scanQr => AppLocalization.t('security_scan_qr');
  static String get cannotScan => AppLocalization.t('security_cannot_scan');
  static String get manualSecret => AppLocalization.t('security_manual_secret');
  static String get code6 => AppLocalization.t('security_code6');
  static String get verifyEnable => AppLocalization.t('security_verify_enable');
  static String get setupStarted => AppLocalization.t('security_setup_started');
  static String get enabledMessage => AppLocalization.t('security_enabled_message');
  static String get disabledMessage => AppLocalization.t('security_disabled_message');
  static String get protectAccount => AppLocalization.t('security_protect_account');
  static String get copied => AppLocalization.t('security_copied');
}
