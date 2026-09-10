import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../categories/domain/usecases/get_categories_usecase.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/usecases/get_orders_usecase.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/usecases/get_products_usecase.dart';
import 'home_state.dart';

/// أقصى عدد عناصر بتتعرض في قسمي "Recent Orders" و"Products Overview" في
/// صفحة الهوم — القائمة الكاملة متاحة من زرار "See all" اللي بيودي لصفحة
/// الـ Orders/Products الكاملة.
const int _kHomePreviewLimit = 3;

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._getProductsUseCase,
    this._getOrdersUseCase,
    this._getCategoriesUseCase,
  ) : super(const HomeInitial());

  final GetProductsUseCase _getProductsUseCase;
  final GetOrdersUseCase _getOrdersUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;

  /// بيجيب المنتجات والطلبات والتصنيفات كلها من الـ API في نفس الوقت، وبيحسب
  /// منهم كل إحصائيات صفحة الهوم (لا يوجد endpoint مخصص للـ dashboard، فبنبني
  /// الأرقام من نفس الـ list endpoints اللي بتستخدمها صفحات المنتجات/الطلبات/
  /// التصنيفات).
  Future<void> loadDashboard() async {
    emit(const HomeLoading());

    try {
      final products = await _getProductsUseCase();

      final ordersResult = await _getOrdersUseCase();
      final orders = ordersResult.fold(
        (failure) => throw failure,
        (value) => value,
      );

      final categoriesResult = await _getCategoriesUseCase();
      final categories = categoriesResult.fold(
        (failure) => throw failure,
        (value) => value,
      );

      emit(
        HomeLoaded(
          totalProducts: products.length,
          totalOrders: orders.length,
          pendingOrders: orders
              .where(
                (order) =>
                    order.status.trim().toLowerCase().contains('pending'),
              )
              .length,
          totalCategories: categories.length,
          recentOrders: _mostRecentOrders(orders),
          productsOverview: _mostRecentProducts(products),
        ),
      );
    } catch (error) {
      emit(HomeFailure(_errorMessage(error)));
    }
  }

  List<OrderEntity> _mostRecentOrders(List<OrderEntity> orders) {
    final sorted = List<OrderEntity>.from(orders)
      ..sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return bDate.compareTo(aDate);
      });

    return sorted.take(_kHomePreviewLimit).toList();
  }

  List<ProductEntity> _mostRecentProducts(List<ProductEntity> products) {
    final sorted = List<ProductEntity>.from(products)
      ..sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return bDate.compareTo(aDate);
      });

    return sorted.take(_kHomePreviewLimit).toList();
  }

  String _errorMessage(Object error) {
    final message = error.toString();

    const failurePrefix = 'ServerFailure(message: ';
    if (message.startsWith(failurePrefix) && message.endsWith(')')) {
      return message.substring(failurePrefix.length, message.length - 1).trim();
    }

    return message.replaceFirst('Exception: ', '').trim();
  }
}
