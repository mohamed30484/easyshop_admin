import 'package:equatable/equatable.dart';

import '../../domain/entities/product_entity.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductsState {
  const ProductsLoaded(this.products);

  final List<ProductEntity> products;

  @override
  List<Object?> get props => [products];
}

class ProductsFailure extends ProductsState {
  const ProductsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ProductCreating extends ProductsState {
  const ProductCreating();
}

class ProductCreated extends ProductsState {
  const ProductCreated(this.product);

  final ProductEntity product;

  @override
  List<Object?> get props => [product];
}

class ProductCreateFailure extends ProductsState {
  const ProductCreateFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ProductUpdating extends ProductsState {
  const ProductUpdating();
}

class ProductUpdated extends ProductsState {
  const ProductUpdated(this.product);

  final ProductEntity product;

  @override
  List<Object?> get props => [product];
}

class ProductUpdateFailure extends ProductsState {
  const ProductUpdateFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ProductDeleting extends ProductsState {
  const ProductDeleting();
}

class ProductDeleted extends ProductsState {
  const ProductDeleted();
}

class ProductDeleteFailure extends ProductsState {
  const ProductDeleteFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
