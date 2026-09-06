import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getOrders();
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  OrdersRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await _apiClient.dio.get('/admin/orders');

    final responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Unexpected orders response format.');
    }

    final rawData = responseData['data'];

    final List<dynamic>? orders = switch (rawData) {
      List<dynamic>() => rawData,
      Map<String, dynamic>() =>
        rawData['data'] as List<dynamic>? ??
            rawData['orders'] as List<dynamic>?,
      _ => responseData['orders'] as List<dynamic>?,
    };

    if (orders == null) {
      throw const FormatException('Orders list was not found.');
    }

    return orders
        .whereType<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .toList();
  }
}
