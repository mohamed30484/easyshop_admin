import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts();
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
}
