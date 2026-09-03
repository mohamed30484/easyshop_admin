import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../../domain/usecases/create_product_params.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._remoteDataSource);

  final ProductsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      final products = await _remoteDataSource.getProducts();

      return Right(products);
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
  Future<Either<Failure, ProductEntity>> createProduct(
    CreateProductParams params,
  ) async {
    try {
      final product = await _remoteDataSource.createProduct(params);

      return Right(product);
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

      if (errors is Map<String, dynamic>) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
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
