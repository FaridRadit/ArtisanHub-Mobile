// lib/screens/auth/login.dart

import 'package:flutter/material.dart';
import '../../services/userService.dart';
import '../../services/auth_manager.dart';
import '../../routes/Routenames.dart';
import '../../theme/theme.dart'; // Import your theme

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService();
  bool _isLoading = false;
  String? _errorMessage; // This is a nullable string

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan password harus diisi.'; // Assign a non-null string
        _isLoading = false;
      });
      return;
    }

    try {
      final result = await _userService.loginUser(email, password);

      if (result['success']) {
        // Login berhasil, navigasi ke Homepage dan hapus rute sebelumnya
        Navigator.pushReplacementNamed(context, Routenames.home);
      } else {
        setState(() {
          // Ensure result['message'] is handled even if it's null from the API
          _errorMessage = result['message'] ?? 'Login gagal. Pesan tidak tersedia.'; // Provide a fallback string
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}'; // Convert error object to string
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add your illustration here
              Image.asset(
                'assets/images/login_illustration.png',
                height: 300,
              ),
              const SizedBox(height: 32.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text("Username/Email",style: TextStyle(fontSize: 15),),
                  const SizedBox(height: 13,),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFCACACA),
                      labelText: 'Enter Username / Email....',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,

                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontFamily: "jakarta-sans"),
                  ),
                ],
              ),

              const SizedBox(height: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Password",style: TextStyle(fontSize: 15),),
                  const SizedBox(height: 13,),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFCACACA),
                      labelText: 'Enter Password....',
                      // prefixIcon: Icon(Icons.lock), // Design doesn't show icon
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                    obscureText: true,
                  ),
                ],
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!, // This is now safer because _errorMessage is always a String if not null
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        // The styling for this button should come from AppTheme
                      ),
                      child: const Text('Login'),
                    ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't Have An Account?",style: TextStyle(color: Colors.black,fontSize: 13),),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routenames.register);
                    },
                    child: const Text('Register Here.',style: TextStyle(color: Color(0xFF4300FF),fontFamily: 'jakarta-sans'),
                    ),)
                ],
              )

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}