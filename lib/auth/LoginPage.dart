import 'package:flutter/material.dart';
import 'package:note_vault_frontend/admin/AdminPanel.dart';
import 'package:note_vault_frontend/auth/RegistrationPage.dart';
import 'package:note_vault_frontend/screens/UserProfilePage.dart';

// Use the actual filenames (lowercase recommended)
import '/services/ApiServices.dart';
import '/services/AuthServices.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool rememberMe = true; // persistent by default
  bool isPasswordVisible = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final username = usernameController.text.trim();
    final password = passwordController.text;

    try {
      if (username.isEmpty || password.isEmpty) {
        throw Exception('Please enter both username and password.');
      }

      // Admin shortcut (optional)
      if (username == "admin123" && password == "admin@123") {
        if (rememberMe) {
          await AuthService.saveSession(token: 'admin-session-token', userId: 'admin');
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminPanel(title: "Admin Panel")),
        );
        return;
      }

      // Calls backend, gets token (+ maybe userId) and saves session
      // Ensure ApiServices.loginUser returns Map<String, String>
      final result = await ApiServices.loginUser(username, password);

      // Resolve userId: prefer backend response; else decode from token via AuthService
      String? userId = result['userId'];
      userId ??= await AuthService.getUserId();

      if (userId == null || userId.isEmpty) {
        throw Exception('Login succeeded, but userId could not be resolved.');
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserProfilePage(
            userId: userId!,
            profileImageUrl: '', // Widget has asset fallback
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed. ${e.toString()}")),
      );
      // Optionally route to registration
      Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationPage
      ()));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              children: [
                Icon(Icons.person_pin, size: 120, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                const Text(
                  "Welcome to your Safe Place",
                  style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "eg: chromicle",
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.white10,
                    labelStyle: const TextStyle(color: Colors.white),
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                    ),
                    filled: true,
                    fillColor: Colors.white10,
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (val) => setState(() => rememberMe = val ?? false),
                      checkColor: Colors.black,
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    const Text("Remember me", style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SIGN IN", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.facebook, color: Colors.blueAccent, size: 32),
                    SizedBox(width: 24),
                    Icon(Icons.g_mobiledata, color: Colors.redAccent, size: 32),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationPage()));
                  },
                  child: const Text("New here? Create an account", style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}