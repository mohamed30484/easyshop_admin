import '../../domain/entities/category_entity.dart';

sealed class CategoriesState {
  const CategoriesState();
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded(this.categories);

  final List<CategoryEntity> categories;
}

class CategoriesCreating extends CategoriesState {
  const CategoriesCreating();
}

class CategoriesCreated extends CategoriesState {
  const CategoriesCreated(this.category);

  final CategoryEntity category;
}

class CategoriesUpdating extends CategoriesState {
  const CategoriesUpdating();
}

class CategoriesUpdated extends CategoriesState {
  const CategoriesUpdated(this.category);

  final CategoryEntity category;
}

class CategoriesFailure extends CategoriesState {
  const CategoriesFailure(this.message);

  final String message;
}
