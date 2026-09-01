import 'package:equatable/equatable.dart';

import '../../data/models/admin_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthRegisterSuccess extends AuthState {
  const AuthRegisterSuccess(this.admin);

  final AdminModel admin;

  @override
  List<Object?> get props => [admin];
}

class AuthLoginSuccess extends AuthState {
  const AuthLoginSuccess({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthVerifyOtpSuccess extends AuthState {
  const AuthVerifyOtpSuccess({required this.token});

  final String token;

  @override
  List<Object?> get props => [token];
}

class AuthOtpResendSuccess extends AuthState {
  const AuthOtpResendSuccess();
}

class AuthFailure extends AuthState {
  const AuthFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
