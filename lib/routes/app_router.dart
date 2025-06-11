// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:artisanhub11/routes/Routenames.dart'; // Impor nama rute Anda

// Impor semua halaman yang akan digunakan dalam routing
import 'package:artisanhub11/pages/auth/login.dart'; // Asumsi Anda punya halaman login
import 'package:artisanhub11/pages/auth/register.dart'; // Asumsi Anda punya halaman register
import 'package:artisanhub11/pages/home.dart'; // Halaman utama
import 'package:artisanhub11/pages/product_screen.dart'; // Halaman produk
import 'package:artisanhub11/pages/events_screen.dart'; // Halaman event
import 'package:artisanhub11/pages/edit_profile_user_screen.dart'; // Halaman edit profil user
import 'package:artisanhub11/pages/about_us_screen.dart'; // Halaman About Us
import 'package:artisanhub11/pages/auth_check_wrapper.dart'; // Halaman wrapper untuk cek otentikasi

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routenames.wrapper:
        return MaterialPageRoute(builder: (_) => const AuthCheckWrapper());
      case Routenames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routenames.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen()); // Ganti dengan halaman register Anda
      case Routenames.home:
        return MaterialPageRoute(builder: (_) => const Homepage());
      // Anda mungkin perlu parameter untuk halaman product, contohnya:
      // case Routenames.product:
      //   final args = settings.arguments as Map<String, dynamic>;
      //   return MaterialPageRoute(builder: (_) => ProductManagementScreen(artisanId: args['artisanId']));
      case Routenames.events:
        return MaterialPageRoute(builder: (_) => const EventsScreen());
      // Untuk editProfileUser, Anda mungkin perlu passing User object
      // case Routenames.editProfileUser:
      //   final args = settings.arguments as User; // Asumsi argumen adalah objek User
      //   return MaterialPageRoute(builder: (_) => EditProfileUserScreen(currentUser: args));
      case Routenames.aboutUs:
        return MaterialPageRoute(builder: (_) => const AboutUsScreen());
      
      // Tambahkan rute default atau error jika rute tidak ditemukan
      default:
        return MaterialPageRoute(builder: (_) => const Text('Error: Unknown route'));
    }
  }
}

// Catatan: Pastikan Anda telah mengimpor semua halaman yang relevan di atas.
// Jika ada halaman seperti RegisterScreen atau EditProfileUserScreen yang membutuhkan argumen,
// Anda perlu menyesuaikan `onGenerateRoute` untuk menangani argumen tersebut (seperti contoh di atas).