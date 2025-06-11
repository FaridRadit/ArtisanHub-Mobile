// lib/pages/home.dart
import 'package:artisanhub11/pages/about_us_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/auth_manager.dart';
import '../routes/Routenames.dart';

// Import your custom theme
import '../theme/theme.dart';

// Import screens (assuming these paths are correct)
import './auth/login.dart';
import './events_screen.dart';
import './profile_screen.dart';
import './settings_screen.dart';
import './suggestions_feedback_screen.dart';

import '../services/artisanService.dart';
import '../model/artisanModel.dart';
import '../model/userModel.dart';

// NEW IMPORTS FOR LOCATION AND SENSORS
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' show pi, atan2;
import 'dart:async';
// END NEW IMPORTS

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

  // Daftar widget dan item bilah navigasi yang akan ditampilkan berdasarkan peran
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
    setState(() {}); // Bangun ulang untuk mencerminkan peran pengguna dan item navigasi
  }

  void _buildNavigationItems() {
    _allBottomNavBarItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_filled),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outlined),
        label: 'Profile',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        label: 'Suggestions',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.info_outline),
        label: 'About Us',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.event),
        label: 'Events',
      ),
    ];

    _allWidgetOptions = <Widget>[
      _HomeContent(userRole: _userRole),
      const ProfileScreen(),
      const SuggestionsFeedbackScreen(),
      const AboutUsScreen(),
      const SettingsScreen(),
      const EventsScreen(),
    ];

    _currentWidgetOptions = [];
    _currentBottomNavBarItems = [];

    _currentWidgetOptions.add(_allWidgetOptions[0]);
    _currentBottomNavBarItems.add(_allBottomNavBarItems[0]);

    _currentWidgetOptions.add(_allWidgetOptions[1]);
    _currentBottomNavBarItems.add(_allBottomNavBarItems[1]);

    _currentWidgetOptions.add(_allWidgetOptions[2]);
    _currentBottomNavBarItems.add(_allBottomNavBarItems[2]);
    _currentWidgetOptions.add(_allWidgetOptions[3]);
    _currentBottomNavBarItems.add(_allBottomNavBarItems[3]);

    // Jika Anda ingin mengatur item navigasi lainnya berdasarkan peran, lakukan di sini
    // Contoh: Admin bisa melihat EventsScreen
    if (_userRole == 'admin') { // Ganti 'admin' dengan peran admin Anda
      _currentWidgetOptions.add(_allWidgetOptions[5]); // EventsScreen
      _currentBottomNavBarItems.add(_allBottomNavBarItems[5]); // Events item
    }
    // Jika Anda ingin settings juga ada di bottom nav
    _currentWidgetOptions.add(_allWidgetOptions[4]); // SettingsScreen
    _currentBottomNavBarItems.add(_allBottomNavBarItems[4]); // Settings item
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    await AuthManager.clearAuthData();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routenames.login,
        (Route<dynamic> route) => false,
      );
    }
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
        // Menghilangkan tombol kembali dengan mengatur leading menjadi null
        leading: null, // <-- Perubahan di sini
        automaticallyImplyLeading: false, // <-- Menghilangkan tombol kembali secara otomatis
        title: Text(
          'Homepage',
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Theme.of(context).appBarTheme.foregroundColor),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _currentWidgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _currentBottomNavBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        onTap: _onItemTapped,
        type: Theme.of(context).bottomNavigationBarTheme.type,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        elevation: Theme.of(context).bottomNavigationBarTheme.elevation,
        showSelectedLabels: Theme.of(context).bottomNavigationBarTheme.showSelectedLabels,
        showUnselectedLabels: Theme.of(context).bottomNavigationBarTheme.showUnselectedLabels,
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
  LatLng _markerLocation = const LatLng(-7.7956, 110.3695); // Lokasi default (Yogyakarta)
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

  final TextEditingController _searchController = TextEditingController();
  List<artisan> _foundArtisans = [];
  List<artisan> _allArtisansForMap = [];
  bool _isSearchingArtisans = false;
  String? _artisanSearchErrorMessage;

  // Lokasi pengguna saat ini
  LatLng? _userCurrentLocation;
  bool _isGettingUserLocation = false;
  String? _userLocationErrorMessage;

  // Variabel terkait magnetometer
  StreamSubscription? _magnetometerSubscription;
  double _northHeading = 0.0; // Arah saat ini relatif terhadap utara sejati (0-360 derajat)

  // Lokasi dan bearing artisan
  LatLng? _selectedArtisanLocation; // Menyimpan lokasi pengrajin yang dipilih
  double _bearingToArtisan = 0.0; // Bearing dari pengguna ke pengrajin yang dipilih
  VoidCallback? _dialogSetState; // Menyimpan callback setState untuk dialog

  // Toleransi untuk arah "benar" (dalam derajat)
  final double _directionTolerance = 10.0; // +/- 10 derajat dari bearing target

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchAllArtisansForMapAndList();
    _getUserCurrentLocation();
    _startMagnetometer();
    if (widget.userRole == 'artisan') {
      _fetchCurrentArtisanProfile();
    }
  }

  void _startMagnetometer() {
    _magnetometerSubscription = magnetometerEventStream(samplingPeriod: const Duration(milliseconds: 100)).listen(
      (MagnetometerEvent event) {
        if (mounted) {
          setState(() {
            final double headingRadians = atan2(event.x, event.y);
            _northHeading = ((headingRadians * 180 / pi) + 360) % 360;

            if (_dialogSetState != null) {
              _dialogSetState!();
            }
          });
        }
      },
      onError: (e) {
        print('Error reading magnetometer: $e');
      },
      onDone: () {
        print('Magnetometer stream done.');
      },
      cancelOnError: true,
    );
  }

  Future<void> _getUserCurrentLocation() async {
    setState(() {
      _isGettingUserLocation = true;
      _userLocationErrorMessage = null;
    });

    var status = await Permission.locationWhenInUse.request();
    if (status.isDenied) {
      setState(() {
        _userLocationErrorMessage = 'Izin lokasi ditolak.';
        _isGettingUserLocation = false;
      });
      return;
    }
    if (status.isPermanentlyDenied) {
      setState(() {
        _userLocationErrorMessage = 'Izin lokasi ditolak secara permanen. Harap aktifkan di pengaturan.';
        _isGettingUserLocation = false;
      });
      openAppSettings();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userCurrentLocation = LatLng(position.latitude, position.longitude);
        _isGettingUserLocation = false;
        if (_mapController.camera.center == _markerLocation) {
          _mapController.move(_userCurrentLocation!, _mapController.camera.zoom);
        }
      });
    } catch (e) {
      setState(() {
        _userLocationErrorMessage = 'Gagal mendapatkan lokasi saat ini: $e';
        _isGettingUserLocation = false;
      });
    }
  }

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
          _foundArtisans = result['data'];
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

  Future<void> _fetchCurrentArtisanProfile() async {
    setState(() {
      _isLoadingArtisanProfile = true;
    });
    try {
      final userId = await AuthManager.getUserId();
      if (userId == null) {
        print('ID Pengguna tidak ditemukan untuk mengambil profil pengrajin.');
        return;
      }

      artisan? fetchedArtisan;
      final artisanByIdResult = await _artisanService.getArtisanById(userId);
      if (artisanByIdResult['success']) {
        fetchedArtisan = artisanByIdResult['data'];
      } else {
        print('getArtisanById gagal untuk ID pengguna $userId. Mencoba getAllArtisans...');
        final allArtisansResult = await _artisanService.getAllArtisans(limit: 100);
        if (allArtisansResult['success'] && allArtisansResult['data'] is List) {
          List<artisan> allArtisans = allArtisansResult['data'];
          fetchedArtisan = allArtisans.firstWhere(
            (art) => art.user_id == userId,
            orElse: () => null!,
          );
          if (fetchedArtisan == null) {
            print('Tidak ada profil pengrajin yang cocok dengan user_id $userId di semua pengrajin.');
          }
        }
      }

      setState(() {
        _currentArtisanProfile = fetchedArtisan;
        if (_currentArtisanProfile != null) {
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
              title: Text(dialogTitle, style: Theme.of(context).textTheme.titleLarge),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Lokasi Terpilih: Lat ${_markerLocation.latitude.toStringAsFixed(4)}, Lon ${_markerLocation.longitude.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: 'Bio (Opsional)', border: OutlineInputBorder()),
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _expertiseCategoryController,
                      decoration: const InputDecoration(labelText: 'Kategori Keahlian*', border: OutlineInputBorder()),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Alamat*', border: OutlineInputBorder()),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contactEmailController,
                      decoration: const InputDecoration(labelText: 'Email Kontak (Opsional)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contactPhoneController,
                      decoration: const InputDecoration(labelText: 'Telepon Kontak (Opsional)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _websiteUrlController,
                      decoration: const InputDecoration(labelText: 'URL Situs Web (Opsional)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.url,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    if (dialogErrorMessage != null)
                      Text(
                        dialogErrorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                                  _fetchCurrentArtisanProfile();
                                  _fetchAllArtisansForMapAndList();
                                } else {
                                  setStateInDialog(() {
                                    dialogErrorMessage = result['message'] ?? 'Gagal menyimpan profil.';
                                  });
                                }
                              } catch (e) {
                                setStateInDialog(() {
                                  dialogErrorMessage = 'Kesalahan API: $e';
                                });
                              } finally {
                                setStateInDialog(() {
                                  isLoading = false;
                                });
                              }
                            },
                            child: Text(buttonText, style: Theme.of(context).elevatedButtonTheme.style?.textStyle?.resolve({})?.copyWith(color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({}))),
                          ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Batal', style: Theme.of(context).textButtonTheme.style?.textStyle?.resolve({})),
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

  Future<void> _showArtisanDetailDialog(artisan selectedArtisan) async {
    _selectedArtisanLocation = LatLng(selectedArtisan.latitude!, selectedArtisan.longitude!);

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        _dialogSetState = () {
          if (mounted) {
            (dialogContext as Element).markNeedsBuild();
          }
        };

        return AlertDialog(
          title: Text(selectedArtisan.user?.fullName ?? selectedArtisan.user?.username ?? 'Detail Pengrajin', style: Theme.of(context).textTheme.titleLarge),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateInDialog) {
                String distanceInfo = 'Menghitung jarak...';
                String bearingInfo = '';
                String directionInfo = '';
                String guidanceText = '';
                Color guidanceColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
                IconData guidanceIcon = Icons.help_outline;

                double relativeBearing = 0.0;
                bool isFacingCorrectly = false;

                if (_userCurrentLocation != null && selectedArtisan.latitude != null && selectedArtisan.longitude != null) {
                  final double distanceInMeters = Geolocator.distanceBetween(
                    _userCurrentLocation!.latitude,
                    _userCurrentLocation!.longitude,
                    selectedArtisan.latitude!,
                    selectedArtisan.longitude!,
                  );
                  distanceInfo = 'Jarak: ${(distanceInMeters / 1000).toStringAsFixed(2)} km';

                  _bearingToArtisan = Geolocator.bearingBetween(
                    _userCurrentLocation!.latitude,
                    _userCurrentLocation!.longitude,
                    selectedArtisan.latitude!,
                    selectedArtisan.longitude!,
                  );

                  bearingInfo = 'Bearing ke Pengrajin (dari Utara): ${_bearingToArtisan.toStringAsFixed(1)}°';

                  relativeBearing = (_bearingToArtisan - _northHeading + 360) % 360;
                  directionInfo = 'Pengrajin berada ${relativeBearing.toStringAsFixed(1)}° relatif terhadap arah Anda saat ini (${_getCardinalDirection(relativeBearing)})';

                  if (relativeBearing >= (360 - _directionTolerance) || relativeBearing <= _directionTolerance) {
                    isFacingCorrectly = true;
                    guidanceText = 'Lurus!';
                    guidanceColor = Colors.green;
                    guidanceIcon = Icons.arrow_upward;
                  } else if (relativeBearing > _directionTolerance && relativeBearing < 180) {
                    guidanceText = 'Belok Kanan';
                    guidanceColor = Colors.orange;
                    guidanceIcon = Icons.turn_right;
                  } else {
                    guidanceText = 'Belok Kiri';
                    guidanceColor = Colors.orange;
                    guidanceIcon = Icons.turn_left;
                  }
                } else if (_userLocationErrorMessage != null) {
                  distanceInfo = 'Kesalahan lokasi: $_userLocationErrorMessage';
                  guidanceText = 'Tidak dapat mendapatkan lokasi Anda.';
                  guidanceColor = Colors.red;
                } else if (_isGettingUserLocation) {
                  distanceInfo = 'Mendapatkan lokasi Anda...';
                  guidanceText = 'Mendapatkan lokasi Anda...';
                  guidanceColor = Colors.blue;
                } else {
                  distanceInfo = 'Lokasi Anda tidak tersedia.';
                  guidanceText = 'Layanan lokasi mati atau tidak ada pengrajin yang dipilih.';
                  guidanceColor = Colors.grey;
                }

                return ListBody(
                  children: <Widget>[
                    Text('Bio: ${selectedArtisan.bio ?? '-'}', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Kategori: ${selectedArtisan.expertise_category ?? '-'}', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Alamat: ${selectedArtisan.address ?? '-'}', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Email: ${selectedArtisan.contact_email ?? '-'}', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Telepon: ${selectedArtisan.contact_phone ?? '-'}', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Situs Web: ${selectedArtisan.website_url ?? '-'}', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Peringkat: ${selectedArtisan.avg_rating?.toStringAsFixed(1) ?? '-'}', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Ulasan: ${selectedArtisan.total_reviews ?? '-'}', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Terverifikasi: ${selectedArtisan.is_verified == true ? 'Ya' : 'Tidak'}', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Lat: ${selectedArtisan.latitude?.toStringAsFixed(4) ?? '-'}, Lon: ${selectedArtisan.longitude?.toStringAsFixed(4) ?? '-'}', style: Theme.of(context).textTheme.bodyMedium),
                    const Divider(),
                    Text(distanceInfo, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(bearingInfo, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(directionInfo, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Arah Perangkat Anda (Utara): ${_northHeading.toStringAsFixed(1)}°', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: guidanceColor.withOpacity(0.2),
                              border: Border.all(color: guidanceColor, width: 2),
                            ),
                          ),
                          Transform.rotate(
                            angle: (_userCurrentLocation != null && _selectedArtisanLocation != null)
                                ? ((_bearingToArtisan - _northHeading) * pi / 180)
                                : 0,
                            child: Icon(
                              Icons.navigation,
                              size: 80,
                              color: guidanceColor,
                            ),
                          ),
                          Icon(
                            guidanceIcon,
                            size: 40,
                            color: guidanceColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        guidanceText,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: guidanceColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Text(
                        'Tetap lurus saat ikon hijau dan menunjuk ke atas!',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Tutup', style: Theme.of(context).textButtonTheme.style?.textStyle?.resolve({})),
              onPressed: () {
                _dialogSetState = null;
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
      _dialogSetState = null;
    });
  }

  String _getCardinalDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) {
      return 'N (Utara)';
    } else if (degrees >= 22.5 && degrees < 67.5) {
      return 'NE (Timur Laut)';
    } else if (degrees >= 67.5 && degrees < 112.5) {
      return 'E (Timur)';
    } else if (degrees >= 112.5 && degrees < 157.5) {
      return 'SE (Tenggara)';
    } else if (degrees >= 157.5 && degrees < 202.5) {
      return 'S (Selatan)';
    } else if (degrees >= 202.5 && degrees < 247.5) {
      return 'SW (Barat Daya)';
    } else if (degrees >= 247.5 && degrees < 292.5) {
      return 'W (Barat)';
    } else if (degrees >= 292.5 && degrees < 337.5) {
      return 'NW (Barat Laut)';
    }
    return '';
  }

  void _searchArtisans({String? query}) {
    setState(() {
      _isSearchingArtisans = true;
      _artisanSearchErrorMessage = null;
    });

    if (query == null || query.isEmpty) {
      setState(() {
        _foundArtisans = _allArtisansForMap;
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

  void _onSearchChanged() {
    _searchArtisans(query: _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    String welcomeName = 'Artisan'; // Anda bisa mendapatkan nama asli dari AuthManager jika disimpan

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang, $welcomeName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (widget.userRole == 'artisan')
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                    onPressed: _showCreateArtisanProfileDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: _isLoadingArtisanProfile
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : Text(
                            _currentArtisanProfile != null ? 'Edit Profil Pengrajin' : 'Buat Profil Pengrajin',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                          ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _markerLocation,
                  initialZoom: 13.0,
                  onTap: (tapPosition, latlng) async {
                    setState(() {
                      _markerLocation = latlng;
                      _selectedArtisanLocation = null;
                    });
                    if (widget.userRole == 'artisan' && !_isLoadingArtisanProfile) {
                      await Future.delayed(const Duration(milliseconds: 100));
                      _showCreateArtisanProfileDialog();
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.artisanhub11',
                  ),
                  MarkerLayer(
                    markers: [
                      if (_userCurrentLocation != null)
                        Marker(
                          point: _userCurrentLocation!,
                          width: 100,
                          height: 100,
                          child: Column(
                            children: [
                              Transform.rotate(
                                angle: (_userCurrentLocation != null && _selectedArtisanLocation != null)
                                    ? ((Geolocator.bearingBetween(
                                        _userCurrentLocation!.latitude,
                                        _userCurrentLocation!.longitude,
                                        _selectedArtisanLocation!.latitude,
                                        _selectedArtisanLocation!.longitude,
                                      ) - _northHeading) * pi / 180)
                                    : -_northHeading * (pi / 180),
                                child: Icon(
                                  Icons.navigation,
                                  color: Theme.of(context).primaryColor,
                                  size: 40,
                                ),
                              ),
                              Text(
                                'Arah Anda',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                      ..._allArtisansForMap.where((artisan) => artisan.latitude != null && artisan.longitude != null).map((artisan) {
                        return Marker(
                          point: LatLng(artisan.latitude!, artisan.longitude!),
                          width: 80,
                          height: 80,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _markerLocation = LatLng(artisan.latitude!, artisan.longitude!);
                                _selectedArtisanLocation = LatLng(artisan.latitude!, artisan.longitude!);
                                if (_userCurrentLocation != null) {
                                  _bearingToArtisan = Geolocator.bearingBetween(
                                    _userCurrentLocation!.latitude,
                                    _userCurrentLocation!.longitude,
                                    artisan.latitude!,
                                    artisan.longitude!,
                                  );
                                }
                              });
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
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Cari di sini ...',
              labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
              suffixIcon: Icon(Icons.search, color: Theme.of(context).inputDecorationTheme.hintStyle?.color),
              filled: Theme.of(context).inputDecorationTheme.filled,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              border: Theme.of(context).inputDecorationTheme.border,
              enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
              focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
              contentPadding: Theme.of(context).inputDecorationTheme.contentPadding,
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _isSearchingArtisans
                ? const Center(child: CircularProgressIndicator())
                : _artisanSearchErrorMessage != null
                    ? Center(
                        child: Text(
                          _artisanSearchErrorMessage!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _foundArtisans.isEmpty
                        ? Center(child: Text('Tidak ada pengrajin ditemukan.', style: Theme.of(context).textTheme.bodyLarge))
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _foundArtisans.length,
                            itemBuilder: (context, index) {
                              final artisan = _foundArtisans[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                elevation: Theme.of(context).cardTheme.elevation,
                                shape: Theme.of(context).cardTheme.shape,
                                color: Theme.of(context).cardColor,
                                child: InkWell(
                                  // borderRadius: Theme.of(context).cardTheme.shape?.borderRadius,
                                  onTap: () {
                                    setState(() {
                                      _markerLocation = LatLng(artisan.latitude!, artisan.longitude!);
                                      _selectedArtisanLocation = LatLng(artisan.latitude!, artisan.longitude!);
                                      if (_userCurrentLocation != null) {
                                        _bearingToArtisan = Geolocator.bearingBetween(
                                          _userCurrentLocation!.latitude,
                                          _userCurrentLocation!.longitude,
                                          artisan.latitude!,
                                          artisan.longitude!,
                                        );
                                      }
                                    });
                                    _mapController.move(
                                        LatLng(artisan.latitude!, artisan.longitude!),
                                        _mapController.camera.zoom);
                                    _showArtisanDetailDialog(artisan);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundImage: artisan.user?.profile_picture_url != null && artisan.user!.profile_picture_url!.isNotEmpty
                                              ? NetworkImage(artisan.user!.profile_picture_url!)
                                              : null,
                                          child: artisan.user?.profile_picture_url == null || artisan.user!.profile_picture_url!.isEmpty
                                              ? Icon(Icons.person, size: 25, color: Theme.of(context).textTheme.bodyMedium?.color)
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                artisan.user?.fullName ?? artisan.user?.username ?? 'Pengrajin Tanpa Nama',
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'Pengrajin',
                                                style: Theme.of(context).textTheme.bodyMedium,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (artisan.avg_rating != null && false)
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                                    Text('${artisan.avg_rating!.toStringAsFixed(1)} (${artisan.total_reviews ?? 0})',
                                                      style: Theme.of(context).textTheme.bodySmall,
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.location_searching, size: 24, color: Theme.of(context).colorScheme.primary),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
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
    _mapController.dispose();
    _magnetometerSubscription?.cancel();
    super.dispose();
  }
}