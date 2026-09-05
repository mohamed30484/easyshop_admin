class UpdateCategoryParams {
  const UpdateCategoryParams({
    required this.slug,
    required this.name,
    required this.description,
  });

  final String slug;
  final String name;
  final String description;
}
