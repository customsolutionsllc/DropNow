import 'package:firebase_auth/firebase_auth.dart';

/// Wraps Firebase Authentication. Handles anonymous sign-in and auth state.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current Firebase user (null if not signed in).
  User? get currentUser => _auth.currentUser;

  /// Current user UID (null if not signed in).
  String? get uid => _auth.currentUser?.uid;

  /// Whether the user is authenticated.
  bool get isSignedIn => _auth.currentUser != null;

  /// Whether the current auth is anonymous.
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  /// Auth provider label for display.
  String get authProviderLabel {
    final user = _auth.currentUser;
    if (user == null) return 'Not signed in';
    if (user.isAnonymous) return 'Anonymous';
    return 'Signed in';
  }

  /// Sign in anonymously. Creates a new anonymous account or returns existing.
  /// Safe to call multiple times — if already signed in, returns current user.
  Future<User?> ensureSignedIn() async {
    if (_auth.currentUser != null) return _auth.currentUser;
    try {
      final credential = await _auth.signInAnonymously();
      return credential.user;
    } catch (e) {
      // Auth failure is non-fatal — app continues in local-only mode
      return null;
    }
  }

  /// Sign out. After sign out, call ensureSignedIn() to re-establish anonymous.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // Non-fatal
    }
  }

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
