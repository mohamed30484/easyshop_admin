import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_category_params.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/update_category_params.dart';
import '../../domain/usecases/update_category_usecase.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(
    this._getCategoriesUseCase,
    this._createCategoryUseCase,
    this._updateCategoryUseCase,
  ) : super(const CategoriesInitial());

  final GetCategoriesUseCase _getCategoriesUseCase;
  final CreateCategoryUseCase _createCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;

  Future<void> getCategories() async {
    emit(const CategoriesLoading());

    final result = await _getCategoriesUseCase();

    result.fold(
      (failure) => emit(CategoriesFailure(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  Future<void> createCategory(CreateCategoryParams params) async {
    emit(const CategoriesCreating());

    final result = await _createCategoryUseCase(params);

    result.fold(
      (failure) => emit(CategoriesFailure(failure.message)),
      (category) => emit(CategoriesCreated(category)),
    );
  }

  Future<void> updateCategory(UpdateCategoryParams params) async {
    emit(const CategoriesUpdating());

    final result = await _updateCategoryUseCase(params);

    result.fold(
      (failure) => emit(CategoriesFailure(failure.message)),
      (category) => emit(CategoriesUpdated(category)),
    );
  }
}
