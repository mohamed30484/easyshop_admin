import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/admin_profile_storage.dart';
import '../../data/models/admin_model.dart';
import '../../domain/usecases/login_admin_usecase.dart';
import '../../domain/usecases/register_admin_usecase.dart';
import '../../domain/usecases/resend_otp_admin_usecase.dart';
import '../../domain/usecases/verify_otp_admin_usecase.dart';
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

  final AdminProfileStorage _profileStorage = AdminProfileStorage();

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
      final response = await _verifyOtpAdminUseCase(
        email: email,
        otpCode: otpCode,
      );

      final token = _extractToken(response);
      final admin = _extractAdmin(response);

      await _saveToken(token);
      await _profileStorage.save(admin);

      emit(AuthVerifyOtpSuccess(token: token));
    } on DioException catch (error) {
      emit(AuthFailure(message: _getDioErrorMessage(error)));
    } on FormatException catch (error) {
      emit(AuthFailure(message: error.message));
    } catch (error) {
      emit(AuthFailure(message: error.toString()));
    }
  }

  AdminModel _extractAdmin(Map<String, dynamic> response) {
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      final user = data['user'];

      if (user is Map<String, dynamic>) {
        return AdminModel.fromJson(user);
      }

      return AdminModel.fromJson(data);
    }

    final user = response['user'];

    if (user is Map<String, dynamic>) {
      return AdminModel.fromJson(user);
    }

    return AdminModel.fromJson(response);
  }

  String _extractToken(Map<String, dynamic> response) {
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      final token = data['token'] ?? data['access_token'];

      if (token != null && token.toString().trim().isNotEmpty) {
        return token.toString().trim();
      }
    }

    final token = response['token'] ?? response['access_token'];

    if (token != null && token.toString().trim().isNotEmpty) {
      return token.toString().trim();
    }

    throw const FormatException(
      'Token was not found in the verify OTP response.',
    );
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    final saved = await prefs.setString('admin_token', token);

    if (!saved) {
      throw Exception('Failed to save admin token.');
    }

    final storedToken = prefs.getString('admin_token');

    if (storedToken == null || storedToken.trim().isEmpty) {
      throw Exception('Admin token was not saved correctly.');
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

      if (message != null && message.toString().trim().isNotEmpty) {
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

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Connection timed out. Please try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to connect to the server.';
    }

    return 'Something went wrong. Please try again.';
  }
}
