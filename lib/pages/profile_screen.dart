
import 'package:flutter/material.dart';
import '../services/userService.dart';
import '../services/artisanService.dart';
import '../services/auth_manager.dart';
import '../model/userModel.dart';
import '../model/artisanModel.dart';
import '../routes/Routenames.dart';
import 'edit_profile_user_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final ArtisanService _artisanService = ArtisanService();
  User? _userProfile;
  artisan? _artisanProfile;
  bool _isLoading = true;
  String? _errorMessage;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileAndRole();
  }

  Future<void> _fetchUserProfileAndRole() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _userProfile = null;
      _artisanProfile = null;
    });

    try {
      _userRole = await AuthManager.getUserRole();
      final userResult = await _userService.getProfile();

      if (userResult['success']) {
        setState(() {
          _userProfile = userResult['user'];
        });

        if (_userRole == 'artisan' && _userProfile?.id != null) {
          // --- LOGIKA PERBAIKAN PENGAMBILAN PROFIL ARTISAN ---
          final userId = _userProfile!.id!;
          artisan? fetchedArtisan;

          final artisanByIdResult = await _artisanService.getArtisanById(userId);
          if (artisanByIdResult['success']) {
            fetchedArtisan = artisanByIdResult['data'];
          } else {
           
            print('getArtisanById failed for user ID $userId. Trying getAllArtisans...');
            final allArtisansResult = await _artisanService.getAllArtisans(limit: 100); // Ambil lebih banyak atau sesuaikan limit
            if (allArtisansResult['success'] && allArtisansResult['data'] is List) {
              List<artisan> allArtisans = allArtisansResult['data'];
              fetchedArtisan = allArtisans.firstWhere(
                (art) => art.user_id == userId,
                orElse: () => null!, 
              );
              if (fetchedArtisan == null) {
                print('No artisan profile found matching user_id $userId in all artisans.');
              }
            } else {
              print('Failed to fetch all artisans: ${allArtisansResult['message']}');
            }
          }

          if (fetchedArtisan != null) {
            setState(() {
              _artisanProfile = fetchedArtisan;
            });
          } else {
            print('Catatan: Pengguna adalah artisan tetapi belum memiliki profil pengrajin atau tidak dapat ditemukan.');
          }

        }
      } else {
        setState(() {
          _errorMessage = userResult['message'] ?? 'Gagal memuat profil pengguna.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat profil: $e';
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
        title: const Text('Profil Pengguna'),
        centerTitle: true,
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
              : _userProfile == null
                  ? const Center(child: Text('Tidak ada data profil pengguna.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: _userProfile!.profile_picture_url != null && _userProfile!.profile_picture_url!.isNotEmpty
                                  ? NetworkImage(_userProfile!.profile_picture_url!)
                                  : null,
                              child: _userProfile!.profile_picture_url == null || _userProfile!.profile_picture_url!.isEmpty
                                  ? const Icon(Icons.person, size: 60)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildProfileSection('Informasi Akun', [
                            _buildProfileInfo('Username', _userProfile!.username),
                            _buildProfileInfo('Email', _userProfile!.email),
                            _buildProfileInfo('Nama Lengkap', _userProfile!.fullName),
                            _buildProfileInfo('Role', _userProfile!.role),
                            _buildProfileInfo('Nomor Telepon', _userProfile!.phone_number),
                            _buildProfileInfo('Bergabung Sejak', _userProfile!.created_at?.toLocal().toString().split(' ')[0]),
                          ]),
                          const SizedBox(height: 20),

                          // Tampilkan data profil pengrajin jika role adalah 'artisan'
                          if (_userRole == 'artisan')
                            _buildProfileSection('Profil Pengrajin', [
                              if (_artisanProfile != null) ...[ // <--- Bagian ini yang mengecek jika data artisan profile sudah ada
                                _buildProfileInfo('Bio', _artisanProfile!.bio),
                                _buildProfileInfo('Kategori Keahlian', _artisanProfile!.expertise_category),
                                _buildProfileInfo('Alamat Pengrajin', _artisanProfile!.address),
                                _buildProfileInfo('Email Kontak', _artisanProfile!.contact_email),
                                _buildProfileInfo('Telepon Kontak', _artisanProfile!.contact_phone),
                                _buildProfileInfo('URL Website', _artisanProfile!.website_url),
                                _buildProfileInfo('Rating Rata-rata', _artisanProfile!.avg_rating?.toStringAsFixed(1)),
                                _buildProfileInfo('Total Ulasan', _artisanProfile!.total_reviews?.toString()),
                                _buildProfileInfo('Terverifikasi', _artisanProfile!.is_verified == true ? 'Ya' : 'Tidak'),
                                const SizedBox(height: 10),
                                Center(
                                  child: Text(
                                    'Lat: ${_artisanProfile!.latitude?.toStringAsFixed(4)}, Lon: ${_artisanProfile!.longitude?.toStringAsFixed(4)}',
                                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ] else
                                const Text(
                                  'Anda adalah pengrajin tetapi belum memiliki profil pengrajin. Silakan buat di halaman Beranda atau profil tidak ditemukan.',
                                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.orange),
                                  textAlign: TextAlign.center,
                                ),
                            ]),
                          const SizedBox(height: 30),

                          // Tombol Aksi Berdasarkan Role
                          _buildRoleBasedButtons(context),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const Divider(color: Colors.blue, thickness: 1.5),
        ...children,
      ],
    );
  }

  Widget _buildProfileInfo(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? '-',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildRoleBasedButtons(BuildContext context) {
    if (_userProfile == null) return const SizedBox.shrink();

    switch (_userProfile!.role) {
      case 'artisan':
        return Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Tambah/Kelola Produk'),
            onPressed: () {
              // Menggunakan named route
              Navigator.pushNamed(context, Routenames.product);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        );
      case 'admin':
        return Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.event_note),
            label: const Text('Manajemen Acara'),
            onPressed: () {
              // Menggunakan named route
              Navigator.pushNamed(context, Routenames.events);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        );
      case 'user':
      default:
        return Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profil'),
            onPressed: () async {
              if (_userProfile != null) {
                // Tetap menggunakan MaterialPageRoute karena perlu meneruskan objek
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileUserScreen(currentUser: _userProfile!)),
                );
                if (result == true) {
                  _fetchUserProfileAndRole();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        );
    }
  }
}
