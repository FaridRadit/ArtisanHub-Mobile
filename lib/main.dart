import 'package:artisanhub11/pages/auth/login.dart';
import 'package:artisanhub11/pages/auth/register.dart';
import 'package:artisanhub11/pages/auth_check_wrapper.dart';
import 'package:artisanhub11/pages/events_screen.dart';
import 'package:artisanhub11/pages/home.dart';
import 'package:artisanhub11/pages/product_screen.dart';
import 'package:artisanhub11/routes/Routenames.dart';
import 'package:artisanhub11/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:artisanhub11/pages/auth_check_wrapper.dart'; // Import wrapper baru

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Penting untuk shared_preferences
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // initialRoute tidak lagi digunakan di sini, karena AuthCheckWrapper yang akan menentukan rute awal
      home:  AuthCheckWrapper(), // AuthCheckWrapper akan menjadi halaman pertama
      routes: {
        Routenames.home: (context) => const Homepage(),
        Routenames.login: (context) => const LoginScreen(),
        Routenames.register: (context) => const RegisterScreen(),
        Routenames.product: (context) => const ProductScreen(), // Tambahkan rute produk
        Routenames.events: (context) => const EventsScreen(), 
        Routenames.wrapper:(context)=> const AuthCheckWrapper(),
      },
      theme: AppTheme.lightTheme,
    );
  }
}
