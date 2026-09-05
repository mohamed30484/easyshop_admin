import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/categories_repository.dart';
import 'create_category_params.dart';

class CreateCategoryUseCase {
  CreateCategoryUseCase(this._repository);

  final CategoriesRepository _repository;

  Future<Either<Failure, CategoryEntity>> call(CreateCategoryParams params) {
    return _repository.createCategory(params);
  }
}
