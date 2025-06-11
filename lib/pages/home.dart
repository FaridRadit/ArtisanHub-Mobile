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
import './events_screen.dart'; // Still potentially used for admin, but not in main nav
import './profile_screen.dart';
import './settings_screen.dart'; // Not in main nav as per design, but kept if needed elsewhere
import './suggestions_feedback_screen.dart'; // Mapped to the third icon

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
        title: Text(
          'Homepage',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            fontFamily: "jakarta-sans",
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _currentWidgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _currentBottomNavBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4300FF),
        unselectedItemColor: Colors.grey[400],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
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

  // User's current location
  LatLng? _userCurrentLocation;
  bool _isGettingUserLocation = false;
  String? _userLocationErrorMessage;

  // Magnetometer related variables
  StreamSubscription? _magnetometerSubscription;
  double _northHeading = 0.0; // Current heading relative to true north (0-360 degrees)

  // Artisan's location and bearing
  LatLng? _selectedArtisanLocation; // Menyimpan lokasi pengrajin yang dipilih
  double _bearingToArtisan = 0.0; // Bearing dari user ke pengrajin yang dipilih
  VoidCallback? _dialogSetState; // Store the setState callback for the dialog

  // Tolerance for "correct" direction (in degrees)
  final double _directionTolerance = 10.0; // +/- 10 degrees from target bearing

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

            // If dialog is open, update its state
            if (_dialogSetState != null) {
              _dialogSetState!(); // Trigger rebuild for the dialog
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
        _userLocationErrorMessage = 'Location permission denied.';
        _isGettingUserLocation = false;
      });
      return;
    }
    if (status.isPermanentlyDenied) {
      setState(() {
        _userLocationErrorMessage = 'Location permission permanently denied. Please enable it in settings.';
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
        _userLocationErrorMessage = 'Failed to get current location: $e';
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
                                  _fetchCurrentArtisanProfile();
                                  _fetchAllArtisansForMapAndList();
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
    // Update selected artisan location for compass on map
    _selectedArtisanLocation = LatLng(selectedArtisan.latitude!, selectedArtisan.longitude!);

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        // Assign the setState function of the dialog's StatefulBuilder
        // This allows the parent _HomeContentState to trigger updates in this dialog.
        _dialogSetState = () {
          if (mounted) { // Ensure the parent widget is still mounted
            // Use markNeedsBuild to trigger a rebuild of the dialog's content
            (dialogContext as Element).markNeedsBuild();
          }
        };

        return AlertDialog(
          title: Text(selectedArtisan.user?.fullName ?? selectedArtisan.user?.username ?? 'Artisan Details'),
          content: SingleChildScrollView(
            child: StatefulBuilder( // Keep StatefulBuilder here to manage dialog's internal state
              builder: (BuildContext context, StateSetter setStateInDialog) {
                String distanceInfo = 'Calculating distance...';
                String bearingInfo = '';
                String directionInfo = '';
                String guidanceText = '';
                Color guidanceColor = Colors.black;
                IconData guidanceIcon = Icons.help_outline; // Default icon

                double relativeBearing = 0.0;
                bool isFacingCorrectly = false;

                if (_userCurrentLocation != null && selectedArtisan.latitude != null && selectedArtisan.longitude != null) {
                  final double distanceInMeters = Geolocator.distanceBetween(
                    _userCurrentLocation!.latitude,
                    _userCurrentLocation!.longitude,
                    selectedArtisan.latitude!,
                    selectedArtisan.longitude!,
                  );
                  distanceInfo = 'Distance: ${(distanceInMeters / 1000).toStringAsFixed(2)} km';

                  _bearingToArtisan = Geolocator.bearingBetween(
                    _userCurrentLocation!.latitude,
                    _userCurrentLocation!.longitude,
                    selectedArtisan.latitude!,
                    selectedArtisan.longitude!,
                  );

                  bearingInfo = 'Bearing to Artisan (from North): ${_bearingToArtisan.toStringAsFixed(1)}°';

                  relativeBearing = (_bearingToArtisan - _northHeading + 360) % 360;
                  directionInfo = 'Artisan is ${relativeBearing.toStringAsFixed(1)}° relative to your current heading (${_getCardinalDirection(relativeBearing)})';

                  // Determine guidance
                  if (relativeBearing >= (360 - _directionTolerance) || relativeBearing <= _directionTolerance) {
                    // Facing roughly forward
                    isFacingCorrectly = true;
                    guidanceText = 'Go Straight!';
                    guidanceColor = Colors.green;
                    guidanceIcon = Icons.arrow_upward;
                  } else if (relativeBearing > _directionTolerance && relativeBearing < 180) {
                    // Need to turn right
                    guidanceText = 'Turn Right';
                    guidanceColor = Colors.orange;
                    guidanceIcon = Icons.turn_right;
                  } else {
                    // Need to turn left
                    guidanceText = 'Turn Left';
                    guidanceColor = Colors.orange;
                    guidanceIcon = Icons.turn_left;
                  }
                } else if (_userLocationErrorMessage != null) {
                  distanceInfo = 'Location error: $_userLocationErrorMessage';
                  guidanceText = 'Cannot get your location.';
                  guidanceColor = Colors.red;
                } else if (_isGettingUserLocation) {
                  distanceInfo = 'Getting your location...';
                  guidanceText = 'Getting your location...';
                  guidanceColor = Colors.blue;
                } else {
                  distanceInfo = 'Your location not available.';
                  guidanceText = 'Location services off or no artisan selected.';
                  guidanceColor = Colors.grey;
                }

                return ListBody(
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
                    const Divider(),
                    Text(distanceInfo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(bearingInfo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(directionInfo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Your Device Heading (North): ${_northHeading.toStringAsFixed(1)}°', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    // Visual Kompas dan Indikator Arah
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background Circle (optional, for visual flair)
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: guidanceColor.withOpacity(0.2), // Light background color
                              border: Border.all(color: guidanceColor, width: 2),
                            ),
                          ),
                          // Rotating Compass Icon
                          Transform.rotate(
                            angle: (_userCurrentLocation != null && selectedArtisan.latitude != null && selectedArtisan.longitude != null)
                                ? ((_bearingToArtisan - _northHeading) * pi / 180) // Rotate to point to artisan
                                : 0, // No rotation if no target
                            child: Icon(
                              Icons.navigation, // Compass icon
                              size: 80,
                              color: guidanceColor, // Color based on guidance
                            ),
                          ),
                          // Guidance Icon on top (e.g., arrow for go straight, turn left/right)
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: guidanceColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Keep walking straight when the icon is green and points up!',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
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
              child: const Text('Close'),
              onPressed: () {
                _dialogSetState = null; // Clear the dialog's setState callback
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Ensure _dialogSetState is null if dialog is dismissed (e.g., by tapping outside)
      _dialogSetState = null;
    });
  }

  String _getCardinalDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) {
      return 'N (North)';
    } else if (degrees >= 22.5 && degrees < 67.5) {
      return 'NE (Northeast)';
    } else if (degrees >= 67.5 && degrees < 112.5) {
      return 'E (East)';
    } else if (degrees >= 112.5 && degrees < 157.5) {
      return 'SE (Southeast)';
    } else if (degrees >= 157.5 && degrees < 202.5) {
      return 'S (South)';
    } else if (degrees >= 202.5 && degrees < 247.5) {
      return 'SW (Southwest)';
    } else if (degrees >= 247.5 && degrees < 292.5) {
      return 'W (West)';
    } else if (degrees >= 292.5 && degrees < 337.5) {
      return 'NW (Northwest)';
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
        _artisanSearchErrorMessage = 'No artisans found for "${query}".';
      }
    });
  }

  void _onSearchChanged() {
    _searchArtisans(query: _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    String welcomeName = 'Artisan';

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
                'Welcome, $welcomeName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: "jakarta-sans"
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: "jakarta-sans"
                ),
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
                            _currentArtisanProfile != null ? 'Edit Artisan Profile' : 'Create Artisan Profile',
                            style: const TextStyle(fontFamily: "jakarta-sans"),
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
                      _selectedArtisanLocation = null; // Clear selected artisan when tapping map
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
                      // User's current location marker
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
                                    : -_northHeading * (pi / 180), // Default to point North
                                child: Icon(
                                  Icons.navigation, // Icon untuk arah pengguna
                                  color: Theme.of(context).primaryColor, // Warna primer aplikasi
                                  size: 40,
                                ),
                              ),
                              Text(
                                'Your Direction',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  fontFamily: "jakarta-sans"
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Marker lokasi yang dipilih (bisa lokasi artisan atau lokasi tap di peta)
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
                                _selectedArtisanLocation = LatLng(artisan.latitude!, artisan.longitude!); // Set selected artisan location
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
        const SizedBox(height: 20),
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
                                      _selectedArtisanLocation = LatLng(artisan.latitude!, artisan.longitude!); // Set selected artisan location
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
                                              ? const Icon(Icons.person, size: 25, color: Colors.grey)
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
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
                                              if (artisan.avg_rating != null && false)
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
    _magnetometerSubscription?.cancel();
    super.dispose();
  }
}