import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/categories_repository.dart';

class DeleteCategoryUseCase {
  DeleteCategoryUseCase(this._repository);

  final CategoriesRepository _repository;

  Future<Either<Failure, void>> call(String slug) {
    return _repository.deleteCategory(slug);
  }
}
