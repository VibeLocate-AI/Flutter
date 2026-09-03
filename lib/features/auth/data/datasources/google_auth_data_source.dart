import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthDataSource {
  GoogleAuthDataSource({
    required this.serverClientId,
  });

  final String serverClientId;

  final GoogleSignIn _googleSignIn =
      GoogleSignIn.instance;

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    if (serverClientId.trim().isEmpty) {
      throw Exception(
        'GOOGLE_SERVER_CLIENT_ID is not configured.',
      );
    }

    await _googleSignIn.initialize(
      serverClientId: serverClientId,
    );

    _initialized = true;
  }

  Future<String> signInAndGetIdToken() async {
    await _ensureInitialized();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw Exception(
        'Google Sign-In is not supported on this platform.',
      );
    }

    final GoogleSignInAccount account =
    await _googleSignIn.authenticate();

    final GoogleSignInAuthentication authentication =
        account.authentication;

    final idToken = authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Google did not return an ID token.',
      );
    }

    return idToken;
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
  }
}