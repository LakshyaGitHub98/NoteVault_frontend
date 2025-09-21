// lib/main.dart
import 'package:flutter/material.dart';
import 'SplashScreen.dart';
import 'auth/LoginPage.dart';
import 'HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      title: 'Note Vault',
      home: SplashScreen(),
      routes: {
        '/home': (_) => const MyHomePage(title: 'Note Vault'),
        '/login': (_) => LoginPage(),
      },
    );
  }
}