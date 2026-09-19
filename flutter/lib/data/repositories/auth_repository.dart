import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';

import '../local/database.dart';
import '../../core/google_config.dart';
import 'settings_repository.dart';

/// Hashes a plain-text password with SHA-256.
String _hashPassword(String password) {
  final bytes = utf8.encode(password);
  return sha256.convert(bytes).toString();
}

/// Handles local email/password authentication against the SQLite UserProfiles table.
class LocalAuthRepository {
  LocalAuthRepository(this._db, this._settings);

  final AppDatabase _db;
  final SettingsRepository _settings;

  /// Signs up a new user. Returns null if email is already taken.
  Future<UserProfile?> signUp({
    required String name,
    required String email,
    required String password,
    required String region,
    required String currency,
  }) async {
    final existing = await (_db.select(_db.userProfiles)
          ..where((p) => p.email.equals(email.toLowerCase().trim()))
          ..limit(1))
        .get();
    if (existing.isNotEmpty) return null; // email already exists

    final id = await _db.into(_db.userProfiles).insert(
          UserProfilesCompanion.insert(
            name: name.trim(),
            email: email.toLowerCase().trim(),
            passwordHash: Value(_hashPassword(password)),
            region: Value(region),
            createdAt: DateTime.now(),
          ),
        );

    await _settings.setCurrency(currency);
    await _settings.saveSession(id);
    await _settings.setOnboardingDone();

    return await _settings.getProfileById(id);
  }

  /// Logs in with email + password. Returns null if credentials are wrong.
  Future<UserProfile?> login({
    required String email,
    required String password,
  }) async {
    final rows = await (_db.select(_db.userProfiles)
          ..where((p) => p.email.equals(email.toLowerCase().trim()))
          ..limit(1))
        .get();
    if (rows.isEmpty) return null;
    final profile = rows.first;
    if (profile.passwordHash == null) return null;
    if (profile.passwordHash != _hashPassword(password)) return null;
    await _settings.saveSession(profile.id);
    return profile;
  }

  /// Signs out the current user.
  Future<void> logout() async {
    await _settings.clearSession();
  }

  /// Checks for an existing valid session.
  Future<UserProfile?> restoreSession() async {
    return _settings.getProfile();
  }

  Future<String?> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (newPassword.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    final rows = await (_db.select(_db.userProfiles)
          ..where((p) => p.id.equals(userId))
          ..limit(1))
        .get();
    if (rows.isEmpty) return 'Account not found.';
    final profile = rows.first;
    if (profile.isGoogleAccount || profile.passwordHash == null) {
      return 'Google accounts use Google to sign in. Password cannot be changed here.';
    }
    if (profile.passwordHash != _hashPassword(currentPassword)) {
      return 'Current password is incorrect.';
    }
    await (_db.update(_db.userProfiles)..where((p) => p.id.equals(userId)))
        .write(UserProfilesCompanion(
      passwordHash: Value(_hashPassword(newPassword)),
    ));
    return null;
  }
}

/// Wraps google_sign_in. Returns a [UserProfile]-compatible map.
/// Note: Requires google-services.json / GoogleService-Info.plist configured.
class GoogleAuthRepository {
  GoogleAuthRepository(this._db, this._settings);

  final AppDatabase _db;
  final SettingsRepository _settings;

  static String get _webClientId {
    const fromEnv = String.fromEnvironment('GOOGLE_CLIENT_ID');
    if (fromEnv.isNotEmpty) return fromEnv;
    return kGoogleWebClientId;
  }

  static final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: kIsWeb ? _webClientId : null,
  );

  /// Initiates Google Sign-In. Returns null if the user cancelled.
  /// Throws [GoogleSignInFailure] when configuration or the Google SDK fails.
  Future<UserProfile?> signInWithGoogle() async {
    if (kIsWeb && _webClientId.isEmpty) {
      throw GoogleSignInFailure(
        'Google on Chrome needs a Web client ID. '
        'Paste it in flutter/lib/core/google_config.dart '
        '(see comments in that file). Email/password works without it. '
        'On a phone, Google does not use this key.',
      );
    }
    try {
      GoogleSignInAccount? account = _googleSignIn.currentUser;
      account ??= await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();
      if (account == null) return null;

      final signedIn = account;
      final existing = await (_db.select(_db.userProfiles)
            ..where((p) => p.googleId.equals(signedIn.id))
            ..limit(1))
          .get();

      if (existing.isNotEmpty) {
        await _settings.saveSession(existing.first.id);
        return existing.first;
      }

      final byEmail = await (_db.select(_db.userProfiles)
            ..where(
                (p) => p.email.equals(signedIn.email.toLowerCase().trim()))
            ..limit(1))
          .get();

      if (byEmail.isNotEmpty) {
        await (_db.update(_db.userProfiles)
              ..where((p) => p.id.equals(byEmail.first.id)))
            .write(UserProfilesCompanion(
          googleId: Value(signedIn.id),
          isGoogleAccount: const Value(true),
        ));
        await _settings.saveSession(byEmail.first.id);
        return byEmail.first;
      }

      final id = await _db.into(_db.userProfiles).insert(
            UserProfilesCompanion.insert(
              name: signedIn.displayName ?? signedIn.email.split('@').first,
              email: signedIn.email.toLowerCase().trim(),
              avatarPath: Value(signedIn.photoUrl),
              isGoogleAccount: const Value(true),
              googleId: Value(signedIn.id),
              createdAt: DateTime.now(),
            ),
          );
      await _settings.saveSession(id);
      await _settings.setOnboardingDone();
      return await _settings.getProfileById(id);
    } catch (e) {
      final text = e.toString().toLowerCase();
      if (text.contains('12501') ||
          text.contains('sign_in_canceled') ||
          text.contains('sign_in_cancelled') ||
          text.contains('canceled')) {
        return null;
      }
      throw GoogleSignInFailure(
        'Google Sign-In failed. Check that a Google account is available '
        'on this device and that the app SHA-1 / package name is registered '
        'in Google Cloud. ($e)',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}

class GoogleSignInFailure implements Exception {
  GoogleSignInFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Wraps local_auth for biometric authentication.
class BiometricRepository {
  static final _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> availableTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Returns true if biometric auth succeeded.
  Future<bool> authenticate() async {
    if (kIsWeb) return false;
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to access your budget',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
