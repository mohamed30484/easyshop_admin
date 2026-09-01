import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/usecases/login_admin_usecase.dart';
import '../../domain/usecases/register_admin_usecase.dart';
import '../../domain/usecases/verify_otp_admin_usecase.dart';
import '../../domain/usecases/resend_otp_admin_usecase.dart';
import '../models/admin_registration_data.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._registerAdminUseCase,
    this._loginAdminUseCase,
    this._verifyOtpAdminUseCase,
    this._resendOtpAdminUseCase,
  ) : super(const AuthInitial());

  final RegisterAdminUseCase _registerAdminUseCase;
  final LoginAdminUseCase _loginAdminUseCase;
  final VerifyOtpAdminUseCase _verifyOtpAdminUseCase;
  final ResendOtpAdminUseCase _resendOtpAdminUseCase;

  Future<void> registerAdmin(AdminRegistrationData registrationData) async {
    emit(const AuthLoading());

    try {
      final admin = await _registerAdminUseCase(registrationData);
      emit(AuthRegisterSuccess(admin as dynamic));
    } on DioException catch (error) {
      emit(AuthFailure(message: _getDioErrorMessage(error)));
    } catch (error) {
      emit(AuthFailure(message: error.toString()));
    }
  }

  Future<void> loginAdmin({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    try {
      await _loginAdminUseCase(email: email, password: password);
      emit(AuthLoginSuccess(email: email));
    } on DioException catch (error) {
      emit(AuthFailure(message: _getDioErrorMessage(error)));
    } catch (error) {
      emit(AuthFailure(message: error.toString()));
    }
  }

  Future<void> verifyOtpAdmin({
    required String email,
    required String otpCode,
  }) async {
    emit(const AuthLoading());

    try {
      final data = await _verifyOtpAdminUseCase(email: email, otpCode: otpCode);

      // Extract token from response
      final token = _extractToken(data);

      // Save token to SharedPreferences
      await _saveToken(token);

      emit(AuthVerifyOtpSuccess(token: token));
    } on DioException catch (error) {
      emit(AuthFailure(message: _getDioErrorMessage(error)));
    } catch (error) {
      emit(AuthFailure(message: error.toString()));
    }
  }

  String _extractToken(Map<String, dynamic> data) {
    // Try different token field names
    if (data['token'] != null && data['token'].toString().trim().isNotEmpty) {
      return data['token'].toString();
    }
    if (data['access_token'] != null &&
        data['access_token'].toString().trim().isNotEmpty) {
      return data['access_token'].toString();
    }
    if (data['data'] != null &&
        data['data']['token'] != null &&
        data['data']['token'].toString().trim().isNotEmpty) {
      return data['data']['token'].toString();
    }
    if (data['data'] != null &&
        data['data']['access_token'] != null &&
        data['data']['access_token'].toString().trim().isNotEmpty) {
      return data['data']['access_token'].toString();
    }

    // If no token found, return empty string
    return '';
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_token', token);
    } catch (e) {
      // Log error but don't fail the operation
      print('Error saving token: $e');
    }
  }

  Future<void> resendOtpAdmin({required String email}) async {
    emit(const AuthLoading());

    try {
      await _resendOtpAdminUseCase(email: email);
      emit(const AuthOtpResendSuccess());
    } on DioException catch (error) {
      emit(AuthFailure(message: _getDioErrorMessage(error)));
    } catch (error) {
      emit(AuthFailure(message: error.toString()));
    }
  }

  String _getDioErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message != null) {
        return message.toString();
      }

      final errors = data['errors'];

      if (errors is Map<String, dynamic> && errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }

        return firstError.toString();
      }
    }

    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timed out. Please try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to connect to the server.';
    }

    return 'Something went wrong. Please try again.';
  }
}
