import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';
import 'update_product_params.dart';

class UpdateProductUseCase {
  const UpdateProductUseCase(this._repository);

  final ProductsRepository _repository;

  Future<ProductEntity> call(UpdateProductParams params) async {
    final result = await _repository.updateProduct(params);

    return result.fold(
      (Failure failure) => throw Exception(failure.message),
      (product) => product,
    );
  }
}
