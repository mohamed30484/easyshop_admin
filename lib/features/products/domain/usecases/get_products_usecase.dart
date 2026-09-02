import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';

class GetProductsUseCase {
  GetProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<List<ProductEntity>> call() async {
    final result = await _repository.getProducts();

    return result.fold((failure) => throw failure, (products) => products);
  }
}
