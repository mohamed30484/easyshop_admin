import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.quantity,
    required this.categoryId,
    required this.categoryName,
    required this.visible,
    required this.imageUrl,
    this.description,
  });

  final int id;
  final String name;
  final String slug;
  final double price;
  final int quantity;
  final int categoryId;
  final String categoryName;
  final bool visible;
  final String imageUrl;
  final String? description;

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    price,
    quantity,
    categoryId,
    categoryName,
    visible,
    imageUrl,
    description,
  ];
}
