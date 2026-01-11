import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../main.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state for profile data
  String username = "Fyndo User";
  XFile? profileImage;
  final ImagePicker picker = ImagePicker();

  // --- EDIT USERNAME LOGIC ---
  void _showEditNameDialog() {
    TextEditingController nameController = TextEditingController(
      text: username,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Username"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => username = nameController.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- PROFILE PICTURE LOGIC ---
  Future<void> _updateProfilePic() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => profileImage = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // 1. BEAUTIFIED PROFILE HEADER
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _updateProfilePic,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF6366F1),
                        backgroundImage: profileImage != null
                            ? FileImage(File(profileImage!.path))
                            : null,
                        child: profileImage == null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.grey,
                            ),
                            onPressed: _showEditNameDialog,
                          ),
                        ],
                      ),
                      const Text(
                        "Premium Member",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(indent: 20, endIndent: 20),

          // 2. PREFERENCES SECTION
          _buildSectionHeader("PREFERENCES"),
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: Text(
              isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode",
            ),
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: isDarkMode,
            onChanged: (bool value) {
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.auto_awesome_outlined,
              color: Color(0xFF6366F1),
            ),
            title: const Text("Smart Recommendations"),
            subtitle: const Text("Personalize your FYNDO feed"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Action for Smart Recommendations
            },
          ),

          const SizedBox(height: 10),

          // 3. SUPPORT SECTION
          _buildSectionHeader("SUPPORT"),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About Us"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "FYNDO",
                applicationVersion: "1.0.2",
                applicationIcon: const Icon(
                  Icons.shopping_bag,
                  color: Color(0xFF6366F1),
                ),
                children: [
                  const Text(
                    "FYNDO is your premier destination for smart shopping and trend discovery.",
                  ),
                ],
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Help Center"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // 4. LOGOUT BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                foregroundColor: Colors.red,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Header Helper
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.withValues(alpha: 0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
