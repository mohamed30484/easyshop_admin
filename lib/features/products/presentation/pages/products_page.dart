import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/injection_container.dart';
import '../../../categories/presentation/pages/manage_categories_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../domain/entities/product_entity.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import 'add_product_page.dart';
import 'product_details_page.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductsCubit>()..getProducts(),
      child: const _ProductsView(),
    );
  }
}

class _ProductsView extends StatefulWidget {
  const _ProductsView();

  @override
  State<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<_ProductsView> {
  final _searchController = TextEditingController();

  String _query = '';
  int _selectedIndex = 1;

  static const orange = Color(0xFFFF821D);
  static const dark = Color(0xFF20212B);
  static const grey = Color(0xFF92939D);
  static const background = Color(0xFFF7F8FA);

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openManageCategoriesPage() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ManageCategoriesPage()));

    if (!mounted) {
      return;
    }

    await context.read<ProductsCubit>().getProducts();
  }

  Future<void> _openAddProductPage() async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddProductPage()));

    if (!mounted || created != true) {
      return;
    }

    await context.read<ProductsCubit>().getProducts();
  }

  Future<void> _openProductDetails(ProductEntity product) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProductDetailsPage(product: product)),
    );

    if (!mounted || changed != true) {
      return;
    }

    await context.read<ProductsCubit>().getProducts();
  }

  void _onBottomNavigationChanged(int index) {
    if (index == 0) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      return;
    }

    if (index == 1) {
      setState(() {
        _selectedIndex = 1;
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This page will be available soon.')),
    );
  }

  List<ProductEntity> _filterProducts(List<ProductEntity> products) {
    if (_query.isEmpty) {
      return products;
    }

    return products.where((product) {
      return product.name.toLowerCase().contains(_query) ||
          product.categoryName.toLowerCase().contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _ProductsHeader(onAdd: _openAddProductPage),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(color: grey, fontSize: 14),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: grey,
                    size: 21,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF0EFF5),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _openManageCategoriesPage,
              icon: const Icon(Icons.sell_outlined, size: 16),
              label: const Text('Manage Categories'),
              style: OutlinedButton.styleFrom(
                foregroundColor: orange,
                backgroundColor: const Color(0xFFFFF7F1),
                side: const BorderSide(color: Color(0xFFFFDDC5)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: orange),
                    );
                  }

                  if (state is ProductsFailure) {
                    return _ErrorView(
                      message: state.message,
                      onRetry: () {
                        context.read<ProductsCubit>().getProducts();
                      },
                    );
                  }

                  if (state is ProductsLoaded) {
                    final products = _filterProducts(state.products);

                    if (products.isEmpty) {
                      return _EmptyView(
                        hasSearch: _query.isNotEmpty,
                        onRefresh: () {
                          _searchController.clear();
                          context.read<ProductsCubit>().getProducts();
                        },
                      );
                    }

                    return RefreshIndicator(
                      color: orange,
                      onRefresh: () async {
                        await context.read<ProductsCubit>().getProducts();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                        itemCount: products.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 11),
                        itemBuilder: (_, index) {
                          final product = products[index];

                          return _ProductListCard(
                            product: product,
                            onTap: () => _openProductDetails(product),
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
      bottomNavigationBar: _BottomBar(
        selectedIndex: _selectedIndex,
        onChanged: _onBottomNavigationChanged,
      ),
    );
  }
}

class _ProductsHeader extends StatelessWidget {
  const _ProductsHeader({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Products',
              style: TextStyle(
                color: _ProductsViewState.dark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: _ProductsViewState.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductListCard extends StatelessWidget {
  const _ProductListCard({required this.product, required this.onTap});

  final ProductEntity product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          height: 89,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(17)),
          child: Row(
            children: [
              _ProductImage(imageUrl: product.imageUrl),
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
                        color: _ProductsViewState.dark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ProductsViewState.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          product.price.toStringAsFixed(0),
                          style: const TextStyle(
                            color: _ProductsViewState.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          'Qty ${product.quantity}',
                          style: const TextStyle(
                            color: _ProductsViewState.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _VisibilityBadge(visible: product.visible),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _ProductsViewState.grey,
                    size: 21,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.trim().isEmpty
          ? const Icon(
              Icons.inventory_2_outlined,
              color: _ProductsViewState.grey,
              size: 28,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return const Icon(
                  Icons.inventory_2_outlined,
                  color: _ProductsViewState.grey,
                  size: 28,
                );
              },
            ),
    );
  }
}

class _VisibilityBadge extends StatelessWidget {
  const _VisibilityBadge({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final color = visible ? const Color(0xFF13A978) : const Color(0xFF9699A5);

    final background = visible
        ? const Color(0xFFEAFBF4)
        : const Color(0xFFF0F1F4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 6),
          const SizedBox(width: 4),
          Text(
            visible ? 'Visible' : 'Hidden',
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

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.hasSearch, required this.onRefresh});

  final bool hasSearch;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: _ProductsViewState.orange,
              size: 52,
            ),
            const SizedBox(height: 14),
            Text(
              hasSearch ? 'No matching products' : 'No products yet',
              style: const TextStyle(
                color: _ProductsViewState.dark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try another search term.'
                  : 'Add your first product to get started.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ProductsViewState.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            TextButton(onPressed: onRefresh, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

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
                color: _ProductsViewState.dark,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _ProductsViewState.orange,
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
                        ? _ProductsViewState.orange
                        : const Color(0xFF9699A5),
                    size: 23,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$3,
                    style: TextStyle(
                      color: selected
                          ? _ProductsViewState.orange
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
                      color: _ProductsViewState.orange,
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
