

import 'package:flutter/material.dart';

class SuggestionsFeedbackScreen extends StatelessWidget {
  const SuggestionsFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saran & Kesan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            const Text(
              'Kesan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

          
            const SizedBox(height: 16),

            _buildFeedbackCard(
              context,
              'Anonim',
              'Kelas ini membuka wawasan saya tentang pengembangan aplikasi mobile. Dosen sangat interaktif dan selalu siap membantu. Sangat direkomendasikan untuk siapa saja yang ingin belajar Flutter!',
              'Teknologi Pemrograman Mobile',
            ),
            const SizedBox(height: 16),

           
            _buildFeedbackCard(
              context,
              'Anonim',
              'Awalnya saya kesulitan, tapi dengan bimbingan di kelas, saya jadi lebih percaya diri. Proyek akhir sangat menantang tapi rewarding. Pengalaman belajar yang luar biasa!',
              'Teknologi Pemrograman Mobile',
            ),
            const SizedBox(height: 16),

           
            _buildFeedbackCard(
              context,
              '....',
              'Saran: Mungkin bisa ditambahkan sesi khusus tentang deployment aplikasi ke Play Store/App Store agar lebih lengkap.',
              'Saran untuk Kelas',
              isSuggestion: true,
            ),
            const SizedBox(height: 16),

           
          
         

           
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(
      BuildContext context,
      String author,
      String content,
      String category, {
        bool isSuggestion = false,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSuggestion ? Icons.lightbulb_outline : Icons.rate_review,
                  color: isSuggestion ? Colors.orange : Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isSuggestion ? 'Saran dari $author' : 'Kesan dari $author',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '- $category',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
