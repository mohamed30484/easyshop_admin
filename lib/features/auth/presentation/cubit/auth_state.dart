import '../../domain/entities/admin_entity.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthRegisterSuccess extends AuthState {
  const AuthRegisterSuccess(this.admin);

  final AdminEntity admin;
}

class AuthLoginSuccess extends AuthState {
  const AuthLoginSuccess({required this.email});

  final String email;
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;
}
