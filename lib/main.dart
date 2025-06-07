import 'package:artisanhub11/pages/auth/login.dart';
import 'package:artisanhub11/pages/auth/register.dart';
import 'package:artisanhub11/pages/auth_check_wrapper.dart';
import 'package:artisanhub11/pages/events_screen.dart';
import 'package:artisanhub11/pages/home.dart';
import 'package:artisanhub11/pages/product_screen.dart';
import 'package:artisanhub11/routes/Routenames.dart';
import 'package:artisanhub11/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:artisanhub11/pages/auth_check_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      home:  AuthCheckWrapper(),
      routes: {
        Routenames.home: (context) => const Homepage(),
        Routenames.login: (context) => const LoginScreen(),
        Routenames.register: (context) => const RegisterScreen(),
        Routenames.product: (context) => const ProductScreen(), 
        Routenames.events: (context) => const EventsScreen(), 
        Routenames.wrapper:(context)=> const AuthCheckWrapper(),
      },
      theme: AppTheme.lightTheme,
    );
  }
}
