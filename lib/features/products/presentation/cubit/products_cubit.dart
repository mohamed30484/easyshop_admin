import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_products_usecase.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._getProductsUseCase) : super(const ProductsInitial());

  final GetProductsUseCase _getProductsUseCase;

  Future<void> getProducts() async {
    emit(const ProductsLoading());

    try {
      final products = await _getProductsUseCase();

      emit(ProductsLoaded(products));
    } on DioException catch (error) {
      emit(
        ProductsFailure(
          error.response?.data is Map<String, dynamic>
              ? (error.response?.data['message']?.toString() ??
                    'Failed to load products.')
              : 'Failed to load products.',
        ),
      );
    } catch (error) {
      emit(ProductsFailure(error.toString()));
    }
  }
}
