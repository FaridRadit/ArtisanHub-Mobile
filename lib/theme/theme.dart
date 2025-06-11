// lib/theme/theme.dart

import 'package:flutter/material.dart';

// Definisi warna kustom Anda
const Color primaryBlue = Color(0xFF2D9CDB);
const Color lightGreyAccent = Color(0xFFE0E0E0); // Contoh abu-abu terang

final ThemeData appTheme = ThemeData(
  useMaterial3: true, // Mengaktifkan Material Design 3
  fontFamily: 'JakartaSans', // Menggunakan font JakartaSans sebagai default
  colorScheme: ColorScheme.light(
    primary: primaryBlue,
    onPrimary: Colors.white,
    secondary: lightGreyAccent,
    onSecondary: Colors.black87,
    surface: Colors.white,
    onSurface: Colors.black87,
    background: const Color(0xFFF5F5F5), // Warna latar belakang yang lebih halus
    onBackground: Colors.black87,
    error: Colors.red,
    onError: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white, // AppBar putih
    foregroundColor: Colors.black87, // Warna teks dan ikon di AppBar
    elevation: 0, // Tanpa bayangan
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'JakartaSans',
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 4, // Bayangan halus
    shadowColor: Colors.grey.withOpacity(0.2), // Warna bayangan yang halus
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16), // Sudut membulat
    ),
    margin: EdgeInsets.zero, // Default margin nol, atur secara manual di widget
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryBlue, // Warna utama tombol
      foregroundColor: Colors.white, // Warna teks tombol
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Sudut membulat
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      elevation: 4, // Bayangan tombol
      shadowColor: primaryBlue.withOpacity(0.3),
      textStyle: const TextStyle(
        fontFamily: 'JakartaSans',
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryBlue, // Warna teks tombol
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Sudut membulat
      ),
      textStyle: const TextStyle(
        fontFamily: 'JakartaSans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white, // Latar belakang TextField putih
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16), // Sudut membulat
      borderSide: BorderSide.none, // Tanpa border
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: primaryBlue, width: 2), // Border fokus biru
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
    labelStyle: TextStyle(
      fontFamily: 'JakartaSans',
      color: Colors.grey[600],
    ),
    hintStyle: TextStyle(
      fontFamily: 'JakartaSans',
      color: Colors.grey[400],
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: primaryBlue,
    unselectedItemColor: Colors.grey[400],
    type: BottomNavigationBarType.fixed,
    elevation: 8, // Bayangan halus
    showSelectedLabels: false,
    showUnselectedLabels: false,
    selectedIconTheme: const IconThemeData(size: 28),
    unselectedIconTheme: const IconThemeData(size: 24),
  ),
  // Tambahkan Box Shadow untuk komponen Container yang mungkin membutuhkan
  extensions: <ThemeExtension<dynamic>>[
    CustomBoxShadowExtension( // Ubah _CustomBoxShadowExtension menjadi CustomBoxShadowExtension
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 4), // Bayangan ke bawah
        ),
      ],
    ),
  ],
);

// Custom ThemeExtension untuk Box Shadow, jika ingin menggunakannya di berbagai tempat
class CustomBoxShadowExtension extends ThemeExtension<CustomBoxShadowExtension> { // Ubah _CustomBoxShadowExtension menjadi CustomBoxShadowExtension
  final List<BoxShadow>? boxShadow;

  const CustomBoxShadowExtension({this.boxShadow});

  @override
  ThemeExtension<CustomBoxShadowExtension> copyWith({List<BoxShadow>? boxShadow}) { // Ubah _CustomBoxShadowExtension menjadi CustomBoxShadowExtension
    return CustomBoxShadowExtension(boxShadow: boxShadow ?? this.boxShadow); // Ubah _CustomBoxShadowExtension menjadi CustomBoxShadowExtension
  }

  @override
  ThemeExtension<CustomBoxShadowExtension> lerp(covariant ThemeExtension<CustomBoxShadowExtension>? other, double t) { // Ubah _CustomBoxShadowExtension menjadi CustomBoxShadowExtension
    if (other is! CustomBoxShadowExtension) { // Ubah _CustomBoxShadowExtension menjadi CustomBoxShadowExtension
      return this;
    }
    return CustomBoxShadowExtension( // Ubah _CustomBoxShadowExtension menjadi CustomBoxShadowExtension
      boxShadow: BoxShadow.lerpList(boxShadow, other.boxShadow, t),
    );
  }
}