import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['categoryid'];
    final rawName = json['name'] ?? json['title'];
    final rawSlug = json['slug'];
    final rawDescription = json['description'] ?? json['details'];

    final id = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;

    final name = rawName?.toString().trim() ?? '';
    final slug = rawSlug?.toString().trim() ?? '';
    final description = rawDescription?.toString().trim() ?? '';

    if (id <= 0 || name.isEmpty || slug.isEmpty) {
      throw const FormatException('Invalid category data.');
    }

    return CategoryModel(
      id: id,
      name: name,
      slug: slug,
      description: description,
    );
  }
}
