// lib/widgets/home_shell.dart
import 'package:flutter/material.dart';
import '/services/AuthServices.dart';
import '/screens/UserProfilePage.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  String? _userId;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    _userId = await AuthService.getUserId(); // optional, may be null
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      // If you don’t store userId, you can fetch profile using token later.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return UserProfilePage(
      userId: _userId!,
      profileImageUrl: 'https://your-image-url.com',
    );
  }
}