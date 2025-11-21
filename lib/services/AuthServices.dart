import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyToken = 'token';
  static const _keyUserId = 'userId';

  static const String baseUrl = 'https://notevault-backend-c04n.onrender.com/api/auth';
  // 👆 Apne backend ka URL dalna (localhost/production)

  // ---------------- SESSION HELPERS ----------------

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

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyUserId);
    if (stored != null && stored.isNotEmpty) return stored;

    final token = prefs.getString(_keyToken);
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload =
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> map = jsonDecode(payload);

      final id = map['id'] ?? map['_id'] ?? map['userId'];
      if (id != null) {
        await prefs.setString(_keyUserId, id.toString());
        return id.toString();
      }
    } catch (_) {}
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

  // ---------------- API CALL WRAPPERS ----------------

  // LOGIN
  static Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["token"] != null) {
        await saveSession(token: data["token"]);
        return {
          "success": true,
          "isVerified": data["isVerified"] ?? false,
          "message": "Login successful"
        };
      }

      if (data["isVerified"] == false) {
        return {
          "success": false,
          "needsVerification": true,
          "message": "Account not verified. OTP required."
        };
      }

      return {
        "success": false,
        "error": data["error"] ?? "Login failed"
      };
    } catch (e) {
      return {"success": false, "error": "Login error: $e"};
    }
  }

  // REGISTER
  static Future<Map<String, dynamic>> registerUser(
      String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"username": username, "email": email, "password": password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {
          "success": true,
          "message": data["message"] ?? "Registered successfully"
        };
      }
      return {
        "success": false,
        "error": data["error"] ?? "Registration failed"
      };
    } catch (e) {
      return {"success": false, "error": "Register error: $e"};
    }
  }

  // SEND OTP
  static Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/send-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"]};
      }
      return {
        "success": false,
        "error": data["error"] ?? "Failed to send OTP"
      };
    } catch (e) {
      return {"success": false, "error": "Send OTP error: $e"};
    }
  }

  // VERIFY OTP
  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"]};
      }
      return {
        "success": false,
        "error": data["error"] ?? "OTP verification failed"
      };
    } catch (e) {
      return {"success": false, "error": "Verify OTP error: $e"};
    }
  }

  // FORGOT PASSWORD
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"]};
      }
      return {
        "success": false,
        "error": data["error"] ?? "Failed to request reset"
      };
    } catch (e) {
      return {"success": false, "error": "Forgot password error: $e"};
    }
  }

  // RESET PASSWORD
  static Future<Map<String, dynamic>> resetPassword(
      String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token, "newPassword": newPassword}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"]};
      }
      return {
        "success": false,
        "error": data["error"] ?? "Failed to reset password"
      };
    } catch (e) {
      return {"success": false, "error": "Reset password error: $e"};
    }
  }
}