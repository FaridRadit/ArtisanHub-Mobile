// lib/screens/edit_profile_user_screen.dart

import 'package:flutter/material.dart';
import '../services/userService.dart'; // Pastikan path benar
import '../model/userModel.dart'; // Pastikan path model User sudah benar

class EditProfileUserScreen extends StatefulWidget {
  final User currentUser; // Menerima data pengguna saat ini

  const EditProfileUserScreen({super.key, required this.currentUser});

  @override
  State<EditProfileUserScreen> createState() => _EditProfileUserScreenState();
}

class _EditProfileUserScreenState extends State<EditProfileUserScreen> {
  final UserService _userService = UserService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _profilePictureUrlController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Untuk mengubah password
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data pengguna saat ini
    _usernameController.text = widget.currentUser.username ?? '';
    _emailController.text = widget.currentUser.email ?? '';
    _fullNameController.text = widget.currentUser.fullName ?? '';
    _phoneNumberController.text = widget.currentUser.phone_number ?? '';
    _profilePictureUrlController.text = widget.currentUser.profile_picture_url ?? '';
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _userService.updateProfile(
        username: _usernameController.text,
        email: _emailController.text,
        fullName: _fullNameController.text,
        phoneNumber: _phoneNumberController.text,
        profilePictureUrl: _profilePictureUrlController.text,
        password: _passwordController.text.isEmpty ? null : _passwordController.text, // Kirim password hanya jika diisi
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        Navigator.pop(context, true); // Kembali ke ProfileScreen dan beri tahu bahwa update berhasil
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
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
      appBar: AppBar(
        title: const Text('Edit Profil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _profilePictureUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Gambar Profil',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password Baru (Isi jika ingin mengubah)',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Simpan Perubahan'),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _profilePictureUrlController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
