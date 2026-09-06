import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.code,
    required super.customerName,
    required super.customerEmail,
    required super.customerPhone,
    required super.createdAt,
    required super.itemsCount,
    required super.paymentMethod,
    required super.status,
    required super.total,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['orderid'];
    final rawCode = json['code'] ?? json['ordercode'] ?? json['number'];

    final rawClient = json['client'] ?? json['customer'] ?? json['user'];
    final client = rawClient is Map<String, dynamic> ? rawClient : null;

    final rawCreatedAt =
        json['date'] ?? json['created_at'] ?? json['createdat'];

    final rawItems =
        json['order_items'] ??
        json['items'] ??
        json['products'] ??
        const <dynamic>[];

    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    OrderItemModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <OrderItemEntity>[];

    final rawPayment =
        json['payment_method'] ?? json['paymentmethod'] ?? json['payment'];

    final rawStatus = json['status'] ?? json['order_status'];

    final rawTotal =
        json['total'] ??
        json['total_price'] ??
        json['totalprice'] ??
        json['amount'];

    final id = _toInt(rawId);
    final code = rawCode?.toString().trim() ?? '';

    if (id <= 0 || code.isEmpty) {
      throw const FormatException('Invalid order data.');
    }

    final customerName = _readString(
      client?['name'] ??
          client?['fullname'] ??
          client?['full_name'] ??
          json['customer_name'] ??
          json['client_name'],
    );

    final customerEmail = _readNullableString(
      client?['email'] ?? json['customer_email'] ?? json['client_email'],
    );

    final customerPhone = _readNullableString(
      client?['phone'] ?? json['customer_phone'] ?? json['client_phone'],
    );

    return OrderModel(
      id: id,
      code: code,
      customerName: customerName.isEmpty ? 'Unknown customer' : customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      createdAt: _toDateTime(rawCreatedAt),
      itemsCount: items.isNotEmpty
          ? items.length
          : _toInt(
              json['items_count'] ??
                  json['itemsCount'] ??
                  json['products_count'],
            ),
      paymentMethod: _readString(rawPayment, fallback: 'Unknown'),
      status: _readString(rawStatus, fallback: 'Pending'),
      total: _toDouble(rawTotal),
      address: _readNullableString(json['address'] ?? json['delivery_address']),
      latitude: _toNullableDouble(json['latitude'] ?? json['lat']),
      longitude: _toNullableDouble(json['longitude'] ?? json['lng']),
      items: items,
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  static String _readString(dynamic value, {String fallback = ''}) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  static String? _readNullableString(dynamic value) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? null : result;
  }
}

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.categoryName,
    required super.imageUrl,
    required super.price,
    required super.quantity,
    required super.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final rawProduct = json['product'];
    final product = rawProduct is Map<String, dynamic>
        ? rawProduct
        : <String, dynamic>{};

    final rawCategory = product['category'];
    final category = rawCategory is Map<String, dynamic>
        ? rawCategory
        : <String, dynamic>{};

    final price = _toDouble(json['price'] ?? product['price']);
    final quantity = _toInt(json['quantity']);

    return OrderItemModel(
      id: _toInt(json['id']),
      productId: _toInt(json['product_id'] ?? product['id']),
      productName: _readString(
        product['name'] ?? json['product_name'],
        fallback: 'Unknown product',
      ),
      categoryName: _readNullableString(
        category['name'] ?? product['category_name'],
      ),
      imageUrl: _readNullableString(
        product['image_url'] ?? product['image'] ?? json['image_url'],
      ),
      price: price,
      quantity: quantity,
      totalPrice: _toDouble(
        json['total_price'] ?? json['subtotal'] ?? (price * quantity),
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _readString(dynamic value, {String fallback = ''}) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  static String? _readNullableString(dynamic value) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? null : result;
  }
}
