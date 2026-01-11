import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../main.dart'; // Needed to access themeNotifier
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Detects if the app is currently in Dark Mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        children: [
          // 1. FIXED: Added the UserProfileHeader widget below
          const UserProfileHeader(),

          const Divider(indent: 20, endIndent: 20),

          // 2. Dark Mode Toggle
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

          // 3. Smart Feature placeholder
          ListTile(
            leading: const Icon(
              Icons.auto_awesome_outlined,
              color: Color(0xFF6366F1),
            ),
            title: const Text("Smart Recommendations"),
            subtitle: const Text("Personalize your FYNDO feed"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Future logic for AI personalization
            },
          ),

          // 4. FIXED: Enhanced Logout with Navigation
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await AuthService().signOut();
              if (context.mounted) {
                // Clears all screens and goes back to Login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// --- SUPPORTING WIDGETS ---

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFF6366F1),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Fyndo User",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text("Premium Member", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
