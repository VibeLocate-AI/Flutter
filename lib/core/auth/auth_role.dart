class AuthRole {
  AuthRole._();

  static bool isAgent(String? role) {
    final normalized = normalize(role);
    return const {
      'agent',
      'broker',
      'real_estate_agent',
      'real-estate-agent',
      'realestate_agent',
      'property_agent',
      'property-agent',
    }.contains(normalized);
  }

  static bool isKnown(String? role) {
    return normalize(role).isNotEmpty;
  }

  static String normalize(String? role) {
    return role?.trim().toLowerCase() ?? '';
  }
}
