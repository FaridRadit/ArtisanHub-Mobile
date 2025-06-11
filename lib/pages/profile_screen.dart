import 'package:artisanhub11/pages/artisanprofile.dart';
import 'package:artisanhub11/pages/auth/login.dart';
import 'package:artisanhub11/pages/product_screen.dart';
import 'package:flutter/material.dart';
import '../services/userService.dart';
import '../services/artisanService.dart';
import '../services/auth_manager.dart';
import '../model/userModel.dart';
import '../model/artisanModel.dart';
import '../routes/Routenames.dart';
import 'edit_profile_user_screen.dart';

import 'product_screen.dart'; // Import the new ProductManagementScreen
import '../theme/theme.dart'; // Import your theme for text styles

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
          final userId = _userProfile!.id!;
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
            } else {
              print('Failed to fetch all artisans: ${allArtisansResult['message']}');
            }
          }

          if (fetchedArtisan != null) {
            setState(() {
              _artisanProfile = fetchedArtisan;
            });
          } else {
            print('Note: User is an artisan but does not have an artisan profile or it could not be found.');
          }
        }
      } else {
        setState(() {
          _errorMessage = userResult['message'] ?? 'Failed to load user profile.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while loading profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthManager.clearAuthData();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anda telah keluar.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          
          style: TextStyle(
            color: Colors.black, // Dark text color for app bar title
            fontFamily: "jakarta-sans", // Apply custom font
            fontWeight: FontWeight.bold,
          ),
          
          
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent background
        elevation: 0, // No shadow
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16, fontFamily: "jakarta-sans"),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _userProfile == null
                  ? const Center(child: Text('Tidak ada data profil pengguna.', style: TextStyle(fontFamily: "jakarta-sans"),))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Profile Card (as per design)
                          Card(
                            margin: EdgeInsets.zero, // Remove default card margin
                            elevation: 0, // No shadow
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), // Rounded corners
                              side: BorderSide(color: Colors.grey[200]!, width: 1), // Subtle border
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30, // Adjust size as per design
                                    backgroundImage: _userProfile!.profile_picture_url != null && _userProfile!.profile_picture_url!.isNotEmpty
                                        ? NetworkImage(_userProfile!.profile_picture_url!)
                                        : null,
                                    child: _userProfile!.profile_picture_url == null || _userProfile!.profile_picture_url!.isEmpty
                                        ? const Icon(Icons.person, size: 30, color: Colors.grey)
                                        : null,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _userProfile!.fullName ?? _userProfile!.username??'',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "jakarta-sans",
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _userProfile!.email??_userProfile!.email??'',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontFamily: "jakarta-sans",
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Edit Icon Button
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF4300FF)), // Blue edit icon
                                    onPressed: () async {
                                      if (_userProfile != null) {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => EditProfileUserScreen(currentUser: _userProfile!)),
                                        );
                                        if (result == true) {
                                          _fetchUserProfileAndRole(); // Refresh data after edit
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Artisan Profile Section (Conditional)
                          if (_userRole == 'artisan' && _artisanProfile != null) ...[
                            Text(
                              'Profil Pengrajin',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                                fontFamily: "jakarta-sans",
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildSupportListItem(
                              icon: Icons.business_center_outlined, // Ikon untuk profil pengrajin
                              text: 'Detail Profil Pengrajin Anda',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArtisanProfileDetailScreen(artisanProfile: _artisanProfile!),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10), // Spacing between Artisan Profile and Products
                            _buildSupportListItem(
                              icon: Icons.shopping_bag_outlined, // Icon for products
                              text: 'Produk Saya',
                              onTap: () {
                                if (_artisanProfile?.id != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductManagementScreen(
                                        artisanId: _artisanProfile!.id!,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('ID Artisan tidak ditemukan untuk mengelola produk.')),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 30),
                          ],

                          // Support Section Header
                          Text(
                            'Dukungan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontFamily: "jakarta-sans",
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Help List Item
                          _buildSupportListItem(
                            icon: Icons.help_outline,
                            text: 'Bantuan',
                            onTap: () {
                              // Navigate to Help Screen or show help dialog
                              print('Bantuan diklik');
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }

  // Helper widget for support list items
  Widget _buildSupportListItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLogout ? Colors.red : Colors.grey[700], // Red for logout
                size: 24,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isLogout ? Colors.red : Colors.black, // Red for logout
                    fontFamily: "jakarta-sans",
                  ),
                ),
              ),
            // No arrow for logout as per design
                // const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
