import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/injection_container.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/entities/order_entity.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import 'order_details_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrdersCubit>()..getOrders(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView();

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  static const orange = Color(0xFFFF821D);
  static const dark = Color(0xFF20212B);
  static const grey = Color(0xFF92939D);
  static const background = Color(0xFFF7F8FA);

  int _selectedIndex = 2;

  void _onBottomNavigationChanged(int index) {
    if (index == 0) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProductsPage()),
      );
      return;
    }

    if (index == 2) {
      setState(() {
        _selectedIndex = 2;
      });
      return;
    }

    if (index == 3) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  void _openOrderDetails(OrderEntity order) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => OrderDetailsPage(order: order)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            const _OrdersHeader(),
            const SizedBox(height: 22),
            Expanded(
              child: BlocBuilder<OrdersCubit, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: orange),
                    );
                  }

                  if (state is OrdersFailure) {
                    return _OrdersErrorView(
                      message: state.message,
                      onRetry: () {
                        context.read<OrdersCubit>().getOrders();
                      },
                    );
                  }

                  if (state is OrdersLoaded) {
                    if (state.orders.isEmpty) {
                      return const _OrdersEmptyView();
                    }

                    return RefreshIndicator(
                      color: orange,
                      onRefresh: () async {
                        await context.read<OrdersCubit>().getOrders();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                        itemCount: state.orders.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          final order = state.orders[index];

                          return _OrderCard(
                            order: order,
                            onTap: () => _openOrderDetails(order),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _OrdersBottomBar(
        selectedIndex: _selectedIndex,
        onChanged: _onBottomNavigationChanged,
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Orders',
          style: TextStyle(
            color: _OrdersViewState.dark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final OrderEntity order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDate(order.createdAt);
    final timeText = _formatTime(order.createdAt);
    final statusStyle = _statusStyle(order.status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 12, 15),
          constraints: const BoxConstraints(minHeight: 124),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(17)),
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
                        color: _OrdersViewState.dark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _OrderStatusBadge(
                    label: _capitalize(order.status),
                    color: statusStyle.color,
                    backgroundColor: statusStyle.backgroundColor,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                order.customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _OrdersViewState.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _OrderMetaItem(
                    icon: Icons.calendar_today_outlined,
                    text: timeText.isEmpty ? dateText : '$dateText · $timeText',
                  ),
                  _OrderMetaItem(
                    icon: Icons.inventory_2_outlined,
                    text:
                        '${order.itemsCount} ${order.itemsCount == 1 ? 'item' : 'items'}',
                  ),
                  _OrderMetaItem(
                    icon: _paymentIcon(order.paymentMethod),
                    text: _capitalize(order.paymentMethod),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Text(
                    _formatPrice(order.total),
                    style: const TextStyle(
                      color: _OrdersViewState.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _OrdersViewState.grey,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Unknown date';
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

    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  IconData _paymentIcon(String method) {
    final value = method.trim().toLowerCase();

    if (value.contains('card')) {
      return Icons.credit_card_outlined;
    }

    if (value.contains('cash')) {
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

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 6),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderMetaItem extends StatelessWidget {
  const _OrderMetaItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _OrdersViewState.grey, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: _OrdersViewState.grey, fontSize: 12),
        ),
      ],
    );
  }
}

class _OrdersEmptyView extends StatelessWidget {
  const _OrdersEmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              color: _OrdersViewState.orange,
              size: 52,
            ),
            SizedBox(height: 14),
            Text(
              'No orders yet',
              style: TextStyle(
                color: _OrdersViewState.dark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'New customer orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _OrdersViewState.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersErrorView extends StatelessWidget {
  const _OrdersErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _OrdersViewState.dark,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _OrdersViewState.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersBottomBar extends StatelessWidget {
  const _OrdersBottomBar({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'Products'),
      (Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Orders'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
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
          final selected = selectedIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? item.$2 : item.$1,
                    color: selected
                        ? _OrdersViewState.orange
                        : const Color(0xFF9699A5),
                    size: 23,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$3,
                    style: TextStyle(
                      color: selected
                          ? _OrdersViewState.orange
                          : const Color(0xFF9699A5),
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: selected ? 28 : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      color: _OrdersViewState.orange,
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
