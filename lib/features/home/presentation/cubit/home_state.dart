import '../../../orders/domain/entities/order_entity.dart';
import '../../../products/domain/entities/product_entity.dart';

sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.totalProducts,
    required this.totalOrders,
    required this.pendingOrders,
    required this.totalCategories,
    required this.recentOrders,
    required this.productsOverview,
  });

  /// إجمالي عدد المنتجات الراجع من GET /admin/products.
  final int totalProducts;

  /// إجمالي عدد الطلبات الراجع من GET /admin/orders.
  final int totalOrders;

  /// عدد الطلبات اللي لسه status بتاعها "pending".
  final int pendingOrders;

  /// إجمالي عدد التصنيفات الراجع من GET /admin/categories.
  final int totalCategories;

  /// أحدث الطلبات (الأحدث أولاً) لعرضها في قسم "Recent Orders".
  final List<OrderEntity> recentOrders;

  /// عينة من المنتجات (الأحدث أولاً) لعرضها في قسم "Products Overview".
  final List<ProductEntity> productsOverview;
}

class HomeFailure extends HomeState {
  const HomeFailure(this.message);

  final String message;
}
