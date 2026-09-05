class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
  });

  final int id;
  final String name;
  final String slug;
  final String description;
}
