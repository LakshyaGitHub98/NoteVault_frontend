import 'package:flutter/material.dart';
import 'Screen3.dart';
class Screen2 extends StatelessWidget {
  final PageController controller;
  const Screen2({super.key, required this.controller});


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
              Icon(Icons.shield, size: 100, color: Theme.of(context).colorScheme.primary),
              SizedBox(height: 24),
              Text("Military-Grade Encryption", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              SizedBox(height: 12),
              Text("AES-256 encryption protects your data from everyone but you.", style: TextStyle(fontSize: 16, color: Colors.white70), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            controller.nextPage(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text("Next", style: TextStyle(color:Colors.white,fontSize: 18)),
        ),
      ),
    );
  }
}