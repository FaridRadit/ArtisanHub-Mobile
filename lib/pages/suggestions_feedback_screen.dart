// lib/pages/suggestions_feedback_screen.dart

import 'package:flutter/material.dart';
import '../theme/theme.dart'; // Import your custom theme for font consistency

class SuggestionsFeedbackScreen extends StatefulWidget {
  const SuggestionsFeedbackScreen({super.key});

  @override
  State<SuggestionsFeedbackScreen> createState() => _SuggestionsFeedbackScreenState();
}

class _SuggestionsFeedbackScreenState extends State<SuggestionsFeedbackScreen> {
  // FINAL TEKS SARAN DAN KESAN
  final String _kesanMobileProgramming =
      "Mata kuliah Teknologi dan Pemrograman Mobile memberikan pemahaman mendalam tentang pengembangan aplikasi modern, mulai dari konsep dasar hingga implementasi fitur kompleks. Materi yang disampaikan sangat relevan dengan kebutuhan industri saat ini, dan project-based learning membantu kami mengaplikasikan teori secara langsung. Ini adalah fondasi yang kuat untuk karir di bidang pengembangan mobile.";

  final String _kesanUntukPakBagus =
      "Untuk Bapak Bagus, terima kasih atas bimbingan dan pengajaran yang sangat inspiratif. Penjelasan yang jelas, kesabaran dalam menjawab pertanyaan, dan dorongan untuk terus bereksplorasi menjadikan proses belajar sangat menyenangkan dan efektif. Pendekatan pengajaran Bapak yang praktis sangat membantu kami memahami konsep-konsep sulit dengan lebih mudah.";

  final String _saranUmum =
      "Sebagai saran, mungkin bisa ditambahkan sesi lebih lanjut mengenai integrasi dengan layanan cloud pihak ketiga (misalnya Firebase atau AWS Amplify) untuk manajemen database real-time dan otentikasi. Diskusi tentang optimasi performa aplikasi dan praktik terbaik dalam pengujian (testing) juga akan sangat bermanfaat.";

  // State untuk emoji yang dipilih
  String _selectedEmoji = '😐';
  String _selectedEmojiLabel = 'Netral';
  Color _selectedEmojiColor = Colors.yellow; // Warna default untuk netral
  Color _selectedEmojiBorderColor = Colors.yellow; // Warna border default untuk netral

  // Tidak ada lagi _formKey, _subjectController, _messageController karena tidak ada form input
  // Tidak ada lagi _isLoading, _statusMessage, _isSuccess karena tidak ada submit form

  // Method untuk memilih emoji (tetap ada karena terkait visual)
  void _selectEmoji(String emoji, String label, Color emojiColor, Color borderColor) {
    setState(() {
      _selectedEmoji = emoji;
      _selectedEmojiLabel = label;
      _selectedEmojiColor = emojiColor;
      _selectedEmojiBorderColor = borderColor;
    });
  }

  @override
  Widget build(BuildContext context) {

    final customBoxShadow = Theme.of(context).extension<CustomBoxShadowExtension>()?.boxShadow ?? [];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0), // Padding sesuai desain
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60), // Space for the top title

            // "Feedback" Header with three dots
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0), // No extra horizontal padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Umpan Balik',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Dark color for Feedback title
                    ),
                  ),
                  
                ],
              ),
            ),
            const SizedBox(height: 30), // Spacing after Feedback header

            // Rate Experience Section
            Center(
              child: Column(
                children: [
                  Text(
                    'Nilai Pengalaman',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Large Emoji (placeholder for a single selected emoji)
                  Container( // Menggunakan Container untuk bayangan dan border radius
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedEmojiBorderColor.withOpacity(0.2), // Light background based on selection
                      border: Border.all(color: _selectedEmojiBorderColor, width: 2), // Border based on selection
                      boxShadow: customBoxShadow, // Terapkan bayangan kustom
                    ),
                    child: Center(
                      child: Text(
                        _selectedEmoji, // Selected emoji
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Smaller Emoji Options with labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEmojiOption('😡', 'Marah', Colors.red, Colors.red[200]!, _selectedEmoji == '😡'),
                      _buildEmojiOption('😟', 'Kurang', Colors.orange, Colors.orange[200]!, _selectedEmoji == '😟'),
                      _buildEmojiOption('😐', 'Netral', Colors.yellow, Colors.yellow[200]!, _selectedEmoji == '😐'),
                      _buildEmojiOption('😀', 'Senang', Colors.green, Colors.green[200]!, _selectedEmoji == '😀'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Colored Horizontal Bar (representing a rating or progress)
                  Container(
                    height: 8, // Sedikit lebih tebal
                    width: MediaQuery.of(context).size.width * 0.8, // Sesuaikan lebar
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE0E0E0), // Abu-abu terang (default)
                          Color(0xFFBDBDBD), // Abu-abu sedang
                          Color(0xFF9E9E9E), // Abu-abu gelap
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(8), // Sudut membulat
                      boxShadow: customBoxShadow, // Terapkan bayangan kustom
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40), // Spacing before text block

            // === BAGIAN TEKS KESAN DAN SARAN ===
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Sesuaikan alignment
              children: [
                Text(
                  'Kesan tentang Mata Kuliah:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _kesanMobileProgramming,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.justify, // Agar teks rata kanan-kiri
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Kesan untuk Pak Bagus sebagai Dosen:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _kesanUntukPakBagus,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Saran Umum:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _saranUmum,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ],
            ),
            // === AKHIR BAGIAN TEKS KESAN DAN SARAN ===

            const SizedBox(height: 30), // Spacing after text blocks
          ],
        ),
      ),
    );
  }

  // Diperbarui untuk mendukung selected state dan warna border
  Widget _buildEmojiOption(String emoji, String label, Color emojiColor, Color borderColor, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectEmoji(emoji, label, emojiColor, borderColor),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Theme.of(context).colorScheme.secondary.withOpacity(0.5) : Colors.white, // Latar belakang abu-abu terang jika terpilih
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : borderColor, // Biru jika terpilih, kuning/oranye/merah jika tidak
                width: isSelected ? 3 : 2, // Border lebih tebal jika terpilih
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ] : [],
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 30), // Emoji itu sendiri, warna disesuaikan oleh font default
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Tidak ada lagi controller yang perlu didispose karena form dihilangkan
    super.dispose();
  }
}