import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0), // Padding sesuai desain
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/Foto_profile.png', // Pastikan Anda memiliki logo ini di assets
                height: 120,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to ArtisanHub!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: "jakarta-sans",
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ArtisanHub is a platform dedicated to connecting skilled artisans with customers who appreciate unique, handmade products. Our mission is to empower local artisans by providing them with a digital marketplace to showcase their creations and reach a wider audience.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: "jakarta-sans",
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Our Vision',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: "jakarta-sans",
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'To foster a thriving community where creativity flourishes, traditional craftsmanship is celebrated, and sustainable livelihoods are built.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: "jakarta-sans",
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Developer',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: "jakarta-sans",
              ),
            ),
            const SizedBox(height: 8),
            // Example Team Member Card
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farid Radityo Suharman',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: "jakarta-sans",
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '123220094',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontFamily: "jakarta-sans",
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Farid has a passion for traditional crafts and a vision to bring artisans into the digital age.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: "jakarta-sans",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Add more team member cards as needed
            const SizedBox(height: 24),
            Text(
              'Contact Us',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: "jakarta-sans",
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.email, color: Theme.of(context).colorScheme.primary),
              title: Text('info@artisanhub.com', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: "jakarta-sans")),
              onTap: () {
                // Handle email tap
              },
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Theme.of(context).colorScheme.primary),
              title: Text('+123 456 7890', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: "jakarta-sans")),
              onTap: () {
                // Handle phone tap
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '© 2023 ArtisanHub. All rights reserved.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500], fontFamily: "jakarta-sans"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}