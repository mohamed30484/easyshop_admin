import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../domain/entities/order_entity.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key, required this.order});

  final OrderEntity order;

  static const Color _orange = Color(0xFFFF821D);
  static const Color _background = Color(0xFFF7F8FA);
  static const Color _textPrimary = Color(0xFF20212B);
  static const Color _textSecondary = Color(0xFF92939D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textPrimary,
            size: 20,
          ),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'CUSTOMER',
                child: _buildCustomerSection(),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'DELIVERY',
                child: _buildDeliverySection(context),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'ORDER ITEMS',
                child: _buildOrderItemsSection(),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'PAYMENT',
                child: _buildPaymentSection(),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'SUMMARY',
                child: _buildSummarySection(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _OrderDetailsBottomBar(
        onHomeTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        },
        onProductsTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ProductsPage()),
            (route) => false,
          );
        },
        onOrdersTap: () => Navigator.of(context).pop(),
        onProfileTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This page will be available soon.')),
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader() {
    final statusStyle = _statusStyle(order.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${order.code}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusStyle.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: statusStyle.color, size: 7),
                    const SizedBox(width: 6),
                    Text(
                      _capitalize(order.status),
                      style: TextStyle(
                        color: statusStyle.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: _textSecondary,
                size: 15,
              ),
              const SizedBox(width: 7),
              Text(
                _formatDateTime(order.createdAt),
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    final hasEmail =
        order.customerEmail != null && order.customerEmail!.trim().isNotEmpty;

    final hasPhone =
        order.customerPhone != null && order.customerPhone!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _orange,
              child: Text(
                _initials(order.customerName),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                order.customerName.isEmpty
                    ? 'Customer not available'
                    : order.customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (hasEmail) ...[
          const SizedBox(height: 16),
          _infoRow(
            icon: Icons.mail_outline_rounded,
            text: order.customerEmail!,
          ),
        ],
        if (hasPhone) ...[
          const SizedBox(height: 10),
          _infoRow(icon: Icons.phone_outlined, text: order.customerPhone!),
        ],
      ],
    );
  }

  Widget _buildDeliverySection(BuildContext context) {
    final hasAddress =
        order.address != null && order.address!.trim().isNotEmpty;
    final hasLocation = order.latitude != null && order.longitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasAddress)
          _infoRow(
            icon: Icons.location_on_outlined,
            text: order.address!,
            textColor: _textPrimary,
          )
        else
          const Text(
            'Delivery address is not available.',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (hasLocation) ...[
          const SizedBox(height: 14),
          InkWell(
            onTap: () => _openMap(context),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined, color: _orange, size: 17),
                  SizedBox(width: 7),
                  Text(
                    'View on Map',
                    style: TextStyle(
                      color: _orange,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderItemsSection() {
    if (order.items.isEmpty) {
      return Text(
        '${order.itemsCount} ${order.itemsCount == 1 ? 'item' : 'items'} in this order',
        style: const TextStyle(
          color: _textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.items.length,
      separatorBuilder: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Divider(height: 1, color: Color(0xFFF0F0F2)),
      ),
      itemBuilder: (_, index) => _buildOrderItem(order.items[index]),
    );
  }

  Widget _buildOrderItem(OrderItemEntity item) {
    final hasImage = item.imageUrl != null && item.imageUrl!.trim().isNotEmpty;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 58,
            height: 58,
            color: const Color(0xFFF0F0F2),
            child: hasImage
                ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.inventory_2_outlined,
                      color: _textSecondary,
                      size: 28,
                    ),
                  )
                : const Icon(
                    Icons.inventory_2_outlined,
                    color: _textSecondary,
                    size: 28,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (item.categoryName != null &&
                  item.categoryName!.trim().isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  item.categoryName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 3),
              Text(
                '${_formatNumber(item.price)} × ${item.quantity}',
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _formatNumber(item.totalPrice),
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Row(
      children: [
        Icon(
          _paymentIcon(order.paymentMethod),
          color: _textSecondary,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          _paymentLabel(order.paymentMethod),
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Items (${order.itemsCount})',
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              _formatPrice(order.total),
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Divider(height: 1, color: Color(0xFFF0F0F2)),
        ),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Total',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              _formatPrice(order.total),
              style: const TextStyle(
                color: _orange,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String text,
    Color textColor = _textSecondary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _textSecondary, size: 17),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openMap(BuildContext context) async {
    final latitude = order.latitude;
    final longitude = order.longitude;

    if (latitude == null || longitude == null) {
      return;
    }

    try {
      final mapUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );

      final opened = await launchUrl(
        mapUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the map.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open the map. Restart the app and try again.',
            ),
          ),
        );
      }
    }
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Date not available';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${months[dateTime.month - 1]} ${dateTime.day}, '
        '${dateTime.year} at $hour:$minute $period';
  }

  String _formatPrice(double value) {
    return '${_formatNumber(value)} EGP';
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  String _paymentLabel(String value) {
    final method = value.trim().toLowerCase();

    if (method == 'cash') {
      return 'Cash';
    }

    if (method == 'card') {
      return 'Card';
    }

    if (method == 'wallet') {
      return 'Wallet';
    }

    return _capitalize(value);
  }

  IconData _paymentIcon(String value) {
    final method = value.trim().toLowerCase();

    if (method.contains('card')) {
      return Icons.credit_card_outlined;
    }

    if (method.contains('cash')) {
      return Icons.payments_outlined;
    }

    return Icons.account_balance_wallet_outlined;
  }

  String _capitalize(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return 'Unknown';
    }

    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }

  String _initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      return 'CU';
    }

    if (words.length == 1) {
      final word = words.first;
      return word.substring(0, word.length > 2 ? 2 : word.length).toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  _OrderStatusStyle _statusStyle(String status) {
    final value = status.trim().toLowerCase();

    if (value.contains('complete') || value.contains('deliver')) {
      return const _OrderStatusStyle(
        color: Color(0xFF13A978),
        backgroundColor: Color(0xFFEAFBF4),
      );
    }

    if (value.contains('cancel') || value.contains('reject')) {
      return const _OrderStatusStyle(
        color: Color(0xFFE84B4B),
        backgroundColor: Color(0xFFFFEEEE),
      );
    }

    if (value.contains('process') || value.contains('ship')) {
      return const _OrderStatusStyle(
        color: Color(0xFF4776E6),
        backgroundColor: Color(0xFFEEF3FF),
      );
    }

    return const _OrderStatusStyle(
      color: Color(0xFFE89B17),
      backgroundColor: Color(0xFFFFF8E8),
    );
  }
}

class _OrderStatusStyle {
  const _OrderStatusStyle({required this.color, required this.backgroundColor});

  final Color color;
  final Color backgroundColor;
}

class _OrderDetailsBottomBar extends StatelessWidget {
  const _OrderDetailsBottomBar({
    required this.onHomeTap,
    required this.onProductsTap,
    required this.onOrdersTap,
    required this.onProfileTap,
  });

  final VoidCallback onHomeTap;
  final VoidCallback onProductsTap;
  final VoidCallback onOrdersTap;
  final VoidCallback onProfileTap;

  static const Color _orange = Color(0xFFFF821D);
  static const Color _inactive = Color(0xFF9699A5);

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'Products'),
      (Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Orders'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];

    final onTapCallbacks = [
      onHomeTap,
      onProductsTap,
      onOrdersTap,
      onProfileTap,
    ];

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final selected = index == 2;

          return Expanded(
            child: InkWell(
              onTap: onTapCallbacks[index],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? item.$2 : item.$1,
                    color: selected ? _orange : _inactive,
                    size: 23,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$3,
                    style: TextStyle(
                      color: selected ? _orange : _inactive,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: selected ? 28 : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      color: _orange,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
