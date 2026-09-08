import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../local/database.dart';
import '../models/default_categories.dart';

/// Centralized repository for all application settings.
/// Persists currency & onboarding flag in SharedPreferences (fast reads),
/// and profile data in the local SQLite database (UserProfiles table).
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;
  static const _currencyKey = 'app_currency';
  static const _onboardingKey = 'onboarding_done';
  static const _biometricKey = 'biometric_enabled';
  static const _sessionKey = 'session_user_id';
  static final _secureStorage = FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // Currency
  // ---------------------------------------------------------------------------

  Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? 'TND';
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
    // Also persist in DB for future multi-user support
    await _db.setSetting(_currencyKey, currency);
  }

  // ---------------------------------------------------------------------------
  // Onboarding
  // ---------------------------------------------------------------------------

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // ---------------------------------------------------------------------------
  // Biometrics
  // ---------------------------------------------------------------------------

  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _biometricKey);
    return value == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(key: _biometricKey, value: enabled.toString());
  }

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------

  Future<int?> getSessionUserId() async {
    final value = await _secureStorage.read(key: _sessionKey);
    return value == null ? null : int.tryParse(value);
  }

  Future<void> saveSession(int userId) async {
    await _secureStorage.write(key: _sessionKey, value: userId.toString());
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _sessionKey);
  }

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

  Future<UserProfile?> getProfile() async {
    final userId = await getSessionUserId();
    if (userId == null) return null;
    final rows = await (_db.select(_db.userProfiles)
          ..where((p) => p.id.equals(userId))
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<UserProfile?> getProfileById(int id) async {
    final rows = await (_db.select(_db.userProfiles)
          ..where((p) => p.id.equals(id))
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> updateProfile({
    required int id,
    required String name,
    required String region,
    String? currency,
  }) async {
    await (_db.update(_db.userProfiles)..where((p) => p.id.equals(id))).write(
      UserProfilesCompanion(
        name: Value(name),
        region: Value(region),
      ),
    );
    if (currency != null && kSupportedCurrencies.contains(currency)) {
      await setCurrency(currency);
    }
  }
}
