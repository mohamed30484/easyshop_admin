import '../../../../core/error/failures.dart';
import '../repositories/products_repository.dart';

class DeleteProductUseCase {
  const DeleteProductUseCase(this._repository);

  final ProductsRepository _repository;

  Future<void> call(String slug) async {
    final result = await _repository.deleteProduct(slug);

    result.fold((Failure failure) => throw Exception(failure.message), (_) {});
  }
}
