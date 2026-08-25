class RegisterRequestModel {
  const RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.country,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    this.roleSlug = 'tenant',
  });

  final String firstName;
  final String lastName;
  final String city;
  final String country;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;
  final String roleSlug;

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'city': city,
      'country': country,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role_slug': roleSlug,
    };
  }
}