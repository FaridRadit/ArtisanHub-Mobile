// lib/pages/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart'; // Import tema kustom Anda

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'IDR';
  String _toCurrency = 'USD';
  double _convertedAmount = 0.0;

  final Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'IDR': 15500.0,
    'EUR': 0.92,
    'JPY': 155.0,
  };

  void _convertCurrency() {
    final double? amount = double.tryParse(_amountController.text.replaceAll(',', '.')); // Handle comma as decimal
    if (amount == null || amount <= 0) {
      setState(() {
        _convertedAmount = 0.0;
      });
      return;
    }

    // Konversi ke USD dulu
    final double amountInUsd = amount / (_exchangeRates[_fromCurrency] ?? 1.0); // Handle null safety
    // Lalu konversi ke mata uang tujuan
    final double finalAmount = amountInUsd * (_exchangeRates[_toCurrency] ?? 1.0); // Handle null safety

    setState(() {
      _convertedAmount = finalAmount;
    });
  }

  // --- Konversi Waktu ---
  DateTime _currentTime = DateTime.now();
  // Timer untuk memperbarui waktu
  late final Future<void> _timeUpdater; // Menggunakan Future agar bisa di-await jika perlu

  @override
  void initState() {
    super.initState();
    // Mendengarkan perubahan pada input mata uang
    _amountController.addListener(_convertCurrency);
    // Memperbarui waktu setiap detik
    _timeUpdater = _updateTimePeriodically(); // Memulai pembaruan waktu
  }

  Future<void> _updateTimePeriodically() async {
    while (mounted) { // Pastikan widget masih ada
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    }
  }

  String _formatTime(DateTime dateTime, Duration offset, String timezoneName) {
    // Menggunakan toLocal() dan kemudian menyesuaikan offset
    // Untuk format yang lebih baik, pertimbangkan package 'timezone'
    final targetTime = dateTime.toUtc().add(offset);
    return '$timezoneName: ${DateFormat('HH:mm:ss').format(targetTime)}';
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'IDR': return 'Rp';
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'JPY': return '¥';
      default: return '';
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_convertCurrency); // Penting: Hapus listener
    _amountController.dispose();
    // Tidak perlu secara eksplisit membatalkan Future _timeUpdater
    // karena sudah menggunakan `mounted` di dalam loop.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil custom boxShadow dari tema
    final customBoxShadow = Theme.of(context).extension<CustomBoxShadowExtension>()?.boxShadow ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        automaticallyImplyLeading: false,
        // Style sudah diatur di tema utama
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0), // Padding sesuai desain
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian Konversi Mata Uang ---
            Text(
              'Konversi Mata Uang',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              margin: EdgeInsets.zero, // Hilangkan margin default
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Jumlah',
                        hintText: 'Masukkan jumlah',
                        // Style dari InputDecorationTheme
                      ),
                      style: Theme.of(context).textTheme.bodyLarge, // Style teks input
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _fromCurrency,
                            decoration: InputDecoration(
                              labelText: 'Dari',
                              // Style dari InputDecorationTheme
                            ),
                            items: _exchangeRates.keys.map((String currency) {
                              return DropdownMenuItem<String>(
                                value: currency,
                                child: Text(currency, style: Theme.of(context).textTheme.bodyLarge),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _fromCurrency = newValue!;
                                _convertCurrency();
                              });
                            },
                            dropdownColor: Theme.of(context).colorScheme.surface, // Warna dropdown background
                            style: Theme.of(context).textTheme.bodyLarge, // Style teks dropdown
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.arrow_right_alt, color: Theme.of(context).colorScheme.primary, size: 32), // Ikon panah
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _toCurrency,
                            decoration: InputDecoration(
                              labelText: 'Ke',
                            ),
                            items: _exchangeRates.keys.map((String currency) {
                              return DropdownMenuItem<String>(
                                value: currency,
                                child: Text(currency, style: Theme.of(context).textTheme.bodyLarge),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _toCurrency = newValue!;
                                _convertCurrency();
                              });
                            },
                            dropdownColor: Theme.of(context).colorScheme.surface, // Warna dropdown background
                            style: Theme.of(context).textTheme.bodyLarge, // Style teks dropdown
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Hasil Konversi: ${_getCurrencySymbol(_toCurrency)} ${NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 2).format(_convertedAmount)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary, // Warna biru
                        // fontFamily sudah diatur di tema utama
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 40, thickness: 1, color: Color(0xFFE0E0E0)), // Divider halus

            // --- Bagian Konversi Waktu ---
            Text(
              'Waktu Berbagai Zona Waktu',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                // fontFamily sudah diatur di tema utama
              ),
            ),
            const SizedBox(height: 20),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimezoneRow(context, _currentTime, const Duration(hours: 7), 'WIB (Jakarta)'), // UTC+7
                    _buildTimezoneRow(context, _currentTime, const Duration(hours: 8), 'WITA (Bali)'), // UTC+8
                    _buildTimezoneRow(context, _currentTime, const Duration(hours: 9), 'WIT (Jayapura)'), // UTC+9
                    const Divider(height: 24, thickness: 1, color: Colors.grey),
                    _buildTimezoneRow(context, _currentTime, const Duration(hours: 0), 'London (GMT)'), // UTC+0
                    _buildTimezoneRow(context, _currentTime, const Duration(hours: -5), 'New York (EST)'), // UTC-5
                    _buildTimezoneRow(context, _currentTime, const Duration(hours: 9), 'Tokyo (JST)'), // UTC+9 (same as WIT)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20), // Spacing di bawah
          ],
        ),
      ),
    );
  }

  Widget _buildTimezoneRow(BuildContext context, DateTime currentTime, Duration offset, String timezoneName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _formatTime(currentTime, offset, timezoneName),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}