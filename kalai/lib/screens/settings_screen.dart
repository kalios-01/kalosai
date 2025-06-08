import 'package:flutter/material.dart';
import 'package:kalai/screens/onboarding_screen.dart';
import 'personal_details_screen.dart'; // Import the new screen
import 'package:provider/provider.dart'; // Import provider
import '../providers/auth_provider.dart'; // Import AuthProvider
import 'login_screen.dart'; // Import LoginScreen
import 'onboarding_screen.dart'; // Import OnboardingScreen
import '../providers/profile_setup_provider.dart'; // Import ProfileSetupProvider
import 'package:intl/intl.dart'; // Import for date formatting
import 'adjust_goals_screen.dart'; // Import AdjustGoalsScreen
import 'package:shimmer/shimmer.dart'; // Import shimmer package

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  void initState() {
    super.initState();
    // Fetch profile data when the screen initializes
    Future.microtask(() => context.read<ProfileSetupProvider>().fetchUserProfile());
  }

  // Function to show confirmation dialog
  Future<void> _confirmDeleteAccount() async {
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Account Deletion'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User cancels
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // User confirms
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed

    if (confirm) {
      // Call the delete account method in AuthProvider
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.deleteAccount();

      if (success && mounted) {
        // Navigate to onboarding screen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  // Helper to calculate age from birth date string (YYYY-MM-DD)
  String _calculateAge(String? birthDateStr) {
    if (birthDateStr == null) return 'N/A';
    try {
      final birthDate = DateTime.parse(birthDateStr);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      print('Error parsing birth date: $e');
      return 'N/A';
    }
  }

  // Helper to format height (assuming API returns inches)
  String _formatHeight(double? heightInches) {
     if (heightInches == null) return 'N/A';
     // Example: Convert inches to feet and inches (assuming API gives inches)
     final feet = (heightInches / 12).floor();
     final inches = (heightInches % 12).round();
     return '$feet ft $inches in';
  }

  // Helper to format weight (assuming API returns lbs)
   String _formatWeight(double? weightLbs) {
     if (weightLbs == null) return 'N/A';
     return '${weightLbs.toStringAsFixed(0)} lbs';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
     // Watch the ProfileSetupProvider for data changes
    final profileProvider = context.watch<ProfileSetupProvider>();
    final userProfile = profileProvider.userProfileData;
    final isLoading = profileProvider.isFetchingProfile || profileProvider.isUpdatingProfile;

    // Extract user info, handling potential nulls and loading state
    final age = profileProvider.isFetchingProfile ? null : _calculateAge(userProfile?['age']);
    final height = profileProvider.isFetchingProfile ? null : _formatHeight(userProfile?['height']?.toDouble());
    final currentWeight = profileProvider.isFetchingProfile ? null : _formatWeight(userProfile?['weight']?.toDouble());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User Info Section
          const Text(
            'User Info',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildUserInfoRow(label: 'Age', value: age, isLoading: isLoading),
          _buildUserInfoRow(label: 'Height', value: height, isLoading: isLoading),
          _buildUserInfoRow(label: 'Current Weight', value: currentWeight, isLoading: isLoading),

          const SizedBox(height: 24),
          const Divider(color: Colors.black26,),
          const SizedBox(height: 24),
          // Customization Section
          const Text(
            'Customization',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            context,
            title: 'Personal details',
            onTap: () {
              // Navigate to PersonalDetailsScreen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PersonalDetailsScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            title: 'Adjust goals',
            subtitle: 'Calories, carbs, fats, and protein',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdjustGoalsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Legal Section
          const Text(
            'Legal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            context,
            title: 'Terms and Conditions',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            title: 'Delete Account?',
            onTap: _confirmDeleteAccount, // Call the confirmation function
          ),

          const SizedBox(height: 48),
          Center(
            child: Text(
              'VERSION 1.0.62',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow({
    required String label,
    required String? value,
    required bool isLoading,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          isLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 20,
                    width: 80,
                    color: Colors.white, // Placeholder for shimmering effect
                  ),
                )
              : Text(
                  value ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required String title, String? subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildPreferenceTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
