import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrdersUseCase {
  GetOrdersUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, List<OrderEntity>>> call() {
    return _repository.getOrders();
  }
}
