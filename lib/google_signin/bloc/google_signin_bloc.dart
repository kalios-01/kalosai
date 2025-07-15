import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'google_signin_event.dart';
import 'google_signin_state.dart';

class GoogleSignInBloc extends Bloc<GoogleSignInEvent, GoogleSignInState> {
  static const String _androidClientId =
      '552853286855-2lonrk45gunof5dva0g816dap4aal7r4.apps.googleusercontent.com';
  static const String _backendUrl =
      'https://a9527bf3ba73.ngrok-free.app/v1/auth/google';
  static const String _serverwebclientid =
      '552853286855-c92u9squhkpsl0he8r0g7eckg596p1fg.apps.googleusercontent.com';
  late final StreamSubscription _authSub;

  GoogleSignInBloc() : super(GoogleSignInInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    await GoogleSignIn.instance.initialize(
      clientId: _androidClientId,
      serverClientId: _serverwebclientid,
    );
    _authSub = GoogleSignIn.instance.authenticationEvents.listen(_onAuthEvent);
    GoogleSignIn.instance.attemptLightweightAuthentication();
  }

  Future<void> _onAuthEvent(GoogleSignInAuthenticationEvent event) async {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      final user = event.user;
      final auth = await user.authentication;
      final idToken = auth.idToken;
      print('Google User Info:');
      print('Display Name: ${user.displayName}');
      print('Email: ${user.email}');
      print('ID: ${user.id}');
      print('Photo URL: ${user.photoUrl}');
      print('ID Token: ${idToken}');
      if (idToken != null) {
        final tokenPayload = jsonEncode({'id_token': idToken});
        print('Sending token payload to backend: ${tokenPayload}');
        final response = await http.post(
          Uri.parse(_backendUrl),
          headers: {'Content-Type': 'application/json'},
          body: tokenPayload,
        );
        print('Server response status: ${response.statusCode}');
        print('Server response body: ${response.body}');
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final data = responseData['data'];
          final accessToken = data['access_token'] as String;
          final userId = data['user']['user_id'] as String;
          emit(GoogleSignInSuccess(accessToken: accessToken, userId: userId));
        } else {
          emit(GoogleSignInFailure('Backend error: ${response.statusCode}'));
        }
      } else {
        emit(const GoogleSignInFailure('Failed to get ID token'));
      }
    } else {
      emit(const GoogleSignInFailure('Sign in failed or signed out'));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<GoogleSignInState> emit,
  ) async {
    emit(GoogleSignInLoading());
    try {
      await GoogleSignIn.instance.authenticate();
    } catch (e) {
      emit(GoogleSignInFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }
}
