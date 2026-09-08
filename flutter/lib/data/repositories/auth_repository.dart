import 'dart:convert';
import 'package:drift/drift.dart';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';

import '../local/database.dart';
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
    await _settings.setBiometricEnabled(false);
  }

  /// Checks for an existing valid session.
  Future<UserProfile?> restoreSession() async {
    return _settings.getProfile();
  }
}

/// Wraps google_sign_in. Returns a [UserProfile]-compatible map.
/// Note: Requires google-services.json / GoogleService-Info.plist configured.
class GoogleAuthRepository {
  GoogleAuthRepository(this._db, this._settings);

  final AppDatabase _db;
  final SettingsRepository _settings;

  static final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  /// Initiates Google Sign-In. Returns null if cancelled / unavailable.
  Future<UserProfile?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      // Check if user already exists
      final existing = await (_db.select(_db.userProfiles)
            ..where((p) => p.googleId.equals(account.id))
            ..limit(1))
          .get();

      if (existing.isNotEmpty) {
        await _settings.saveSession(existing.first.id);
        return existing.first;
      }

      // Check by email
      final byEmail = await (_db.select(_db.userProfiles)
            ..where(
                (p) => p.email.equals(account.email.toLowerCase().trim()))
            ..limit(1))
          .get();

      if (byEmail.isNotEmpty) {
        // Link Google account to existing local account
        await (_db.update(_db.userProfiles)
              ..where((p) => p.id.equals(byEmail.first.id)))
            .write(UserProfilesCompanion(
          googleId: Value(account.id),
          isGoogleAccount: const Value(true),
        ));
        await _settings.saveSession(byEmail.first.id);
        return byEmail.first;
      }

      // New Google user — create profile
      final id = await _db.into(_db.userProfiles).insert(
            UserProfilesCompanion.insert(
              name: account.displayName ?? account.email.split('@').first,
              email: account.email.toLowerCase().trim(),
              isGoogleAccount: const Value(true),
              googleId: Value(account.id),
              createdAt: DateTime.now(),
            ),
          );
      await _settings.saveSession(id);
      await _settings.setOnboardingDone();
      return await _settings.getProfileById(id);
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _settings.clearSession();
  }
}

/// Wraps local_auth for biometric authentication.
class BiometricRepository {
  static final _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
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
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to access your budget',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
