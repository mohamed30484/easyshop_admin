class CreateProductParams {
  const CreateProductParams({
    required this.name,
    required this.price,
    required this.quantity,
    required this.categoryId,
    required this.visible,
    this.description,
    this.imagePath,
  });

  final String name;
  final double price;
  final int quantity;
  final int categoryId;
  final bool visible;
  final String? description;
  final String? imagePath;
}
