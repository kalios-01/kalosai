import 'package:flutter/material.dart';
import 'package:kalosai/profile/edit_username_screen.dart';
// import 'google_signin/google_signin_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalosai',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
          onSecondary: Colors.white,
          background: Colors.white,
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Manrope',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Manrope'),
          displayMedium: TextStyle(fontFamily: 'Manrope'),
          displaySmall: TextStyle(fontFamily: 'Manrope'),
          headlineLarge: TextStyle(fontFamily: 'Manrope'),
          headlineMedium: TextStyle(fontFamily: 'Manrope'),
          headlineSmall: TextStyle(fontFamily: 'Manrope'),
          titleLarge: TextStyle(fontFamily: 'Manrope'),
          titleMedium: TextStyle(fontFamily: 'Manrope'),
          titleSmall: TextStyle(fontFamily: 'Manrope'),
          bodyLarge: TextStyle(fontFamily: 'Manrope'),
          bodyMedium: TextStyle(fontFamily: 'Manrope'),
          bodySmall: TextStyle(fontFamily: 'Manrope'),
          labelLarge: TextStyle(fontFamily: 'Manrope'),
          labelMedium: TextStyle(fontFamily: 'Manrope'),
          labelSmall: TextStyle(fontFamily: 'Manrope'),
        ),
      ),
      home: EditUsernameScreen(userId: '123232322'),
    );
  }
}
