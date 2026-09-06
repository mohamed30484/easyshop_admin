import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_orders_usecase.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._getOrdersUseCase) : super(const OrdersInitial());

  final GetOrdersUseCase _getOrdersUseCase;

  Future<void> getOrders() async {
    emit(const OrdersLoading());

    final result = await _getOrdersUseCase();

    result.fold(
      (failure) => emit(OrdersFailure(failure.message)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }
}
