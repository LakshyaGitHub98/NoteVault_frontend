import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/User.dart';

class ApiServices {
  static const String baseUrl = 'http://192.168.29.43:8000/api';

  static Future<List<User>> fetchUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users'))
          .timeout(const Duration(seconds: 10));

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print("Caught error: $e");
      throw Exception("API call failed: $e");
    }
  }

  static Future<User> fetchUserbyId(String id) async{
    try{
      final response = await http
          .get(Uri.parse('$baseUrl/users/$id'))
          .timeout(const Duration(seconds: 10));
      if(response.statusCode==200){
        final Map<String,dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      }
      else{
        throw Exception('Failed to load User : ${response.statusCode}');
      }

    }
    catch(e)
    {
      throw Exception('Api Called Failed : $e');
    }
  }

  static Future<bool> createNewUser(User user)async{
    try{
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/'),
            headers: {'Content-Type':'application/json'},
            body: jsonEncode(user.toJson())
          )
          .timeout(const Duration(seconds: 10));
      print("Status : ${response.statusCode}");
      print("Body : ${response.body}");
      if(response.statusCode==200 || response.statusCode==201)return true;
      else throw Exception('Failed to Create User : ${response.statusCode}');
    }
    catch(e){
      throw Exception('Api Called Failed : $e');
    }

  }

  static Future<bool> deleteUserbyId(String id) async{
    try{
      final response = await http
          .delete(Uri.parse('$baseUrl/users/$id'))
          .timeout(const Duration(seconds: 10));
      if(response.statusCode==200)return true;
      else{
        throw Exception('Failed to delete User : ${response.statusCode}');
      }
    }
    catch(e)
    {
      throw Exception('Api Called Failed : $e');
    }
  }

  static Future<bool> updateUserById(String id, User updatedData) async {
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData.toJson()),
      )
          .timeout(const Duration(seconds: 10));

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API call failed: $e');
    }
  }

  static Future<String> loginUser(String username, String password) async {
    try {
      print("Calling: $baseUrl/auth/login");
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userId = data['userId'];
        print("✅ Logged in! User ID: $userId");
        return userId;
      }else {
        throw Exception('Failed to load User : ${response.statusCode}');
      }
    }catch (e, stackTrace) {

      throw Exception('API Call Failed: $e');
    }

  }

  static Future<bool> registerUser(User user) async{
    try{
      final response = await http
          .post(
          Uri.parse('$baseUrl/auth/register'),
          headers: {'Content-Type':'application/json'},
          body: jsonEncode(user.toJson())
      )
          .timeout(const Duration(seconds: 10));
      print("Status : ${response.statusCode}");
      print("Body : ${response.body}");
      if(response.statusCode==200 || response.statusCode==201)return true;
      else throw Exception('Failed to Register : ${response.statusCode}');
    }
    catch(e){
      throw Exception('Api Called Failed  through register: $e');
    }
  }



  static Future<bool> uploadFile({
    required String filename,
    required String description,
    required String userId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/files/upload');
      final response = await http
          .post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'filename': filename,
          'description': description,
          'userId': userId,
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) return true;
      throw Exception('Failed to Upload File : ${response.statusCode}');
    } catch (e) {
      throw Exception('API Call Failed through upload file : $e');
    }
  }
}