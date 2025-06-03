
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; 
import '../services/auth_manager.dart';
import '../routes/Routenames.dart'; 

import './auth/login.dart';
import './events_screen.dart';
import './profile_screen.dart';
import './settings_screen.dart';
import './suggestions_feedback_screen.dart';

import '../services/artisanService.dart'; 
import '../model/artisanModel.dart'; 
import '../model/userModel.dart'; 

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
    _buildNavigationItems(); 
    setState(() {}); 
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
    
    if (_userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("ArtisanHub"),
        
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
        children: _currentWidgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _currentBottomNavBarItems, 
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 10, 
      ),
    );
  }
}


class _HomeContent extends StatefulWidget {
  final String? userRole;

  const _HomeContent({required this.userRole});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  LatLng _markerLocation = const LatLng(-7.7956, 110.3695);
  final ArtisanService _artisanService = ArtisanService();
  final MapController _mapController = MapController(); 
  artisan? _currentArtisanProfile;
  bool _isLoadingArtisanProfile = false;


  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _expertiseCategoryController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _websiteUrlController = TextEditingController();

  // Controllers dan state untuk pencarian artisan
  final TextEditingController _searchController = TextEditingController();
  List<artisan> _foundArtisans = []; 
  List<artisan> _allArtisansForMap = []; 
  bool _isSearchingArtisans = false;
  String? _artisanSearchErrorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged); 
    _fetchAllArtisansForMapAndList();
    if (widget.userRole == 'artisan') {
      _fetchCurrentArtisanProfile();
    }
  }

  // Method untuk mengambil semua artisan untuk peta dan daftar pencarian awal
  Future<void> _fetchAllArtisansForMapAndList() async {
    setState(() {
      _isSearchingArtisans = true;
      _artisanSearchErrorMessage = null;
    });

    try {
      final result = await _artisanService.getAllArtisans();
      if (result['success']) {
        setState(() {
          _allArtisansForMap = result['data'];
          _foundArtisans = result['data']; // Awalnya, daftar pencarian sama dengan semua artisan
        });
      } else {
        setState(() {
          _artisanSearchErrorMessage = result['message'] ?? 'Gagal memuat pengrajin.';
          _allArtisansForMap = [];
          _foundArtisans = [];
        });
      }
    } catch (e) {
      setState(() {
        _artisanSearchErrorMessage = 'Terjadi kesalahan saat memuat pengrajin: $e';
        _allArtisansForMap = [];
        _foundArtisans = [];
      });
    } finally {
      setState(() {
        _isSearchingArtisans = false;
      });
    }
  }

  // Method untuk mengambil profil artisan yang sedang login
  Future<void> _fetchCurrentArtisanProfile() async {
    setState(() {
      _isLoadingArtisanProfile = true;
    });
    try {
      final userId = await AuthManager.getUserId();
      if (userId == null) {
        print('User ID not found for fetching artisan profile.');
        return;
      }

      artisan? fetchedArtisan;
      final artisanByIdResult = await _artisanService.getArtisanById(userId);
      if (artisanByIdResult['success']) {
        fetchedArtisan = artisanByIdResult['data'];
      } else {
        print('getArtisanById failed for user ID $userId. Trying getAllArtisans...');
        final allArtisansResult = await _artisanService.getAllArtisans(limit: 100);
        if (allArtisansResult['success'] && allArtisansResult['data'] is List) {
          List<artisan> allArtisans = allArtisansResult['data'];
          fetchedArtisan = allArtisans.firstWhere(
            (art) => art.user_id == userId,
            orElse: () => null!,
          );
          if (fetchedArtisan == null) {
            print('No artisan profile found matching user_id $userId in all artisans.');
          }
        }
      }

      setState(() {
        _currentArtisanProfile = fetchedArtisan;
        if (_currentArtisanProfile != null) {
          // Jika profil ditemukan, set marker ke lokasi profil artisan
          _markerLocation = LatLng(_currentArtisanProfile!.latitude!, _currentArtisanProfile!.longitude!);
          _mapController.move(_markerLocation, _mapController.camera.zoom);
        }
      });
    } catch (e) {
      print('Error fetching current artisan profile: $e');
    } finally {
      setState(() {
        _isLoadingArtisanProfile = false;
      });
    }
  }

  // Method untuk menampilkan dialog profil pengrajin (untuk create/edit)
  Future<void> _showCreateArtisanProfileDialog() async {
    final bool isEditing = _currentArtisanProfile != null;
    final String dialogTitle = isEditing ? 'Edit Profil Pengrajin' : 'Buat Profil Pengrajin';
    final String buttonText = isEditing ? 'Simpan Perubahan' : 'Buat Profil';

    if (isEditing) {
      _bioController.text = _currentArtisanProfile!.bio ?? '';
      _expertiseCategoryController.text = _currentArtisanProfile!.expertise_category ?? '';
      _addressController.text = _currentArtisanProfile!.address ?? '';
      _contactEmailController.text = _currentArtisanProfile!.contact_email ?? '';
      _contactPhoneController.text = _currentArtisanProfile!.contact_phone ?? '';
      _websiteUrlController.text = _currentArtisanProfile!.website_url ?? '';
    } else {
      _bioController.clear();
      _expertiseCategoryController.clear();
      _addressController.clear();
      _contactEmailController.clear();
      _contactPhoneController.clear();
      _websiteUrlController.clear();
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        bool isLoading = false;
        String? dialogErrorMessage;

        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text(dialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Lokasi Terpilih: Lat ${_markerLocation.latitude.toStringAsFixed(4)}, Lon ${_markerLocation.longitude.toStringAsFixed(4)}',
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

                              if (_expertiseCategoryController.text.isEmpty || _addressController.text.isEmpty) {
                                setStateInDialog(() {
                                  dialogErrorMessage = 'Kategori Keahlian dan Alamat wajib diisi.';
                                  isLoading = false;
                                });
                                return;
                              }

                              try {
                                Map<String, dynamic> result;
                                if (isEditing) {
                                  result = await _artisanService.updateArtisanProfile(
                                    _currentArtisanProfile!.id!,
                                    bio: _bioController.text.isEmpty ? null : _bioController.text,
                                    expertiseCategory: _expertiseCategoryController.text,
                                    address: _addressController.text,
                                    latitude: _markerLocation.latitude,
                                    longitude: _markerLocation.longitude,
                                    contactEmail: _contactEmailController.text.isEmpty ? null : _contactEmailController.text,
                                    contactPhone: _contactPhoneController.text.isEmpty ? null : _contactPhoneController.text,
                                    websiteUrl: _websiteUrlController.text.isEmpty ? null : _websiteUrlController.text,
                                  );
                                } else {
                                  result = await _artisanService.createArtisanProfile(
                                    bio: _bioController.text.isEmpty ? null : _bioController.text,
                                    expertiseCategory: _expertiseCategoryController.text,
                                    address: _addressController.text,
                                    latitude: _markerLocation.latitude,
                                    longitude: _markerLocation.longitude,
                                    contactEmail: _contactEmailController.text.isEmpty ? null : _contactEmailController.text,
                                    contactPhone: _contactPhoneController.text.isEmpty ? null : _contactPhoneController.text,
                                    websiteUrl: _websiteUrlController.text.isEmpty ? null : _websiteUrlController.text,
                                  );
                                }


                                if (result['success']) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result['message'])),
                                  );
                                  Navigator.of(dialogContext).pop();
                                  _fetchCurrentArtisanProfile(); // Refresh profil artisan setelah berhasil membuat/mengedit
                                  _fetchAllArtisansForMapAndList(); // Refresh daftar artisan di peta/list
                                } else {
                                  setStateInDialog(() {
                                    dialogErrorMessage = result['message'] ?? 'Gagal menyimpan profil.';
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
                            child: Text(buttonText),
                          ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
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
          title: Text(selectedArtisan.user?.fullName ?? selectedArtisan.user?.username ?? 'Detail Pengrajin'),
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
  // Sekarang hanya memfilter dari _allArtisansForMap
  void _searchArtisans({String? query}) {
    setState(() {
      _isSearchingArtisans = true;
      _artisanSearchErrorMessage = null;
    });

    if (query == null || query.isEmpty) {
      setState(() {
        _foundArtisans = _allArtisansForMap; // Tampilkan semua jika query kosong
        _isSearchingArtisans = false;
      });
      return;
    }

    final lowerCaseQuery = query.toLowerCase();
    final filteredList = _allArtisansForMap.where((artisan) {
      final name = artisan.user?.fullName?.toLowerCase() ?? artisan.user?.username?.toLowerCase() ?? '';
      final description = artisan.bio?.toLowerCase() ?? '';
      final category = artisan.expertise_category?.toLowerCase() ?? '';
      return name.contains(lowerCaseQuery) ||
             description.contains(lowerCaseQuery) ||
             category.contains(lowerCaseQuery);
    }).toList();

    setState(() {
      _foundArtisans = filteredList;
      _isSearchingArtisans = false;
      if (_foundArtisans.isEmpty) {
        _artisanSearchErrorMessage = 'Tidak ada pengrajin ditemukan untuk "${query}".';
      }
    });
  }

  // Callback saat teks pencarian berubah
  void _onSearchChanged() {
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
              // Tombol untuk memicu dialog pembuatan profil pengrajin
              if (widget.userRole == 'artisan')
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                    onPressed: _showCreateArtisanProfileDialog,
                    child: _isLoadingArtisanProfile
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : Text(_currentArtisanProfile != null ? 'Edit Profil Pengrajin' : 'Buat Profil Pengrajin'),
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
                  if (widget.userRole == 'artisan' && !_isLoadingArtisanProfile) {
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
                // Marker untuk lokasi yang dipilih pengguna
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _markerLocation,
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
                // Marker untuk semua artisan
                MarkerLayer(
                  markers: _allArtisansForMap.where((artisan) => artisan.latitude != null && artisan.longitude != null).map((artisan) {
                    return Marker(
                      point: LatLng(artisan.latitude!, artisan.longitude!),
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () {
                          // Pindahkan marker utama ke lokasi artisan ini
                          setState(() {
                            _markerLocation = LatLng(artisan.latitude!, artisan.longitude!);
                          });
                          // Animasikan peta ke lokasi marker artisan
                          _mapController.move(
                              LatLng(artisan.latitude!, artisan.longitude!),
                              _mapController.camera.zoom);
                          _showArtisanDetailDialog(artisan);
                        },
                        child: Column(
                          children: [
                            Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 30),
                            Text(
                              artisan.user?.username ?? '',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
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
                                        elevation: 4, // Tambahkan sedikit shadow
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10), // Rounded corners
                                        ),
                                        child: InkWell( // Membuat Card bisa di-tap
                                          borderRadius: BorderRadius.circular(10),
                                          onTap: () {
                                            // Pindahkan marker utama ke lokasi artisan
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
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0), // Padding di dalam Card
                                            child: Row(
                                              children: [
                                                // Gambar Profil atau Icon Default
                                                CircleAvatar(
                                                  radius: 30,
                                                  backgroundImage: artisan.user?.profile_picture_url != null && artisan.user!.profile_picture_url!.isNotEmpty
                                                      ? NetworkImage(artisan.user!.profile_picture_url!)
                                                      : null,
                                                  child: artisan.user?.profile_picture_url == null || artisan.user!.profile_picture_url!.isEmpty
                                                      ? const Icon(Icons.person, size: 30)
                                                      : null,
                                                ),
                                                const SizedBox(width: 12),
                                                // Nama dan Kategori
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        artisan.user?.fullName ?? artisan.user?.username ?? 'Pengrajin Tanpa Nama',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      Text(
                                                        artisan.expertise_category ?? 'Tanpa Kategori',
                                                        style: TextStyle(
                                                          color: Colors.grey[600],
                                                          fontSize: 14,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      if (artisan.avg_rating != null)
                                                        Row(
                                                          children: [
                                                            Icon(Icons.star, color: Colors.amber, size: 16),
                                                            Text('${artisan.avg_rating!.toStringAsFixed(1)} (${artisan.total_reviews ?? 0})'),
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                // Icon Panah (opsional)
                                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                              ],
                                            ),
                                          ),
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
    _searchController.dispose();
    super.dispose();
  }
}
