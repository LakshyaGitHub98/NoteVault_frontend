import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/User.dart';
import '/services/AuthServices.dart';

class AdminApiServices {
  static const String baseUrl = 'https://notevault-backend-c04n.onrender.com/api/admin';

  // ------------------ PRIVATE HELPERS ------------------
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static void _handleUnauthorized() async {
    await AuthService.logout();
    throw Exception('Unauthorized (401)');
  }

  static String _extractErrorMessage(String body) {
    try {
      final parsed = jsonDecode(body);
      if (parsed is Map<String, dynamic>) {
        return parsed['error'] ?? parsed['message'] ?? body;
      }
    } catch (_) {}
    return body;
  }

  // ------------------ USERS (ADMIN CRUD) ------------------

  /// Get all users
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'), headers: await _headers());
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
      throw Exception('Failed to fetch users: ${response.statusCode} -- ${_extractErrorMessage(response.body)}');
    } catch (e) {
      throw Exception('getAllUsers API failed: $e');
    }
  }

  /// Get user by ID
  static Future<User> getUserById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'), headers: await _headers());
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
      throw Exception('Failed to fetch user: ${response.statusCode} -- ${_extractErrorMessage(response.body)}');
    } catch (e) {
      throw Exception('getUserById API failed: $e');
    }
  }

  /// Create a new user (Admin)
  static Future<bool> createUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: await _headers(),
        body: jsonEncode(user.toJson()),
      );
      if ([200, 201].contains(response.statusCode)) return true;
      if (response.statusCode == 401) _handleUnauthorized();
      throw Exception('Create user failed: ${response.statusCode} -- ${_extractErrorMessage(response.body)}');
    } catch (e) {
      throw Exception('createUser API failed: $e');
    }
  }

  /// Update user by ID (Admin)
  static Future<bool> updateUser(String id, User user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: await _headers(),
        body: jsonEncode(user.toJson()),
      );
      if ([200, 204].contains(response.statusCode)) return true;
      if (response.statusCode == 401) _handleUnauthorized();
      throw Exception('Update user failed: ${response.statusCode} -- ${_extractErrorMessage(response.body)}');
    } catch (e) {
      throw Exception('updateUser API failed: $e');
    }
  }

  /// Delete user by ID (Admin)
  static Future<bool> deleteUser(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: await _headers());
      if (response.statusCode == 200) return true;
      if (response.statusCode == 401) _handleUnauthorized();
      throw Exception('Delete user failed: ${response.statusCode} -- ${_extractErrorMessage(response.body)}');
    } catch (e) {
      throw Exception('deleteUser API failed: $e');
    }
  }
}
