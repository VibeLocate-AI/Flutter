class User {
  const User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.roleSlug,
  });

  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? roleSlug;
}