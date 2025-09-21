import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/User.dart';
import '/models/FileModel.dart';
import '/services/AuthServices.dart';

class ApiServices {
  static const String baseUrl = 'https://notevault-backend-c04n.onrender.com/api';

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

  // ------------------ AUTH ------------------
  static Future<Map<String, String>> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String?;
        final userId = (data['userId'] ?? data['id'] ?? data['_id'])?.toString();

        if (token == null || token.isEmpty) throw Exception('No token in response');

        await AuthService.saveSession(token: token, userId: userId);
        return {'token': token, if (userId != null) 'userId': userId};
      }

      throw Exception('Login failed: ${response.statusCode} ${response.body}');
    } catch (e) {
      throw Exception('Login API failed: $e');
    }
  }

  static Future<bool> registerUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if ([200, 201].contains(response.statusCode)) return true;
      throw Exception('Registration failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('Register API failed: $e');
    }
  }

  // ------------------ FILES ------------------

  /// Upload editor note (plain text)
  static Future<bool> uploadFile({
    required String filename,
    required String content,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/file/upload'),
        headers: await _headers(),
        body: jsonEncode({
          'filename': filename,
          'content': content,
          'userId': userId,
        }),
      );

      if ([200, 201].contains(response.statusCode)) return true;
      if (response.statusCode == 401) _handleUnauthorized();

      throw Exception('Upload file failed: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Upload file API failed: $e');
    }
  }

  /// Upload file from system (multipart)
  static Future<bool> uploadFileFromSystem(FileModel file, String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/file/uploadFile');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath('file', file.path!));
      request.fields['userId'] = userId;

      final token = await AuthService.getToken();
      if (token != null) request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if ([200, 201].contains(res.statusCode)) return true;
      if (res.statusCode == 401) _handleUnauthorized();

      throw Exception('Upload system file failed: ${res.statusCode} - ${res.body}');
    } catch (e) {
      throw Exception('Upload system file API failed: $e');
    }
  }

  /// View all files for a user (editor notes + system files)
  static Future<List<FileModel>> viewAllFiles({required String userId}) async {
    try {
      // Fetch normal uploaded files
      final uploadedResponse = await http.get(
        Uri.parse('$baseUrl/file/files/${Uri.encodeComponent(userId)}'),
        headers: await _headers(),
      );

      List<FileModel> uploadedFiles = [];
      if (uploadedResponse.statusCode == 200) {
        final List<dynamic> files = jsonDecode(uploadedResponse.body)['files'];
        uploadedFiles = files.map((f) => FileModel.fromJson(f)).toList();
      } else if (uploadedResponse.statusCode == 401) {
        _handleUnauthorized();
      }

      // Fetch system/editor files
      final systemResponse = await http.post(
        Uri.parse('$baseUrl/file/files/viewSystemUploadedFiles'),
        headers: await _headers(),
        body: jsonEncode({'userId': userId}),
      );

      List<FileModel> systemFiles = [];
      if (systemResponse.statusCode == 200) {
        final List<dynamic> files = jsonDecode(systemResponse.body)['systemFiles'];
        systemFiles = files.map((f) => FileModel.fromJson(f)).toList();
      } else if (systemResponse.statusCode == 401) {
        _handleUnauthorized();
      }

      // Combine both
      return [...uploadedFiles, ...systemFiles];
    } catch (e) {
      throw Exception('Fetch all files API failed: $e');
    }
  }

  /// Delete a file
  static Future<bool> deleteFile({
    required String userId,
    required String fileId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/file/user/$userId/file/$fileId');
      final response = await http.delete(uri, headers: await _headers());

      if (response.statusCode == 200) return true;
      if (response.statusCode == 401) _handleUnauthorized();

      final msg = _extractErrorMessage(response.body);
      throw Exception('Delete file failed: ${response.statusCode} -- $msg');
    } catch (e) {
      throw Exception('Delete file API failed: $e');
    }
  }

  /// View/download a file
  static Future<http.Response> viewFile({required String fileId}) async {
    try {
      final uri = Uri.parse('$baseUrl/file/$fileId/view');
      final response = await http.get(uri, headers: await _headers());

      if (response.statusCode == 200) return response;
      if (response.statusCode == 401) _handleUnauthorized();

      throw Exception('View file failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('View file API failed: $e');
    }
  }
}