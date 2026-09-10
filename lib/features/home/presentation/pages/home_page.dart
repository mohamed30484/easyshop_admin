import 'package:easyshop_admin/features/categories/presentation/pages/manage_categories_page.dart';
import 'package:easyshop_admin/features/products/presentation/pages/add_product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/injection_container.dart';
import '../../../../core/services/admin_profile_storage.dart';
import '../../../auth/data/models/admin_model.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..loadDashboard(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _selectedIndex = 0;
  AdminModel? _admin;
  bool _isLoadingProfile = true;

  static const orange = Color(0xFFFF821D);
  static const dark = Color(0xFF20212B);
  static const grey = Color(0xFF92939D);
  static const pageBackground = Color(0xFFF7F8FA);

  final AdminProfileStorage _profileStorage = AdminProfileStorage();

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
  }

  Future<void> _loadAdminProfile() async {
    final admin = await _profileStorage.get();

    if (!mounted) {
      return;
    }

    setState(() {
      _admin = admin;
      _isLoadingProfile = false;
    });
  }

  void _onBottomNavigationChanged(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProductsPage()),
      );
      return;
    }

    if (index == 2) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const OrdersPage()));
      return;
    }

    if (index == 3) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _Header(admin: _admin, isLoading: _isLoadingProfile),
                Expanded(
                  child: RefreshIndicator(
                    color: orange,
                    onRefresh: () => context.read<HomeCubit>().loadDashboard(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 92),
                      child: Column(
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -1),
                            child: BlocBuilder<HomeCubit, HomeState>(
                              builder: (context, state) {
                                return _StatsCard(state: state);
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          const _SectionTitle(title: 'Quick Actions'),
                          const SizedBox(height: 12),
                          const _QuickActions(),
                          const SizedBox(height: 22),
                          BlocBuilder<HomeCubit, HomeState>(
                            builder: (context, state) {
                              return _RecentOrdersSection(
                                state: state,
                                onSeeAll: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const OrdersPage(),
                                    ),
                                  );
                                },
                                onRetry: () =>
                                    context.read<HomeCubit>().loadDashboard(),
                              );
                            },
                          ),
                          const SizedBox(height: 22),
                          BlocBuilder<HomeCubit, HomeState>(
                            builder: (context, state) {
                              return _ProductsOverviewSection(
                                state: state,
                                onSeeAll: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const ProductsPage(),
                                    ),
                                  );
                                },
                                onRetry: () =>
                                    context.read<HomeCubit>().loadDashboard(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomBar(
                selectedIndex: _selectedIndex,
                onChanged: _onBottomNavigationChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.admin, required this.isLoading});

  final AdminModel? admin;
  final bool isLoading;

  String get _adminName {
    final name = admin?.name.trim() ?? '';

    if (name.isEmpty) {
      return 'Admin';
    }

    return name;
  }

  String get _businessName {
    final businessName = admin?.businessName.trim() ?? '';

    if (businessName.isEmpty) {
      return 'My Store';
    }

    return businessName;
  }

  String get _initials {
    final nameParts = _adminName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (nameParts.isEmpty) {
      return 'A';
    }

    if (nameParts.length == 1) {
      return nameParts.first.substring(0, 1).toUpperCase();
    }

    return '${nameParts.first.substring(0, 1)}'
            '${nameParts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 148,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: const BoxDecoration(
        color: _HomeViewState.orange,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ProfileAvatar(
            imageUrl: admin?.picture,
            initials: _initials,
            isLoading: isLoading,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isLoading
                ? const _HeaderLoadingText()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Good morning,',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _adminName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderLoadingText extends StatelessWidget {
  const _HeaderLoadingText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning,',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5),
        _HeaderSkeleton(width: 120),
        SizedBox(height: 6),
        _HeaderSkeleton(width: 155),
      ],
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 11,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageUrl,
    required this.initials,
    required this.isLoading,
  });

  final String? imageUrl;
  final String initials;
  final bool isLoading;

  bool get _hasValidImage {
    return imageUrl != null &&
        imageUrl!.trim().isNotEmpty &&
        Uri.tryParse(imageUrl!)?.hasAbsolutePath == true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: isLoading
          ? const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _HomeViewState.orange,
                ),
              ),
            )
          : _hasValidImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _InitialsAvatar(initials: initials);
              },
            )
          : _InitialsAvatar(initials: initials),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFE0C9),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: _HomeViewState.orange,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final loaded = state is HomeLoaded ? state as HomeLoaded : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Stat(
                  value: _statValue(loaded?.totalProducts),
                  label: 'Total Products',
                  icon: Icons.inventory_2_outlined,
                  iconColor: const Color(0xFFFF7620),
                  background: const Color(0xFFFFF5ED),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Stat(
                  value: _statValue(loaded?.totalOrders),
                  label: 'Total Orders',
                  icon: Icons.shopping_bag_outlined,
                  iconColor: const Color(0xFF3779E8),
                  background: const Color(0xFFF0F5FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  value: _statValue(loaded?.pendingOrders),
                  label: 'Pending Orders',
                  icon: Icons.access_time_rounded,
                  iconColor: const Color(0xFFEBA500),
                  background: const Color(0xFFFFFBEA),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Stat(
                  value: _statValue(loaded?.totalCategories),
                  label: 'Categories',
                  icon: Icons.sell_outlined,
                  iconColor: const Color(0xFF13A978),
                  background: const Color(0xFFEAFBF4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statValue(int? value) {
    if (state is HomeFailure) {
      return '!';
    }

    if (value == null) {
      return '--';
    }

    return value.toString();
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.background,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 9),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: _HomeViewState.dark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: _HomeViewState.grey,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _HomeViewState.dark,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                color: _HomeViewState.orange,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddProductPage()),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 21),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _HomeViewState.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ManageCategoriesPage(),
                  ),
                );
              },
              icon: const Icon(Icons.sell_outlined, size: 20),
              label: const Text('Categories'),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF7F1),
                foregroundColor: _HomeViewState.orange,
                side: const BorderSide(color: Color(0xFFFFDDC5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentOrdersSection extends StatelessWidget {
  const _RecentOrdersSection({
    required this.state,
    required this.onSeeAll,
    required this.onRetry,
  });

  final HomeState state;
  final VoidCallback onSeeAll;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Recent Orders',
          action: 'See all',
          onAction: onSeeAll,
        ),
        const SizedBox(height: 11),
        _buildBody(),
      ],
    );
  }

  Widget _buildBody() {
    if (state is HomeInitial || state is HomeLoading) {
      return const _DashboardSectionLoading();
    }

    if (state is HomeFailure) {
      return _DashboardSectionError(
        message: (state as HomeFailure).message,
        onRetry: onRetry,
      );
    }

    final orders = (state as HomeLoaded).recentOrders;

    if (orders.isEmpty) {
      return const _DashboardSectionEmpty(message: 'No orders yet.');
    }

    return Column(
      children: [
        for (var i = 0; i < orders.length; i++) ...[
          if (i > 0) const SizedBox(height: 11),
          _OrderCard(order: orders[i]),
        ],
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderEntity order;

  String _formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
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

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(order.status);

    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: _HomeViewState.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _HomeViewState.dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  order.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _HomeViewState.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusStyle.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: statusStyle.color, size: 6),
                    const SizedBox(width: 4),
                    Text(
                      _capitalize(order.status),
                      style: TextStyle(
                        color: statusStyle.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatPrice(order.total),
                style: const TextStyle(
                  color: _HomeViewState.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderStatusStyle {
  const _OrderStatusStyle({required this.color, required this.backgroundColor});

  final Color color;
  final Color backgroundColor;
}

class _ProductsOverviewSection extends StatelessWidget {
  const _ProductsOverviewSection({
    required this.state,
    required this.onSeeAll,
    required this.onRetry,
  });

  final HomeState state;
  final VoidCallback onSeeAll;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Products Overview',
          action: 'See all',
          onAction: onSeeAll,
        ),
        const SizedBox(height: 11),
        _buildBody(),
      ],
    );
  }

  Widget _buildBody() {
    if (state is HomeInitial || state is HomeLoading) {
      return const _DashboardSectionLoading();
    }

    if (state is HomeFailure) {
      return _DashboardSectionError(
        message: (state as HomeFailure).message,
        onRetry: onRetry,
      );
    }

    final products = (state as HomeLoaded).productsOverview;

    if (products.isEmpty) {
      return const _DashboardSectionEmpty(message: 'No products yet.');
    }

    return Column(
      children: [
        for (var i = 0; i < products.length; i++) ...[
          if (i > 0) const SizedBox(height: 11),
          _ProductCard(product: products[i], index: i),
        ],
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.index});

  final ProductEntity product;
  final int index;

  static const List<Color> _iconBackgrounds = [
    Color(0xFFFFD94A),
    Color(0xFFEFEFEF),
    Color(0xFFCFE8FF),
  ];

  String _formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final iconBackground = _iconBackgrounds[index % _iconBackgrounds.length];

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF29240B),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _HomeViewState.dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatPrice(product.price)} · Qty ${product.quantity}',
                  style: const TextStyle(
                    color: _HomeViewState.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: product.visible
                  ? const Color(0xFFEAFBF4)
                  : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  color: product.visible
                      ? const Color(0xFF13B982)
                      : _HomeViewState.grey,
                  size: 6,
                ),
                const SizedBox(width: 4),
                Text(
                  product.visible ? 'Visible' : 'Hidden',
                  style: TextStyle(
                    color: product.visible
                        ? const Color(0xFF13A978)
                        : _HomeViewState.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSectionLoading extends StatelessWidget {
  const _DashboardSectionLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: _HomeViewState.orange,
          ),
        ),
      ),
    );
  }
}

class _DashboardSectionEmpty extends StatelessWidget {
  const _DashboardSectionEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(color: _HomeViewState.grey, fontSize: 13),
      ),
    );
  }
}

class _DashboardSectionError extends StatelessWidget {
  const _DashboardSectionError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _HomeViewState.dark, fontSize: 13),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: _HomeViewState.orange),
            child: const Text(
              'Try again',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.selectedIndex, required this.onChanged});

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
                        ? _HomeViewState.orange
                        : const Color(0xFF9699A5),
                    size: 23,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$3,
                    style: TextStyle(
                      color: selected
                          ? _HomeViewState.orange
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
                      color: _HomeViewState.orange,
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
