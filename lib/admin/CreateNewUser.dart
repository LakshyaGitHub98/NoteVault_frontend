import 'package:flutter/material.dart';
import '/models/User.dart';
import '/services/AdminApiServices.dart';

class CreateNewUser extends StatefulWidget {
  @override
  State<CreateNewUser> createState() => _CreateNewUserState();
}

class _CreateNewUserState extends State<CreateNewUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _statusMessage;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _statusMessage = null;
      });

      final newUser = User(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      try {
        final success = await AdminApiServices.createUser(newUser);
        setState(() {
          _statusMessage = success ? "User created successfully!" : "Failed to create user.";
        });
      } catch (e) {
        setState(() {
          _statusMessage = "Error: $e";
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create New User")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "Username"),
                validator: (value) => value == null || value.isEmpty ? "Enter username" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) => value == null || value.isEmpty ? "Enter email" : null,
              ),
              SizedBox(height: 12,),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty ? "Enter Password" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading ? CircularProgressIndicator() : Text("Create User"),
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
      ),
    );
  }
}

