import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/admin_model.dart';
import '../../domain/usecases/update_profile_params.dart';

abstract class ProfileRemoteDataSource {
  Future<AdminModel> getProfile();

  Future<AdminModel> updateProfile(UpdateProfileParams params);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AdminModel> getProfile() async {
    final response = await _apiClient.dio.get(ApiConstants.adminProfile);

    final responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Unexpected profile response format.');
    }

    return AdminModel.fromJson(_extractAdminJson(responseData));
  }

  @override
  Future<AdminModel> updateProfile(UpdateProfileParams params) async {
    final formData = FormData.fromMap({
      // معظم سيرفرات Laravel لا تقرأ الـ multipart body مع PUT الحقيقي،
      // لذلك نرسل الطلب كـ POST مع تمويه الـ method مثل تحديث المنتج.
      '_method': 'PUT',
      'name': params.name,
      'email': params.email,
      'phone': params.phone,
      'national_id': params.nationalId,
      'business_name': params.businessName,
      'address': params.address ?? '',
      if (params.latitude != null) 'latitude': params.latitude.toString(),
      if (params.longitude != null) 'longitude': params.longitude.toString(),
    });

    if (params.picturePath != null && params.picturePath!.trim().isNotEmpty) {
      formData.files.add(
        MapEntry('picture', await _attachFile('picture', params.picturePath!)),
      );
    }

    if (params.commercialRegisterPath != null &&
        params.commercialRegisterPath!.trim().isNotEmpty) {
      formData.files.add(
        MapEntry(
          'commercial_register',
          await _attachFile(
            'commercial_register',
            params.commercialRegisterPath!,
          ),
        ),
      );
    }

    if (params.taxCardPath != null && params.taxCardPath!.trim().isNotEmpty) {
      formData.files.add(
        MapEntry(
          'tax_card',
          await _attachFile('tax_card', params.taxCardPath!),
        ),
      );
    }

    final response = await _apiClient.dio.post(
      ApiConstants.adminProfileUpdate,
      data: formData,
    );

    final responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Unexpected update profile response format.');
    }

    return AdminModel.fromJson(_extractAdminJson(responseData));
  }

  /// يتأكد الملف المختار لسه موجود فعليًا على الجهاز قبل ما يحاول يرفعه، ويدي
  /// رسالة خطأ واضحة فيها اسم الحقل لو حصل أي خطأ في القراءة (بدل exception عام غير
  /// واضح).
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

  Map<String, dynamic> _extractAdminJson(Map<String, dynamic> responseData) {
    final data = responseData['data'];

    if (data is Map<String, dynamic>) {
      final admin = data['admin'] ?? data['user'] ?? data['profile'];

      if (admin is Map<String, dynamic>) {
        return admin;
      }

      return data;
    }

    final admin =
        responseData['admin'] ??
        responseData['user'] ??
        responseData['profile'];

    if (admin is Map<String, dynamic>) {
      return admin;
    }

    return responseData;
  }
}
