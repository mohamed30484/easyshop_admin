import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/categories_repository.dart';
import 'update_category_params.dart';

class UpdateCategoryUseCase {
  UpdateCategoryUseCase(this._repository);

  final CategoriesRepository _repository;

  Future<Either<Failure, CategoryEntity>> call(UpdateCategoryParams params) {
    return _repository.updateCategory(params);
  }
}
