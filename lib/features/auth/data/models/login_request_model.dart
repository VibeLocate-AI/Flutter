class LoginRequestModel {
  const LoginRequestModel({
    required this.email,
    required this.password,
    required this.deviceUuid,
    required this.deviceType,
    this.rememberMe = false,
  });

  final String email;
  final String password;
  final String deviceUuid;
  final String deviceType;
  final bool rememberMe;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'remember_me': rememberMe,
      'device_uuid': deviceUuid,
      'device_type': deviceType,
    };
  }
}