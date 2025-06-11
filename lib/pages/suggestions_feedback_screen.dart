
import 'package:flutter/material.dart';
import '../theme/theme.dart'; // Import your custom theme for font consistency

class SuggestionsFeedbackScreen extends StatefulWidget {
  const SuggestionsFeedbackScreen({super.key});

  @override
  State<SuggestionsFeedbackScreen> createState() => _SuggestionsFeedbackScreenState();
}

class _SuggestionsFeedbackScreenState extends State<SuggestionsFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String? _feedbackType; // 'Suggestion' or 'Bug Report'

  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;

  // State untuk emoji yang dipilih
  String _selectedEmoji = '😐';
  String _selectedEmojiLabel = 'Netral';
  Color _selectedEmojiColor = Colors.yellow; // Warna default untuk netral
  Color _selectedEmojiBorderColor = Colors.yellow; // Warna border default untuk netral

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      if (_feedbackType == null) {
        setState(() {
          _statusMessage = 'Harap pilih jenis umpan balik.';
          _isSuccess = false;
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _statusMessage = null;
        _isSuccess = false;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _statusMessage = 'Terima kasih atas $_selectedEmojiLabel Anda! Kami menghargai umpan balik Anda.';
        _subjectController.clear();
        _messageController.clear();
        _feedbackType = null;
        _selectedEmoji = '😐'; // Reset emoji
        _selectedEmojiLabel = 'Netral';
        _selectedEmojiColor = Colors.yellow;
        _selectedEmojiBorderColor = Colors.yellow;
      });

      // Optionally show a SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Umpan balik berhasil dikirim!', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white))),
        );
      }
    }
  }

  // Method untuk memilih emoji
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
    // Ambil custom boxShadow dari tema
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
                    'Umpan Balik', // Change to Bahasa Indonesia
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Dark color for Feedback title
                      // fontFamily sudah diatur di tema utama
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    color: Colors.grey,
                    onPressed: () {
                      // Handle menu icon tap
                      print('Feedback menu tapped');
                    },
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
                    'Nilai Pengalaman', // Change to Bahasa Indonesia
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                      // fontFamily sudah diatur di tema utama
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
                        style: const TextStyle(fontSize: 60), // Emoji itself
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

            // Lorem Ipsum Text Block
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0), // Disesuaikan padding
              child: Text(
                'Masukan Anda sangat berharga bagi kami. Kami berkomitmen untuk terus meningkatkan kualitas layanan. Silakan bagikan pengalaman Anda dengan kami.', // Bahasa Indonesia
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                  // fontFamily sudah diatur di tema utama
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30), // Spacing before form fields

          
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
              // fontFamily sudah diatur di tema utama
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}