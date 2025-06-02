// lib/screens/product_screen.dart

import 'package:flutter/material.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Halaman ini untuk mengelola produk Anda.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            // TODO: Tambahkan daftar produk dan tombol tambah produk di sini
          ],
        ),
      ),
    );
  }
}
