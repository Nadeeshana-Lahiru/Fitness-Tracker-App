import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  static const _storage = FlutterSecureStorage();

  static const _sessionKey = 'session_user_id';

  // ─── Password Hashing ───────────────────────

  /// Hash a password with SHA-256 + a static app salt
  static String hashPassword(String password) {
    const salt = 'fittrack_app_salt_v1';
    final bytes = utf8.encode(salt + password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String plainPassword, String hash) {
    return hashPassword(plainPassword) == hash;
  }

  // ─── Session Management ──────────────────────

  static Future<void> saveSession(String userId) async {
    await _storage.write(key: _sessionKey, value: userId);
  }

  static Future<String?> getSession() async {
    return await _storage.read(key: _sessionKey);
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
  }
}
