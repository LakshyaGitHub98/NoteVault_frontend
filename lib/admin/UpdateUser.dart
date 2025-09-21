import 'package:flutter/material.dart';
import '/models/User.dart';
import '/services/AdminApiServices.dart';

class UpdateUser extends StatefulWidget {
  @override
  State<UpdateUser> createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<User>? _userFuture;
  String? _statusMessage;
  bool _isUpdating = false;

  void _fetchUser() {
    final id = _idController.text.trim();
    if (id.isNotEmpty) {
      setState(() {
        _userFuture = AdminApiServices.getUserById(id);
        _statusMessage = null;
      });

      _userFuture!.then((user) {
        _usernameController.text = user.username;
        _emailController.text = user.email;
        _passwordController.text = user.password;
      });
    }
  }

  Future<void> _updateUser() async {
    final id = _idController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (id.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _statusMessage = "All fields are required";
      });
      return;
    }

    setState(() {
      _isUpdating = true;
      _statusMessage = null;
    });

    final updatedUser = User(
      id: id,
      username: username,
      email: email,
      password: password,
    );

    try {
      final success = await AdminApiServices.updateUser(id, updatedUser);
      setState(() {
        _statusMessage = success ? "User updated successfully!" : "Update failed.";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error: $e";
      });
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update User")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: "Enter User ID",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchUser,
              child: Text("Fetch User"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUpdating ? null : _updateUser,
              child: _isUpdating ? CircularProgressIndicator() : Text("Update User"),
            ),
            SizedBox(height: 20),
            if (_statusMessage != null)
              Text(
                _statusMessage!,
                style: TextStyle(color: Colors.blueAccent),
              ),
          ],
        ),
      ),
    );
  }
}