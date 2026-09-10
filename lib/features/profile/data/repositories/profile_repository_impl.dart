import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/admin_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile_params.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, AdminEntity>> getProfile() async {
    try {
      final admin = await _remoteDataSource.getProfile();

      return Right(admin);
    } on DioException catch (error) {
      return Left(ServerFailure(message: _getDioErrorMessage(error)));
    } on FormatException catch (error) {
      return Left(ServerFailure(message: error.message));
    } catch (error) {
      return Left(ServerFailure(message: _unexpectedErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, AdminEntity>> updateProfile(
    UpdateProfileParams params,
  ) async {
    try {
      final admin = await _remoteDataSource.updateProfile(params);

      return Right(admin);
    } on DioException catch (error) {
      return Left(ServerFailure(message: _getDioErrorMessage(error)));
    } on FormatException catch (error) {
      return Left(ServerFailure(message: error.message));
    } catch (error) {
      return Left(ServerFailure(message: _unexpectedErrorMessage(error)));
    }
  }

  /// رسالة عامة مناسبة للمستخدم النهائي لأي exception حقيقي غير متوقع (مش رفض من
  /// السيرفر). النص التفصيلي للخطأ لسه متطبع في الـ console عبر
  /// `debugPrint('SAVE_ERROR: ...')` في edit_profile_page.dart.
  String _unexpectedErrorMessage(Object error) {
    return 'Something went wrong. Please try again.';
  }

  String _getDioErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      // رسائل الـ validation بتيجي عادةً في Map، سواء تحت 'errors' (الشكل
      // المعتاد في Laravel) أو تحت 'message' نفسها لو رجعت Map مباشرة بدل
      // ما ترجع String — بناخد أول رسالة واضحة بدل ما نطبع الـ Map كله
      // زي ما هي بصيغة غير مقروءة.
      final fieldError =
          _firstFieldError(data['errors']) ?? _firstFieldError(message);

      if (fieldError != null) {
        return fieldError;
      }

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
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

  /// يدور على Map من شكل {"field": ["msg1", "msg2"]} (رسائل الـ validation في
  /// Laravel) ويرجّع أول رسالة لأول حقل، بدل ما نطبع الـ Map/List بصيغتها الخام.
  String? _firstFieldError(dynamic errors) {
    if (errors is Map<String, dynamic>) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }

        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
      }
    }

    return null;
  }
}
