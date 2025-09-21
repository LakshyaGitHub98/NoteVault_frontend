import 'package:flutter/material.dart';
import 'package:note_vault_frontend/admin/CreateNewUser.dart';
import 'package:note_vault_frontend/admin/DeleteUser.dart';
import 'package:note_vault_frontend/admin/UpdateUser.dart';
import 'package:note_vault_frontend/widgets/tiles/TileBox.dart';
import 'UsersPage.dart';
import 'UserPage.dart';

class AdminPanel extends StatelessWidget {
  final String title;
  AdminPanel({super.key, required this.title});

  final List<String> labels = [
    "Users",
    "User",
    "New User",
    "Update User",
    "Delete User"
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: labels.map((label) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () {
                    if (label == "Users") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UsersPage()),
                      );
                    } else if (label == "User") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserPage()),
                      );
                    } else if (label == "New User") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateNewUser()),
                      );
                    } else if (label == "Update User") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UpdateUser()),
                      );
                    } else if (label == "Delete User") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DeleteUser()),
                      );
                    }
                  },
                  child: TileBox(
                    label: label,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}