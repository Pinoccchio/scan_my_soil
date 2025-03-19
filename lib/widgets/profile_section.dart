import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../screens/profile_edit_screen.dart';
import 'profile_picture_preview.dart';
import '../screens/about_screen.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final _supabaseService = SupabaseService();
  bool _isUploading = false;
  bool _isSigningOut = false;
  // Store references to providers to avoid accessing context in dispose
  late AuthProvider _authProvider;
  bool _mounted = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely store a reference to the AuthProvider
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _showProfilePicturePreview(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ProfilePicturePreview(
              imageUrl: imageUrl,
            ),
          );
        },
      ),
    );
  }

  Future<void> _showImageSourceOptions() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue.shade700),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green.shade700),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      if (!_mounted) return;

      setState(() {
        _isUploading = true;
      });

      final File imageFile = File(image.path);
      final imageUrl = await _supabaseService.uploadProfileImage(imageFile);

      if (imageUrl != null) {
        // Refresh profile data
        await _authProvider.checkAuthState();

        if (_mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (_mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // Show sign out confirmation dialog
  Future<void> _showSignOutConfirmationDialog() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                // Close the dialog first
                Navigator.of(dialogContext).pop();

                // Perform sign out
                _performSignOut();
              },
            ),
          ],
        );
      },
    );
  }

  // Separate method to handle sign out process
  Future<void> _performSignOut() async {
    if (!_mounted) return;

    // Set signing out state to prevent UI updates
    setState(() {
      _isSigningOut = true;
    });

    // Navigate to sign in screen immediately
    // This prevents seeing the profile with default values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
    });

    // Then perform the actual sign out in the background
    await _authProvider.signOut();
  }

  @override
  Widget build(BuildContext context) {
    // If signing out, show a loading indicator instead of profile content
    if (_isSigningOut) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final profile = authProvider.profile;
    final fullName = profile?['full_name'] ?? 'User';
    final email = profile?['email'] ?? 'No email';
    final bio = profile?['bio'] as String?;
    final avatarUrl = profile?['avatar_url'];

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Manage your account',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Profile card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade200,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Profile picture with camera icon
                          Stack(
                            children: [
                              // Profile picture with tap gesture
                              GestureDetector(
                                onTap: () {
                                  if (avatarUrl != null && avatarUrl.isNotEmpty) {
                                    _showProfilePicturePreview(avatarUrl);
                                  }
                                },
                                child: Hero(
                                  tag: 'profile-picture',
                                  child: _isUploading
                                      ? CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Colors.green.shade100,
                                    child: const CircularProgressIndicator(),
                                  )
                                      : CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Colors.green.shade100,
                                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    child: avatarUrl == null || avatarUrl.isEmpty
                                        ? Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.green.shade700,
                                    )
                                        : null,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: _isUploading ? null : _showImageSourceOptions,
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Navigate to edit profile screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileEditScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),

                      // Bio section
                      if (bio != null || bio?.isEmpty == false || bio?.trim().isEmpty == false)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bio?.isNotEmpty == true ? bio! : 'No bio yet. Tap the edit button to add one.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: bio?.isNotEmpty == true
                                      ? (isDarkMode ? Colors.white : Colors.black87)
                                      : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                                  fontStyle: bio?.isNotEmpty == true ? FontStyle.normal : FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // App settings
              Text(
                'App Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade300
                      : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsItem(
                context: context,
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                isSwitch: true,
                switchValue: isDarkMode,
                onToggle: (value) {
                  themeProvider.toggleTheme();
                },
              ),
              _buildSettingsItem(
                context: context,
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Sign out button with confirmation dialog
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showSignOutConfirmationDialog,
                  icon: Icon(Icons.logout, color: Colors.red.shade700),
                  label: Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    bool isSwitch = false,
    bool switchValue = false,
    Function(bool)? onToggle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green.shade700),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: isSwitch
            ? Switch(
          value: switchValue,
          onChanged: onToggle,
          activeColor: Colors.green.shade600,
        )
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: isSwitch ? null : onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

