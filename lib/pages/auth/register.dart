// lib/screens/auth/register.dart

import 'package:flutter/material.dart';
import '../../services/userService.dart';
import '../../routes/Routenames.dart';
import '../../theme/theme.dart'; // Import your theme

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); 
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController(); 
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _profilePictureUrlController = TextEditingController(); 
  final UserService _userService = UserService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedRole; 

  final List<String> _roles = ['user', 'artisan']; // Available roles

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text;
    final email = _emailController.text; 
    final password = _passwordController.text;
    final fullName = _fullNameController.text.isEmpty ? null : _fullNameController.text;
    final phoneNumber = _phoneNumberController.text.isEmpty ? null : _phoneNumberController.text;
    final profilePictureUrl = _profilePictureUrlController.text.isEmpty ? null : _profilePictureUrlController.text;

    if (email.isEmpty || password.isEmpty || _selectedRole == null) {
      setState(() {
        _errorMessage = 'Username, Password, and Role must be filled.';
        _isLoading = false;
      });
      return;
    }

    try {
      final result = await _userService.registerUser(
        username,
        email, 
        password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        profilePictureUrl: profilePictureUrl,
        role: _selectedRole, 
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful! Please log in.')), // Added const
        );
        Navigator.pop(context); // Go back to login page
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
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
                'assets/images/login_illustration.png', // Ensure this asset is correct for register screen
                height: 300, // Adjust height as needed
              ),
              const SizedBox(height: 32.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Username", style: TextStyle(fontSize: 15, fontFamily: "jakarta-sans")),
                  const SizedBox(height: 13),
                  TextField(
                    controller: _usernameController, // Use _usernameController for this field
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFCACACA),
                      labelText: 'Enter Username / Email....', // Changed to labelText
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none, // Match design, no visible border
                      ),
                      enabledBorder: OutlineInputBorder( // Define enabled border to match design
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder( // Define focused border
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF4300FF), width: 1.5), // Example focus color
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never, // Prevents label from floating
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                    keyboardType: TextInputType.emailAddress, // Or TextInputType.text if username can be just text
                    style: const TextStyle(fontFamily: "jakarta-sans"),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Email", style: TextStyle(fontSize: 15, fontFamily: "jakarta-sans")),
                  const SizedBox(height: 13),
                  TextField(
                    controller: _emailController, // Use _usernameController for this field
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFCACACA),
                      labelText: 'Enter Email....', // Changed to labelText
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none, // Match design, no visible border
                      ),
                      enabledBorder: OutlineInputBorder( // Define enabled border to match design
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder( // Define focused border
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF4300FF), width: 1.5), // Example focus color
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never, // Prevents label from floating
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                    keyboardType: TextInputType.text, // Or TextInputType.text if username can be just text
                    style: const TextStyle(fontFamily: "jakarta-sans"),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Password", style: TextStyle(fontSize: 15, fontFamily: "jakarta-sans")),
                  const SizedBox(height: 13),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFCACACA),
                      labelText: 'Enter Password....', // Changed to labelText
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF4300FF), width: 1.5),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                    obscureText: true,
                    style: const TextStyle(fontFamily: "jakarta-sans"),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Dropdown for Role (Re-added)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Role", style: TextStyle(fontSize: 15, fontFamily: "jakarta-sans")),
                  const SizedBox(height: 13),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFCACACA),
                      labelText: 'Select Role',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF4300FF), width: 1.5),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                    items: _roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(
                          role == 'user' ? 'Regular User' : 'Artisan',
                          style: const TextStyle(fontFamily: "jakarta-sans"),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Please select your role' : null,
                    style: const TextStyle(fontFamily: "jakarta-sans", color: Colors.black), // Ensure text color is visible
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black), // Adjust dropdown icon color
                  ),
                ],
              ),
              const SizedBox(height: 16.0),


              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontFamily: "jakarta-sans"),
                  ),
                ),
              const SizedBox(height: 24.0),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        // The styling for this button should come from AppTheme
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontFamily: "jakarta-sans", fontWeight: FontWeight.bold),
                      ),
                    ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already Have an Account?", style: TextStyle(color: Colors.black, fontSize: 13, fontFamily: "jakarta-sans")),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routenames.login);
                    },
                    child: const Text(
                      'Login Here.',
                      style: TextStyle(color: Color(0xFF4300FF), fontFamily: "jakarta-sans"),
                    ),
                  )
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
    _usernameController.dispose();
    _emailController.dispose(); // Dispose if kept
    _passwordController.dispose();
    _fullNameController.dispose(); // Dispose if kept
    _phoneNumberController.dispose(); // Dispose if kept
    _profilePictureUrlController.dispose(); // Dispose if kept
    super.dispose();
  }
}