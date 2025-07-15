import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../profile/edit_username_screen.dart';
import 'bloc/google_signin_bloc.dart';
import 'bloc/google_signin_event.dart';
import 'bloc/google_signin_state.dart';

class GoogleSignInScreen extends StatelessWidget {
  const GoogleSignInScreen({Key? key}) : super(key: key);

  void _showErrorSnackbar(BuildContext context, String message) {
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

  void _navigateToEditUsername(BuildContext context, String userId, String accessToken) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EditUsernameScreen(userId: userId, accessToken: accessToken),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (_) => GoogleSignInBloc(),
      child: BlocListener<GoogleSignInBloc, GoogleSignInState>(
        listener: (context, state) {
          if (state is GoogleSignInFailure) {
            _showErrorSnackbar(context, state.error);
          } else if (state is GoogleSignInSuccess) {
            _navigateToEditUsername(context, state.userId, state.accessToken);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF222222),
          body: Column(
            children: [
              Expanded(
                flex: 4, // 40%
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF222222),
                  child: Image.asset(
                    'assets/images/signin_image.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Expanded(
                flex: 6, // 60%
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Welcome to KALOS AI',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Manrope',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Track calories, compete, and achieve your fitness goals.',
                          style: TextStyle(
                            fontSize: 18, 
                            color: Colors.black87,
                            fontFamily: 'Manrope',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<GoogleSignInBloc, GoogleSignInState>(
                          builder: (context, state) {
                            if (state is GoogleSignInLoading) {
                              return const CircularProgressIndicator();
                            } else if (state is GoogleSignInSuccess) {
                              return const Text(
                                'Sign in successful!',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontFamily: 'Manrope',
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const Spacer(),
                        _GoogleSignInButton(),
                        const SizedBox(height: 20),
                        const Text(
                          'By continuing, you agree to our Terms of Service and Privacy Policy.',
                          style: TextStyle(
                            fontSize: 15, 
                            color: Colors.black38,
                            fontFamily: 'Manrope',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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

class _GoogleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<GoogleSignInBloc>().add(GoogleSignInRequested());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: const BorderSide(color: Colors.transparent),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/google_logo.svg', height: 28, width: 28),
            const SizedBox(width: 16),
            const Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Manrope',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
