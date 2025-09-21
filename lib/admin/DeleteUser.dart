import 'package:flutter/material.dart';
import 'package:note_vault_frontend/services/AdminApiServices.dart';

class DeleteUser extends StatefulWidget {
  @override
  State<DeleteUser> createState() => _DeleteUserPageState();
}

class _DeleteUserPageState extends State<DeleteUser> {
  final TextEditingController _idController = TextEditingController();
  Future<bool>? _deleteUserFuture;

  void _deleteUser() {
    final id = _idController.text.trim();
    if (id.isNotEmpty) {
      setState(() {
        _deleteUserFuture = AdminApiServices.deleteUser(id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Delete User by ID")),
      body: Padding(
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
              onPressed: _deleteUser,
              child: Text("Delete User"),
            ),
            SizedBox(height: 20),
            if (_deleteUserFuture == null) Text("Enter an ID to delete user") else FutureBuilder<bool>(
              future: _deleteUserFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData) {
                  return Text("No user found");
                }
                final id = _idController.text.trim();
                return Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text("User Delete Successfully"),
                    // subtitle: Text(user.email),
                    trailing: Text("ID: ${id}"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}