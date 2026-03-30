import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps Firebase Authentication.
/// Supports Google, Facebook, anonymous, and guest (no-auth) modes.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const _keyLoginSkipped = 'auth_login_skipped';
  static const _keyHasSeenLogin = 'auth_has_seen_login';

  /// Current Firebase user (null if not signed in).
  User? get currentUser => _auth.currentUser;

  /// Current user UID (null if not signed in).
  String? get uid => _auth.currentUser?.uid;

  /// Whether the user is authenticated (including anonymous).
  bool get isSignedIn => _auth.currentUser != null;

  /// Whether the current auth is anonymous.
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  /// Whether user is signed in with a social provider (not anonymous).
  bool get isSocialSignIn {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return false;
    return user.providerData.any(
      (p) => p.providerId == 'google.com' || p.providerId == 'facebook.com',
    );
  }

  /// Display name from the social provider, or null.
  String? get displayName => _auth.currentUser?.displayName;

  /// Email from the social provider, or null.
  String? get email => _auth.currentUser?.email;

  /// Photo URL from the social provider, or null.
  String? get photoUrl => _auth.currentUser?.photoURL;

  /// Auth provider label for display.
  String get authProviderLabel {
    final user = _auth.currentUser;
    if (user == null) return 'Guest';
    if (user.isAnonymous) return 'Anonymous';
    for (final info in user.providerData) {
      if (info.providerId == 'google.com') return 'Google';
      if (info.providerId == 'facebook.com') return 'Facebook';
    }
    return 'Signed in';
  }

  // ── Preferences helpers ──

  /// Whether user chose "Continue as Guest" (skipped login screen).
  Future<bool> hasSkippedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoginSkipped) ?? false;
  }

  Future<void> markLoginSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoginSkipped, true);
    await prefs.setBool(_keyHasSeenLogin, true);
  }

  /// Whether the login screen has ever been shown / dismissed.
  Future<bool> hasSeenLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenLogin) ?? false;
  }

  Future<void> markLoginSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenLogin, true);
  }

  // ── Anonymous ──

  /// Sign in anonymously. Creates a new anonymous account or returns existing.
  Future<User?> ensureSignedIn() async {
    if (_auth.currentUser != null) return _auth.currentUser;
    try {
      final credential = await _auth.signInAnonymously();
      return credential.user;
    } catch (e) {
      debugPrint('[AUTH] anonymous sign-in failed: $e');
      return null;
    }
  }

  // ── Google Sign-In ──

  /// Sign in with Google. Returns the Firebase user or null on cancel / error.
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // If currently anonymous, link the credential to upgrade the account
      final current = _auth.currentUser;
      UserCredential result;
      if (current != null && current.isAnonymous) {
        try {
          result = await current.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            // Another account already exists — sign in directly
            result = await _auth.signInWithCredential(credential);
          } else {
            rethrow;
          }
        }
      } else {
        result = await _auth.signInWithCredential(credential);
      }

      await markLoginSeen();
      debugPrint('[AUTH] Google sign-in success');
      return result.user;
    } catch (e) {
      debugPrint('[AUTH] Google sign-in failed: $e');
      return null;
    }
  }

  // ── Facebook Sign-In ──

  /// Sign in with Facebook. Returns the Firebase user or null on cancel / error.
  Future<User?> signInWithFacebook() async {
    try {
      final loginResult = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (loginResult.status != LoginStatus.success) return null;

      final accessToken = loginResult.accessToken;
      if (accessToken == null) return null;

      final credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      final current = _auth.currentUser;
      UserCredential result;
      if (current != null && current.isAnonymous) {
        try {
          result = await current.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            result = await _auth.signInWithCredential(credential);
          } else {
            rethrow;
          }
        }
      } else {
        result = await _auth.signInWithCredential(credential);
      }

      await markLoginSeen();
      debugPrint('[AUTH] Facebook sign-in success');
      return result.user;
    } catch (e) {
      debugPrint('[AUTH] Facebook sign-in failed: $e');
      return null;
    }
  }

  // ── Sign Out ──

  /// Sign out from all providers. After this, call ensureSignedIn() to
  /// re-establish anonymous auth if needed.
  Future<void> signOut() async {
    try {
      // Sign out from social providers
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      try {
        await FacebookAuth.instance.logOut();
      } catch (_) {}

      await _auth.signOut();

      // Clear the login-skipped flag so login screen shows again
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLoginSkipped);

      debugPrint('[AUTH] signed out');
    } catch (e) {
      debugPrint('[AUTH] sign-out failed: $e');
    }
  }

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
