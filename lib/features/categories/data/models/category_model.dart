import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({required super.id, required super.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['categoryid'];
    final rawName = json['name'] ?? json['title'];

    final id = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;

    final name = rawName?.toString().trim() ?? '';

    if (id <= 0 || name.isEmpty) {
      throw const FormatException('Invalid category data.');
    }

    return CategoryModel(id: id, name: name);
  }
}
