import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'google_signin_screen.dart';
import 'profile_setup/profile_setup_flow.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _isProfileCompleteLocally;
  bool? _needsProfileSetup;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check auth status
    await context.read<AuthProvider>().checkAuthStatus();

    // Read the profile complete and needs setup flags
    final complete = prefs.getBool('profile_complete') ?? false;
    final needsSetup = prefs.getBool('needs_profile_setup_after_signup') ?? false;
    
    if (mounted) {
      setState(() {
        _isProfileCompleteLocally = complete;
        _needsProfileSetup = needsSetup;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (_loading || authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Decide which screen to show based on auth status and needsSetup flag
    if (authProvider.isAuthenticated) {
      // If authenticated, check if profile setup is specifically needed after signup
      if (_needsProfileSetup == true) {
        // Show profile setup if needed after signup, regardless of the profile_complete flag
        return const ProfileSetupFlow();
      } else {
        // If not needing specific signup setup, proceed based on general auth status (should go to home)
        // We can still keep the _isProfileCompleteLocally check here if it's relevant for general return users
        // but for the signup vs login distinction, the _needsProfileSetup is key.
        // For simplicity based on the request, we'll go to HomeScreen if authenticated and not needing signup setup.
         return HomeScreen();
      }
    } else {
      // If not authenticated, show Google Sign-In screen
      return const GoogleSignInScreen();
    }
  }
} 