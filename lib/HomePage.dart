import 'package:flutter/material.dart';
import 'package:note_vault_frontend/auth/LoginPage.dart';
import 'package:note_vault_frontend/auth/RegistrationPage.dart';
import 'OnBoardingPager.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Optional: match image vibe
      appBar: AppBar(
        leading: Icon(Icons.lock),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      // ✅ Main body stays clean
      body: Center(
        child: Text(
          "Welcome to NoteVault",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),

      // ✅ Bottom button like nav bar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) =>OnboardingPager()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Get Started", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
              },
              child: RichText(
                text: TextSpan(
                  text: "Already a member? ",
                  style: TextStyle(color: Colors.white),
                  children: [
                    TextSpan(
                      text: "Sign Up",
                      style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}