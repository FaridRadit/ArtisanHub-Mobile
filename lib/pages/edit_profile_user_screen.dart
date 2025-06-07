// lib/screens/auth/edit_profile_user_screen.dart

import 'package:flutter/material.dart';
import '../services/userService.dart';
import '../services/artisanService.dart'; // Import ArtisanService
import '../services/auth_manager.dart'; // Import AuthManager to get user role
import '../model/userModel.dart';
import '../model/artisanModel.dart'; // Import Artisan model
import '../theme/theme.dart'; // Import theme for consistent styling

class EditProfileUserScreen extends StatefulWidget {
  final User currentUser;

  const EditProfileUserScreen({super.key, required this.currentUser});

  @override
  State<EditProfileUserScreen> createState() => _EditProfileUserScreenState();
}

class _EditProfileUserScreenState extends State<EditProfileUserScreen> {
  final UserService _userService = UserService();
  final ArtisanService _artisanService = ArtisanService();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _userRole;
  artisan? _artisanProfile;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeProfileControllers();
  }

  Future<void> _initializeProfileControllers() async {
    _userRole = await AuthManager.getUserRole();

    // Initialize with current user data
    _fullNameController.text = widget.currentUser.fullName ?? '';
    _phoneNumberController.text = widget.currentUser.phone_number ?? '';
    _emailAddressController.text = widget.currentUser.email ?? '';

    // If the user is an artisan, fetch and initialize artisan-specific fields
    if (_userRole == 'artisan') {
      setState(() => _isLoading = true);
      try {
        // Correctly get userId from currentUser
        final userId = widget.currentUser.id;
        if (userId != null) {
          final artisanResult = await _artisanService.getArtisanById(userId);
          if (artisanResult['success']) {
            _artisanProfile = artisanResult['data'];
           
            // If artisan, use contact_email for 'Email Address' field if available
            _emailAddressController.text = _artisanProfile?.contact_email ?? widget.currentUser.email ?? '';
          } else {
            // Handle case where artisan profile is not found for the given user ID
            _errorMessage = artisanResult['message'] ?? 'Failed to load artisan profile.';
            print('Artisan profile not found for user ID $userId: ${_errorMessage}'); // Debugging message
          }
        } else {
          // Handle case where currentUser.id is null (shouldn't happen if logged in)
          _errorMessage = 'User ID not available to fetch artisan profile.';
        }
      } catch (e) {
        _errorMessage = 'Error loading artisan profile: $e';
        print('Error fetching artisan profile: $e'); // Debugging message
      } finally {
        setState(() => _isLoading = false);
      }
    }
    // No need for a separate setState() here if all state changes are handled inside the async blocks
    // or if the build method relies on _isLoading to show loading state.
    // However, if you need the initial values to appear immediately before the async call completes,
    // you might keep a setState here. For this case, it's fine.
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> userUpdateResult;
      // Update User profile (common for all roles)
      userUpdateResult = await _userService.updateProfile(
        // username: _usernameController.text, // Username is usually not updated directly in profile edit
        email: _emailAddressController.text, // This is the user's login email
        fullName: _fullNameController.text,
        phoneNumber: _phoneNumberController.text,
        profilePictureUrl: widget.currentUser.profile_picture_url, // Assuming this is set via image picker or similar, or not updated here
        password: _passwordController.text.isEmpty ? null : _passwordController.text,
      );

      if (!userUpdateResult['success']) {
        setState(() {
          _errorMessage = userUpdateResult['message'];
          _isLoading = false;
        });
        return;
      }

      // If user is an artisan, also update artisan profile
      if (_userRole == 'artisan' && _artisanProfile != null) {
        final artisanUpdateResult = await _artisanService.updateArtisanProfile(
          _artisanProfile!.id!,
          contactEmail: _emailAddressController.text,
          // These fields below must be non-null for the API, ensure your backend or models handle optionality
          // If they are required for artisan profile but not on this edit screen, you'd need to fetch
          // the existing values from _artisanProfile! and pass them.
          expertiseCategory: _artisanProfile!.expertise_category,
          address: _artisanProfile!.address,
          latitude: _artisanProfile!.latitude,
          longitude: _artisanProfile!.longitude,
        );

        if (!artisanUpdateResult['success']) {
          setState(() {
            _errorMessage = artisanUpdateResult['message'];
            _isLoading = false;
          });
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context, true); // Go back and indicate success
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black), // Back arrow
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black, // Dark text color for app bar title
            fontFamily: "jakarta-sans", // Apply custom font
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent background
        elevation: 0, // No shadow
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center items for image
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.currentUser.profile_picture_url != null && widget.currentUser.profile_picture_url!.isNotEmpty
                        ? NetworkImage(widget.currentUser.profile_picture_url!)
                        : null,
                    child: widget.currentUser.profile_picture_url == null || widget.currentUser.profile_picture_url!.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 30),

                  // Full Name Field
                  _buildTextField(
                    controller: _fullNameController,
                    labelText: 'Full Name',
                    initialValue: widget.currentUser.fullName,
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Field
                  _buildTextField(
                    controller: _phoneNumberController,
                    labelText: 'Phone Number',
                    initialValue: widget.currentUser.phone_number,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Email Address (or Contact Email for Artisan) Field
                  _buildTextField(
                    controller: _emailAddressController,
                    labelText: 'Email Address',
                    initialValue: _userRole == 'artisan'
                        ? _artisanProfile?.contact_email // Use artisan contact email
                        : widget.currentUser.email, // Use user's login email
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Bio Field (only for artisans, or optional for users if supported)
                 
                

                  // Role Field (static text "Artisan" or "User")
                  _buildTextField(
                    controller: TextEditingController(text: _userRole == 'artisan' ? 'Artisan' : 'User'),
                    labelText: 'Role',
                    readOnly: true, // Not editable
                    fillColor: Colors.grey[100], // Light grey background for static field
                  ),
                  const SizedBox(height: 16),

                  // New Password Field (Optional)
                  _buildTextField(
                    controller: _passwordController,
                    labelText: 'New Password (fill to change)',
                    obscureText: true,
                    isOptionalPassword: true,
                  ),

                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: const Color(0xFF4300FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(fontFamily: "jakarta-sans", fontWeight: FontWeight.bold),
                          ),
                        ),
                ],
              ),
            ),
          );
  
  }

  // Helper method to build TextFields with consistent styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    bool readOnly = false,
    Color? fillColor,
    bool isOptionalPassword = false,
  }) {
    if (initialValue != null && controller.text.isEmpty && !readOnly) {
      controller.text = initialValue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            fontFamily: "jakarta-sans",
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor ?? const Color(0xFFCACACA),
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
            hintText: isOptionalPassword ? 'Leave blank to keep current' : null,
            hintStyle: TextStyle(color: Colors.grey[400], fontFamily: "jakarta-sans"),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          readOnly: readOnly,
          style: const TextStyle(fontFamily: "jakarta-sans"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailAddressController.dispose();
  
    _passwordController.dispose();
    super.dispose();
  }
}