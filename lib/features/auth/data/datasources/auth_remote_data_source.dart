import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../presentation/models/admin_registration_data.dart';
import '../models/admin_model.dart';

abstract class AuthRemoteDataSource {
  Future<AdminModel> registerAdmin(AdminRegistrationData registrationData);

  Future<void> loginAdmin({required String email, required String password});

  Future<Map<String, dynamic>> verifyOtpAdmin({
    required String email,
    required String otpCode,
  });

  Future<void> resendOtpAdmin({required String email});

  Future<void> logoutAdmin();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AdminModel> registerAdmin(
    AdminRegistrationData registrationData,
  ) async {
    final formData = FormData.fromMap({
      'name': registrationData.name,
      'email': registrationData.email,
      'phone': registrationData.phone,
      'password': registrationData.password,
      'password_confirmation': registrationData.passwordConfirmation,
      'national_id': registrationData.nationalId,
      'business_name': registrationData.businessName,
      if (registrationData.address.isNotEmpty)
        'address': registrationData.address,
      if (registrationData.latitude != null)
        'latitude': registrationData.latitude,
      if (registrationData.longitude != null)
        'longitude': registrationData.longitude,
    });

    if (registrationData.picture != null) {
      formData.files.add(
        MapEntry(
          'picture',
          await _attachFile('picture', registrationData.picture!.path),
        ),
      );
    }

    if (registrationData.commercialRegister != null) {
      formData.files.add(
        MapEntry(
          'commercial_register',
          await _attachFile(
            'commercial_register',
            registrationData.commercialRegister!.path,
          ),
        ),
      );
    }

    if (registrationData.taxCard != null) {
      formData.files.add(
        MapEntry(
          'tax_card',
          await _attachFile('tax_card', registrationData.taxCard!.path),
        ),
      );
    }

    final response = await _apiClient.dio.post(
      ApiConstants.adminRegister,
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );

    final responseData = response.data;

    if (responseData is Map<String, dynamic>) {
      final adminJson = _extractAdminJson(responseData);
      return AdminModel.fromJson(adminJson);
    }

    throw const FormatException('Unexpected register response format.');
  }

  /// يتأكد إن الملف المختار لسه موجود فعليًا على الجهاز قبل ما يحاول يرفعه، ويدي
  /// رسالة خطأ واضحة فيها اسم الحقل لو حصل أي خطأ في القراءة (نفس نمط تحديث
  /// البروفايل في `profile_remote_data_source.dart`).
  Future<MultipartFile> _attachFile(String fieldName, String path) async {
    final file = File(path);

    if (!await file.exists()) {
      throw Exception('Selected $fieldName file no longer exists at: $path');
    }

    try {
      return await MultipartFile.fromFile(path);
    } catch (error) {
      throw Exception('Failed to read $fieldName file ($path): $error');
    }
  }

  @override
  Future<void> loginAdmin({
    required String email,
    required String password,
  }) async {
    await _apiClient.dio.post(
      ApiConstants.adminLogin,
      data: {'email': email, 'password': password},
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  @override
  Future<Map<String, dynamic>> verifyOtpAdmin({
    required String email,
    required String otpCode,
  }) async {
    final response = await _apiClient.dio.post(
      ApiConstants.adminOtpVerify,
      data: {'email': email, 'otp_code': otpCode},
      options: Options(contentType: Headers.jsonContentType),
    );

    final responseData = response.data;

    if (responseData is Map<String, dynamic>) {
      return responseData;
    }

    throw const FormatException('Unexpected verify OTP response format.');
  }

  @override
  Future<void> resendOtpAdmin({required String email}) async {
    await _apiClient.dio.post(
      ApiConstants.adminOtpResend,
      data: {'email': email},
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  @override
  Future<void> logoutAdmin() async {
    await _apiClient.dio.post(ApiConstants.adminLogout);
  }

  Map<String, dynamic> _extractAdminJson(Map<String, dynamic> responseData) {
    final data = responseData['data'];

    if (data is Map<String, dynamic>) {
      final user = data['user'];

      if (user is Map<String, dynamic>) {
        return user;
      }

      return data;
    }

    final user = responseData['user'];

    if (user is Map<String, dynamic>) {
      return user;
    }

    return responseData;
  }
}
