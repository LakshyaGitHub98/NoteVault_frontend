import 'package:flutter/material.dart';
import 'package:note_vault_frontend/auth/RegistrationPage.dart';
class Screen3 extends StatelessWidget {
  final PageController controller;
  const Screen3({super.key, required this.controller});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_done, size: 100, color: Theme.of(context).colorScheme.primary),
              SizedBox(height: 24),
              Text("Access Anywhere", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              SizedBox(height: 12),
              Text("Login securely and access your vault from any device.", style: TextStyle(fontSize: 16, color: Colors.white70), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => RegistrationPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text("Get Started", style: TextStyle(color:Colors.white,fontSize: 18)),
        ),
      ),
    );
  }
}