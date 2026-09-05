import '../../../../core/network/api_client.dart';
import '../../domain/usecases/create_category_params.dart';
import '../../domain/usecases/update_category_params.dart';
import '../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<CategoryModel> createCategory(CreateCategoryParams params);

  Future<CategoryModel> updateCategory(UpdateCategoryParams params);
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

  @override
  Future<CategoryModel> createCategory(CreateCategoryParams params) async {
    final response = await _apiClient.dio.post(
      '/admin/categories/store',
      data: {'name': params.name, 'description': params.description},
    );

    return _parseCategoryResponse(
      response.data,
      fallbackMessage: 'Created category data was not found.',
    );
  }

  @override
  Future<CategoryModel> updateCategory(UpdateCategoryParams params) async {
    final response = await _apiClient.dio.put(
      '/admin/categories/update/${params.slug}',
      data: {'name': params.name, 'description': params.description},
    );

    return _parseCategoryResponse(
      response.data,
      fallbackMessage: 'Updated category data was not found.',
    );
  }

  CategoryModel _parseCategoryResponse(
    dynamic responseData, {
    required String fallbackMessage,
  }) {
    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Unexpected category response format.');
    }

    final rawCategory = responseData['data'] ?? responseData['category'];

    if (rawCategory is! Map<String, dynamic>) {
      throw FormatException(fallbackMessage);
    }

    return CategoryModel.fromJson(rawCategory);
  }
}
