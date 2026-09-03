import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  CategoriesRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.dio.get('/admin/categories');

    final responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Unexpected categories response format.');
    }

    final rawData = responseData['data'];

    final List<dynamic>? categories = switch (rawData) {
      List<dynamic>() => rawData,
      Map<String, dynamic>() =>
        rawData['data'] as List<dynamic>? ??
            rawData['categories'] as List<dynamic>?,
      _ => null,
    };

    if (categories == null) {
      throw const FormatException('Categories list was not found.');
    }

    return categories
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }
}
