import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/usecases/create_product_params.dart';
import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts();

  Future<ProductModel> createProduct(CreateProductParams params);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  ProductsRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await _apiClient.dio.get('/admin/products');

    final responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Unexpected products response format.');
    }

    final data = responseData['data'];

    if (data is! List) {
      throw const FormatException('Products list was not found.');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }

  @override
  Future<ProductModel> createProduct(CreateProductParams params) async {
    final formData = FormData.fromMap({
      'name': params.name,
      'price': params.price.toString(),
      'quantity': params.quantity.toString(),
      'categoryid': params.categoryId.toString(),
      'visible': params.visible ? '1' : '0',
      if (params.description != null && params.description!.trim().isNotEmpty)
        'description': params.description!.trim(),
    });

    if (params.imagePath != null && params.imagePath!.trim().isNotEmpty) {
      formData.files.add(
        MapEntry('image', await MultipartFile.fromFile(params.imagePath!)),
      );
    }

    final response = await _apiClient.dio.post(
      '/admin/products/store',
      data: formData,
    );

    final responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Unexpected create product response format.');
    }

    final data = responseData['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Created product data was not found.');
    }

    return ProductModel.fromJson(data);
  }
}
