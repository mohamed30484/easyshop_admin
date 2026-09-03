import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_product_params.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/update_product_params.dart';
import '../../domain/usecases/update_product_usecase.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(
    this._getProductsUseCase,
    this._createProductUseCase,
    this._deleteProductUseCase,
    this._updateProductUseCase,
  ) : super(const ProductsInitial());

  final GetProductsUseCase _getProductsUseCase;
  final CreateProductUseCase _createProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;
  final UpdateProductUseCase _updateProductUseCase;

  Future<void> getProducts() async {
    emit(const ProductsLoading());

    try {
      final products = await _getProductsUseCase();

      emit(ProductsLoaded(products));
    } catch (error) {
      emit(ProductsFailure(_errorMessage(error)));
    }
  }

  Future<void> createProduct(CreateProductParams params) async {
    emit(const ProductCreating());

    try {
      final product = await _createProductUseCase(params);

      emit(ProductCreated(product));
    } catch (error) {
      emit(ProductCreateFailure(_errorMessage(error)));
    }
  }

  Future<void> updateProduct(UpdateProductParams params) async {
    emit(const ProductUpdating());

    try {
      final product = await _updateProductUseCase(params);

      emit(ProductUpdated(product));
    } catch (error) {
      emit(ProductUpdateFailure(_errorMessage(error)));
    }
  }

  Future<void> deleteProduct(String slug) async {
    emit(const ProductDeleting());

    try {
      await _deleteProductUseCase(slug);

      emit(const ProductDeleted());
    } catch (error) {
      emit(ProductDeleteFailure(_errorMessage(error)));
    }
  }

  String _errorMessage(Object error) {
    final message = error.toString();

    const failurePrefix = 'ServerFailure(message: ';
    if (message.startsWith(failurePrefix) && message.endsWith(')')) {
      return message.substring(failurePrefix.length, message.length - 1).trim();
    }

    return message.replaceFirst('Exception: ', '').trim();
  }
}
