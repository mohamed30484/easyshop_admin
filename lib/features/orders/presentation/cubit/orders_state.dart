import '../../domain/entities/order_entity.dart';

sealed class OrdersState {
  const OrdersState();
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  const OrdersLoaded(this.orders);

  final List<OrderEntity> orders;
}

class OrdersFailure extends OrdersState {
  const OrdersFailure(this.message);

  final String message;
}
