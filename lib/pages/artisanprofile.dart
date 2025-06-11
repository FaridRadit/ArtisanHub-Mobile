import 'package:flutter/material.dart';
import '../model/artisanModel.dart';
import '../theme/theme.dart'; 

class ArtisanProfileDetailScreen extends StatelessWidget {
  final artisan artisanProfile; // Profil artisan yang akan ditampilkan

  const ArtisanProfileDetailScreen({super.key, required this.artisanProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Profil Pengrajin',
          style: TextStyle(
            color: Colors.black, // Warna teks gelap untuk judul app bar
            fontFamily: "jakarta-sans", // Terapkan font kustom
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Latar belakang transparan
        elevation: 0, // Tanpa bayangan
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama Pengguna / Nama Lengkap
            Text(
              artisanProfile.user?.fullName ?? artisanProfile.user?.username ?? 'Pengrajin Tanpa Nama',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "jakarta-sans",
              ),
            ),
            const SizedBox(height: 8),

            // Kategori Keahlian
            _buildDetailRow(
              icon: Icons.category_outlined,
              label: 'Kategori Keahlian',
              value: artisanProfile.expertise_category ?? 'Tidak Tersedia',
            ),
            _buildDetailRow(
              icon: Icons.info_outline,
              label: 'Bio',
              value: artisanProfile.bio ?? 'Tidak Tersedia',
            ),
            _buildDetailRow(
              icon: Icons.location_on_outlined,
              label: 'Alamat',
              value: artisanProfile.address ?? 'Tidak Tersedia',
            ),
            _buildDetailRow(
              icon: Icons.email_outlined,
              label: 'Email Kontak',
              value: artisanProfile.contact_email ?? 'Tidak Tersedia',
            ),
            _buildDetailRow(
              icon: Icons.phone_outlined,
              label: 'Telepon Kontak',
              value: artisanProfile.contact_phone ?? 'Tidak Tersedia',
            ),
            _buildDetailRow(
              icon: Icons.public_outlined,
              label: 'Situs Web',
              value: artisanProfile.website_url ?? 'Tidak Tersedia',
            ),
            _buildDetailRow(
              icon: Icons.star_outline,
              label: 'Peringkat Rata-rata',
              value: artisanProfile.avg_rating?.toStringAsFixed(1) ?? 'Tidak Tersedia',
            ),
            _buildDetailRow(
              icon: Icons.reviews_outlined,
              label: 'Total Ulasan',
              value: artisanProfile.total_reviews?.toString() ?? 'Tidak Tersedia',
            ),
            _buildDetailRow(
              icon: Icons.verified_user_outlined,
              label: 'Terverifikasi',
              value: artisanProfile.is_verified == true ? 'Ya' : 'Tidak',
            ),
            const SizedBox(height: 16),
            // Operational Hours
            Text(
              'Jam Operasional:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: "jakarta-sans",
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            if (artisanProfile.operational_hours != null && artisanProfile.operational_hours!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: artisanProfile.operational_hours!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "jakarta-sans",
                        color: Colors.grey[700],
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Text(
                'Tidak Tersedia',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "jakarta-sans",
                  color: Colors.grey[700],
                ),
              ),

            const SizedBox(height: 16),
            // Social Media Links
            Text(
              'Tautan Media Sosial:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: "jakarta-sans",
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            if (artisanProfile.social_media_links != null && artisanProfile.social_media_links!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: artisanProfile.social_media_links!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "jakarta-sans",
                        color: Colors.grey[700],
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Text(
                'Tidak Tersedia',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "jakarta-sans",
                  color: Colors.grey[700],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk baris detail
  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontFamily: "jakarta-sans",
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: "jakarta-sans",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
