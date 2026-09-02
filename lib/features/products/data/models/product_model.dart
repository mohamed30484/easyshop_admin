import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.price,
    required super.quantity,
    required super.categoryId,
    required super.categoryName,
    required super.visible,
    required super.imageUrl,
    super.description,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'];

    return ProductModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      price: _toDouble(json['price']),
      quantity: _toInt(json['quantity']),
      categoryId: _toInt(json['category_id']),
      categoryName: category is Map<String, dynamic>
          ? category['name']?.toString() ?? 'Uncategorized'
          : 'Uncategorized',
      visible: _toBool(json['visible']),
      imageUrl: json['image_url']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value == 1;
    }

    final normalizedValue = value?.toString().trim().toLowerCase();

    return normalizedValue == '1' || normalizedValue == 'true';
  }
}
