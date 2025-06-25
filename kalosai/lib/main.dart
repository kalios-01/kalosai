import 'package:flutter/material.dart';
import 'package:kalos_ai/screens/google_signin_screen.dart';
import 'package:kalos_ai/screens/home_screen.dart';
import 'package:kalos_ai/screens/profile_setup/profile_setup_flow.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_setup_provider.dart';
import 'providers/goals_provider.dart';
import 'providers/food_history_provider.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';

void main() {
  // Disable debug painting
  debugPaintSizeEnabled = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileSetupProvider()),
        ChangeNotifierProvider(create: (_) => GoalsProvider()),
        ChangeNotifierProvider(create: (context) => FoodHistoryProvider(context.read<AuthProvider>().authService)),
      ],
      child: MaterialApp(
        title: 'Kalos Ai - Calorie Tracker',
        theme: AppTheme.lightTheme,
        home: ProfileSetupFlow(),
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
      ),
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  bool? _showOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_complete') ?? false;
    setState(() {
      _showOnboarding = !completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _showOnboarding!
        ? const OnboardingScreen()
        : const AuthWrapper();
  }
}
