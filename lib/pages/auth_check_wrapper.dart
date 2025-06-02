// lib/screens/auth_check_wrapper.dart

import 'package:flutter/material.dart';
import '../services/auth_manager.dart';
import '../routes/Routenames.dart'; 

class AuthCheckWrapper extends StatefulWidget {
  const AuthCheckWrapper({super.key});

  @override
  State<AuthCheckWrapper> createState() => _AuthCheckWrapperState();
}

class _AuthCheckWrapperState extends State<AuthCheckWrapper> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndNavigate();
  }

  Future<void> _checkLoginStatusAndNavigate() async {
    final token = await AuthManager.getAuthToken();
    if (mounted) { 
      if (token != null) {
        // Pengguna sudah login, arahkan ke halaman utama
        Navigator.pushReplacementNamed(context, Routenames.home);
      } else {
        // Pengguna belum login, arahkan ke halaman login
        Navigator.pushReplacementNamed(context, Routenames.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan splash screen atau loading indicator saat memeriksa status
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
      ),
    );
  }
}
