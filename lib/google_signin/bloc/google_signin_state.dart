import 'package:equatable/equatable.dart';

abstract class GoogleSignInState extends Equatable {
  const GoogleSignInState();

  @override
  List<Object?> get props => [];
}

class GoogleSignInInitial extends GoogleSignInState {}

class GoogleSignInLoading extends GoogleSignInState {}

class GoogleSignInSuccess extends GoogleSignInState {
  final String accessToken;
  final String userId;
  const GoogleSignInSuccess({required this.accessToken, required this.userId});

  @override
  List<Object?> get props => [accessToken, userId];
}

class GoogleSignInFailure extends GoogleSignInState {
  final String error;
  const GoogleSignInFailure(this.error);

  @override
  List<Object?> get props => [error];
} 