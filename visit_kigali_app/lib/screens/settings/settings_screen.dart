import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Settings Screen - User profile and app settings
/// 
/// This screen was fun to design! I wanted it to look professional
/// Added the gradient header inspired by modern app designs
/// The color-coded icons make it easy to scan
/// 
/// Features:
/// - User profile with avatar (just shows first letter of name)
/// - Notification toggle (placeholder - doesn't do anything yet!)
/// - Theme settings (also placeholder for now)
/// - About dialog with app info
/// - Logout with confirmation (important!)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Placeholder for future notification feature
  // Right now this just shows a snackbar, but could connect to Firebase Cloud Messaging later
  bool _notificationsEnabled = true;

  Future<void> _logout() async {
    // ALWAYS confirm before logout - learned this the hard way when I
    // accidentally logged out while testing and lost my progress! 😅
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,  // Red for destructive action
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    // Only proceed if user confirmed
    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      
      // Don't need to navigate manually - AuthWrapper in main.dart handles it!
      // It automatically shows LoginScreen when user is null
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // === PROFILE SECTION ===
          // Gradient header looks SO much better than plain color!
          // Used the primary color from theme so it matches the rest of the app
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              children: [
                // Profile Avatar (just a circle with user's initial)
                // Real apps would have actual profile photos, but this works for now!
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      // Get first letter of name, uppercase it
                      authProvider.userProfile?.name[0].toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // User's full name
                Text(
                  authProvider.userProfile?.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Email address
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // "Verified" badge if email is verified
                // This gives users confidence their account is secure!
                if (user?.emailVerified == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // App Settings Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'App Settings',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          // Notifications Toggle
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.notifications,
                color: Colors.blue[700],
                size: 24,
              ),
            ),
            title: const Text(
              'Push Notifications',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Get notified about new listings',
              style: TextStyle(fontSize: 12),
            ),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                // TODO: Implement notification settings
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value 
                          ? 'Notifications enabled' 
                          : 'Notifications disabled'
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
          
          const Divider(height: 1),
          
          // Theme (Placeholder for future)
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.palette,
                color: Colors.purple[700],
                size: 24,
              ),
            ),
            title: const Text(
              'Theme',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Light mode',
              style: TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement theme settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Theme settings coming soon!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          
          const Divider(height: 1),
          
          const SizedBox(height: 8),
          
          // About Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          // About App
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info,
                color: Colors.green[700],
                size: 24,
              ),
            ),
            title: const Text(
              'About Visit Kigali',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Visit Kigali',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.location_city,
                  size: 48,
                  color: Colors.blue,
                ),
                children: [
                  const Text(
                    'Discover and share services and places in Kigali, Rwanda.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Built with Flutter and Firebase',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              );
            },
          ),
          
          const Divider(height: 1),
          
          // Privacy Policy (Placeholder)
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.privacy_tip,
                color: Colors.orange[700],
                size: 24,
              ),
            ),
            title: const Text(
              'Privacy Policy',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy policy coming soon!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          
          const Divider(height: 1),
          
          const SizedBox(height: 24),
          
          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Footer
          Center(
            child: Text(
              '🇷🇼 Made with ❤️ for Kigali',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}