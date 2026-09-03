import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/injection_container.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../domain/entities/product_entity.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import 'edit_product_page.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key, required this.product});

  final ProductEntity product;

  static const orange = Color(0xFFFF821D);
  static const dark = Color(0xFF20212B);
  static const grey = Color(0xFF92939D);
  static const background = Color(0xFFF7F8FA);
  static const green = Color(0xFF13A978);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductsCubit>(),
      child: _ProductDetailsView(product: product),
    );
  }
}

class _ProductDetailsView extends StatelessWidget {
  const _ProductDetailsView({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductDeleted) {
          Navigator.of(context).pop(true);
          return;
        }

        if (state is ProductDeleteFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFE84A4A),
              content: Text(state.message),
            ),
          );
        }
      },
      child: _ProductDetailsContent(product: product),
    );
  }
}

class _ProductDetailsContent extends StatelessWidget {
  const _ProductDetailsContent({required this.product});

  final ProductEntity product;

  Future<void> _openEditProductPage(BuildContext context) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditProductPage(product: product)),
    );

    if (!context.mounted || updated != true) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  void _showDeleteDialog(BuildContext pageContext) {
    final productsCubit = pageContext.read<ProductsCubit>();

    showDialog<void>(
      context: pageContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: productsCubit,
          child: BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) {
              final isDeleting = state is ProductDeleting;

              return PopScope(
                canPop: !isDeleting,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text(
                    'Delete Product?',
                    style: TextStyle(
                      color: ProductDetailsPage.dark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to delete "${product.name}"? '
                    'This action cannot be undone.',
                    style: const TextStyle(
                      color: ProductDetailsPage.grey,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                  actions: [
                    TextButton(
                      onPressed: isDeleting
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: ProductDetailsPage.grey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isDeleting
                          ? null
                          : () {
                              Navigator.of(dialogContext).pop();
                              productsCubit.deleteProduct(product.slug);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE84A4A),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFF2A6A6),
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final isDeleting = state is ProductDeleting;

        return Scaffold(
          backgroundColor: ProductDetailsPage.background,
          body: SafeArea(
            child: Column(
              children: [
                _Header(
                  onBack: isDeleting ? null : () => Navigator.of(context).pop(),
                  onEdit: isDeleting
                      ? null
                      : () => _openEditProductPage(context),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProductImage(imageUrl: product.imageUrl),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 17, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  color: ProductDetailsPage.dark,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.categoryName,
                                style: const TextStyle(
                                  color: ProductDetailsPage.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _StatsCard(product: product),
                              const SizedBox(height: 16),
                              _DescriptionCard(
                                description: product.description,
                              ),
                              const SizedBox(height: 16),
                              _DetailsCard(product: product),
                              const SizedBox(height: 20),
                              _EditButton(
                                onPressed: isDeleting
                                    ? null
                                    : () => _openEditProductPage(context),
                              ),
                              const SizedBox(height: 12),
                              _DeleteButton(
                                isDeleting: isDeleting,
                                onPressed: isDeleting
                                    ? null
                                    : () => _showDeleteDialog(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _DetailsBottomBar(
            selectedIndex: 1,
            onChanged: isDeleting
                ? (_) {}
                : (index) {
                    if (index == 0) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomePage()),
                        (route) => false,
                      );
                      return;
                    }

                    if (index == 1) {
                      Navigator.of(context).pop();
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This page will be available soon.'),
                      ),
                    );
                  },
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.onEdit});

  final VoidCallback? onBack;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ProductDetailsPage.dark,
              size: 20,
            ),
          ),
          const Expanded(
            child: Text(
              'Product Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ProductDetailsPage.dark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              color: ProductDetailsPage.dark,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: imageUrl.trim().isEmpty
          ? const ColoredBox(
              color: Color(0xFFEFEFEF),
              child: Center(
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: ProductDetailsPage.grey,
                  size: 55,
                ),
              ),
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return const ColoredBox(
                  color: Color(0xFFEFEFEF),
                  child: Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: ProductDetailsPage.grey,
                      size: 55,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              value: product.price.toStringAsFixed(0),
              label: 'Price',
              valueColor: ProductDetailsPage.orange,
            ),
          ),
          Container(width: 1, height: 48, color: const Color(0xFFE9EAF0)),
          Expanded(
            child: _StatItem(
              value: product.quantity.toString(),
              label: 'In Stock',
              valueColor: ProductDetailsPage.dark,
            ),
          ),
          Container(width: 1, height: 48, color: const Color(0xFFE9EAF0)),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _VisibilityBadge(visible: product.visible),
                  const SizedBox(height: 7),
                  const Text(
                    'Visibility',
                    style: TextStyle(
                      color: ProductDetailsPage.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: ProductDetailsPage.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisibilityBadge extends StatelessWidget {
  const _VisibilityBadge({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final color = visible ? ProductDetailsPage.green : const Color(0xFF9699A5);

    final background = visible
        ? const Color(0xFFEAFBF4)
        : const Color(0xFFF0F1F4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 6),
          const SizedBox(width: 5),
          Text(
            visible ? 'Visible' : 'Hidden',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String? description;

  @override
  Widget build(BuildContext context) {
    final text = description?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DESCRIPTION',
            style: TextStyle(
              color: ProductDetailsPage.grey,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            text == null || text.isEmpty ? 'No description added.' : text,
            style: const TextStyle(
              color: ProductDetailsPage.dark,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.product});

  final ProductEntity product;

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not available';
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

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DETAILS',
            style: TextStyle(
              color: ProductDetailsPage.grey,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(label: 'Category', value: product.categoryName),
          const SizedBox(height: 13),
          _DetailRow(label: 'Added', value: _formatDate(product.createdAt)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: ProductDetailsPage.grey, fontSize: 14),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ProductDetailsPage.dark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ProductDetailsPage.orange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFFFC18F),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Edit Product',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed, required this.isDeleting});

  final VoidCallback? onPressed;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: isDeleting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFE84A4A),
                ),
              )
            : const Icon(Icons.delete_outline_rounded, size: 19),
        label: Text(
          isDeleting ? 'Deleting...' : 'Delete Product',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE84A4A),
          disabledForegroundColor: const Color(0xFFE84A4A),
          side: const BorderSide(color: Color(0xFFFFC8C8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _DetailsBottomBar extends StatelessWidget {
  const _DetailsBottomBar({
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
                        ? ProductDetailsPage.orange
                        : const Color(0xFF9699A5),
                    size: 23,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$3,
                    style: TextStyle(
                      color: selected
                          ? ProductDetailsPage.orange
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
                      color: ProductDetailsPage.orange,
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
