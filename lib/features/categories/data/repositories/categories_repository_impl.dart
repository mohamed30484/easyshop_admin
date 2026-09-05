import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/categories_repository.dart';
import '../../domain/usecases/create_category_params.dart';
import '../../domain/usecases/update_category_params.dart';
import '../datasources/categories_remote_data_source.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  CategoriesRepositoryImpl(this._remoteDataSource);

  final CategoriesRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await _remoteDataSource.getCategories();
      return Right(categories);
    } on DioException catch (error) {
      return Left(ServerFailure(message: _getDioErrorMessage(error)));
    } on FormatException catch (error) {
      return Left(ServerFailure(message: error.message));
    } catch (_) {
      return const Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory(
    CreateCategoryParams params,
  ) async {
    try {
      final category = await _remoteDataSource.createCategory(params);
      return Right(category);
    } on DioException catch (error) {
      return Left(ServerFailure(message: _getDioErrorMessage(error)));
    } on FormatException catch (error) {
      return Left(ServerFailure(message: error.message));
    } catch (_) {
      return const Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(
    UpdateCategoryParams params,
  ) async {
    try {
      final category = await _remoteDataSource.updateCategory(params);
      return Right(category);
    } on DioException catch (error) {
      return Left(ServerFailure(message: _getDioErrorMessage(error)));
    } on FormatException catch (error) {
      return Left(ServerFailure(message: error.message));
    } catch (_) {
      return const Left(
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

        if (firstError != null) {
          return firstError.toString();
        }
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
