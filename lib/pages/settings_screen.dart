// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk NumberFormat dan DateFormat

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- Konversi Mata Uang ---
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'IDR';
  String _toCurrency = 'USD';
  double _convertedAmount = 0.0;

  // Nilai tukar relatif terhadap 1 USD
  final Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'IDR': 15500.0, // 1 USD = 15500 IDR (contoh)
    'EUR': 0.92,    // 1 USD = 0.92 EUR (contoh)
    'JPY': 155.0,   // 1 USD = 155 JPY (contoh)
  };

  void _convertCurrency() {
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _convertedAmount = 0.0;
      });
      return;
    }

    // Konversi ke USD dulu
    final double amountInUsd = amount / _exchangeRates[_fromCurrency]!;
    // Lalu konversi ke mata uang tujuan
    final double finalAmount = amountInUsd * _exchangeRates[_toCurrency]!;

    setState(() {
      _convertedAmount = finalAmount;
    });
  }

  // --- Konversi Waktu ---
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Mendengarkan perubahan pada input mata uang
    _amountController.addListener(_convertCurrency);
    // Memperbarui waktu setiap detik
    _updateTime();
  }

  void _updateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
        _updateTime(); // Rekursif untuk update terus-menerus
      }
    });
  }

  String _formatTime(DateTime dateTime, Duration offset, String timezoneName) {
    final targetTime = dateTime.toUtc().add(offset);
    return '$timezoneName: ${DateFormat('HH:mm:ss').format(targetTime)}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian Konversi Mata Uang ---
            const Text(
              'Konversi Mata Uang',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fromCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Dari',
                      border: OutlineInputBorder(),
                    ),
                    items: _exchangeRates.keys.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _fromCurrency = newValue!;
                        _convertCurrency();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.arrow_right_alt),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _toCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Ke',
                      border: OutlineInputBorder(),
                    ),
                    items: _exchangeRates.keys.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _toCurrency = newValue!;
                        _convertCurrency();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Hasil Konversi: ${NumberFormat.currency(symbol: _toCurrency == 'IDR' ? 'Rp' : (_toCurrency == 'USD' ? '\$' : (_toCurrency == 'EUR' ? '€' : '¥')), decimalDigits: 2).format(_convertedAmount)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 40, thickness: 2),

            // --- Bagian Konversi Waktu ---
            const Text(
              'Waktu Saat Ini',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _formatTime(_currentTime, const Duration(hours: 7), 'WIB'), // UTC+7
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(_currentTime, const Duration(hours: 8), 'WITA'), // UTC+8
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(_currentTime, const Duration(hours: 9), 'WIT'), // UTC+9
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(_currentTime, const Duration(hours: 0), 'London (GMT)'), // UTC+0
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
