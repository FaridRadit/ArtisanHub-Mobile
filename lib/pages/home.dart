import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/auth_manager.dart';
import '../routes/Routenames.dart';

// Import your custom theme
import '../theme/theme.dart';

// Import screens (assuming these paths are correct)
import './auth/login.dart';
import './events_screen.dart'; // Still potentially used for admin, but not in main nav
import './profile_screen.dart';
import './settings_screen.dart'; // Not in main nav as per design, but kept if needed elsewhere
import './suggestions_feedback_screen.dart'; // Mapped to the third icon

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
  String? _userRole; // To store user role

  // List of all possible widgets (pages)
  late List<Widget> _allWidgetOptions;
  late List<BottomNavigationBarItem> _allBottomNavBarItems;

  // List of widgets and nav bar items to be displayed based on role
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
    setState(() {}); // Rebuild to reflect user role and navigation items
  }

  void _buildNavigationItems() {
    // Initialize all possible navigation items (BottomNavigationBarItem)
    // Based on the Figma design for the homepage
    _allBottomNavBarItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_filled), // Home icon is filled
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outlined), // Profile icon is outlined
        label: 'Profile',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline), // Assuming chat/message icon for suggestions
        label: 'Suggestions',
      ),
      // Keep other items if they might be used elsewhere, but not in main nav for now
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.event),
        label: 'Events',
      ),
    ];

    // Initialize all possible pages (Widget)
    _allWidgetOptions = <Widget>[
      _HomeContent(userRole: _userRole), // Pass role to _HomeContent
      const ProfileScreen(),
      const SuggestionsFeedbackScreen(),
      const SettingsScreen(),
      const EventsScreen(),
    ];

    // Clear current lists
    _currentWidgetOptions = [];
    _currentBottomNavBarItems = [];

    // Add common items for all roles as per design
    _currentWidgetOptions.add(_allWidgetOptions[0]); // Home (Widget)
    _currentBottomNavBarItems.add(_allBottomNavBarItems[0]); // Home (BottomNavigationBarItem)

    _currentWidgetOptions.add(_allWidgetOptions[1]); // Profile (Widget)
    _currentBottomNavBarItems.add(_allBottomNavBarItems[1]); // Profile (BottomNavigationBarItem)

    _currentWidgetOptions.add(_allWidgetOptions[2]); // Suggestions (Widget) - mapped to chat icon
    _currentBottomNavBarItems.add(_allBottomNavBarItems[2]); // Suggestions (BottomNavigationBarItem)

    // Admin-specific items (not in main nav, but example)
    // if (_userRole == 'admin') {
    //   _currentWidgetOptions.add(_allWidgetOptions[4]); // Events (Widget)
    //   _currentBottomNavBarItems.add(_allBottomNavBarItems[4]); // Events (BottomNavigationBarItem)
    // }
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
      // AppBar is removed as per design
      body: Stack( // Using Stack to place "homepage" text at top-left
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _currentWidgetOptions,
          ),
          Positioned(
            top: 40, // Adjust position as needed
            left: 20, // Adjust position as needed
            child: Text(
              'homepage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600], // Adjust color to match design
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _currentBottomNavBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4300FF), // Blue color from buttons
        unselectedItemColor: Colors.grey[400], // Lighter grey for unselected
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure items are evenly distributed
        backgroundColor: Colors.white, // White background
        elevation: 0, // No shadow as per design
        showSelectedLabels: false, // Hide labels for a cleaner look
        showUnselectedLabels: false, // Hide labels
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
  LatLng _markerLocation = const LatLng(-7.7956, 110.3695); // Default location (Yogyakarta)
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchAllArtisansForMapAndList();
    if (widget.userRole == 'artisan') {
      _fetchCurrentArtisanProfile();
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
          _artisanSearchErrorMessage = result['message'] ?? 'Failed to load artisans.';
          _allArtisansForMap = [];
          _foundArtisans = [];
        });
      }
    } catch (e) {
      setState(() {
        _artisanSearchErrorMessage = 'An error occurred while loading artisans: $e';
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
    final String dialogTitle = isEditing ? 'Edit Artisan Profile' : 'Create Artisan Profile';
    final String buttonText = isEditing ? 'Save Changes' : 'Create Profile';

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
                      'Selected Location: Lat ${_markerLocation.latitude.toStringAsFixed(4)}, Lon ${_markerLocation.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: 'Bio (Optional)', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _expertiseCategoryController,
                      decoration: const InputDecoration(labelText: 'Expertise Category*', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address*', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contactEmailController,
                      decoration: const InputDecoration(labelText: 'Contact Email (Optional)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contactPhoneController,
                      decoration: const InputDecoration(labelText: 'Contact Phone (Optional)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _websiteUrlController,
                      decoration: const InputDecoration(labelText: 'Website URL (Optional)', border: OutlineInputBorder()),
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
                                  dialogErrorMessage = 'Expertise Category and Address are required.';
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
                                  _fetchCurrentArtisanProfile(); // Refresh profile after success
                                  _fetchAllArtisansForMapAndList(); // Refresh map/list
                                } else {
                                  setStateInDialog(() {
                                    dialogErrorMessage = result['message'] ?? 'Failed to save profile.';
                                  });
                                }
                              } catch (e) {
                                setStateInDialog(() {
                                  dialogErrorMessage = 'API Error: $e';
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
                  child: const Text('Cancel'),
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
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(selectedArtisan.user?.fullName ?? selectedArtisan.user?.username ?? 'Artisan Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bio: ${selectedArtisan.bio ?? '-'}'),
                Text('Category: ${selectedArtisan.expertise_category ?? '-'}'),
                Text('Address: ${selectedArtisan.address ?? '-'}'),
                Text('Email: ${selectedArtisan.contact_email ?? '-'}'),
                Text('Phone: ${selectedArtisan.contact_phone ?? '-'}'),
                Text('Website: ${selectedArtisan.website_url ?? '-'}'),
                Text('Rating: ${selectedArtisan.avg_rating?.toStringAsFixed(1) ?? '-'}'),
                Text('Reviews: ${selectedArtisan.total_reviews ?? '-'}'),
                Text('Verified: ${selectedArtisan.is_verified == true ? 'Yes' : 'No'}'),
                Text('Lat: ${selectedArtisan.latitude?.toStringAsFixed(4) ?? '-'}, Lon: ${selectedArtisan.longitude?.toStringAsFixed(4) ?? '-'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        _artisanSearchErrorMessage = 'No artisans found for "${query}".';
      }
    });
  }

  void _onSearchChanged() {
    _searchArtisans(query: _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    // Determine the user's full name or username for the welcome message
    String welcomeName = 'Artisan'; // Default if no user info
    // It's better to get this directly from AuthManager for the current user's name
    // and then update it in a FutureBuilder or a similar async way
    // This synchronous approach here won't immediately reflect the name if it's fetched asynchronously

    // For now, let's fetch it once in initState or in a FutureBuilder
    // For a quick fix to show current user's name if available:
    //  AuthManager.getUsername().then((username) { //
    //   if (username != null && username.isNotEmpty) {
    //     if (mounted) { // Check if widget is still in tree to prevent setState on a disposed object
    //       setState(() {
    //         welcomeName = username;
    //       });
    //     }
    //   }
    // });

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children to fill width
      children: [
        // Welcome Section (as per Figma design)
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 16.0), // Adjust top padding for 'homepage' text
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $welcomeName',
                style: const TextStyle(
                  fontSize: 24, // Larger font size
                  fontWeight: FontWeight.bold,
                  fontFamily: "jakarta-sans" // Apply custom font
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: "jakarta-sans" // Apply custom font
                ),
              ),
              // Artisan profile button
              if (widget.userRole == 'artisan')
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                    onPressed: _showCreateArtisanProfileDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor, // Use primary color
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
                            _currentArtisanProfile != null ? 'Edit Artisan Profile' : 'Create Artisan Profile',
                            style: const TextStyle(fontFamily: "jakarta-sans"),
                          ),
                  ),
                ),
            ],
          ),
        ),
        // Map Section (takes more space, as per Figma)
        Expanded(
          flex: 3, // Allocate more space for the map
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Horizontal padding
            child: ClipRRect( // Clip map with rounded corners
              borderRadius: BorderRadius.circular(15),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _markerLocation,
                  initialZoom: 13.0,
                  onTap: (tapPosition, latlng) async {
                    setState(() {
                      _markerLocation = latlng;
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
                  // Markers for selected location and all artisans
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
                      // Artisan markers
                      ..._allArtisansForMap.where((artisan) => artisan.latitude != null && artisan.longitude != null).map((artisan) {
                        return Marker(
                          point: LatLng(artisan.latitude!, artisan.longitude!),
                          width: 80,
                          height: 80,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _markerLocation = LatLng(artisan.latitude!, artisan.longitude!);
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
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    fontFamily: "jakarta-sans"
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
        const SizedBox(height: 20), // Spacing between map and search bar
        // Search Bar (as per Figma design)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search here ...',
              labelStyle: TextStyle(color: Colors.grey[400], fontFamily: "jakarta-sans"),
              suffixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF4300FF), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            ),
            style: const TextStyle(fontFamily: "jakarta-sans"),
          ),
        ),
        const SizedBox(height: 10), // Spacing between search bar and list
        // Artisan List
        Expanded(
          flex: 2, // Allocate remaining space for the list
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _isSearchingArtisans
                ? const Center(child: CircularProgressIndicator())
                : _artisanSearchErrorMessage != null
                    ? Center(
                        child: Text(
                          _artisanSearchErrorMessage!,
                          style: const TextStyle(color: Colors.red, fontFamily: "jakarta-sans"),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _foundArtisans.isEmpty
                        ? const Center(child: Text('No artisans found.', style: TextStyle(fontFamily: "jakarta-sans"),))
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _foundArtisans.length,
                            itemBuilder: (context, index) {
                              final artisan = _foundArtisans[index];
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
                                  onTap: () {
                                    setState(() {
                                      _markerLocation = LatLng(artisan.latitude!, artisan.longitude!);
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
                                        // Profile Picture
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundImage: artisan.user?.profile_picture_url != null && artisan.user!.profile_picture_url!.isNotEmpty
                                              ? NetworkImage(artisan.user!.profile_picture_url!)
                                              : null,
                                          child: artisan.user?.profile_picture_url == null || artisan.user!.profile_picture_url!.isEmpty
                                              ? const Icon(Icons.person, size: 25, color: Colors.grey)
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        // Name and Role/Category
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                artisan.user?.fullName ?? artisan.user?.username ?? 'Unnamed Artisan',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  fontFamily: "jakarta-sans"
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'Artisan',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                  fontFamily: "jakarta-sans"
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (artisan.avg_rating != null && false) // Set to false to hide for now
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                                    Text('${artisan.avg_rating!.toStringAsFixed(1)} (${artisan.total_reviews ?? 0})',
                                                      style: const TextStyle(fontFamily: "jakarta-sans"),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                        // Blue target icon (right-aligned)
                                        const Icon(Icons.location_searching, size: 24, color: Color(0xFF4300FF)),
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
    super.dispose();
  }
}