import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/models/admin_registration_data.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, AdminEntity>> registerAdmin(
    AdminRegistrationData registrationData,
  ) async {
    try {
      final admin = await _remoteDataSource.registerAdmin(registrationData);
      return Right(admin);
    } on DioException catch (error) {
      return Left(ServerFailure(message: _getDioErrorMessage(error)));
    } on FormatException catch (error) {
      return Left(ServerFailure(message: error.message));
    } catch (_) {
      return Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.loginAdmin(email: email, password: password);

      return const Right(null);
    } on DioException catch (error) {
      return Left(ServerFailure(message: _getDioErrorMessage(error)));
    } catch (_) {
      return Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, AdminEntity>> verifyOtpAdmin({
    required String email,
    required String otpCode,
  }) async {
    try {
      final admin = await _remoteDataSource.verifyOtpAdmin(
        email: email,
        otpCode: otpCode,
      );

      return Right(admin);
    } on DioException catch (error) {
      return Left(ServerFailure(message: _getDioErrorMessage(error)));
    } on FormatException catch (error) {
      return Left(ServerFailure(message: error.message));
    } catch (_) {
      return Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resendOtpAdmin({required String email}) async {
    try {
      await _remoteDataSource.resendOtpAdmin(email: email);

      return const Right(null);
    } on DioException catch (error) {
      return Left(ServerFailure(message: _getDioErrorMessage(error)));
    } catch (_) {
      return Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
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
