// lib/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyToken = 'token';
  static const _keyUserId = 'userId';

  // Save token and (optionally) userId if backend returns it
  static Future<void> saveSession({
    required String token,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    if (userId != null && userId.isNotEmpty) {
      await prefs.setString(_keyUserId, userId);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Get userId: prefer stored; else decode from JWT (supports id or _id keys)
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyUserId);
    if (stored != null && stored.isNotEmpty) return stored;

    final token = prefs.getString(_keyToken);
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> map = jsonDecode(payload);

      final id = map['id'] ?? map['_id'] ?? map['userId'];
      if (id != null) {
        await prefs.setString(_keyUserId, id.toString());
        return id.toString();
      }
    } catch (_) {
      // swallow decode errors; return null
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
  }
}