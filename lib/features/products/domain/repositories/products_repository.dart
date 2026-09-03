import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../usecases/create_product_params.dart';
import '../usecases/update_product_params.dart';

abstract class ProductsRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();

  Future<Either<Failure, ProductEntity>> createProduct(
    CreateProductParams params,
  );

  Future<Either<Failure, ProductEntity>> updateProduct(
    UpdateProductParams params,
  );

  Future<Either<Failure, void>> deleteProduct(String slug);
}
