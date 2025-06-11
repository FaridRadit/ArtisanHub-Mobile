
import 'package:flutter/material.dart';
import '../theme/theme.dart'; 

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Developer', // Changed title to "About Developer"
          style: TextStyle(
            color: Colors.black,
            fontFamily: "jakarta-sans",
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
       
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center the content
          children: [
            const SizedBox(height: 20),
            // Developer's Photo
            CircleAvatar(
              radius: 70,
              backgroundImage: AssetImage('assets/images/Foto_profile.png'), // Replace with your image asset path
              backgroundColor: Colors.grey[200], // Placeholder background
            ),
            const SizedBox(height: 30),
            // Developer's Name
            Text(
              'Farid Radityo Suharman', // Your Name
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "jakarta-sans",
              ),
            ),
            const SizedBox(height: 10),
            // Developer's NIM
            Text(
              'NIM: 123220094', // Your NIM
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontFamily: "jakarta-sans",
              ),
            ),
            const SizedBox(height: 10),
            // Developer's Class
            Text(
              'Kelas: H', // Your Class
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontFamily: "jakarta-sans",
              ),
            ),
            const SizedBox(height: 40),
            // Optional: Add a brief description or motto
            Text(
              'This application was developed as a final project for Mobile Programming course. Aiming to connect artisans with customers and promote local craftsmanship.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: "jakarta-sans",
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}