class UpdateProductParams {
  const UpdateProductParams({
    required this.slug,
    required this.name,
    required this.price,
    required this.quantity,
    required this.categoryId,
    required this.visible,
    this.description,
    this.imagePath,
  });

  /// الـ slug مطلوب داخل مسار API:
  /// /admin/products/update/{slug}
  final String slug;

  final String name;
  final double price;
  final int quantity;
  final int categoryId;
  final bool visible;
  final String? description;

  /// تكون null إذا المستخدم لم يغيّر الصورة،
  /// وبالتالي نحتفظ بصورة المنتج القديمة في السيرفر.
  final String? imagePath;
}
