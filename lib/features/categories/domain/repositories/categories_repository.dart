import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../usecases/create_category_params.dart';
import '../usecases/update_category_params.dart';

abstract class CategoriesRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, CategoryEntity>> createCategory(
    CreateCategoryParams params,
  );

  Future<Either<Failure, CategoryEntity>> updateCategory(
    UpdateCategoryParams params,
  );
}
