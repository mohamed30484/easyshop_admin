class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.code,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.createdAt,
    required this.itemsCount,
    required this.paymentMethod,
    required this.status,
    required this.total,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.items,
  });

  final int id;
  final String code;

  final String customerName;
  final String? customerEmail;
  final String? customerPhone;

  final DateTime? createdAt;
  final int itemsCount;
  final String paymentMethod;
  final String status;
  final double total;

  final String? address;
  final double? latitude;
  final double? longitude;

  final List<OrderItemEntity> items;
}

class OrderItemEntity {
  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.categoryName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });

  final int id;
  final int productId;

  final String productName;
  final String? categoryName;
  final String? imageUrl;

  final double price;
  final int quantity;
  final double totalPrice;
}
