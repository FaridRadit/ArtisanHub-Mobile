// lib/screens/homepage.dart

import 'package:artisanhub11/pages/auth/login.dart';
import 'package:artisanhub11/pages/events_screen.dart';
import 'package:artisanhub11/pages/profile_screen.dart';
import 'package:artisanhub11/pages/settings_screen.dart';
import 'package:artisanhub11/pages/suggestions_feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Import flutter_map
import 'package:latlong2/latlong.dart'; // Import latlong2
import '../services/auth_manager.dart';
import '../routes/Routenames.dart'; // Import Routenames

import '../services/artisanService.dart'; // Import ArtisanService
import '../model/artisanModel.dart'; // Import model artisan
import '../model/userModel.dart'; // Pastikan model User juga diimpor di sini, karena artisan menggunakannya

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  String? _userRole; // Untuk menyimpan peran pengguna

  // Daftar semua widget (halaman) yang mungkin
  late List<Widget> _allWidgetOptions;
  late List<BottomNavigationBarItem> _allBottomNavBarItems;

  // Daftar widget dan item nav bar yang akan ditampilkan berdasarkan role
  List<Widget> _currentWidgetOptions = [];
  List<BottomNavigationBarItem> _currentBottomNavBarItems = [];

  @override
  void initState() {
    super.initState();
    _initializeHomepage();
  }

  Future<void> _initializeHomepage() async {
    _userRole = await AuthManager.getUserRole();
    _buildNavigationItems(); // Panggil fungsi untuk membangun item navigasi setelah role didapat
    setState(() {}); // Perbarui UI setelah role dan item navigasi dimuat
  }

  void _buildNavigationItems() {
    // Inisialisasi semua kemungkinan item navigasi (BottomNavigationBarItem)
    _allBottomNavBarItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Beranda',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profil',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.feedback),
        label: 'Saran',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Pengaturan',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.event), // Hanya untuk admin
        label: 'Acara',
      ),
    ];

    // Inisialisasi semua kemungkinan halaman (Widget)
    _allWidgetOptions = <Widget>[
      // Halaman Beranda (dengan peta interaktif dan pencarian)
      _HomeContent(userRole: _userRole), // Mengirim role ke _HomeContent
      const ProfileScreen(),
      const SuggestionsFeedbackScreen(),
      const SettingsScreen(),
      const EventsScreen(), // Hanya untuk admin
    ];

    // Kosongkan list yang akan digunakan saat ini
    _currentWidgetOptions = [];
    _currentBottomNavBarItems = [];

    // Tambahkan item yang umum untuk semua role
    _currentWidgetOptions.add(_allWidgetOptions[0]); // Beranda (Widget)
    _currentBottomNavBarItems.add(_allBottomNavBarItems[0]); // Beranda (BottomNavigationBarItem)

    _currentWidgetOptions.add(_allWidgetOptions[1]); // Profil (Widget)
    _currentBottomNavBarItems.add(_allBottomNavBarItems[1]); // Profil (BottomNavigationBarItem)

    _currentWidgetOptions.add(_allWidgetOptions[2]); // Saran (Widget)
    _currentBottomNavBarItems.add(_allBottomNavBarItems[2]); // Saran (BottomNavigationBarItem)

    _currentWidgetOptions.add(_allWidgetOptions[3]); // Pengaturan (Widget)
    _currentBottomNavBarItems.add(_allBottomNavBarItems[3]); // Pengaturan (BottomNavigationBarItem)

    // Tambahkan item khusus admin jika role adalah 'admin'
    if (_userRole == 'admin') {
      _currentWidgetOptions.add(_allWidgetOptions[4]); // Acara (Widget)
      _currentBottomNavBarItems.add(_allBottomNavBarItems[4]); // Acara (BottomNavigationBarItem)
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan CircularProgressIndicator jika role belum dimuat
    if (_userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("ArtisanHub"),
        backgroundColor: Colors.blue, // Contoh warna AppBar
        foregroundColor: Colors.white, // Warna teks AppBar
        actions: [
          // Tombol Logout di AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthManager.clearAuthData();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Anda telah logout.')),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _currentWidgetOptions, // Ini harus List<Widget>
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _currentBottomNavBarItems, // Ini harus List<BottomNavigationBarItem>
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Penting untuk lebih dari 3 item
      ),
    );
  }
}

// Widget terpisah untuk konten halaman Beranda
class _HomeContent extends StatefulWidget {
  final String? userRole;

  const _HomeContent({required this.userRole});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  // Posisi awal marker (contoh: Yogyakarta)
  LatLng _markerLocation = const LatLng(-7.7956, 110.3695);
  final ArtisanService _artisanService = ArtisanService(); // Instance ArtisanService
  final MapController _mapController = MapController(); // Controller untuk mengontrol peta

  // Controllers untuk input di dialog (untuk artisan profile creation)
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _expertiseCategoryController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _websiteUrlController = TextEditingController();

  // Controllers dan state untuk pencarian artisan
  final TextEditingController _searchController = TextEditingController();
  List<artisan> _foundArtisans = [];
  bool _isSearchingArtisans = false;
  String? _artisanSearchErrorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged); // Dengarkan perubahan pada search bar
    _searchArtisans(); // Lakukan pencarian awal saat halaman dimuat
  }

  // Method untuk menampilkan dialog profil pengrajin (untuk create/edit)
  Future<void> _showCreateArtisanProfileDialog() async {
    // Reset controllers setiap kali dialog dibuka
    _bioController.clear();
    _expertiseCategoryController.clear();
    _addressController.clear();
    _contactEmailController.clear();
    _contactPhoneController.clear();
    _websiteUrlController.clear();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext dialogContext) {
        bool isLoading = false;
        String? dialogErrorMessage;

        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text('Buat Profil Pengrajin'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Lokasi: Lat ${_markerLocation.latitude.toStringAsFixed(4)}, Lon ${_markerLocation.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: 'Bio (Opsional)', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _expertiseCategoryController,
                      decoration: const InputDecoration(labelText: 'Kategori Keahlian*', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Alamat*', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contactEmailController,
                      decoration: const InputDecoration(labelText: 'Email Kontak (Opsional)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contactPhoneController,
                      decoration: const InputDecoration(labelText: 'Telepon Kontak (Opsional)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _websiteUrlController,
                      decoration: const InputDecoration(labelText: 'URL Website (Opsional)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    if (dialogErrorMessage != null)
                      Text(
                        dialogErrorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 16),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              setStateInDialog(() {
                                isLoading = true;
                                dialogErrorMessage = null;
                              });

                              // Validasi input
                              if (_expertiseCategoryController.text.isEmpty || _addressController.text.isEmpty) {
                                setStateInDialog(() {
                                  dialogErrorMessage = 'Kategori Keahlian dan Alamat wajib diisi.';
                                  isLoading = false;
                                });
                                return;
                              }

                              try {
                                final result = await _artisanService.createArtisanProfile(
                                  bio: _bioController.text.isEmpty ? null : _bioController.text,
                                  expertiseCategory: _expertiseCategoryController.text,
                                  address: _addressController.text,
                                  latitude: _markerLocation.latitude,
                                  longitude: _markerLocation.longitude,
                                  contactEmail: _contactEmailController.text.isEmpty ? null : _contactEmailController.text,
                                  contactPhone: _contactPhoneController.text.isEmpty ? null : _contactPhoneController.text,
                                  websiteUrl: _websiteUrlController.text.isEmpty ? null : _websiteUrlController.text,
                                );

                                if (result['success']) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result['message'])),
                                  );
                                  Navigator.of(dialogContext).pop(); // Tutup dialog
                                } else {
                                  setStateInDialog(() {
                                    dialogErrorMessage = result['message'] ?? 'Gagal membuat profil.';
                                  });
                                }
                              } catch (e) {
                                setStateInDialog(() {
                                  dialogErrorMessage = 'Error API: $e';
                                });
                              } finally {
                                setStateInDialog(() {
                                  isLoading = false;
                                });
                              }
                            },
                            child: const Text('Buat Profil'),
                          ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Tutup dialog
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method untuk menampilkan dialog detail pengrajin
  Future<void> _showArtisanDetailDialog(artisan selectedArtisan) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text(selectedArtisan.user?.full_name ?? selectedArtisan.user?.username ?? 'Detail Pengrajin'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bio: ${selectedArtisan.bio ?? '-'}'),
                Text('Kategori: ${selectedArtisan.expertise_category ?? '-'}'),
                Text('Alamat: ${selectedArtisan.address ?? '-'}'),
                Text('Email: ${selectedArtisan.contact_email ?? '-'}'),
                Text('Telepon: ${selectedArtisan.contact_phone ?? '-'}'),
                Text('Website: ${selectedArtisan.website_url ?? '-'}'),
                Text('Rating: ${selectedArtisan.avg_rating?.toStringAsFixed(1) ?? '-'}'),
                Text('Ulasan: ${selectedArtisan.total_reviews ?? '-'}'),
                Text('Terverifikasi: ${selectedArtisan.is_verified == true ? 'Ya' : 'Tidak'}'),
                Text('Lat: ${selectedArtisan.latitude?.toStringAsFixed(4) ?? '-'}, Lon: ${selectedArtisan.longitude?.toStringAsFixed(4) ?? '-'}'),
                // Tambahkan detail lain yang relevan
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method untuk melakukan pencarian artisan
  Future<void> _searchArtisans({String? query}) async {
    setState(() {
      _isSearchingArtisans = true;
      _artisanSearchErrorMessage = null;
    });

    try {
      // Anda bisa menambahkan lat/lon/radius di sini jika ingin pencarian berbasis lokasi
      final result = await _artisanService.getAllArtisans(q: query);
      if (result['success']) {
        setState(() {
          _foundArtisans = result['data'];
        });
      } else {
        setState(() {
          _artisanSearchErrorMessage = result['message'] ?? 'Gagal mencari pengrajin.';
          _foundArtisans = []; // Kosongkan daftar jika gagal
        });
      }
    } catch (e) {
      setState(() {
        _artisanSearchErrorMessage = 'Terjadi kesalahan saat mencari: $e';
        _foundArtisans = [];
      });
    } finally {
      setState(() {
        _isSearchingArtisans = false;
      });
    }
  }

  // Callback saat teks pencarian berubah
  void _onSearchChanged() {
    // Implementasi debounce jika ingin menghindari terlalu banyak panggilan API
    // Untuk kesederhanaan, kita panggil langsung
    _searchArtisans(query: _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Selamat Datang di Artisan Hub!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Anda login sebagai: ${widget.userRole ?? 'Tidak Diketahui'}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Lokasi Terpilih: Lat ${_markerLocation.latitude.toStringAsFixed(4)}, Lon ${_markerLocation.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              // Tambahkan tombol untuk memicu dialog secara manual (opsional)
              if (widget.userRole == 'artisan')
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                    onPressed: _showCreateArtisanProfileDialog,
                    child: const Text('Buat/Edit Profil Pengrajin di Lokasi Ini'),
                  ),
                ),
            ],
          ),
        ),
        // Peta (mengambil 2/4 dari sisa ruang)
        Expanded(
          flex: 1, // Mengambil 1 bagian dari 2 (setengah)
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlutterMap(
              mapController: _mapController, // Kaitkan mapController
              options: MapOptions(
                initialCenter: _markerLocation, // Gunakan posisi marker sebagai pusat awal
                initialZoom: 13.0,
                onTap: (tapPosition, latlng) async {
                  // Ketika peta diketuk, perbarui posisi marker
                  setState(() {
                    _markerLocation = latlng;
                  });

                  // Jika role adalah artisan, tampilkan dialog
                  if (widget.userRole == 'artisan') {
                    // Beri sedikit jeda agar marker sempat pindah sebelum dialog muncul
                    await Future.delayed(const Duration(milliseconds: 100));
                    _showCreateArtisanProfileDialog();
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.artisanhub11', // Ganti dengan package name aplikasi Anda
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _markerLocation, // Marker akan mengikuti _markerLocation
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Bagian Pencarian dan Daftar Artisan (mengambil 2/4 dari sisa ruang)
        Expanded(
          flex: 1, // Mengambil 1 bagian dari 2 (setengah)
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Cari Pengrajin (nama/deskripsi)',
                    suffixIcon: Icon(Icons.search),
                    // border: OutlineInputBorder(), // Sudah diatur di AppTheme
                  ),
                ),
                const SizedBox(height: 8),
                _isSearchingArtisans
                    ? const LinearProgressIndicator() // Indikator loading
                    : _artisanSearchErrorMessage != null
                        ? Text(
                            _artisanSearchErrorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          )
                        : Expanded(
                            child: _foundArtisans.isEmpty
                                ? const Center(child: Text('Tidak ada pengrajin ditemukan.'))
                                : ListView.builder(
                                    itemCount: _foundArtisans.length,
                                    itemBuilder: (context, index) {
                                      final artisan = _foundArtisans[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        child: ListTile(
                                          // leading: artisan.user?.profile_picture_url != null && artisan.user!.profile_picture_url!.isNotEmpty
                                          //     ? CircleAvatar(
                                          //         backgroundImage: NetworkImage(artisan.user!.profile_picture_url!),
                                          //       )
                                          //     : const CircleAvatar(
                                          //         child: Icon(Icons.person),
                                          //       ),
                                          // title: Text(artisan.user?.full_name ?? artisan.user?.username ?? 'Pengrajin Tanpa Nama'),
                                          subtitle: Text(artisan.expertise_category ?? 'Tanpa Kategori'),
                                          onTap: () {
                                            // Pindahkan marker ke lokasi artisan
                                            setState(() {
                                              _markerLocation = LatLng(artisan.latitude!, artisan.longitude!);
                                            });
                                            // Animasikan peta ke lokasi baru
                                            _mapController.move(
                                                LatLng(artisan.latitude!, artisan.longitude!),
                                                _mapController.camera.zoom);
                                            // Tampilkan popup detail artisan
                                            _showArtisanDetailDialog(artisan);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    _expertiseCategoryController.dispose();
    _addressController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _websiteUrlController.dispose();
    _searchController.dispose(); // Jangan lupa dispose search controller
    super.dispose();
  }
}
