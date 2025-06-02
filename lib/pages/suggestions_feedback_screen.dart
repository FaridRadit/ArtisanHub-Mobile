

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Kami sangat menghargai masukan Anda!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Tulis saran atau kesan Anda di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implementasi pengiriman saran/kesan ke backend
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saran/kesan Anda telah dikirim! (Simulasi)')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}
