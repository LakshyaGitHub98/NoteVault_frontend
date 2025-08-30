import 'package:flutter/material.dart';
import 'package:note_vault_frontend/services/ApiServices.dart';
import '/models/User.dart';

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController _idController = TextEditingController();
  Future<User>? _userFuture;

  void _fetchUser() {
    final id = _idController.text.trim();
    if (id.isNotEmpty) {
      setState(() {
        _userFuture = ApiServices.fetchUserbyId(id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Find User by ID")),
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
              onPressed: _fetchUser,
              child: Text("Fetch User"),
            ),
            SizedBox(height: 20),
            _userFuture == null
                ? Text("Enter an ID to fetch user")
                : FutureBuilder<User>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData) {
                  return Text("No user found");
                }

                final user = snapshot.data!;
                return Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text(user.username),
                    subtitle: Text(user.email),
                    trailing: Text("ID: ${user.id}"),
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