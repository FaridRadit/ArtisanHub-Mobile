// lib/screens/events_screen.dart

import 'package:flutter/material.dart';
import '../services/eventService.dart'; // Pastikan path benar
import '../model/eventModel.dart'; // Pastikan path model EventModel sudah benar

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = EventService();
  List<EventModel> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _eventService.getAllEvents();
      if (result['success']) {
        setState(() {
          _events = result['data'];
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal memuat acara.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat acara: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Acara'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEvents,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implementasi navigasi ke halaman tambah acara baru
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur tambah acara belum diimplementasikan.')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _events.isEmpty
                  ? const Center(child: Text('Tidak ada acara yang tersedia.'))
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(event.name ?? 'Nama Acara Tidak Diketahui'),
                            subtitle: Text(
                              '${event.location_name ?? ''} - ${event.start_date?.toLocal().toString().split(' ')[0] ?? ''}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    // TODO: Implementasi edit acara
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Edit acara: ${event.name}')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    // TODO: Implementasi hapus acara
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Konfirmasi Hapus'),
                                        content: Text('Apakah Anda yakin ingin menghapus acara "${event.name}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && event.id != null) {
                                      final deleteResult = await _eventService.deleteEvent(event.id!);
                                      if (deleteResult['success']) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(deleteResult['message'])),
                                        );
                                        _fetchEvents(); // Refresh daftar
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(deleteResult['message'] ?? 'Gagal menghapus acara.')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              // TODO: Implementasi detail acara
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lihat detail acara: ${event.name}')),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
