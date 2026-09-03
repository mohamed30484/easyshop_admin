import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';
import 'create_product_params.dart';

class CreateProductUseCase {
  CreateProductUseCase(this._repository);

  final ProductsRepository _repository;

  Future<ProductEntity> call(CreateProductParams params) async {
    final result = await _repository.createProduct(params);

    return result.fold((failure) => throw failure, (product) => product);
  }
}
