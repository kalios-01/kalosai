import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class EditUsernameScreen extends StatefulWidget {
  final String userId;
  final String? accessToken;
  const EditUsernameScreen({Key? key, required this.userId, this.accessToken}) : super(key: key);

  @override
  State<EditUsernameScreen> createState() => _EditUsernameScreenState();
}

class _EditUsernameScreenState extends State<EditUsernameScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    setState(() { _loading = true; });
    try {
      final url = Uri.parse('https://a9527bf3ba73.ngrok-free.app/v1/user/${widget.userId}/username');
      final response = await http.get(url, headers: widget.accessToken != null ? {'Authorization': 'Bearer ${widget.accessToken}'} : {});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _controller.text = data['username'] ?? '';
      } else {
        _showError('Failed to fetch username.');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _saveUsername() async {
    final username = _controller.text.trim();
    if (username.length < 3) {
      _showError('Username must be at least 3 characters.');
      return;
    }
    if (username.length > 20) {
      _showError('Username exceeded character limit.');
      return;
    }
    setState(() { _saving = true; });
    try {
      final url = Uri.parse('https://a9527bf3ba73.ngrok-free.app/v1/user/${widget.userId}/username');
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (widget.accessToken != null) 'Authorization': 'Bearer ${widget.accessToken}',
        },
        body: json.encode({'username': username}),
      );
      if (response.statusCode == 200) {
        Navigator.pop(context, username);
      } else {
        _showError('Failed to update username.');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() { _saving = false; });
    }
  }

  void _showError(String message) {
    final snackBar = SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      content: AwesomeSnackbarContent(
        title: 'Error',
        message: message,
        contentType: ContentType.failure,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Row(
                  children: [
                    const Text(
                      'Edit username',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: const Text(
                  'Username',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: TextField(
                  controller: _controller,
                  enabled: !_loading && !_saving,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.black12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Text(
                  '${_controller.text.length}/20 characters',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: _controller.text.length > 20 ? Colors.red : Colors.black38,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading || _saving ? null : _saveUsername,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 