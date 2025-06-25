import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';

class UsernameUpdateScreen extends StatefulWidget {
  const UsernameUpdateScreen({Key? key}) : super(key: key);

  @override
  State<UsernameUpdateScreen> createState() => _UsernameUpdateScreenState();
}

class _UsernameUpdateScreenState extends State<UsernameUpdateScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _submitUsername() async {
    final username = _controller.text.trim();
    if (username.isEmpty) {
      setState(() {
        _error = 'Username cannot be empty.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final idToken = await authProvider.authService.getAccessToken();
    if (idToken == null) {
      setState(() {
        _isLoading = false;
        _error = 'No Google ID token available. Please sign in again.';
      });
      return;
    }
    final url = Uri.parse('http://65.0.181.77:8000/v1/auth/username');
    try {
      print('🔒 Sending ID token to username update endpoint: Bearer $idToken');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'username': username}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success, navigate to home or next screen
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomeScreen()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          _error = 'Failed to update username. (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
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
        title: const Text('Set Your Username'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitUsername,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 